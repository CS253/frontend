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
  Future<Map<String, dynamic>> fetchExpenses() async {
    Map<String, dynamic> response = {'expenses': []};
    try {
      response = await _apiClient.get(ApiEndpoints.expenses);
    } catch (e) {
      // API Error (Expenses)
    }

    // MOCK DATA: Injecting mock entries for testing. 
    // REMOVE THIS BLOCK once backend is fully populated.
    final List<dynamic> mockExpenses = [
      {
        "id": "mock_1",
        "title": "Breakfast at Cafe",
        "amount": "450",
        "payer_name": "Kashish",
        "payer_initials": "K",
        "payer_color": 0xFF9FDFCA,
        "date": "Jan 12",
        "your_share": "150",
        "status": "Pending"
      },
      {
        "id": "mock_2",
        "title": "Taxi to Airport",
        "amount": "1200",
        "payer_name": "Rushabh",
        "payer_initials": "RU",
        "payer_color": 0xFFCCB3E6,
        "date": "Jan 13",
        "your_share": "400",
        "status": "Settled"
      },
      {
        "id": "mock_3",
        "title": "Museum Tickets",
        "amount": "3000",
        "payer_name": "You",
        "payer_initials": "ME",
        "payer_color": 0xFF87D4F8,
        "date": "Jan 14",
        "your_share": "1000",
        "status": "Pending"
      }
    ];

    if (response['expenses'] != null && response['expenses'] is List) {
      response['expenses'] = [...mockExpenses, ...(response['expenses'] as List)];
    } else {
      response['expenses'] = mockExpenses;
    }
    // END MOCK DATA

    return response;
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

  /// Mark a payment as paid for approval.
  Future<Map<String, dynamic>> markAsPaid(Map<String, dynamic> body) {
    // TODO: Add proper endpoint in ApiEndpoints if different from settle
    return _apiClient.post(ApiEndpoints.settle, body: body);
  }

  /// Fetch trip members. Returns mock data for now.
  Future<Map<String, dynamic>> fetchTripMembers() async {
    // TODO: Replace with real API call
    return {
      'members': [
        {'id': '1', 'initials': 'K', 'name': 'Kashish', 'avatar_color': 0xFF9FDFCA},
        {'id': '2', 'initials': 'HP', 'name': 'Hipalantya', 'avatar_color': 0xFFFABD9E},
        {'id': '3', 'initials': 'RU', 'name': 'Rushabh', 'avatar_color': 0xFFCCB3E6},
        {'id': '4', 'initials': 'AS', 'name': 'Ashish', 'avatar_color': 0xFF87D4F8},
        {'id': '5', 'initials': 'ME', 'name': 'You', 'avatar_color': 0xFF87D4F8},
        {'id': '6', 'initials': 'AM', 'name': 'Aman', 'avatar_color': 0xFFFFB3B3},
        {'id': '7', 'initials': 'SK', 'name': 'Suresh', 'avatar_color': 0xFFB3FFB3},
        {'id': '8', 'initials': 'RK', 'name': 'Rahul', 'avatar_color': 0xFFB3B3FF},
        {'id': '9', 'initials': 'PD', 'name': 'Priya', 'avatar_color': 0xFFFFFFB3},
        {'id': '10', 'initials': 'NJ', 'name': 'Neha', 'avatar_color': 0xFFFFB3FF},
        {'id': '11', 'initials': 'VJ', 'name': 'Vijay', 'avatar_color': 0xFFB3FFFF},
      ]
    };
  }

  /// Delete an expense.
  Future<Map<String, dynamic>> deleteExpense(String id) {
    return _apiClient.delete(ApiEndpoints.paymentById(id));
  }
}
