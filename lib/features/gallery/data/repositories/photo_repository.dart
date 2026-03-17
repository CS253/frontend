import 'dart:io';
import '../models/photo_model.dart';
import '../services/photo_service.dart';
import '../../../../core/api/api_client.dart';

class PhotoRepository {
  final PhotoService _photoService;

  PhotoRepository({required ApiClient apiClient})
    : _photoService = PhotoService(apiClient: apiClient);

  Future<List<Photo>> fetchPhotos({int page = 1, int limit = 20}) async {
    try {
      final response = await _photoService.fetchPhotos(
        page: page,
        limit: limit,
      );

      final List<dynamic> data = response['data'];
      return data.map((json) => Photo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch photos: $e');
    }
  }

  Future<void> uploadPhoto(File image) async {
    try {
      await _photoService.uploadPhoto(image.path);
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  Future<void> deletePhoto(String id) async {
    try {
      await _photoService.deletePhoto(id);
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }

  Future<void> deletePhotos(List<String> ids) async {
    try {
      await _photoService.deletePhotos(ids);
    } catch (e) {
      throw Exception('Failed to delete photos: $e');
    }
  }
}
