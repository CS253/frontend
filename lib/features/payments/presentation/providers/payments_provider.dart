import 'dart:async';

import 'package:flutter/material.dart';
import 'package:travelly/features/payments/data/models/expense_model.dart';
import 'package:travelly/features/payments/data/models/group_summary_model.dart';
import 'package:travelly/features/payments/data/models/settlement_model.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/data/models/balance_model.dart';
import 'package:travelly/core/services/user_identity_service.dart';
import 'package:travelly/core/cache/trip_cache.dart';
import 'package:travelly/core/state/mutation_tracker.dart';

/// Centralized provider for the Payments screen.
///
/// Uses **progressive loading**: each section (summary, settlements, expenses)
/// loads independently and notifies the UI as soon as its data arrives.
/// This eliminates the "blank screen until everything loads" problem.
class PaymentsProvider extends ChangeNotifier {
  final PaymentRepository _repository;

  PaymentsProvider({required PaymentRepository repository})
    : _repository = repository;

  // ---------------------------------------------------------------------------
  // State — granular loading flags per section
  // ---------------------------------------------------------------------------

  /// True only during the initial bootstrap (userId + simplifyDebts resolution).
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  /// Legacy getter — true if ANY section is still loading.
  bool get isLoading => _isSummaryLoading || _isSettlementsLoading || _isExpensesLoading;

  bool _isSummaryLoading = true;
  bool get isSummaryLoading => _isSummaryLoading;

  bool _isSettlementsLoading = true;
  bool get isSettlementsLoading => _isSettlementsLoading;

  bool _isExpensesLoading = true;
  bool get isExpensesLoading => _isExpensesLoading;

  String? _error;
  String? get error => _error;

  String _currentUserId = '';
  String get currentUserId => _currentUserId;

  GroupSummaryModel? _summary;
  GroupSummaryModel? get summary => _summary;

  List<SettlementModel> _settlements = [];
  List<SettlementModel> get settlements => _settlements;

  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;

  List<MemberModel> _members = [];
  List<MemberModel> get members => _members;

  bool _simplifyDebts = false;
  bool get simplifyDebts => _simplifyDebts;

  List<UserBalance> _balances = [];
  List<UserBalance> get balances => _balances;

  /// True after the first successful loadAll for a given groupId.
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  String _loadedGroupId = '';

  // ---------------------------------------------------------------------------
  // Load All Data — Progressive
  // ---------------------------------------------------------------------------

  /// Returns the member count: uses _members if populated, otherwise falls
  /// back to the TripCache shell membersCount for instant display.
  int get memberCount {
    if (_members.isNotEmpty) return _members.length;
    return TripCache.instance.getShell(_loadedGroupId)?.membersCount ?? 0;
  }

  /// Loads all payments page data with progressive rendering.
  ///
  /// Phase 1: Resolve userId + simplifyDebts (needed as inputs for later calls).
  /// Phase 2: Fire expenses, balances, settlements, summary **in parallel**.
  ///          Each one updates the UI independently as it completes.
  Future<void> loadAll({
    required String groupId,
    bool? simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    // ── Guard: skip full reload if already loaded for this group ──────────────
    // This prevents re-fetching everything when the user navigates back to the
    // Payments screen. Only a full refresh (explicit pull-to-refresh) bypasses this.
    if (_isLoaded && _loadedGroupId == groupId) {
      // Silently check if balances are stale from a mutation that happened elsewhere
      if (TripCache.instance.isBalancesStale(groupId)) {
        unawaited(refreshDerived(groupId: groupId));
      }
      return;
    }

    _loadedGroupId = groupId;
    _isInitializing = true;
    _isSummaryLoading = true;
    _isSettlementsLoading = true;
    _isExpensesLoading = true;
    _error = null;

    // Seed member count from cache shell immediately — zero-latency display
    if (participants != null && participants.isNotEmpty) {
      _members = participants;
    } else {
      // Keep _members empty so memberCount getter falls back to shell
      _members = [];
    }
    notifyListeners(); // Show the screen skeleton right away

    try {
      // Phase 1: Resolve prerequisites in parallel
      final prereqResults = await Future.wait([
        UserIdentityService.instance.getBackendUserId(groupId, _repository),
        if (simplifyDebts == null)
          _repository.getSimplifyDebtsSetting(groupId),
      ]);

      _currentUserId = prereqResults[0] as String;
      final bool finalSimplify = simplifyDebts ??
          (prereqResults.length > 1 ? prereqResults[1] as bool : false);
      _simplifyDebts = finalSimplify;

      _isInitializing = false;
      notifyListeners(); // UI can now show userId-dependent elements

      // Phase 2: Fire all data requests in parallel — each updates UI on arrival
      Future<void> loadExpenses() async {
        try {
          _expenses = await _repository.getExpenses(groupId);
          // Auto-refresh derived data if balances were invalidated by a mutation
          if (TripCache.instance.isBalancesStale(groupId)) {
            TripCache.instance.markBalancesFresh(groupId);
            unawaited(_refreshDerivedData(
              groupId: groupId,
              simplifyDebts: _simplifyDebts,
            ));
          }
        } catch (e) {
          debugPrint('PaymentsProvider: expenses error: $e');
        } finally {
          _isExpensesLoading = false;
          notifyListeners();
        }
      }

      Future<void> loadSettlements() async {
        try {
          final results = await Future.wait([
            _repository.getBalances(groupId),
            _repository.getSettlements(groupId, simplifyDebts: finalSimplify),
          ]);
          _balances = results[0] as List<UserBalance>;
          _settlements = results[1] as List<SettlementModel>;
        } catch (e) {
          debugPrint('PaymentsProvider: settlements error: $e');
        } finally {
          _isSettlementsLoading = false;
          notifyListeners();
        }
      }

      Future<void> loadSummary() async {
        try {
          _summary = await _repository.getGroupSummary(
            groupId,
            userId: _currentUserId.isNotEmpty ? _currentUserId : null,
          );
        } catch (e) {
          debugPrint('PaymentsProvider: summary error: $e');
        } finally {
          _isSummaryLoading = false;
          notifyListeners();
        }
      }

      // All three fire simultaneously — whichever finishes first renders first
      await Future.wait([
        loadExpenses(),
        loadSettlements(),
        loadSummary(),
        // Ensure member names are available for FriendBalances name resolution
        if (_members.isEmpty)
          () async {
            try {
              final fetched = await _repository.getMembers(groupId);
              if (fetched.isNotEmpty && _members.isEmpty) {
                _members = fetched;
                notifyListeners();
              }
            } catch (_) {}
          }(),
      ]);
      _isLoaded = true;
    } catch (e) {
      _error = e.toString();
      debugPrint('PaymentsProvider.loadAll error: $e');
      _isInitializing = false;
      _isSummaryLoading = false;
      _isSettlementsLoading = false;
      _isExpensesLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes only the derived (balance-dependent) sections.
  ///
  /// Use this after adding/deleting/editing an expense so only balances and
  /// settlements re-fetch. The expense list is already updated optimistically.
  Future<void> refreshDerived({required String groupId}) async {
    await _refreshDerivedData(
      groupId: groupId,
      simplifyDebts: _simplifyDebts,
    );
  }

  /// Force a complete reload (e.g. pull-to-refresh).
  Future<void> forceReload({
    required String groupId,
    bool? simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    _isLoaded = false; // Clear guard so loadAll runs again
    await loadAll(
      groupId: groupId,
      simplifyDebts: simplifyDebts,
      participants: participants,
    );
  }

  // ---------------------------------------------------------------------------
  // Optimistic Expense Mutations
  // ---------------------------------------------------------------------------

  /// Adds an expense optimistically:
  /// 1. Inserts the item at the top of the list immediately
  /// 2. Calls the API
  /// 3. Replaces the optimistic item with the real server item (has ID, etc.)
  /// 4. Re-fetches balances/settlements (derived data)
  /// 5. On API failure: removes the optimistic item and rethrows
  Future<void> addExpense(
    String groupId,
    Map<String, dynamic> expenseData, {
    bool? simplifyDebts,
  }) async {
    // --- Optimistic add ---
    final optimisticId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticExpense = ExpenseModel(
      id: optimisticId,
      groupId: groupId,
      title: expenseData['title'] as String? ?? 'New Expense',
      amount: expenseData['amount'] as double? ?? 0.0,
      currency: expenseData['currency'] as String? ?? 'INR',
      paidBy: expenseData['paidBy'] as String? ?? _currentUserId,
      date: DateTime.now(),
      splitType: expenseData['splitType'] as String? ?? 'EQUAL',
      createdAt: DateTime.now(),
      splits: [],
    );

    // --- Mathematical local sum updating (Optimistic) ---
    if (_summary != null) {
      final currency = expenseData['currency'] as String? ?? 'INR';
      final amount = (expenseData['amount'] as num?)?.toDouble() ?? 0.0;
      final paidBy = expenseData['paidBy'] as String? ?? _currentUserId;
      final isPayer = paidBy == _currentUserId;
      final youPaidDelta = isPayer ? amount : 0.0;
      
      double yourShare = 0.0;
      final split = expenseData['split'];
      if (split != null && split['type'] == 'EQUAL') {
        final participants = split['participants'] as List;
        if (participants.contains(_currentUserId)) {
          yourShare = amount / participants.length;
        }
      } else if (split != null) {
        final splits = split['splits'] as List;
        final mySplit = splits.firstWhere((s) => s['userId'] == _currentUserId, orElse: () => null);
        if (mySplit != null) {
          yourShare = (mySplit['amount'] as num).toDouble();
        }
      }

      _summary!.totalExpensesByPaymentCurrency[currency] = 
          (_summary!.totalExpensesByPaymentCurrency[currency] ?? 0.0) + amount;
          
      if (_summary!.individual != null) {
        final ind = _summary!.individual!;
        ind.paid[currency] = (ind.paid[currency] ?? 0.0) + youPaidDelta;
        ind.owed[currency] = (ind.owed[currency] ?? 0.0) + yourShare;
        ind.balance[currency] = (ind.paid[currency] ?? 0.0) - (ind.owed[currency] ?? 0.0);
      }
    }

    _expenses = List.from(_expenses)..insert(0, optimisticExpense);
    MutationTracker.instance.begin(groupId);
    notifyListeners(); // instant feedback

    try {
      final expenseResponse = await _repository.createExpense(groupId, expenseData);

      final index = _expenses.indexWhere((e) => e.id == optimisticId);
      if (index >= 0) {
        if (expenseResponse != null) {
          _expenses = List.from(_expenses)..[index] = expenseResponse;
        } else {
          _expenses = List.from(_expenses)..removeAt(index);
        }
      }

      // Evict the expenses cache so re-navigation always shows fresh data
      _repository.invalidateExpensesCache(groupId);

      // Invalidate & refresh derived balance data silently (to preserve optimistic look for summary)
      // but DO show empty-box loaders for Settlements per user request.
      TripCache.instance.invalidateBalances(groupId);
      TripCache.instance.invalidateSettlements(groupId);
      
      _isSettlementsLoading = true;
      notifyListeners();

      MutationTracker.instance.succeed(groupId);
      
      unawaited(_refreshDerivedData(
        groupId: groupId,
        simplifyDebts: simplifyDebts ?? _simplifyDebts,
        showLoading: false, // Don't disrupt UX for summary!
      ));
    } catch (e) {
      // Rollback
      _expenses = List.from(_expenses)..removeWhere((e) => e.id == optimisticId);
      MutationTracker.instance.fail(groupId, e.toString());
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes an expense optimistically:
  /// 1. Removes the item from the list immediately (snappy feel)
  /// 2. Calls the API
  /// 3. Re-fetches balances/settlements (derived data)
  /// 4. On API failure: restores the item and rethrows so the UI can show an error
  Future<void> deleteExpense(
    String groupId,
    String expenseId, {
    bool? simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    // --- Optimistic remove ---
    final removedIndex = _expenses.indexWhere((e) => e.id == expenseId);
    ExpenseModel? removed;
    if (removedIndex >= 0) {
      removed = _expenses[removedIndex];
      _expenses = List.from(_expenses)..removeAt(removedIndex);
      notifyListeners(); // instant feedback
    }

    try {
      await _repository.deleteExpense(groupId, expenseId);

      // Invalidate & refresh derived balance data
      TripCache.instance.invalidateBalances(groupId);
      await _refreshDerivedData(
        groupId: groupId,
        simplifyDebts: simplifyDebts ?? _simplifyDebts,
      );
    } catch (e) {
      // Rollback
      if (removed != null && removedIndex >= 0) {
        _expenses = List.from(_expenses)..insert(removedIndex, removed);
      }
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Refreshes only the derived (balance-dependent) sections without
  /// touching the expense list. Called after any expense mutation.
  Future<void> _refreshDerivedData({
    required String groupId,
    required bool simplifyDebts,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _isSettlementsLoading = true;
      _isSummaryLoading = true;
      notifyListeners();
    }

    await Future.wait([
      () async {
        try {
          final results = await Future.wait([
            _repository.getBalances(groupId, forceRefresh: true),
            _repository.getSettlements(groupId, simplifyDebts: simplifyDebts, forceRefresh: true),
          ]);
          _balances = results[0] as List<UserBalance>;
          _settlements = results[1] as List<SettlementModel>;
        } catch (_) {}
        _isSettlementsLoading = false;
        notifyListeners();
      }(),
      () async {
        try {
          // Refresh expenses from server so the list is authoritative after mutation
          final freshExpenses = await _repository.getExpenses(groupId, forceRefresh: true);
          // Only replace if server returned something meaningful
          if (freshExpenses.isNotEmpty || _expenses.every((e) => e.id.startsWith('temp_'))) {
            _expenses = freshExpenses;
          }
        } catch (_) {}
        _isExpensesLoading = false;
        notifyListeners();
      }(),
      () async {
        try {
          _summary = await _repository.getGroupSummary(
            groupId,
            userId: _currentUserId.isNotEmpty ? _currentUserId : null,
            forceRefresh: true,
          );
        } catch (_) {}
        _isSummaryLoading = false;
        TripCache.instance.markBalancesFresh(groupId);
        notifyListeners();
      }(),
    ]);
  }
}
