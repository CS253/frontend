/// Data model for a friend balance.
class BalanceModel {
  final String id;
  final String name;
  final String initials;
  final int avatarColorValue;
  final String statusText;
  final int statusColorValue;
  final int statusTextColorValue;

  const BalanceModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColorValue,
    required this.statusText,
    required this.statusColorValue,
    required this.statusTextColorValue,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      avatarColorValue: json['avatar_color'] as int? ?? 0xFF87D4F8,
      statusText: json['status_text'] as String? ?? '',
      statusColorValue: json['status_color'] as int? ?? 0xFFE0F5EE,
      statusTextColorValue: json['status_text_color'] as int? ?? 0xFF339977,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'avatar_color': avatarColorValue,
      'status_text': statusText,
      'status_color': statusColorValue,
      'status_text_color': statusTextColorValue,
    };
  }
}
