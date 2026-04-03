import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';

class DocumentService {
  final ApiClient _apiClient;

  DocumentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> fetchDocuments({
    required String groupId,
    int page = 1,
    int limit = 20,
  }) async {
    final response =
        await _apiClient.get(
              ApiEndpoints.documents,
              queryParams: {
                'groupId': groupId,
                'page': page.toString(),
                'limit': limit.toString(),
              },
            )
            as Map<String, dynamic>;

    final data = (response['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return {
      'documents': data.map(_mapDocumentForUi).toList(),
      'meta': response['meta'],
    };
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String groupId,
    required String filePath,
    required String title,
  }) async {
    return await _apiClient.uploadMultipart(
          ApiEndpoints.uploadDocument,
          fields: {'groupId': groupId, 'title': title},
          fileFieldName: 'file',
          filePath: filePath,
        )
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteDocument(String id) async {
    return await _apiClient.delete(ApiEndpoints.documentById(id))
        as Map<String, dynamic>;
  }

  Map<String, dynamic> _mapDocumentForUi(Map<String, dynamic> item) {
    final fileName = (item['fileName'] as String?) ?? '';
    final title = (item['title'] as String?)?.trim().isNotEmpty == true
        ? item['title'] as String
        : fileName;
    final extension = ((item['extension'] as String?) ?? '')
        .replaceAll('.', '')
        .toLowerCase();
    final uploadedAt = item['createdAt'] as String?;
    final subtitleParts = <String>[
      _formatFileSize(item['sizeBytes']),
      if (extension.isNotEmpty) extension.toUpperCase(),
      if (uploadedAt != null && uploadedAt.isNotEmpty) _formatDate(uploadedAt),
    ]..removeWhere((part) => part.isEmpty);

    final url = item['documentUrl'] ?? item['downloadUrl'] ?? item['fileUrl'];

    return {
      'id': item['id'],
      'emoji': _emojiForExtension(extension),
      'title': title,
      'subtitle': subtitleParts.join(' • '),
      'url': url,
      'extension': extension,
      'uploadedAt': uploadedAt,
      'fileName': fileName,
    };
  }

  String _emojiForExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return '📕';
      case 'doc':
      case 'docx':
        return '📝';
      case 'txt':
        return '📄';
      default:
        return '📎';
    }
  }

  String _formatFileSize(dynamic value) {
    final bytes = value is int ? value : int.tryParse('$value') ?? 0;

    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '$bytes B';
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsed.day} ${months[parsed.month - 1]}';
  }
}
