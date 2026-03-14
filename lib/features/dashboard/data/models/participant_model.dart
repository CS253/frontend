/// Data model representing a trip participant / traveler.
///
/// Each participant is rendered as an avatar bubble in the
/// [ParticipantRow] widget on the dashboard.
class ParticipantModel {
  /// Unique user identifier.
  final String id;

  /// Display name shown alongside the avatar.
  final String name;

  /// URL to the participant's avatar image.
  /// Falls back to an emoji avatar when empty.
  final String avatarUrl;

  /// Emoji fallback when [avatarUrl] is not available.
  /// Used during mock / offline mode.
  final String emoji;

  const ParticipantModel({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.emoji = '😊',
  });

  /// Parses a participant from the backend JSON map.
  ///
  /// Expected JSON shape:
  /// ```json
  /// {
  ///   "id": "user1",
  ///   "name": "Ronit",
  ///   "avatarUrl": "https://...",
  ///   "emoji": "😊"
  /// }
  /// ```
  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '😊',
    );
  }

  /// Serializes this model back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'emoji': emoji,
    };
  }
}
