class Photo {
  final String id;
  final String imageUrl;
  final String? title;
  final String? createdAt;

  // Additional fields based on Figma design: User's name
  final String authorName;
  final String? localPath; // For rendering newly picked media

  Photo({
    required this.id,
    required this.imageUrl,
    this.title,
    this.createdAt,
    required this.authorName,
    this.localPath,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String?,
      createdAt: json['createdAt'] as String?,
      authorName: json['authorName'] as String? ?? 'Unknown',
      localPath: json['localPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'createdAt': createdAt,
      'authorName': authorName,
    };
  }
}
