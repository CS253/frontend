import 'package:travelly/features/documents/data/models/document_model.dart';
import 'package:travelly/features/documents/data/services/document_service.dart';

class DocumentRepository {
  final DocumentService _service;

  DocumentRepository({DocumentService? service})
    : _service = service ?? DocumentService();

  Future<List<DocumentModel>> getDocuments({
    required String groupId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _service.fetchDocuments(
      groupId: groupId,
      page: page,
      limit: limit,
    );

    final data = (response['documents'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return data.map(DocumentModel.fromJson).toList();
  }
}
