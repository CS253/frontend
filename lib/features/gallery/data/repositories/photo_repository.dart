import '../models/photo_model.dart';
import '../services/photo_service.dart';

class PhotoRepository {
  final PhotoService _service;

  PhotoRepository(this._service);

  Future<List<PhotoModel>> getPhotos(String tripId) async {
    try {
      final response = await _service.fetchPhotos(tripId);
      final List<dynamic> data = response['data'] ?? [];
      
      return data.map((json) => PhotoModel.fromJson(json)).toList();
    } catch (e) {
      // Handle or re-throw error for the provider to catch
      throw Exception('Failed to load photos: $e');
    }
  }

  Future<PhotoModel> addPhoto(String tripId, String url, String uploadedBy) async {
    final newPhoto = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'url': url,
      'uploaded_by': uploadedBy,
      'uploaded_at': DateTime.now().toIso8601String(),
    };
    
    final response = await _service.uploadPhoto(tripId, newPhoto);
    return PhotoModel.fromJson(response['data']);
  }
}
