import 'package:flutter/material.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';
import 'package:travelly/features/dashboard/data/models/activity_model.dart';
import 'package:travelly/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:travelly/core/cache/trip_cache.dart';
import 'package:travelly/core/state/mutation_tracker.dart';
import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/features/trips/data/models/trip_model.dart' as trips_model;

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

  /// Per-section loading flags — UI shows targeted shimmer for each section.
  bool _isMembersLoading = false;
  bool get isMembersLoading => _isMembersLoading;

  bool _isActivitiesLoading = false;
  bool get isActivitiesLoading => _isActivitiesLoading;

  /// Instant member count: uses loaded participants when ready, otherwise
  /// falls back to the TripCache shell membersCount for zero-latency display.
  int get memberCount {
    if (_participants.isNotEmpty) return _participants.length;
    if (_currentTrip?.id != null) {
      return TripCache.instance.getShell(_currentTrip!.id)?.membersCount ?? 0;
    }
    return 0;
  }

  /// Whether we have successfully loaded data at least once.
  bool get hasData => _currentTrip != null;

  /// Snapshot of the trip at the time editing began (for dirty-check).
  Map<String, dynamic> _editSnapshot = {};

  /// True while a PATCH is in-flight for the current trip.
  bool get isSyncing =>
      _currentTrip != null &&
      MutationTracker.instance.isSyncing(_currentTrip!.id);

  // ── Constructor ──────────────────────────────────────────────────

  DashboardProvider({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository();

  // ── Public methods ───────────────────────────────────────────────

  /// Fetches all dashboard data progressively: shell instantly, then
  /// members and activities in parallel with per-section loading flags.
  Future<void> fetchDashboard(String tripId) async {
    final isNewTrip = _currentTrip?.id != tripId;

    // ── Step 0: Instant shell render ─────────────────────────────────────────
    // Pull the shell from TripCache and render immediately — zero wait time.
    // The shell already has: title, dates, tripType, coverImage, membersCount.
    if (isNewTrip) {
      final shell = TripCache.instance.getShell(tripId);
      _currentTrip = _mapTripShell(shell);
      _participants = [];     // will populate once members fetch completes
      _activities = [];       // will populate once history fetch completes
      _isMembersLoading = true;
      _isActivitiesLoading = true;
      notifyListeners();      // Render the screen shell instantly
    }

    // ── Step 1: Full-screen spinner only if we have no shell at all ──────────
    _isLoading = _currentTrip == null;
    _errorMessage = '';
    if (_isLoading) notifyListeners();

    try {
      // ── Step 2: Fire groupDetails, members, and history in parallel ──────────
      // Each one updates the UI independently as it completes.
      await Future.wait([
        _fetchTripDetails(tripId),
        _fetchMembers(tripId),
        _fetchActivities(tripId),
      ]);
    } catch (e) {
      _errorMessage = 'Failed to load dashboard. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches and applies the full trip/group detail record.
  Future<void> _fetchTripDetails(String tripId) async {
    try {
      final response = await _repository.getTripDetails(tripId);
      if (response != null) {
        _currentTrip = response;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Fetches the member list and updates the UI section when done.
  Future<void> _fetchMembers(String tripId) async {
    try {
      _participants = await _repository.getTripMembers(tripId);
    } catch (_) {
      _participants = [];
    } finally {
      _isMembersLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the activity/history log and updates the UI section when done.
  Future<void> _fetchActivities(String tripId) async {
    try {
      _activities = await _repository.getTripActivities(tripId);
    } catch (_) {
      _activities = [];
    } finally {
      _isActivitiesLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes only the activity/history log (useful after adding payments).
  Future<void> refreshActivities(String tripId) async {
    _isActivitiesLoading = true;
    notifyListeners();
    await _fetchActivities(tripId);
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

  // ── Dirty-check PATCH ────────────────────────────────────────────

  /// Call this when the user opens the edit dialog to snapshot the
  /// current trip state for dirty-check comparison.
  void beginEdit() {
    if (_currentTrip == null) return;
    _editSnapshot = {
      'name': _currentTrip!.name,
      'destination': _currentTrip!.destination,
      'startDate': _currentTrip!.startDate,
      'endDate': _currentTrip!.endDate,
      'tripType': _currentTrip!.tripType,
      // Include updatedAt for optimistic locking — sent to server with PATCH
      'updatedAt': _currentTrip!.updatedAt,
    };
  }

  /// Computes the diff between [fields] and the snapshot taken in [beginEdit],
  /// then sends ONLY the changed fields via PATCH.
  ///
  /// [fields] must use the same keys as [_editSnapshot].
  /// Returns the updated [TripModel] on success.
  Future<TripModel?> patchTrip(Map<String, dynamic> fields, {
    required Future<dynamic> Function(String, Map<String, dynamic>) patchFn,
  }) async {
    final tripId = _currentTrip?.id;
    if (tripId == null) return null;

    // Snapshot before optimistic update (for rollback)
    final rollbackTrip = _currentTrip;

    final diff = <String, dynamic>{};
    for (final entry in fields.entries) {
      if (entry.key == 'updatedAt') continue; // don't diff this
      final old = _editSnapshot[entry.key];
      if (old != entry.value) {
        diff[entry.key] = entry.value;
      }
    }

    if (diff.isEmpty) return _currentTripAsModel(); // nothing changed

    // Include updatedAt for optimistic locking check on the server
    final updatedAt = _editSnapshot['updatedAt'] as DateTime?;
    if (updatedAt != null) {
      diff['updatedAt'] = updatedAt.toIso8601String();
    }

    MutationTracker.instance.begin(tripId);
    // Optimistically reflect the patch on the UI
    _currentTrip = _currentTrip!.copyWith(
      name: diff['name'] as String? ?? _currentTrip!.name,
      destination: diff['destination'] as String? ?? _currentTrip!.destination,
      tripType: diff['tripType'] as String? ?? _currentTrip!.tripType,
    );
    notifyListeners();

    try {
      await patchFn(tripId, diff);
      MutationTracker.instance.succeed(tripId);
    } on ConflictException catch (e) {
      // 409 — server has a newer version. Silently rollback + notify user.
      _currentTrip = rollbackTrip;
      // Update cache with fresh server data so next open is correct
      if (e.freshData != null) {
        final fresh = trips_model.TripModel.fromJson(e.freshData!);
        TripCache.instance.patchShell(tripId, fresh);
      }
      MutationTracker.instance.fail(tripId, 'CONFLICT');
      notifyListeners();
      rethrow; // Let the calling dialog show the snackbar
    } catch (e) {
      _currentTrip = rollbackTrip;
      MutationTracker.instance.fail(tripId, e.toString());
      notifyListeners();
      rethrow;
    }
    return _currentTripAsModel();
  }

  TripModel? _currentTripAsModel() => _currentTrip;

  TripModel? _mapTripShell(trips_model.TripModel? shell) {
    if (shell == null) return null;
    return TripModel(
      id: shell.id,
      name: shell.name,
      location: shell.destination, // Fallback since Trips doesn't separate location
      destination: shell.destination,
      startDate: shell.startDate.toIso8601String(),
      endDate: shell.endDate.toIso8601String(),
      daysRemaining: 0, // Gets updated after full API fetch
      emoji: '♠️',
      tripType: shell.tripType,
      coverImage: shell.coverImage,
      simplifyDebts: shell.simplifyDebts,
    );
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

