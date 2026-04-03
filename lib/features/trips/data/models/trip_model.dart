// =============================================================================
// Trip Model — Represents a trip in the Travelly app.
//
// Maps to the trip object returned by GET /trips and GET /trips/{id}:
// {
//   "id": "uuid",
//   "name": "Santorini Dreams",
//   "destination": "Santorini, Greece",
//   "coverImage": "https://...",
//   "startDate": "2024-05-01",
//   "endDate": "2024-05-15",
//   "tripType": "Beach",
//   "membersCount": 5,
//   "createdBy": "user-001"
// }
//
// TODO: Update field names if backend uses different keys.
// =============================================================================

class TripModel {
  final String id;
  final String name;
  final String destination;
  final String? coverImage;
  final DateTime startDate;
  final DateTime endDate;
  final String tripType;
  final int membersCount;
  final String? createdBy;
  final bool simplifyDebts;
  /// Server-side last-updated timestamp, used for optimistic locking.
  final DateTime? updatedAt;

  TripModel({
    required this.id,
    required this.name,
    required this.destination,
    this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.tripType,
    this.membersCount = 0,
    this.createdBy,
    this.simplifyDebts = false,
    this.updatedAt,
  });

  /// Creates a TripModel from API JSON response.
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      name: json['name'] as String,
      destination: json['destination'] as String,
      coverImage: json['coverImage'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      tripType: json['tripType'] as String? ?? 'Other',
      membersCount: json['membersCount'] as int? ?? 0,
      createdBy: json['createdBy'] as String?,
      simplifyDebts: json['simplifyDebts'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converts to JSON map for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'coverImage': coverImage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tripType': tripType,
      'membersCount': membersCount,
      'createdBy': createdBy,
      'simplifyDebts': simplifyDebts,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Creates a copy with optional field overrides.
  TripModel copyWith({
    String? id,
    String? name,
    String? destination,
    String? coverImage,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
    int? membersCount,
    String? createdBy,
    bool? simplifyDebts,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      coverImage: coverImage ?? this.coverImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tripType: tripType ?? this.tripType,
      membersCount: membersCount ?? this.membersCount,
      createdBy: createdBy ?? this.createdBy,
      simplifyDebts: simplifyDebts ?? this.simplifyDebts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns formatted date range string (e.g., "May 2024").
  String get formattedDateRange {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[startDate.month - 1]} ${startDate.year}';
  }

  @override
  String toString() => 'TripModel(id: $id, name: $name, destination: $destination)';
}
