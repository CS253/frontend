import 'package:travelly/core/utils/initials_util.dart';

/// Data model for an expense returned by the API.
///
/// Maps to GET /groups/:groupId/expenses and
/// GET /groups/:groupId/expenses/:expenseId responses.
class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String groupId;
  final String paidBy;
  final String? payerName;
  final String? payerEmail;
  final DateTime? date;
  final String? notes;
  final String splitType; // 'EQUAL' | 'CUSTOM'
  final List<ExpenseSplit> splits;
  final DateTime? createdAt;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.groupId,
    required this.paidBy,
    this.payerName,
    this.payerEmail,
    this.date,
    this.notes,
    required this.splitType,
    this.splits = const [],
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final payer = json['payer'] as Map<String, dynamic>?;
    return ExpenseModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      groupId: json['groupId'] as String? ?? '',
      paidBy: json['paidBy'] as String? ?? '',
      payerName: payer?['name'] as String? ?? json['payerName'] as String?,
      payerEmail: payer?['email'] as String?,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      notes: json['notes'] as String?,
      splitType: json['splitType'] as String? ?? 'EQUAL',
      splits: (json['splits'] as List<dynamic>?)
              ?.map((s) => ExpenseSplit.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currency': currency,
      'groupId': groupId,
      'paidBy': paidBy,
      'date': date?.toIso8601String(),
      'notes': notes,
      'splitType': splitType,
      'splits': splits.map((s) => s.toJson()).toList(),
    };
  }

  /// Helper: get initials from payer name for avatar display.
  String get payerInitials {
    return getInitials(payerName ?? '');
  }

  /// Helper: formatted date string for display.
  String get formattedDate {
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date!.month - 1]} ${date!.day}';
  }
}

/// A single split entry within an expense.
class ExpenseSplit {
  final String id;
  final String expenseId;
  final String userId;
  final double amount;
  final String? userName;
  final String? userEmail;

  const ExpenseSplit({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.amount,
    this.userName,
    this.userEmail,
  });

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ExpenseSplit(
      id: json['id'] as String? ?? '',
      expenseId: json['expenseId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      userName: user?['name'] as String?,
      userEmail: user?['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseId': expenseId,
      'userId': userId,
      'amount': amount,
    };
  }
}
