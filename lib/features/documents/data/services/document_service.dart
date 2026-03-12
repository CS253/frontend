import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';

/// Service layer for document-related API calls.
class DocumentService {
  final ApiClient _apiClient;

  DocumentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> fetchDocuments() {
    return _apiClient.get(ApiEndpoints.documents);
  }

  Future<Map<String, dynamic>> uploadDocument(Map<String, dynamic> body) {
    return _apiClient.post(ApiEndpoints.documents, body: body);
  }

  Future<Map<String, dynamic>> deleteDocument(String id) {
    return _apiClient.delete(ApiEndpoints.documentById(id));
  }
}
