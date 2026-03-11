import 'dart:io';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

/// Photo Service connecting explicitly through the core ApiClient
class PhotoService {
  final ApiClient _apiClient;

  PhotoService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> fetchPhotos({int page = 1, int limit = 20}) async {
    return _apiClient.get(
      ApiEndpoints.photos,
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    );
  }

  Future<Map<String, dynamic>> uploadPhoto(String filePath) async {
    return _apiClient.postMultipart(ApiEndpoints.uploadPhoto, filePath);
  }
}
