class PhotoModel {
  final String id;
  final String url;
  final String title;

  PhotoModel({required this.id, required this.url, required this.title});

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
    };
  }
}
