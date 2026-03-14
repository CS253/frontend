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
  Future<void> fetchDashboard() async {
    // ── Step 1: Enter loading state ──────────────────────────────
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // ── Step 2–3: Fetch and parse data ─────────────────────────
      final response = await _repository.getDashboard();

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
  Future<void> refresh() => fetchDashboard();
}
