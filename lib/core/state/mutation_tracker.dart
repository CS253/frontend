// =============================================================================
// MutationTracker — Global per-entity mutation state.
//
// Tracks whether a specific trip or expense is currently being synced to the
// server. UI components listen to this to show a subtle "Syncing..." indicator.
//
// Usage:
//   MutationTracker.instance.begin(tripId);     // before API call
//   MutationTracker.instance.succeed(tripId);   // on success
//   MutationTracker.instance.fail(tripId, msg); // on error / 409
// =============================================================================

import 'package:flutter/foundation.dart';

enum MutationStatus { idle, syncing, error }

class MutationState {
  final MutationStatus status;
  final String? errorMessage;

  const MutationState({required this.status, this.errorMessage});

  bool get isSyncing => status == MutationStatus.syncing;
  bool get hasError => status == MutationStatus.error;
}

class MutationTracker extends ChangeNotifier {
  MutationTracker._();
  static final MutationTracker instance = MutationTracker._();

  final Map<String, MutationState> _states = {};

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  MutationState statusFor(String id) =>
      _states[id] ?? const MutationState(status: MutationStatus.idle);

  bool isSyncing(String id) => statusFor(id).isSyncing;
  bool hasError(String id) => statusFor(id).hasError;
  String? errorFor(String id) => statusFor(id).errorMessage;

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  void begin(String id) {
    _states[id] = const MutationState(status: MutationStatus.syncing);
    notifyListeners();
  }

  void succeed(String id) {
    _states.remove(id);
    notifyListeners();
  }

  void fail(String id, String message) {
    _states[id] = MutationState(status: MutationStatus.error, errorMessage: message);
    notifyListeners();
  }

  void clear(String id) {
    _states.remove(id);
    notifyListeners();
  }

  void clearAll() {
    _states.clear();
    notifyListeners();
  }
}
