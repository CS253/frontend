import '../../../../core/api/api_client.dart';

class PhotoService {
  final ApiClient apiClient;

  PhotoService({required this.apiClient});

  Future<List<dynamic>> fetchGalleryPhotos() async {
    final response = await apiClient.get('/photos');
    if (response != null && response['data'] != null) {
      return response['data'];
    }
    return [];
  }
}
