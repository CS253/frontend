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
/// Fetches all required data (summary, settlements, expenses) in parallel
/// and distributes it to child widgets, eliminating duplicate API calls.
class PaymentsProvider extends ChangeNotifier {
  final PaymentRepository _repository;

  PaymentsProvider({required PaymentRepository repository})
    : _repository = repository;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
  // Load All Data
  // ---------------------------------------------------------------------------

  /// Loads all payments page data in parallel.
  ///
  /// [groupId] — the current group/trip ID.
  /// [simplifyDebts] — from DashboardProvider.currentTrip.simplifyDebts.
  /// [participants] — from DashboardProvider.participants (for member list).
  Future<void> loadAll({
    required String groupId,
    bool? simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Resolve userId (cached after first call — no API hit on subsequent loads)
      _currentUserId = await UserIdentityService.instance.getBackendUserId(
        groupId,
        _repository,
      );

      // 2. Store participants as members
      if (participants != null) {
        _members = participants;
      }

      // If simplifyDebts not provided, fetch it from settings endpoint
      bool finalSimplify;
      if (simplifyDebts == null) {
        finalSimplify = await _repository.getSimplifyDebtsSetting(groupId);
      } else {
        finalSimplify = simplifyDebts;
      }
      _simplifyDebts = finalSimplify;

      // 3. Fire all data requests in parallel
      final results = await Future.wait([
        _repository.getExpenses(groupId),
        _repository.getBalances(groupId), // Added getBalances
        _repository.getSettlements(groupId, simplifyDebts: finalSimplify),
        _repository.getGroupSummary(
          groupId,
          userId: _currentUserId.isNotEmpty ? _currentUserId : null,
        ),
      ]);

      _expenses = results[0] as List<ExpenseModel>;
      _balances = results[1] as List<UserBalance>;
      _settlements = results[2] as List<SettlementModel>;
      _summary = results[3] as GroupSummaryModel?;
    } catch (e) {
      _error = e.toString();
      debugPrint('PaymentsProvider.loadAll error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh all data (e.g. after adding/deleting an expense).
  Future<void> refresh({
    required String groupId,
    bool? simplifyDebts, // Changed to nullable
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
    _isLoading = true;
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
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
