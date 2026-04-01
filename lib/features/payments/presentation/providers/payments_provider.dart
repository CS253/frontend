import 'package:flutter/material.dart';
import 'package:travelly/features/payments/data/models/expense_model.dart';
import 'package:travelly/features/payments/data/models/group_summary_model.dart';
import 'package:travelly/features/payments/data/models/settlement_model.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/data/models/balance_model.dart';
import 'package:travelly/core/services/user_identity_service.dart';

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

  // ---------------------------------------------------------------------------
  // Load All Data — Progressive
  // ---------------------------------------------------------------------------

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
    _isInitializing = true;
    _isSummaryLoading = true;
    _isSettlementsLoading = true;
    _isExpensesLoading = true;
    _error = null;

    // Store participants immediately so the UI can render member avatars
    if (participants != null) {
      _members = participants;
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
      ]);
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

  /// Refresh all data (e.g. after adding/deleting an expense).
  Future<void> refresh({
    required String groupId,
    bool? simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    await loadAll(
      groupId: groupId,
      simplifyDebts: simplifyDebts,
      participants: participants,
    );
  }

  /// Delete an expense and refresh.
  Future<void> deleteExpense(
    String groupId,
    String expenseId, {
    bool? simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    _isExpensesLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteExpense(groupId, expenseId);
      await refresh(
        groupId: groupId,
        simplifyDebts: simplifyDebts,
        participants: participants,
      );
    } catch (e) {
      _error = e.toString();
      _isExpensesLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
