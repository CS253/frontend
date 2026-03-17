// =============================================================================
// Trips Service — Handles all trip-related API calls.
//
// This service communicates with the backend via ApiClient.
// It does NOT transform data — that's the repository's job.
//
// IMAGE UPLOAD:
//   When creating a trip with a cover photo, the service sends a
//   multipart/form-data request using MultipartFile.fromFile.
//   Fields: tripName, destination, startDate, endDate, tripType
//   File: coverImage
//
// TODO: Replace mock implementations with real API calls when backend is ready.
// =============================================================================

// NOTE: Uncomment when real multipart API calls are enabled.
// import 'package:http/http.dart' as http;
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
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> getTrips({int page = 1, int limit = 10}) async {
    // BACKEND CALL: GET /trips with pagination query params
    final response = await apiClient.get(
      ApiEndpoints.trips,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    
    // The API client returns the parsed body
    return response as Map<String, dynamic>;
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
  /// When coverImagePath is provided, sends multipart/form-data request:
  ///   Fields: name, destination, startDate, endDate, tripType
  ///   File: coverImage (MultipartFile.fromFile)
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
    String? coverImagePath,
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
        'coverImage': coverImagePath,
        'startDate': startDate,
        'endDate': endDate,
        'tripType': tripType,
        'membersCount': 0,
        'createdBy': 'user-001',
      },
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: POST /trips — Creates trip with multipart/form-data
    //
    // if (coverImagePath != null) {
    //   // Multipart upload with cover image using MultipartFile.fromFile
    //   final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.trips}');
    //   final request = http.MultipartRequest('POST', uri);
    //
    //   // Add auth header
    //   final token = apiClient.authToken;
    //   if (token != null) {
    //     request.headers['Authorization'] = 'Bearer $token';
    //   }
    //
    //   // Add text fields
    //   request.fields['name'] = name;
    //   request.fields['destination'] = destination;
    //   request.fields['startDate'] = startDate;
    //   request.fields['endDate'] = endDate;
    //   request.fields['tripType'] = tripType;
    //
    //   // Add cover image file
    //   request.files.add(
    //     await http.MultipartFile.fromPath('coverImage', coverImagePath),
    //   );
    //
    //   final streamedResponse = await request.send();
    //   final response = await http.Response.fromStream(streamedResponse);
    //
    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     return jsonDecode(response.body);
    //   } else {
    //     throw Exception('Failed to create trip: ${response.statusCode}');
    //   }
    // } else {
    //   // JSON POST without cover image
    //   return await apiClient.post(
    //     ApiEndpoints.trips,
    //     body: {
    //       'name': name,
    //       'destination': destination,
    //       'startDate': startDate,
    //       'endDate': endDate,
    //       'tripType': tripType,
    //     },
    //   );
    // }
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
