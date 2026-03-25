// =============================================================================
// Trips Repository — Converts raw API data into typed TripModel / MemberModel.
//
// Data Flow: Screen → Provider → Repository → Service → API
//
// TODO: When connecting the real backend, the repository code should
//       remain unchanged — only the service needs updating.
// =============================================================================

import '../models/trip_model.dart';
import '../models/member_model.dart';
import '../services/trips_service.dart';

class TripsRepository {
  final TripsService service;

  TripsRepository({required this.service});

  // ---------------------------------------------------------------------------
  // Get Trips (List)
  // ---------------------------------------------------------------------------

  /// Fetches and parses the list of trips.
  ///
  /// Returns a list of [TripModel] objects.
  ///
  /// Replace mockTrips() inside TripsService with API response mapping
  /// when connecting real backend. The repository code remains unchanged.
  Future<List<TripModel>> getTrips({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final rawData = await service.getTrips(
        userId: userId,
        page: page,
        limit: limit,
      );
      final tripsJson = rawData['trips'] as List<dynamic>;
      return tripsJson
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load trips: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Get Trip Detail
  // ---------------------------------------------------------------------------

  /// Fetches and parses a specific trip by ID.
  Future<TripModel> getTripById(String tripId) async {
    try {
      final rawData = await service.getTripById(tripId);
      return TripModel.fromJson(rawData['trip'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load trip: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Create Trip
  // ---------------------------------------------------------------------------

  /// Creates a new trip and returns the created [TripModel].
  Future<TripModel> createTrip({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String tripType,
    required String createdBy,
  }) async {
    try {
      final rawData = await service.createTrip(
        name: name,
        destination: destination,
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
        tripType: tripType,
        createdBy: createdBy,
      );
      return TripModel.fromJson(rawData['trip'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Add Members
  // ---------------------------------------------------------------------------

  /// Adds members to a trip and returns the added [MemberModel] list.
  Future<List<MemberModel>> addMembers({
    required String tripId,
    required List<Map<String, String>> members,
  }) async {
    try {
      final rawData = await service.addMembers(
        tripId: tripId,
        members: members,
      );
      final membersJson = rawData['members'] as List<dynamic>;
      return membersJson
          .map((json) => MemberModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to add members: $e');
    }
  }

  Future<MemberModel> removeMember({
    required String tripId,
    required String memberId,
  }) async {
    try {
      final rawData = await service.removeMember(
        tripId: tripId,
        memberId: memberId,
      );
      return MemberModel.fromJson(rawData['member'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  Future<Map<String, dynamic>> leaveTrip({
    required String tripId,
    required String userId,
  }) async {
    try {
      final rawData = await service.leaveTrip(
        tripId: tripId,
        userId: userId,
      );
      return rawData['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to leave trip: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Get Members
  // ---------------------------------------------------------------------------

  /// Fetches and parses the members of a trip.
  Future<List<MemberModel>> getMembers(String tripId) async {
    try {
      final rawData = await service.getMembers(tripId);
      final membersJson = rawData['members'] as List<dynamic>;
      return membersJson
          .map((json) => MemberModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load members: $e');
    }
  }
}
