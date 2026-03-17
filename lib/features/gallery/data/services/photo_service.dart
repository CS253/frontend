import 'package:travelly/core/api/api_client.dart';

class PhotoService {
  final ApiClient _apiClient;

  PhotoService(this._apiClient);

  Future<Map<String, dynamic>> fetchPhotos(String tripId) async {
    return await _apiClient.get('trips/$tripId/photos');
  }

  Future<Map<String, dynamic>> uploadPhoto(String tripId, Map<String, dynamic> photoData) async {
    return await _apiClient.post('trips/$tripId/photos', body: photoData);
  }
}
