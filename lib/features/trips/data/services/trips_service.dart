// =============================================================================
// Trips Service — Handles all trip-related API calls.
//
// This service communicates with the backend via ApiClient.
// It does NOT transform data — that's the repository's job.
//
//   Fields: tripName, destination, startDate, endDate, tripType
// TODO: Replace mock implementations with real API calls when backend is ready.
// =============================================================================

import '../../../../core/api/api_client.dart';

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
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> getTrips({int page = 1, int limit = 10}) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — Active by default
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'trips': [
        {
          'id': 'trip-001',
          'name': 'Santorini Dreams',
          'destination': 'Santorini, Greece',
          'coverImage': 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
          'startDate': '2024-05-01',
          'endDate': '2024-05-15',
          'tripType': 'Beach',
          'membersCount': 5,
          'createdBy': 'user-001',
        },
        {
          'id': 'trip-002',
          'name': 'Paris Escape',
          'destination': 'Paris, France',
          'coverImage': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
          'startDate': '2024-07-01',
          'endDate': '2024-07-10',
          'tripType': 'City',
          'membersCount': 3,
          'createdBy': 'user-001',
        },
        {
          'id': 'trip-003',
          'name': 'Mountain Trek',
          'destination': 'Swiss Alps',
          'coverImage': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
          'startDate': '2024-06-01',
          'endDate': '2024-06-10',
          'tripType': 'Mountain',
          'membersCount': 8,
          'createdBy': 'user-001',
        },
      ],
      'total': 3,
      'page': page,
      'limit': limit,
    };

    // -------------------------------------------------------------------------
    // REAL API CALL — Commented out until backend is ready
    // -------------------------------------------------------------------------
    /*
    final response = await apiClient.get(
      ApiEndpoints.trips,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return response as Map<String, dynamic>;
    */
  }

  // ---------------------------------------------------------------------------
  // Get Trip Detail
  // ---------------------------------------------------------------------------

  /// Fetches a specific trip by ID.
  ///
  /// BACKEND CALL: GET /trips/{tripId}
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> getTripById(String tripId) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'trip': {
        'id': tripId,
        'name': 'Santorini Dreams',
        'destination': 'Santorini, Greece',
        'coverImage': 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5f1',
        'startDate': '2024-05-01',
        'endDate': '2024-05-15',
        'tripType': 'Beach',
        'membersCount': 5,
        'createdBy': 'user-001',
      },
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: GET /trips/{tripId}
    // return await apiClient.get(ApiEndpoints.tripDetail(tripId));
    // -------------------------------------------------------------------------
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
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> createTrip({
    required String name,
    required String destination,
    required String startDate,
    required String endDate,
    required String tripType,
  }) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(seconds: 1));
    return {
      'trip': {
        'id': 'trip-new-${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'destination': destination,
        'coverImage': null,
        'startDate': startDate,
        'endDate': endDate,
        'tripType': tripType,
        'membersCount': 0,
        'createdBy': 'user-001',
      },
    };
    // -------------------------------------------------------------------------
  }

  // ---------------------------------------------------------------------------
  // Add Members
  // ---------------------------------------------------------------------------

  /// Adds members to a trip.
  ///
  /// BACKEND CALL: POST /trips/{tripId}/members
  /// Request: { "members": [{ "name": "...", "phone": "..." }] }
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> addMembers({
    required String tripId,
    required List<Map<String, String>> members,
  }) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'members': members.map((m) => {
        ...m,
        'id': 'member-${DateTime.now().millisecondsSinceEpoch}',
        'role': 'member',
      }).toList(),
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: POST /trips/{tripId}/members
    // return await apiClient.post(
    //   ApiEndpoints.addMembers(tripId),
    //   body: {'members': members},
    // );
    // -------------------------------------------------------------------------
  }

  // ---------------------------------------------------------------------------
  // Get Members
  // ---------------------------------------------------------------------------

  /// Fetches members of a trip.
  ///
  /// BACKEND CALL: GET /trips/{tripId}/members
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> getMembers(String tripId) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'members': [
        {'id': 'member-001', 'name': 'Alice', 'phone': '+1234567890', 'role': 'admin'},
        {'id': 'member-002', 'name': 'Bob', 'phone': '+0987654321', 'role': 'member'},
      ],
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: GET /trips/{tripId}/members
    // return await apiClient.get(ApiEndpoints.getMembers(tripId));
    // -------------------------------------------------------------------------
  }
}
