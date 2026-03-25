import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';

/// Service layer for payment-related API calls.
///
/// This class is responsible *only* for HTTP communication.
/// Data transformation happens in the repository layer.
/// All methods require a [groupId] since the API is group-scoped.
class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // ---------------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------------

  /// Fetch all expenses for a group.
  /// GET /groups/:groupId/expenses
  Future<Map<String, dynamic>> fetchExpenses(
    String groupId, {
    String? currency,
    String? paidBy,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, String>{};
    if (currency != null) queryParams['currency'] = currency;
    if (paidBy != null) queryParams['paidBy'] = paidBy;
    if (fromDate != null) queryParams['fromDate'] = fromDate;
    if (toDate != null) queryParams['toDate'] = toDate;

    return await _apiClient.get(
      ApiEndpoints.groupExpenses(groupId),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    ) as Map<String, dynamic>;
  }

  /// Fetch full details for a specific expense.
  /// GET /groups/:groupId/expenses/:expenseId
  Future<Map<String, dynamic>> fetchExpenseDetails(
    String groupId,
    String expenseId,
  ) async {
    return await _apiClient.get(
      ApiEndpoints.groupExpense(groupId, expenseId),
    ) as Map<String, dynamic>;
  }

  /// Create a new expense.
  /// POST /groups/:groupId/expenses
  Future<Map<String, dynamic>> createExpense(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    return await _apiClient.post(
      ApiEndpoints.groupExpenses(groupId),
      body: body,
    ) as Map<String, dynamic>;
  }

  /// Update an expense.
  /// PUT /groups/:groupId/expenses/:expenseId
  Future<Map<String, dynamic>> updateExpense(
    String groupId,
    String expenseId,
    Map<String, dynamic> body,
  ) async {
    return await _apiClient.put(
      ApiEndpoints.groupExpense(groupId, expenseId),
      body: body,
    ) as Map<String, dynamic>;
  }

  /// Delete an expense.
  /// DELETE /groups/:groupId/expenses/:expenseId
  Future<Map<String, dynamic>> deleteExpense(
    String groupId,
    String expenseId,
  ) async {
    return await _apiClient.delete(
      ApiEndpoints.groupExpense(groupId, expenseId),
    ) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Balances & Settlements
  // ---------------------------------------------------------------------------

  /// Fetch balances for all members (per currency).
  /// GET /groups/:groupId/balances
  Future<Map<String, dynamic>> fetchBalances(String groupId) async {
    return await _apiClient.get(
      ApiEndpoints.groupBalances(groupId),
    ) as Map<String, dynamic>;
  }

  /// Fetch settlements (optionally simplified).
  /// GET /groups/:groupId/settlements?simplifyDebts=true/false
  Future<Map<String, dynamic>> fetchSettlements(
    String groupId, {
    bool? simplifyDebts,
  }) async {
    final queryParams = <String, String>{};
    if (simplifyDebts != null) {
      queryParams['simplifyDebts'] = simplifyDebts.toString();
    }

    return await _apiClient.get(
      ApiEndpoints.groupSettlements(groupId),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    ) as Map<String, dynamic>;
  }

  /// Mark a settlement as paid (creates a reimbursement transaction).
  /// POST /groups/:groupId/settlements/mark-paid
  Future<Map<String, dynamic>> markSettlementPaid(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    return await _apiClient.post(
      ApiEndpoints.markSettlementPaid(groupId),
      body: body,
    ) as Map<String, dynamic>;
  }

  /// Request payment from a debtor.
  /// POST /groups/:groupId/settlements/request-payment
  Future<Map<String, dynamic>> requestPayment(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    return await _apiClient.post(
      ApiEndpoints.requestPayment(groupId),
      body: body,
    ) as Map<String, dynamic>;
  }

  /// Initiate UPI payment (get deep link).
  /// POST /groups/:groupId/settlements/initiate-payment
  Future<Map<String, dynamic>> initiatePayment(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    return await _apiClient.post(
      ApiEndpoints.initiatePayment(groupId),
      body: body,
    ) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // History & Summary
  // ---------------------------------------------------------------------------

  /// Fetch payment/reimbursement history.
  /// GET /groups/:groupId/payment-history
  Future<Map<String, dynamic>> fetchPaymentHistory(
    String groupId, {
    String? currency,
    String? userId,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, String>{};
    if (currency != null) queryParams['currency'] = currency;
    if (userId != null) queryParams['userId'] = userId;
    if (fromDate != null) queryParams['fromDate'] = fromDate;
    if (toDate != null) queryParams['toDate'] = toDate;

    return await _apiClient.get(
      ApiEndpoints.paymentHistory(groupId),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    ) as Map<String, dynamic>;
  }

  /// Fetch group summary with optional individual stats.
  /// GET /groups/:groupId/summary?userId=...
  Future<Map<String, dynamic>> fetchGroupSummary(
    String groupId, {
    String? userId,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;

    return await _apiClient.get(
      ApiEndpoints.groupSummary(groupId),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    ) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Group Members
  // ---------------------------------------------------------------------------

  /// Fetch group details (includes members).
  /// GET /groups/:groupId
  Future<Map<String, dynamic>> fetchGroupDetails(String groupId) async {
    return await _apiClient.get(
      ApiEndpoints.groupDetails(groupId),
    ) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  /// Toggle simplify-debts setting.
  /// PUT /groups/:groupId/settings/simplify-debts
  Future<Map<String, dynamic>> updateSimplifyDebts(
    String groupId,
    bool simplifyDebts,
  ) async {
    return await _apiClient.put(
      ApiEndpoints.simplifyDebts(groupId),
      body: {'simplifyDebts': simplifyDebts},
    ) as Map<String, dynamic>;
  }
}
