import 'package:travelly/features/documents/data/models/document_model.dart';
import 'package:travelly/features/documents/data/services/document_service.dart';

/// Repository that converts API responses into typed models.
/// Currently returns mock data.
class DocumentRepository {
  // ignore: unused_field — will be used when backend is connected
  final DocumentService _service;

  DocumentRepository({DocumentService? service})
      : _service = service ?? DocumentService();

  /// Fetch all documents. Returns mock data for now.
  Future<List<DocumentModel>> getDocuments() async {
    // TODO: Replace with real API call:
    // final response = await _service.fetchDocuments();
    // return (response['data'] as List).map((e) => DocumentModel.fromJson(e)).toList();

    return const [
      DocumentModel(
        id: '1',
        emoji: '🚂',
        title: 'Train Ticket - Delhi to pathankot',
        subtitle: 'Jan 15, 2024 · By Rahul',
      ),
      DocumentModel(
        id: '2',
        emoji: '🏨',
        title: 'Hotel Booking - Snow Valley Resort',
        subtitle: 'Jan 15-18, 2024 · By Amit',
      ),
      DocumentModel(
        id: '3',
        emoji: '🚂',
        title: 'Return Train Ticket',
        subtitle: 'Jan 18, 2024 · By Rahul',
      ),
      DocumentModel(
        id: '4',
        emoji: '📄',
        title: 'Hawkins Pass Permit',
        subtitle: 'Jan 16, 2024 · By Priya',
      ),
    ];
  }
}
