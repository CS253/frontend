/// Data model for per-user balance within a group.
///
/// The API returns balances organized by currency:
/// ```json
/// { "USD": { "user-id-1": { "paid": 150, "owed": 100, "balance": 50 } } }
/// ```
/// This model represents a single user's balance for a single currency.
class UserBalance {
  final String userId;
  final String currency;
  final double paid;
  final double owed;
  final double balance; // positive = owed money, negative = owes money

  const UserBalance({
    required this.userId,
    required this.currency,
    required this.paid,
    required this.owed,
    required this.balance,
  });

  /// Whether this user owes money (negative balance).
  bool get owesMoney => balance < 0;

  /// Whether this user is owed money (positive balance).
  bool get isOwed => balance > 0;

  /// Whether this user is settled (zero balance).
  bool get isSettled => balance == 0;

  /// Absolute balance value for display.
  double get absBalance => balance.abs();
}

/// Parses the API balance response into a flat list of [UserBalance].
///
/// Input format: `{ "USD": { "user-id": { paid, owed, balance } }, "INR": { ... } }`
List<UserBalance> parseBalancesResponse(Map<String, dynamic> data) {
  final List<UserBalance> result = [];
  for (final currency in data.keys) {
    final usersMap = data[currency] as Map<String, dynamic>;
    for (final userId in usersMap.keys) {
      final balanceData = usersMap[userId] as Map<String, dynamic>;
      result.add(UserBalance(
        userId: userId,
        currency: currency,
        paid: (balanceData['paid'] as num?)?.toDouble() ?? 0.0,
        owed: (balanceData['owed'] as num?)?.toDouble() ?? 0.0,
        balance: (balanceData['balance'] as num?)?.toDouble() ?? 0.0,
      ));
    }
  }
  return result;
}
