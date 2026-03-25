// =============================================================================
// Trips Service — Handles all trip-related API calls.
//
// This service communicates with the backend via ApiClient.
// It also normalizes group-shaped responses into the trip shape used by the app.
// =============================================================================

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class TripsService {
  final ApiClient apiClient;

  TripsService({required this.apiClient});

  Map<String, dynamic> _normalizeTrip(Map<String, dynamic> rawTrip) {
    final members = rawTrip['members'];
    final preAddedParticipants = rawTrip['preAddedParticipants'];

    final membersCount =
        rawTrip['membersCount'] as int? ??
        ((members is List ? members.length : 0) +
            (preAddedParticipants is List ? preAddedParticipants.length : 0));

    return {
      'id': (rawTrip['id'] ?? rawTrip['groupId']) as String,
      'name': (rawTrip['name'] ?? rawTrip['title'] ?? '') as String,
      'destination': (rawTrip['destination'] ?? '') as String,
      'coverImage': rawTrip['coverImage'] as String?,
      'startDate':
          (rawTrip['startDate'] is String)
              ? rawTrip['startDate'] as String
              : rawTrip['startDate'].toString(),
      'endDate':
          (rawTrip['endDate'] is String)
              ? rawTrip['endDate'] as String
              : rawTrip['endDate'].toString(),
      'tripType': (rawTrip['tripType'] ?? 'Other') as String,
      'membersCount': membersCount,
      'createdBy': rawTrip['createdBy'] as String?,
      if (rawTrip['currency'] != null) 'currency': rawTrip['currency'],
      if (rawTrip['inviteLink'] != null) 'inviteLink': rawTrip['inviteLink'],
    };
  }

  // ---------------------------------------------------------------------------
  // Get Trips (List)
  // ---------------------------------------------------------------------------

  /// Fetches the list of trips with pagination support.
  ///
  /// BACKEND CALL: GET /groups?page=1&limit=10
  /// Response: { "trips": [...], "total": 20, "page": 1, "limit": 10 }
  ///
  Future<Map<String, dynamic>> getTrips({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.trips,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final raw = response as Map<String, dynamic>;
    final data = raw['data'] as List<dynamic>? ?? raw['trips'] as List<dynamic>? ?? [];

    return {
      'trips': data
          .map((item) => _normalizeTrip(item as Map<String, dynamic>))
          .toList(),
      'total': raw['total'] ?? (raw['meta'] as Map<String, dynamic>?)?['total'],
      'page': raw['page'] ?? (raw['meta'] as Map<String, dynamic>?)?['page'] ?? page,
      'limit':
          raw['limit'] ?? (raw['meta'] as Map<String, dynamic>?)?['limit'] ?? limit,
    };
  }

  // ---------------------------------------------------------------------------
  // Get Trip Detail
  // ---------------------------------------------------------------------------

  /// Fetches a specific trip by ID.
  ///
  /// BACKEND CALL: GET /groups/{tripId}
  ///
  Future<Map<String, dynamic>> getTripById(String tripId) async {
    final response = await apiClient.get(ApiEndpoints.tripDetail(tripId));
    final raw = response as Map<String, dynamic>;
    final trip = raw['trip'] as Map<String, dynamic>? ?? raw['data'] as Map<String, dynamic>;

    return {'trip': _normalizeTrip(trip)};
  }

  // ---------------------------------------------------------------------------
  // Create Trip
  // ---------------------------------------------------------------------------

  /// Creates a new trip.
  ///
  /// BACKEND CALL: POST /groups
  ///
  ///
  /// When no cover image, sends regular JSON POST request.
  ///
  Future<Map<String, dynamic>> createTrip({
    required String name,
    required String destination,
    required String startDate,
    required String endDate,
    required String tripType,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.trips,
      body: {
        'title': name,
        'destination': destination,
        'startDate': startDate,
        'endDate': endDate,
        'tripType': tripType,
      },
    );

    final raw = response as Map<String, dynamic>;
    final trip = raw['trip'] as Map<String, dynamic>? ?? raw['data'] as Map<String, dynamic>;

    return {'trip': _normalizeTrip(trip)};
  }

  // ---------------------------------------------------------------------------
  // Add Members
  // ---------------------------------------------------------------------------

  /// Adds members to a trip.
  ///
  /// BACKEND CALL: POST /groups/{tripId}/members
  /// Request: { "members": [{ "name": "...", "phone": "..." }] }
  ///
  Future<Map<String, dynamic>> addMembers({
    required String tripId,
    required List<Map<String, String>> members,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.addMembers(tripId),
      body: {'members': members},
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> removeMember({
    required String tripId,
    required String memberId,
  }) async {
    final response = await apiClient.delete(
      ApiEndpoints.removeMember(tripId, memberId),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> leaveTrip({
    required String tripId,
    required String userId,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.leaveTrip(tripId),
      body: {'userId': userId},
    );

    return response as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Get Members
  // ---------------------------------------------------------------------------

  /// Fetches members of a trip.
  ///
  /// BACKEND CALL: GET /groups/{tripId}/members
  ///
  Future<Map<String, dynamic>> getMembers(String tripId) async {
    final response = await apiClient.get(ApiEndpoints.getMembers(tripId));
    return response as Map<String, dynamic>;
  }
}
