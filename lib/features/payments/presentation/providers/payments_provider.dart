import 'package:flutter/material.dart';
import 'package:travelly/features/payments/data/models/expense_model.dart';
import 'package:travelly/features/payments/data/models/group_summary_model.dart';
import 'package:travelly/features/payments/data/models/settlement_model.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
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
    required bool simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    _isLoading = true;
    _error = null;
    _simplifyDebts = simplifyDebts;
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

      // 3. Fire all data requests in parallel
      final results = await Future.wait([
        _repository.getGroupSummary(
          groupId,
          userId: _currentUserId.isNotEmpty ? _currentUserId : null,
        ),
        _repository.getSettlements(groupId, simplifyDebts: simplifyDebts),
        _repository.getExpenses(groupId),
      ]);

      _summary = results[0] as GroupSummaryModel?;
      _settlements = results[1] as List<SettlementModel>;
      _expenses = results[2] as List<ExpenseModel>;
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
    required bool simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    await loadAll(
      groupId: groupId,
      simplifyDebts: simplifyDebts,
      participants: participants,
    );
  }

  /// Delete an expense and refresh.
  Future<void> deleteExpense(String groupId, String expenseId, {
    required bool simplifyDebts,
    List<MemberModel>? participants,
  }) async {
    await _repository.deleteExpense(groupId, expenseId);
    await refresh(
      groupId: groupId,
      simplifyDebts: simplifyDebts,
      participants: participants,
    );
  }
}
