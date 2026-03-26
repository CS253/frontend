// =============================================================================
// Dashboard Trip Model — Represents the current trip on the dashboard.
//
// Maps to the `currentTrip` object in GET /dashboard response:
// {
//   "id": "trip123",
//   "name": "The Lyaari Trip",
//   "location": "Pakistan",
//   "destination": "Lahore, Pakistan",
//   "startDate": "2026-04-10",
//   "endDate": "2026-04-20",
//   "daysRemaining": 5,
//   "emoji": "♠️",
//   "tripType": "City",
//   "coverImage": "https://storage.travelly.dev/covers/trip123.jpg"
// }
//
// Fields added to match the trip creation dialog parameters:
//   • destination — where the trip is going
//   • endDate     — trip end date (ISO-8601)
//   • tripType    — Beach/Mountain/City/Nature/Island/Other
//   • coverImage  — URL or local path for the trip cover photo
//
// TODO: Update field names if backend uses different keys.
// =============================================================================

class TripModel {
  /// Unique trip identifier from the backend.
  final String id;

  /// Human-readable trip name (e.g. "The Lyaari Trip").
  final String name;

  /// Trip location string (short form, e.g. "Pakistan").
  final String location;

  /// Trip destination (detailed, e.g. "Lahore, Pakistan").
  /// Used in the Trip Details dialog for viewing/editing.
  final String destination;

  /// ISO-8601 date string for when the trip starts.
  final String startDate;

  /// ISO-8601 date string for when the trip ends.
  /// Used in the Trip Details dialog for viewing/editing.
  final String endDate;

  /// Number of days remaining until the trip begins.
  /// Computed server-side so the UI doesn't need timezone logic.
  final int daysRemaining;

  /// Emoji or icon identifier shown on the trip card badge.
  final String emoji;

  /// Trip category type — one of: Beach, Mountain, City, Nature, Island, Other.
  /// Determines the default cover image when no custom cover is uploaded.
  final String tripType;

  /// URL (network) or local file path for the trip's cover photo.
  /// Null if no cover photo has been uploaded — falls back to trip-type default.
  final String? coverImage;
  final bool simplifyDebts;

  const TripModel({
    required this.id,
    required this.name,
    required this.location,
    this.destination = '',
    required this.startDate,
    this.endDate = '',
    required this.daysRemaining,
    this.emoji = '♠️',
    this.tripType = 'Other',
    this.coverImage,
    this.simplifyDebts = false,
  });

  /// Parses a trip from the backend JSON map.
  ///
  /// Expected JSON shape matches the GET /dashboard → currentTrip object.
  /// All new fields have sensible defaults so existing backend responses
  /// won't break if they don't include these fields yet.
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      daysRemaining: json['daysRemaining'] as int? ?? 0,
      emoji: json['emoji'] as String? ?? '♠️',
      tripType: json['tripType'] as String? ?? 'Other',
      coverImage: json['coverImage'] as String?,
      simplifyDebts: json['simplifyDebts'] as bool? ?? false,
    );
  }

  /// Serializes this model back to JSON (useful for API requests / caching).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'daysRemaining': daysRemaining,
      'emoji': emoji,
      'tripType': tripType,
      'coverImage': coverImage,
      'simplifyDebts': simplifyDebts,
    };
  }

  /// Creates a copy of this model with optional field overrides.
  /// Useful for optimistic UI updates before server confirmation.
  TripModel copyWith({
    String? id,
    String? name,
    String? location,
    String? destination,
    String? startDate,
    String? endDate,
    int? daysRemaining,
    String? emoji,
    String? tripType,
    String? coverImage,
    bool? simplifyDebts,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      emoji: emoji ?? this.emoji,
      tripType: tripType ?? this.tripType,
      coverImage: coverImage ?? this.coverImage,
      simplifyDebts: simplifyDebts ?? this.simplifyDebts,
    );
  }
}
