// =============================================================================
// TripCache — In-memory L1 cache for trip shell data.
//
// Provides instant data for the My Trips list on revisit (stale-while-revalidate).
// Also tracks which groups have stale balance/settlement data after mutations.
// Supports pre-fetching cover images via precacheAll() so they are in GPU
// memory before the user navigates to a trip.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelly/features/auth/presentation/providers/auth_provider.dart';
import '../../features/trips/data/models/trip_model.dart';

class TripCache {
  TripCache._();
  static final TripCache instance = TripCache._();

  // L1: Shell data — instantly available after first load
  final Map<String, TripModel> _shells = {};

  // Stale flags — set after any expense / settlement mutation
  final Set<String> _staleBalances = {};
  final Set<String> _staleSettlements = {};

  // ---------------------------------------------------------------------------
  // Shell Cache
  // ---------------------------------------------------------------------------

  /// Returns the cached shell for [tripId], or null if not yet loaded.
  TripModel? getShell(String tripId) => _shells[tripId];

  /// Returns all cached shells in insertion order.
  List<TripModel> getAllShells() => _shells.values.toList();

  /// Returns true if any shells are cached.
  bool get hasShells => _shells.isNotEmpty;

  /// Stores [trip] as the shell for its id.
  void putShell(TripModel trip) => _shells[trip.id] = trip;

  /// Replaces the entire shell cache with [trips].
  void setAll(List<TripModel> trips) {
    _shells.clear();
    for (final t in trips) {
      _shells[t.id] = t;
    }
  }

  /// Merges a single updated trip into the cache (preserves other entries).
  void patchShell(String tripId, TripModel updated) {
    _shells[tripId] = updated;
  }

  /// Removes a trip from the cache (e.g. after leaving/deleting it).
  void remove(String tripId) => _shells.remove(tripId);

  // ---------------------------------------------------------------------------
  // Asset Pre-fetching
  // ---------------------------------------------------------------------------

  /// Pre-fetches all cover images into GPU memory so they render
  /// instantly when the user navigates to a trip detail screen.
  ///
  /// Call this immediately after receiving the summary list.
  void precacheAll(List<TripModel> trips, BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    for (final trip in trips) {
      final url = trip.coverImage;
      if (url != null && url.isNotEmpty && url.startsWith('http')) {
        precacheImage(NetworkImage(url, headers: token != null ? {'Authorization': 'Bearer $token'} : null), context);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Balance Invalidation
  // ---------------------------------------------------------------------------

  void invalidateBalances(String groupId) => _staleBalances.add(groupId);
  bool isBalancesStale(String groupId) => _staleBalances.contains(groupId);
  void markBalancesFresh(String groupId) => _staleBalances.remove(groupId);

  // ---------------------------------------------------------------------------
  // Settlement Invalidation
  // ---------------------------------------------------------------------------

  void invalidateSettlements(String groupId) => _staleSettlements.add(groupId);
  bool isSettlementsStale(String groupId) => _staleSettlements.contains(groupId);
  void markSettlementsFresh(String groupId) => _staleSettlements.remove(groupId);

  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------

  void clear() {
    _shells.clear();
    _staleBalances.clear();
    _staleSettlements.clear();
  }
}
