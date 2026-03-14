/// Data model for a document.
class DocumentModel {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final String? url;

  const DocumentModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.url,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📄',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emoji': emoji,
      'title': title,
      'subtitle': subtitle,
      if (url != null) 'url': url,
    };
  }
}
