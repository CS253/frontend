import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';

/// Service layer for payment-related API calls.
///
/// This class is responsible *only* for HTTP communication.
/// Data transformation happens in the repository layer.
class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch all expenses for the current trip.
  Future<Map<String, dynamic>> fetchExpenses() {
    return _apiClient.get(ApiEndpoints.expenses);
  }

  /// Fetch balances with friends.
  Future<Map<String, dynamic>> fetchBalances() {
    return _apiClient.get(ApiEndpoints.balances);
  }

  /// Create a new expense.
  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> body) {
    return _apiClient.post(ApiEndpoints.expenses, body: body);
  }

  /// Settle a balance.
  Future<Map<String, dynamic>> settleBalance(Map<String, dynamic> body) {
    return _apiClient.post(ApiEndpoints.settle, body: body);
  }
}
