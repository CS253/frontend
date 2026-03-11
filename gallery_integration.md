# Backend Integration Guide for Photo Gallery

This document outlines the step-by-step process for integrating the actual backend APIs into the Gallery screen application.

## 1. Files Requiring Modification

Only the following files in the project need to be modified when wiring up the real backend. You do **NOT** need to touch `lib/screens/gallery_screen.dart` or `lib/widgets/photo_card.dart`.

The files to modify:
- `lib/config/api_config.dart`
- `lib/services/api_service.dart`

## 2. Replacing Mock Data with Real API Calls

In `lib/services/api_service.dart`:
- Currently, the `getPhotos` and `uploadPhoto` functions use `Future.delayed` and return hardcoded maps.
- You must replace these simulated network calls with the `http` package, `dio`, or whichever client is preferred.
- Example replacement:
  ```dart
  Future<Map<String, dynamic>> getPhotos({int page = 1, int limit = 20}) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.photosEndpoint}?page=\$page&limit=\$limit'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load photos');
    }
  }
  ```

## 3. API Endpoints Insertion

Modify `lib/config/api_config.dart` to define the base URL and endpoints:
```dart
class ApiConfig {
  static const String baseUrl = 'https://api.yourbackend.com/v1'; // Set your real API base URL
  static const String photosEndpoint = '/photos'; // Endpoint for GET /photos
  static const String uploadEndpoint = '/photos/upload'; // Endpoint for POST /photos/upload
}
```

## 4. Expected Backend JSON Response Format

The `getPhotos` API should preferably return JSON matching the structure that `Photo.fromJson` is listening for (or a structured wrapper):

```json
{
  "data": [
    {
      "id": "item123",
      "imageUrl": "https://cdn.example.com/item123.jpg",
      "title": "Optional Title",
      "createdAt": "2026-03-11T12:00:00Z",
      "authorName": "Rahul"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 50
  }
}
```

## 5. How Photo.fromJson Connects

In `lib/models/photo.dart`:
- `Photo.fromJson(Map<String, dynamic> json)` reads keys exactly as returned by the backend.
- If your backend JSON keys differ (e.g. `image_url` instead of `imageUrl`), you must alter the key string identifiers inside `Photo.fromJson` to match. 

## 6. Integrating Pagination

The API Service function `getPhotos({int page = 1, int limit = 20})` and `PhotoRepository.fetchPhotos` already accept pagination arguments.
- In `lib/providers/gallery_provider.dart`, you can introduce list appending logic:
  ```dart
  // Inside fetchPhotos()
  final fetchedPhotos = await _photoRepository.fetchPhotos(page: _currentPage, limit: 20);
  _photos.addAll(fetchedPhotos);
  _currentPage++;
  ```
- Trigger this update using a ScrollController inside `lib/screens/gallery_screen.dart` (which requires minimal UI logic adjustments, simply triggering `provider.fetchPhotos()`).

## 7. How Image Upload Works

- The UI trigger lives in the `FloatingActionButton` of `GalleryScreen`.
- Upon image selection, call `context.read<GalleryProvider>().uploadPhoto(imageFile)`.
- The provider calls `PhotoRepository.uploadPhoto(File image)`.
- Integrate `MultipartRequest` logic inside `lib/services/api_service.dart`:
  ```dart
  Future<Map<String, dynamic>> uploadPhoto(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadEndpoint}'));
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));
    // Add auth headers if needed
    var response = await request.send();
    // Parse response...
  }
  ```

## 8. Authentication Tokens

If APIs require Bearer tokens:
- Add a shared or secure token retrieval method.
- Inject headers in `ApiService` calls:
  ```dart
  headers: {
    'Authorization': 'Bearer \$YOUR_TOKEN',
    'Content-Type': 'application/json'
  }
  ```

## 9. Provider Auto-Updating UI

The frontend currently uses `provider` state management. Once you yield an API result in `ApiService`, the `GalleryProvider` sets `_photos = newPhotos` and calls `notifyListeners()`. The UI automatically rebuilds and renders the new images dynamically.

## 10. Environment Configuration

- Keep different environment URLs inside `.env` utilizing packages like `flutter_dotenv`.
- Retrieve them in `ApiConfig` based on debug/release modes.

## 11. Testing the Integration

- Temporarily log incoming HTTP JSON responses prior to `Photo.fromJson` decoding.
- Verify that UI `CachedNetworkImage` components download images successfully (validate CORS if testing from web).
- Test failing API routes to verify `GalleryProvider` logs `error` and renders the error component correctly.

## 12. Scalability Suggestions

For scalable media storage, you should avoid storing Blobs directly in your database.
- Utilize services like **AWS S3**, **Google Cloud Storage**, or **Cloudinary**.
- Either have the device upload directly via Presigned URLs provided by your backend and send only the resultant URL to your DB, or pipe the upload POST through your backend to abstract the cloud storage mechanism.
