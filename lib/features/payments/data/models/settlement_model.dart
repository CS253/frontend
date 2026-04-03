/// Data model for a settlement transaction.
///
/// Represents a suggested or executed settlement between two users.
/// Returned by GET /groups/:groupId/settlements?simplifyDebts=true/false.
class SettlementModel {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;
  final String currency;

  const SettlementModel({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    required this.currency,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      fromUserId: json['fromUserId'] as String? ?? '',
      fromUserName: json['fromUserName'] as String? ?? '',
      toUserId: json['toUserId'] as String? ?? '',
      toUserName: json['toUserName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'currency': currency,
    };
  }
}

/// Parses the settlement response (with simplifyDebts) into a flat list.
///
/// Input: `{ "USD": [ { fromUserId, toUserId, amount, ... } ], "INR": [...] }`
List<SettlementModel> parseSettlementsResponse(Map<String, dynamic> data) {
  final List<SettlementModel> result = [];
  for (final currency in data.keys) {
    final settlements = data[currency] as List<dynamic>;
    for (final s in settlements) {
      result.add(SettlementModel.fromJson(s as Map<String, dynamic>));
    }
  }
  return result;
}
