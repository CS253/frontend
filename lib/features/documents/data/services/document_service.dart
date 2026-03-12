import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';

/// Service layer for document-related API calls.
class DocumentService {
  final ApiClient _apiClient;

  DocumentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> fetchDocuments() async {
    Map<String, dynamic> response = {'documents': []};
    try {
      response = await _apiClient.get(ApiEndpoints.documents);
    } catch (e) {
      // API Error (Documents)
    }

    // MOCK DATA: Injecting mock entries for testing.
    // REMOVE THIS BLOCK once backend is fully populated.
    final List<dynamic> mockDocuments = [
      {
        "id": "mock_doc_1",
        "emoji": "✈️",
        "title": "Flight Tickets.pdf",
        "subtitle": "1.2 MB · pdf · 12 Mar",
        "uploadedAt": "2026-03-12T10:00:00Z"
      },
      {
        "id": "mock_doc_2",
        "emoji": "🛡️",
        "title": "Travel Insurance.pdf",
        "subtitle": "800 KB · pdf · 12 Mar",
        "uploadedAt": "2026-03-12T11:00:00Z"
      },
      {
        "id": "mock_doc_3",
        "emoji": "🏨",
        "title": "Hotel Booking.pdf",
        "subtitle": "450 KB · pdf · 12 Mar",
        "uploadedAt": "2026-03-12T12:00:00Z"
      }
    ];

    if (response['documents'] != null && response['documents'] is List) {
      response['documents'] = [...mockDocuments, ...(response['documents'] as List)];
    } else {
      response['documents'] = mockDocuments;
    }
    // END MOCK DATA

    return response;
  }

  Future<Map<String, dynamic>> uploadDocument(Map<String, dynamic> body) {
    return _apiClient.post(ApiEndpoints.documents, body: body);
  }

  Future<Map<String, dynamic>> deleteDocument(String id) {
    return _apiClient.delete(ApiEndpoints.documentById(id));
  }
}
