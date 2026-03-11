import 'dart:io';
import '../models/photo.dart';
import '../services/api_service.dart';

class PhotoRepository {
  final ApiService _apiService;

  PhotoRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<Photo>> fetchPhotos({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.getPhotos(page: page, limit: limit);
      final List<dynamic> data = response['data'];
      return data.map((json) => Photo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch photos: $e');
    }
  }

  Future<void> uploadPhoto(File image) async {
    try {
      // Intended to pass file to upload service. 
      // For now passing path to the mock service.
      await _apiService.uploadPhoto(image.path);
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }
}
