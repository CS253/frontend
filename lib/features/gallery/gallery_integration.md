# Gallery Backend Integration Guide

This guide outlines the steps required to connect the Gallery feature to a real backend API, following the new layered architecture.

## 1. Project Structure

The gallery feature is structured cleanly under `lib/features/gallery/`:

*   **Models:** `lib/features/gallery/data/models/photo_model.dart`
*   **Services:** `lib/features/gallery/data/services/photo_service.dart`
*   **Repositories:** `lib/features/gallery/data/repositories/photo_repository.dart`
*   **Providers:** `lib/features/gallery/presentation/providers/gallery_provider.dart`
*   **UI (Screens & Widgets):** `lib/features/gallery/presentation/screens/gallery_screen.dart`, `lib/features/gallery/presentation/widgets/photo_card.dart`
*   **Core Endpoints:** `lib/core/api/api_endpoints.dart`
- `lib/services/api_service.dart`

## 2. Replacing Mock Data with Real API Calls

In `lib/core/api/api_client.dart` or `lib/features/gallery/data/services/photo_service.dart`:
- Currently, the requests use `Future.delayed` and return hardcoded maps.
- You must connect real network calls with the `http` package, `dio`, or whichever client is preferred.
- Example replacement for `PhotoService`:
  ```dart
  Future<Map<String, dynamic>> fetchPhotos() async {
    final response = await apiClient.get(ApiEndpoints.photosEndpoint);
    return response; 
  }
  ```

## 3. API Endpoints Insertion

Modify `lib/core/api/api_endpoints.dart` to define the base URL and endpoints:
```dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.yourbackend.com/v1'; // Set your real API base URL
  static const String photosEndpoint = '/photos'; // Endpoint for GET /photos
  static const String uploadEndpoint = '/photos/upload'; // Endpoint for POST /photos/upload
  static const String deletePhotosEndpoint = '/photos/delete'; // Endpoint for POST /photos/delete
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

## 5. How PhotoModels Connect

In `lib/features/gallery/data/models/photo_model.dart`:
- `PhotoModel.fromJson(Map<String, dynamic> json)` reads keys exactly as returned by the backend.
- If your backend JSON keys differ, alter the key string identifiers inside `PhotoModel.fromJson` to match. 

## 6. Integrating Deletion Logic (Single & Bulk)

To make both the multi-selection grid deletion and the fullscreen single deletion functional:
1. In `GalleryProvider`, update `deleteSelected()` and `deletePhoto(String id)` to await the repository:
   ```dart
   // For Bulk (List of IDs)
   await _photoRepository.deletePhotos(_selectedPhotoIds.toList());
   
   // For Single (One ID)
   await _photoRepository.deletePhoto(id); 
   ```
2. In `PhotoRepository`, map these to the specific service endpoints.
3. In `PhotoService`, execute a request to the backend:
   ```dart
   Future<void> deletePhotos(List<String> ids) async {
     await apiClient.post(ApiEndpoints.deletePhotosEndpoint, body: {'ids': ids});
   }
   
   Future<void> deletePhoto(String id) async {
     await apiClient.delete('\${ApiEndpoints.photosEndpoint}/\$id');
   }
   ```

## 7. How Image Upload Works

- The UI trigger lives in the `FloatingActionButton` of `GalleryScreen`.
- Upon image selection, call `context.read<GalleryProvider>().uploadPhoto(imageFile)`.
- The provider calls `PhotoRepository.uploadPhoto(File image)`.
- Integrate `MultipartRequest` logic inside `lib/core/api/api_client.dart`:
  ```dart
  Future<Map<String, dynamic>> uploadPhoto(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.uploadEndpoint}'));
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));
    // Add auth headers if needed
    var response = await request.send();
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
- Retrieve them in `ApiEndpoints` based on debug/release modes.

## 11. Testing the Integration

- Temporarily log incoming HTTP JSON responses prior to `Photo.fromJson` decoding.
- Verify that UI `CachedNetworkImage` components download images successfully (validate CORS if testing from web).
- Test failing API routes to verify `GalleryProvider` logs `error` and renders the error component correctly.

## 12. Scalability Suggestions

For scalable media storage, you should avoid storing Blobs directly in your database.
- Utilize services like **AWS S3**, **Google Cloud Storage**, or **Cloudinary**.
- Either have the device upload directly via Presigned URLs provided by your backend and send only the resultant URL to your DB, or pipe the upload POST through your backend to abstract the cloud storage mechanism.
