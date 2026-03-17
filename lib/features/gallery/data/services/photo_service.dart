import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

/// Photo Service connecting explicitly through the core ApiClient
class PhotoService {
  final ApiClient _apiClient;

  PhotoService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> fetchPhotos({int page = 1, int limit = 20}) async {
    return await _apiClient.get(
      ApiEndpoints.photos,
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    ) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadPhoto(String filePath) async {
    return await _apiClient.postMultipart(ApiEndpoints.uploadPhoto, filePath) as Map<String, dynamic>;
  }

  Future<void> deletePhoto(String id) async {
    await _apiClient.delete('${ApiEndpoints.photos}/$id');
  }

  Future<void> deletePhotos(List<String> ids) async {
    await _apiClient.post(ApiEndpoints.deletePhotos, body: {'ids': ids});
  }
}
