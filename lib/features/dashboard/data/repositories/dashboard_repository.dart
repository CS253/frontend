import 'package:travelly/features/dashboard/data/models/dashboard_response_model.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';
import 'package:travelly/features/dashboard/data/models/activity_model.dart';
import 'package:travelly/features/dashboard/data/services/dashboard_service.dart';

/// Repository layer that transforms raw API JSON into typed models.
///
/// Architecture role:
///   DashboardScreen → Provider → **Repository** → Service → ApiClient
///
/// The repository is the single entry point for the provider to obtain
/// dashboard data. It delegates HTTP concerns to [DashboardService]
/// and JSON parsing to [DashboardResponseModel].
///
/// This separation allows:
///   • Swapping the service implementation for testing
///   • Centralizing JSON-to-model transformation
///   • Adding caching or offline-first logic in the future
class DashboardRepository {
  final DashboardService _service;

  DashboardRepository({DashboardService? service})
      : _service = service ?? DashboardService();

  /// Fetches and parses the full dashboard data.
  ///
  /// Returns a [DashboardResponseModel] containing the current trip,
  /// participants, and recent activities.
  ///
  /// Throws on unrecoverable errors (the provider must handle these).
  Future<DashboardResponseModel> getDashboard(String tripId) async {
    final response = await _service.fetchDashboard(tripId);
    return DashboardResponseModel.fromJson(response);
  }

  /// Fetches only the trip/group detail record.
  Future<TripModel?> getTripDetails(String tripId) async {
    final data = await _service.fetchTripDetails(tripId);
    if (data == null) return null;
    return TripModel.fromJson(data);
  }

  /// Fetches only the member list for the trip.
  Future<List<ParticipantModel>> getTripMembers(String tripId) async {
    final list = await _service.fetchTripMembers(tripId);
    return list.map(ParticipantModel.fromJson).toList();
  }

  /// Fetches only the activity/history log for the trip.
  Future<List<ActivityModel>> getTripActivities(String tripId) async {
    final list = await _service.fetchTripActivities(tripId);
    return list.map(ActivityModel.fromJson).toList();
  }

  /// Updates trip details via the service layer.
  ///
  /// Accepts all editable trip fields (matching the Trip Details dialog):
  ///   • name, destination, startDate, endDate, tripType, emoji
  ///   • coverImagePath (optional) — local file path for cover photo upload
  ///
  /// After a successful update, re-fetches dashboard data so the UI
  /// reflects the changes without a manual refresh.
  Future<DashboardResponseModel> updateTrip({
    required String tripId,
    required String name,
    required String destination,
    required String startDate,
    required String endDate,
    required String tripType,
    required String emoji,
    String? coverImagePath,
  }) async {
    await _service.updateTrip(
      tripId: tripId,
      name: name,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      tripType: tripType,
      emoji: emoji,
      coverImagePath: coverImagePath,
    );

    // Re-fetch full dashboard to get consistent state
    return getDashboard(tripId);
  }
}
