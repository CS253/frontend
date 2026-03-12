import '../models/photo_model.dart';
import '../services/photo_service.dart';

class PhotoRepository {
  final PhotoService service;

  PhotoRepository({required this.service});

  Future<List<PhotoModel>> getPhotos() async {
    try {
      final rawData = await service.fetchGalleryPhotos();
      return rawData.map((json) => PhotoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load photos: $e');
    }
  }
}
