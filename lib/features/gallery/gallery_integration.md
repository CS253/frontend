# Gallery Backend Integration Guide

This guide outlines the steps required to connect the Gallery feature to a real backend API, following the layered architecture.

## 1. Project Structure

The gallery feature is structured cleanly under `lib/features/gallery/`:

*   **Models:** `lib/features/gallery/data/models/photo_model.dart`
*   **Services:** `lib/features/gallery/data/services/photo_service.dart`
*   **Repositories:** `lib/features/gallery/data/repositories/photo_repository.dart`
*   **Providers:** `lib/features/gallery/presentation/providers/gallery_provider.dart`
*   **UI (Screens & Widgets):** `lib/features/gallery/presentation/screens/gallery_screen.dart`, `lib/features/gallery/presentation/widgets/photo_card.dart`
*   **Core API Client:** `lib/core/api/api_client.dart`
*   **Core Endpoints:** `lib/core/api/api_endpoints.dart`

## 2. How Data Flows (Fetch → Delete → Upload)

All network operations follow the same chain:

```
UI (GalleryScreen) → GalleryProvider → PhotoRepository → PhotoService → ApiClient
```

| Operation | Provider method | Repository method | Service method | ApiClient method |
|-----------|----------------|-------------------|----------------|------------------|
| **Fetch** | `fetchPhotos()` | `fetchPhotos()` | `fetchPhotos()` | `get()` |
| **Upload** | `pickAndUploadMedia()` / `uploadPhoto()` | `uploadPhoto()` | `uploadPhoto()` | `postMultipart()` |
| **Delete single** | `deletePhoto(id)` | `deletePhoto(id)` | `deletePhoto(id)` | `delete()` |
| **Delete bulk** | `deleteSelected()` | `deletePhotos(ids)` | `deletePhotos(ids)` | `post()` |

## 3. Replacing Mock Data with Real API Calls

In `lib/core/api/api_client.dart`:
- Currently, all methods use `Future.delayed` and return hardcoded/mock data.
- Replace the mock implementations with real HTTP calls using the `http` package or `dio`.
- Example replacement for `get()`:
  ```dart
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _authHeaders());
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('GET $endpoint failed: ${response.statusCode}');
  }
  ```

## 4. API Endpoints

Defined in `lib/core/api/api_endpoints.dart`:
```dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.yourbackend.com/v1'; // Set your real API base URL
  static const String photos = '/photos';              // GET  → fetch photos
  static const String uploadPhoto = '/photos/upload';  // POST (multipart) → upload photo
  static const String deletePhotos = '/photos/delete'; // POST → bulk delete (body: {ids: [...]})
  // Single delete uses: DELETE /photos/{id}
}
```

## 5. Expected Backend JSON Response Format

The `fetchPhotos` API should return JSON matching the `Photo.fromJson` structure:

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

## 6. How PhotoModels Connect

In `lib/features/gallery/data/models/photo_model.dart`:
- `Photo.fromJson(Map<String, dynamic> json)` reads keys exactly as returned by the backend.
- If your backend JSON keys differ, alter the key string identifiers inside `Photo.fromJson` to match.

## 7. How Deletion Works (Single & Bulk)

Both paths are fully wired through all layers:

**Single deletion** (from full-photo screen):
- `GalleryProvider.deletePhoto(id)` → `PhotoRepository.deletePhoto(id)` → `PhotoService.deletePhoto(id)` → `ApiClient.delete('/photos/$id')`
- After the API call succeeds, the photo is removed from the local list and UI updates.

**Bulk deletion** (from multi-select mode):
- `GalleryProvider.deleteSelected()` → `PhotoRepository.deletePhotos(ids)` → `PhotoService.deletePhotos(ids)` → `ApiClient.post('/photos/delete', body: {ids: [...]})`
- After the API call succeeds, selected photos are removed locally and selection is cleared.

## 8. How Image Upload Works

- The UI trigger is the `FloatingActionButton` ("Add Media") in `GalleryScreen`.
- On tap → `GalleryProvider.pickAndUploadMedia()` opens the image picker.
- For each selected file → `PhotoRepository.uploadPhoto(File)` → `PhotoService.uploadPhoto(filePath)` → `ApiClient.postMultipart('/photos/upload', filePath)`.
- After all uploads complete → `fetchPhotos()` is called to refresh the list from the server.
- For real multipart upload, implement in `ApiClient`:
  ```dart
  Future<Map<String, dynamic>> postMultipart(String endpoint, String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiEndpoints.baseUrl}$endpoint'));
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));
    request.headers.addAll(_authHeaders());
    var response = await request.send();
    var body = await response.stream.bytesToString();
    return json.decode(body);
  }
  ```

## 9. Authentication Tokens

If APIs require Bearer tokens:
- Add a shared or secure token retrieval method.
- Inject headers in `ApiClient` calls:
  ```dart
  Map<String, String> _authHeaders() => {
    'Authorization': 'Bearer $YOUR_TOKEN',
    'Content-Type': 'application/json',
  };
  ```

## 10. Provider Auto-Updating UI

The frontend uses `provider` state management. After any API result, the `GalleryProvider` sets `_photos = newPhotos` and calls `notifyListeners()`. The UI automatically rebuilds and renders the new images dynamically.

## 11. Environment Configuration

- Keep different environment URLs inside `.env` utilizing packages like `flutter_dotenv`.
- Retrieve them in `ApiEndpoints` based on debug/release modes.

## 12. Testing the Integration

- Temporarily log incoming HTTP JSON responses prior to `Photo.fromJson` decoding.
- Verify that UI `CachedNetworkImage` components download images successfully (validate CORS if testing from web).
- Test failing API routes to verify `GalleryProvider` sets `error` and renders the error component correctly.

## 13. Scalability Suggestions

For scalable media storage, avoid storing blobs directly in your database.
- Utilize services like **AWS S3**, **Google Cloud Storage**, or **Cloudinary**.
- Either have the device upload directly via Presigned URLs provided by your backend and send only the resultant URL to your DB, or pipe the upload POST through your backend to abstract the cloud storage mechanism.
