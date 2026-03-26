class Location {
  final String name;
  final double lat;
  final double lng;

  Location({
    required this.name,
    required this.lat,
    required this.lng,
  });

  Location copyWith({
    String? name,
    double? lat,
    double? lng,
  }) => Location(
    name: name ?? this.name,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
  );

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lng': lng,
      };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        name: json['name'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
}

class RouteRequest {
  final String departureTime;
  final bool optimized;
  final Location start;
  final List<Location> destinations;

  RouteRequest({
    required this.departureTime,
    required this.optimized,
    required this.start,
    required this.destinations,
  });

  Map<String, dynamic> toJson() => {
        'departureTime': departureTime,
        'optimized': optimized,
        'start': start.toJson(),
        'destinations': destinations.map((d) => d.toJson()).toList(),
      };
}

class Stop {
  final String name;
  final double lat;
  final double lng;
  final String placeStatus;
  final String timingText;
  final String opensAt;
  final String closesAt;
  final String? openingHoursRaw;
  final String timingSource;

  Stop({
    required this.name,
    required this.lat,
    required this.lng,
    required this.placeStatus,
    required this.timingText,
    required this.opensAt,
    required this.closesAt,
    this.openingHoursRaw,
    required this.timingSource,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        name: json['name'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        placeStatus: json['placeStatus'] ?? 'Not available',
        timingText: json['timingText'] ?? 'Not available',
        opensAt: json['opensAt'] ?? 'Not available',
        closesAt: json['closesAt'] ?? 'Not available',
        openingHoursRaw: json['openingHoursRaw'],
        timingSource: json['timingSource'] ?? 'Unknown',
      );
}

class RouteResponse {
  final bool success;
  final String mode;
  final String departureTime;
  final Location start;
  final List<Stop> stops;
  final String totalDistanceKm;
  final String totalDurationMinutes;

  RouteResponse({
    required this.success,
    required this.mode,
    required this.departureTime,
    required this.start,
    required this.stops,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    // Support both { data: { ... } } wrapper and flat response
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return RouteResponse(
      success: json['success'] as bool? ?? true,
      mode: json['mode'] as String? ?? data['mode'] as String? ?? 'optimized',
      departureTime: data['departureTime'] as String? ?? '',
      start: Location.fromJson(data['start'] as Map<String, dynamic>),
      stops: (data['stops'] as List?)?.map((s) => Stop.fromJson(s as Map<String, dynamic>)).toList() ?? [],
      totalDistanceKm: (data['totalDistanceKm'] ?? data['totalDistance'] ?? '0') .toString(),
      totalDurationMinutes: (data['totalDurationMinutes'] ?? data['totalDuration'] ?? '0').toString(),
    );
  }
}
