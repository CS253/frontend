import 'package:travelly/features/payments/data/models/expense_model.dart';
import 'package:travelly/features/payments/data/models/balance_model.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';

/// Repository that converts API responses into typed models.
///
/// Currently returns mock data. Replace the mock implementations
/// with calls to [PaymentService] when the backend is ready.
class PaymentRepository {
  // ignore: unused_field — will be used when backend is connected
  final PaymentService _service;

  PaymentRepository({PaymentService? service})
    : _service = service ?? PaymentService();

  // ---------------------------------------------------------------------------
  // Mock data (remove when backend is ready)
  // ---------------------------------------------------------------------------

  /// Fetch all expenses. Returns mock data for now.
  Future<List<ExpenseModel>> getExpenses() async {
    // TODO: Replace with real API call:
    // final response = await _service.fetchExpenses();
    // return (response['data'] as List).map((e) => ExpenseModel.fromJson(e)).toList();

    return const [
      ExpenseModel(
        id: '1',
        title: 'Hotel Booking - Snow Valley R...',
        amount: 8000,
        payerName: 'Ashish',
        payerInitials: 'AS',
        payerColorValue: 0xFF9FDFCA,
        date: 'Dec 20',
        yourShare: 500,
        status: 'Pending',
      ),
      ExpenseModel(
        id: '2',
        title: 'Solang Valley Adventure Sports',
        amount: 3200,
        payerName: 'You',
        payerInitials: 'ME',
        payerColorValue: 0xFF87D4F8,
        date: 'Dec 22',
        yourShare: 3200,
        shareTextPrefix: 'You paid',
        status: 'Settled',
      ),
      ExpenseModel(
        id: '3',
        title: 'Dinner at Cafe 1947',
        amount: 2400,
        payerName: 'Priya',
        payerInitials: 'PR',
        payerColorValue: 0xFFFABD9E,
        date: 'Dec 23',
        yourShare: 600,
        status: 'Pending',
      ),
      ExpenseModel(
        id: '4',
        title: 'Taxi to Rohtang Pass',
        amount: 4000,
        payerName: 'Rahul',
        payerInitials: 'RA',
        payerColorValue: 0xFFCCB3E6,
        date: 'Dec 24',
        yourShare: 1000,
        status: 'Settled',
      ),
      ExpenseModel(
        id: '5',
        title: "Breakfast at Johnson's Cafe",
        amount: 1800,
        payerName: 'You',
        payerInitials: 'ME',
        payerColorValue: 0xFF87D4F8,
        date: 'Dec 25',
        yourShare: 1800,
        shareTextPrefix: 'You paid',
        status: 'Settled',
      ),
    ];
  }

  /// Fetch friend balances. Returns mock data for now.
  Future<List<BalanceModel>> getBalances() async {
    // TODO: Replace with real API call:
    // final response = await _service.fetchBalances();
    // return (response['data'] as List).map((e) => BalanceModel.fromJson(e)).toList();

    return const [
      BalanceModel(
        id: '1',
        name: 'Ashish',
        initials: 'AS',
        avatarColorValue: 0xFF9FDFCA,
        statusText: 'You owe ₹500',
        statusColorValue: 0xFFFBE9EC,
        statusTextColorValue: 0xFFD1475E,
      ),
      BalanceModel(
        id: '2',
        name: 'Priya',
        initials: 'PR',
        avatarColorValue: 0xFFFABD9E,
        statusText: 'Owes You ₹800',
        statusColorValue: 0xFFE0F5EE,
        statusTextColorValue: 0xFF339977,
      ),
      BalanceModel(
        id: '3',
        name: 'Rahul',
        initials: 'RA',
        avatarColorValue: 0xFFCCB3E6,
        statusText: 'You owe ₹200',
        statusColorValue: 0xFFFBE9EC,
        statusTextColorValue: 0xFFD1475E,
      ),
      BalanceModel(
        id: '4',
        name: 'Neha',
        initials: 'NH',
        avatarColorValue: 0xFFFAE39E,
        statusText: 'Settled',
        statusColorValue: 0xFFE0F5EE,
        statusTextColorValue: 0xFF339977,
      ),
    ];
  }

  /// Fetch all trip members.
  Future<List<MemberModel>> getTripMembers() async {
    final response = await _service.fetchTripMembers();
    if (response['members'] != null && response['members'] is List) {
      return (response['members'] as List)
          .map((m) => MemberModel.fromJson(m))
          .toList();
    }
    return [];
  }
}
