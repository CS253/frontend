import 'trip_model.dart';
import 'participant_model.dart';
import 'activity_model.dart';

/// Top-level response model for the GET /dashboard endpoint.
///
/// Wraps all dashboard data into a single typed object that the
/// [DashboardRepository] returns to the [DashboardProvider].
///
/// This model acts as the "contract" between the backend API and
/// the Flutter data layer. When the real backend is implemented,
/// ensure the JSON shape matches the [fromJson] factory below.
class DashboardResponseModel {
  /// The currently active trip details.
  final TripModel currentTrip;

  /// List of participants / travelers for the current trip.
  final List<ParticipantModel> participants;

  /// Chronologically ordered list of recent activity items.
  final List<ActivityModel> recentActivities;

  const DashboardResponseModel({
    required this.currentTrip,
    required this.participants,
    required this.recentActivities,
  });

  /// Parses the full dashboard API response.
  ///
  /// Expected JSON shape:
  /// ```json
  /// {
  ///   "currentTrip": {
  ///     "id": "trip123",
  ///     "name": "The Lyaari Trip",
  ///     "location": "Pakistan",
  ///     "startDate": "2026-04-10",
  ///     "daysRemaining": 5,
  ///     "participants": [
  ///       { "id": "user1", "name": "Ronit", "avatarUrl": "..." }
  ///     ]
  ///   },
  ///   "recentActivities": [
  ///     {
  ///       "id": "activity1",
  ///       "type": "payment_added",
  ///       "actor": "Ronit",
  ///       "description": "added ₹10000 for Hotel",
  ///       "timestamp": "2026-03-10T10:00:00Z"
  ///     }
  ///   ]
  /// }
  /// ```
  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse the currentTrip object
    final tripJson = json['currentTrip'] as Map<String, dynamic>? ?? {};
    final trip = TripModel.fromJson(tripJson);

    // Participants may be nested inside currentTrip or at root level.
    // We check both locations for backend flexibility.
    final participantsList =
        (tripJson['participants'] as List<dynamic>?) ??
        (json['participants'] as List<dynamic>?) ??
        [];
    final participants =
        participantsList
            .map(
              (p) => ParticipantModel.fromJson(p as Map<String, dynamic>),
            )
            .toList();

    // Parse the recentActivities array
    final activitiesList =
        (json['recentActivities'] as List<dynamic>?) ?? [];
    final activities =
        activitiesList
            .map(
              (a) => ActivityModel.fromJson(a as Map<String, dynamic>),
            )
            .toList();

    return DashboardResponseModel(
      currentTrip: trip,
      participants: participants,
      recentActivities: activities,
    );
  }

  /// Serializes the full response back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'currentTrip': currentTrip.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'recentActivities': recentActivities.map((a) => a.toJson()).toList(),
    };
  }
}
