/// Data model representing the current trip displayed on the dashboard.
///
/// Maps directly to the `currentTrip` object in the GET /dashboard response.
/// When the backend is implemented, the JSON keys must match the field names
/// used in [fromJson].
class TripModel {
  /// Unique trip identifier from the backend.
  final String id;

  /// Human-readable trip name (e.g. "The Lyaari Trip").
  final String name;

  /// Trip destination or location string.
  final String location;

  /// ISO-8601 date string for when the trip starts.
  final String startDate;

  /// Number of days remaining until the trip begins.
  /// Computed server-side so the UI doesn't need timezone logic.
  final int daysRemaining;

  /// Emoji or icon identifier shown on the trip card badge.
  final String emoji;

  const TripModel({
    required this.id,
    required this.name,
    required this.location,
    required this.startDate,
    required this.daysRemaining,
    this.emoji = '♠️',
  });

  /// Parses a trip from the backend JSON map.
  ///
  /// Expected JSON shape:
  /// ```json
  /// {
  ///   "id": "trip123",
  ///   "name": "The Lyaari Trip",
  ///   "location": "Pakistan",
  ///   "startDate": "2026-04-10",
  ///   "daysRemaining": 5,
  ///   "emoji": "♠️"
  /// }
  /// ```
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      daysRemaining: json['daysRemaining'] as int? ?? 0,
      emoji: json['emoji'] as String? ?? '♠️',
    );
  }

  /// Serializes this model back to JSON (useful for caching / debugging).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'startDate': startDate,
      'daysRemaining': daysRemaining,
      'emoji': emoji,
    };
  }
}
