// =============================================================================
// Trips Service — Handles all trip-related API calls.
//
// This service communicates with the backend via ApiClient.
// It does NOT transform data — that's the repository's job.
// =============================================================================

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class TripsService {
  final ApiClient apiClient;

  TripsService({required this.apiClient});

  // ---------------------------------------------------------------------------
  // Get Trips (List)
  // ---------------------------------------------------------------------------

  /// Fetches the list of trips with pagination support.
  ///
  /// BACKEND CALL: GET /trips?page=1&limit=10
  /// Response: { "trips": [...], "total": 20, "page": 1, "limit": 10 }
  ///
  Future<Map<String, dynamic>> getTrips({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.trips,
      queryParams: {
        'userId': userId,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    return response as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Get Trip Detail
  // ---------------------------------------------------------------------------

  /// Fetches a specific trip by ID.
  ///
  /// BACKEND CALL: GET /trips/{tripId}
  ///
  Future<Map<String, dynamic>> getTripById(String tripId) async {
    final response = await apiClient.get(ApiEndpoints.tripDetail(tripId));
    return response as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Create Trip
  // ---------------------------------------------------------------------------

  /// Creates a new trip.
  ///
  /// BACKEND CALL: POST /trips
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
    required String createdBy,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.trips,
      body: {
        'name': name,
        'destination': destination,
        'startDate': startDate,
        'endDate': endDate,
        'tripType': tripType,
        'createdBy': createdBy,
      },
    );

    return response as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Add Members
  // ---------------------------------------------------------------------------

  /// Adds members to a trip.
  ///
  /// BACKEND CALL: POST /trips/{tripId}/members
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
  /// BACKEND CALL: GET /trips/{tripId}/members
  ///
  Future<Map<String, dynamic>> getMembers(String tripId) async {
    final response = await apiClient.get(ApiEndpoints.getMembers(tripId));
    return response as Map<String, dynamic>;
  }
}
