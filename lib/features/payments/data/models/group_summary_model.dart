/// Data model for the group summary response.
///
/// Maps to GET /groups/:groupId/summary?userId=...
class GroupSummaryModel {
  final String groupId;
  final String groupTitle;
  final String currency;
  final int memberCount;
  final int expenseCount;
  final Map<String, double> totalExpensesByPaymentCurrency;
  final IndividualSummary? individual;

  const GroupSummaryModel({
    required this.groupId,
    required this.groupTitle,
    required this.currency,
    required this.memberCount,
    required this.expenseCount,
    required this.totalExpensesByPaymentCurrency,
    this.individual,
  });

  factory GroupSummaryModel.fromJson(Map<String, dynamic> json) {
    return GroupSummaryModel(
      groupId: json['groupId'] as String? ?? '',
      groupTitle: json['groupTitle'] as String? ?? '',
      currency: json['currency'] as String? ?? 'INR',
      memberCount: json['memberCount'] as int? ?? 0,
      expenseCount: json['expenseCount'] as int? ?? 0,
      totalExpensesByPaymentCurrency:
          _parseDoubleMap(json['totalExpensesByPaymentCurrency']),
      individual: json['individual'] != null
          ? IndividualSummary.fromJson(
              json['individual'] as Map<String, dynamic>)
          : null,
    );
  }

  static Map<String, double> _parseDoubleMap(dynamic raw) {
    if (raw is! Map) return {};
    return (raw as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0.0),
    );
  }
}

/// Individual user stats within a group summary.
class IndividualSummary {
  final String userId;
  final Map<String, double> totalExpensesByPaymentCurrency;
  final Map<String, double> paid;
  final Map<String, double> owed;
  final Map<String, double> balance;

  const IndividualSummary({
    required this.userId,
    required this.totalExpensesByPaymentCurrency,
    required this.paid,
    required this.owed,
    required this.balance,
  });

  factory IndividualSummary.fromJson(Map<String, dynamic> json) {
    return IndividualSummary(
      userId: json['userId'] as String? ?? '',
      totalExpensesByPaymentCurrency:
          GroupSummaryModel._parseDoubleMap(json['totalExpensesByPaymentCurrency']),
      paid: GroupSummaryModel._parseDoubleMap(json['paid']),
      owed: GroupSummaryModel._parseDoubleMap(json['owed']),
      balance: GroupSummaryModel._parseDoubleMap(json['balance']),
    );
  }
}
