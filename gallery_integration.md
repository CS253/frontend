# Gallery Backend Integration Guide

This guide outlines exactly how backend engineers should set up the REST API layer for the Travelly Gallery feature. 
The Flutter frontend is already fully wired via Clean Architecture. All data calls pass through `lib/core/api/api_client.dart` down to `lib/features/gallery/data/services/photo_service.dart`.

## 1. Environment Configuration

Define the Base URL inside `lib/core/api/api_endpoints.dart`:
```dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.yourbackend.com/v1'; 
  static const String photosEndpoint = '/photos'; 
  static const String uploadEndpoint = '/photos/upload'; 
  static const String deletePhotosEndpoint = '/photos/delete'; 
}
```

## 2. GET `/photos` (Paginating Grid Data)

When `GalleryProvider.fetchPhotos()` is called, the UI expects a JSON array payload matching the `PhotoModel`:

**Expected JSON Response:**
```json
{
  "data": [
    {
      "id": "abc12345",
      "imageUrl": "https://cdn.example.com/item123.jpg",
      "title": "Beach Day",
      "createdAt": "2026-03-12T12:00:00Z",
      "authorName": "You"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 50
  }
}
```
*Note: If your JSON keys (like `authorName` vs `author_name`) change, update the string identifiers directly in `lib/features/gallery/data/models/photo_model.dart` line 18.*

## 3. POST `/photos/upload` (Adding Media)

The UI utilizes `ImagePicker` allowing multi-image/video selection. When the "Add Media" FAB is tapped, the provider grabs a `List<XFile>` from native device storage.

Inside `lib/features/gallery/data/services/photo_service.dart`, execute a Multipart POST Request:
```dart
Future<void> uploadPhotos(List<String> filePaths) async {
  var request = http.MultipartRequest('POST', Uri.parse('\${ApiEndpoints.baseUrl}\${ApiEndpoints.uploadEndpoint}'));
  
  // Attach all picked images
  for (String path in filePaths) {
    request.files.add(await http.MultipartFile.fromPath('photos[]', path));
  }
  
  // Attach headers
  request.headers.addAll({
    'Authorization': 'Bearer \$YOUR_TOKEN',
  });
  
  var response = await request.send();
}
```
*Currently, `GalleryProvider.pickAndUploadMedia()` mocks this by inserting local file paths directly into the grid state so the UI updates instantly. Once the backend endpoint is ready, simply loop `await _photoRepository.uploadPhoto(File(file.path))` inside that provider method instead.*

## 4. DELETE `/photos/:id` (Single Shot Viewer Delete)

When a user taps an image to open `FullPhotoScreen` and taps the Trash Can in the AppBar, it executes a single delete.

**Setup in Service:**
```dart
Future<void> deletePhoto(String id) async {
  await apiClient.delete('\${ApiEndpoints.photosEndpoint}/\$id');
}
```

## 5. POST `/photos/delete` (Bulk Selection Checkout)

When a user Long-Presses an image in the grid, the app enters **Selection Mode**, aggregating an array of IDs. Tapping the red Trash Can in the header instantly wipes them.

**Setup in Provider & Service:**
The API should accept a JSON body payload containing the ID array:
```json
{
  "ids": ["abc12345", "def67890"]
}
```

```dart
// Service layer
Future<void> deletePhotos(List<String> ids) async {
  await apiClient.post(ApiEndpoints.deletePhotosEndpoint, body: {'ids': ids});
}
```

## 6. S3/Cloud Delivery Suggestion
For scalable performance, avoid storing Blobs directly in PostgreSQL/MongoDB.
- Configure backend controllers to ship the Multipart incoming files from flutter directly to **AWS S3** or **Cloudinary**.
- Return only the generated CDN URL strings back into your Database table columns.
