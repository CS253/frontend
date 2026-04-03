import 'package:travelly/features/payments/data/models/expense_model.dart';
import 'package:travelly/features/payments/data/models/balance_model.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/models/settlement_model.dart';
import 'package:travelly/features/payments/data/models/group_summary_model.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';

/// Repository that converts API responses into typed models.
///
/// All methods require a [groupId] since the API is group-scoped.
class PaymentRepository {
  final PaymentService _service;

  // In-memory Future caching to prevent redundant API calls during prefetch
  final Map<String, Future<List<ExpenseModel>>> _expensesCache = {};
  final Map<String, Future<List<UserBalance>>> _balancesCache = {};
  final Map<String, Future<List<SettlementModel>>> _settlementsCache = {};
  final Map<String, Future<GroupSummaryModel?>> _summaryCache = {};
  final Map<String, Future<List<MemberModel>>> _membersCache = {};

  PaymentRepository({PaymentService? service})
    : _service = service ?? PaymentService();

  // ---------------------------------------------------------------------------
  // Prefetch
  // ---------------------------------------------------------------------------
  void prefetchAll(String groupId, {String? userId}) {
    getExpenses(groupId);
    getBalances(groupId);
    getGroupSummary(groupId, userId: userId);
  }

  /// Evict the expenses cache for a group so the next call fetches fresh data.
  void invalidateExpensesCache(String groupId) {
    _expensesCache.remove(groupId);
  }

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  /// Fetch all members for a group (cached).
  Future<List<MemberModel>> getMembers(String groupId, {bool forceRefresh = false}) {
    if (forceRefresh || !_membersCache.containsKey(groupId)) {
      _membersCache[groupId] = _fetchMembers(groupId);
    }
    return _membersCache[groupId]!;
  }

  Future<List<MemberModel>> _fetchMembers(String groupId) async {
    final response = await _service.fetchGroupMembers(groupId);
    final data = response['members'];
    if (data is List) {
      return data
          .map((m) => MemberModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------------

  /// Fetch all expenses for a group.
  Future<List<ExpenseModel>> getExpenses(String groupId, {bool forceRefresh = false}) {
    if (forceRefresh || !_expensesCache.containsKey(groupId)) {
      _expensesCache[groupId] = _fetchExpenses(groupId);
    }
    return _expensesCache[groupId]!;
  }

  Future<List<ExpenseModel>> _fetchExpenses(String groupId) async {
    final response = await _service.fetchExpenses(groupId);
    final data = response['data'];
    if (data is List) {
      return data
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch details for a specific expense.
  Future<ExpenseModel?> getExpenseDetails(
    String groupId,
    String expenseId,
  ) async {
    final response = await _service.fetchExpenseDetails(groupId, expenseId);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return ExpenseModel.fromJson(data);
    }
    return null;
  }

  /// Create a new expense.
  Future<ExpenseModel?> createExpense(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    final response = await _service.createExpense(groupId, body);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return ExpenseModel.fromJson(data);
    }
    return null;
  }

  /// Update an expense.
  Future<ExpenseModel?> updateExpense(
    String groupId,
    String expenseId,
    Map<String, dynamic> body,
  ) async {
    final response = await _service.updateExpense(groupId, expenseId, body);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return ExpenseModel.fromJson(data);
    }
    return null;
  }

  /// Delete an expense.
  Future<void> deleteExpense(String groupId, String expenseId) async {
    await _service.deleteExpense(groupId, expenseId);
  }

  // ---------------------------------------------------------------------------
  // Balances & Settlements
  // ---------------------------------------------------------------------------

  /// Fetch per-currency balances for all members.
  Future<List<UserBalance>> getBalances(String groupId, {bool forceRefresh = false}) {
    if (forceRefresh || !_balancesCache.containsKey(groupId)) {
      _balancesCache[groupId] = _fetchBalances(groupId);
    }
    return _balancesCache[groupId]!;
  }

  Future<List<UserBalance>> _fetchBalances(String groupId) async {
    final response = await _service.fetchBalances(groupId);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return parseBalancesResponse(data);
    }
    return [];
  }

  /// Fetch settlement transactions (simplified or netting).
  Future<List<SettlementModel>> getSettlements(
    String groupId, {
    bool? simplifyDebts,
    bool forceRefresh = false,
  }) {
    // Cache key depends on simplifyDebts value to avoid cross-pollination
    final cacheKey = '${groupId}_$simplifyDebts';
    if (forceRefresh || !_settlementsCache.containsKey(cacheKey)) {
      _settlementsCache[cacheKey] = _fetchSettlements(groupId, simplifyDebts: simplifyDebts);
    }
    return _settlementsCache[cacheKey]!;
  }

  Future<List<SettlementModel>> _fetchSettlements(
    String groupId, {
    bool? simplifyDebts,
  }) async {
    final response = await _service.fetchSettlements(
      groupId,
      simplifyDebts: simplifyDebts,
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return parseSettlementsResponse(data);
    }
    return [];
  }

  /// Mark a settlement as paid.
  Future<Map<String, dynamic>> markSettlementPaid(
    String groupId, {
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
  }) async {
    return await _service.markSettlementPaid(groupId, {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'currency': currency,
    });
  }

  /// Initiate UPI payment.
  Future<Map<String, dynamic>> initiatePayment(
    String groupId, {
    required String toUserId,
    required double amount,
    required String currency,
  }) async {
    final response = await _service.initiatePayment(groupId, {
      'toUserId': toUserId,
      'amount': amount,
      'currency': currency,
    });
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  // ---------------------------------------------------------------------------
  // Group Members
  // ---------------------------------------------------------------------------

  /// Fetch group members from the group details endpoint.
  Future<List<MemberModel>> getGroupMembers(String groupId) async {
    final response = await _service.fetchGroupDetails(groupId);
    final data = response['data'];
    if (data is Map<String, dynamic> && data['members'] is List) {
      return (data['members'] as List)
          .map((m) => MemberModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  /// Fetch group summary with optional individual stats.
  Future<GroupSummaryModel?> getGroupSummary(
    String groupId, {
    String? userId,
    bool forceRefresh = false,
  }) {
    // Cache key depends on userId to avoid cross-pollination
    final cacheKey = '${groupId}_$userId';
    if (forceRefresh || !_summaryCache.containsKey(cacheKey)) {
      _summaryCache[cacheKey] = _fetchGroupSummary(groupId, userId: userId);
    }
    return _summaryCache[cacheKey]!;
  }

  Future<GroupSummaryModel?> _fetchGroupSummary(
    String groupId, {
    String? userId,
  }) async {
    final response = await _service.fetchGroupSummary(
      groupId,
      userId: userId,
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return GroupSummaryModel.fromJson(data);
    }
    return null;
  }

  /// Fetch specifically the simplifyDebts setting for a group.
  Future<bool> getSimplifyDebtsSetting(String groupId) async {
    try {
      final response = await _service.fetchSimplifyDebtsSetting(groupId);
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data['simplifyDebts'] as bool? ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
