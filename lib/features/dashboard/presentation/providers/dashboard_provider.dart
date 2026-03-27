import 'package:flutter/material.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';
import 'package:travelly/features/dashboard/data/models/activity_model.dart';
import 'package:travelly/features/dashboard/data/repositories/dashboard_repository.dart';

/// State management provider for the Dashboard feature.
///
/// Architecture role:
///   DashboardScreen → **Provider** → Repository → Service → ApiClient
///
/// This provider uses [ChangeNotifier] to reactively update the UI when
/// dashboard data changes. It manages loading, error, and data states.
///
/// Usage in widget tree:
/// ```dart
/// final provider = Provider.of<DashboardProvider>(context);
/// ```
class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  // ── State fields ─────────────────────────────────────────────────

  /// Whether dashboard data is currently being fetched.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message from the last failed fetch attempt.
  /// Empty string means no error.
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// The currently active trip. Null until data is fetched.
  TripModel? _currentTrip;
  TripModel? get currentTrip => _currentTrip;

  /// List of trip participants / travelers.
  List<ParticipantModel> _participants = [];
  List<ParticipantModel> get participants => _participants;

  /// Chronologically ordered list of recent activities.
  List<ActivityModel> _activities = [];
  List<ActivityModel> get activities => _activities;

  /// Whether we have successfully loaded data at least once.
  bool get hasData => _currentTrip != null;

  // ── Constructor ──────────────────────────────────────────────────

  DashboardProvider({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository();

  // ── Public methods ───────────────────────────────────────────────

  /// Fetches all dashboard data from the repository.
  ///
  /// State transitions:
  ///   1. Sets [isLoading] = true, clears previous error
  ///   2. Calls repository → service → API (with mock fallback)
  ///   3. Updates [currentTrip], [participants], [activities]
  ///   4. Sets [isLoading] = false
  ///   5. On failure: sets [errorMessage]
  ///
  /// Calls [notifyListeners] at each state transition so the UI
  /// can react (show loading spinner, render data, or show error).
  Future<void> fetchDashboard(String tripId) async {
    // ── Step 0: Clear stale data if switching trips ──────────────
    // If the tripId is different from the current one, clear the data
    // so the UI shows a loading spinner instead of the previous trip.
    if (_currentTrip?.id != tripId) {
      _currentTrip = null;
      _participants = [];
      _activities = [];
    }

    // ── Step 1: Enter loading state ──────────────────────────────
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // ── Step 2–3: Fetch and parse data ─────────────────────────
      final response = await _repository.getDashboard(tripId);

      _currentTrip = response.currentTrip;
      _participants = response.participants;
      _activities = response.recentActivities;
    } catch (e) {
      // ── Step 5: Handle errors ──────────────────────────────────
      _errorMessage = 'Failed to load dashboard. Please try again.';
    } finally {
      // ── Step 4: Exit loading state ─────────────────────────────
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes dashboard data. Convenience method for pull-to-refresh.
  Future<void> refresh(String tripId) => fetchDashboard(tripId);

  /// Updates trip details with all editable fields.
  ///
  /// Called from [TripDetailsDialog] when the user saves changes.
  /// Accepts the same fields that the Trip Details dialog displays:
  ///   • name, destination, startDate, endDate, tripType, emoji
  ///   • coverImagePath (optional) — local file path for cover photo
  ///
  /// Flow:
  ///   1. Calls repository.updateTrip() → service.updateTrip() → API
  ///   2. Repository re-fetches dashboard after successful update
  ///   3. Provider updates local state with fresh response
  ///   4. UI rebuilds via notifyListeners()
  ///
  /// On failure, the error is propagated to the dialog for handling.
  ///
  /// BACKEND CALL: PUT /trips/:id
  Future<void> updateTrip({
    required String name,
    required String destination,
    required String startDate,
    required String endDate,
    required String tripType,
    required String emoji,
    String? coverImagePath,
  }) async {
    final tripId = _currentTrip?.id ?? '';
    if (tripId.isEmpty) return;

    try {
      final response = await _repository.updateTrip(
        tripId: tripId,
        name: name,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        tripType: tripType,
        emoji: emoji,
        coverImagePath: coverImagePath,
      );

      // Update local state with the refreshed dashboard data
      _currentTrip = response.currentTrip;
      _participants = response.participants;
      _activities = response.recentActivities;
      notifyListeners();
    } catch (e) {
      // Re-throw so the dialog can show feedback
      rethrow;
    }
  }

  /// Optimistically updates the simplifyDebts setting for the current trip.
  void updateSimplifyDebts(bool value) {
    if (_currentTrip != null) {
      _currentTrip = _currentTrip!.copyWith(simplifyDebts: value);
      notifyListeners();
    }
  }

  /// Clears all dashboard data (e.g., on logout).
  void clear() {
    _currentTrip = null;
    _participants = [];
    _activities = [];
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }
}
