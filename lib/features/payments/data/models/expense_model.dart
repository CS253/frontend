/// Data model for an expense.
class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String payerName;
  final String payerInitials;
  final int payerColorValue;
  final String date;
  final double yourShare;
  final String shareTextPrefix;
  final String status; // 'Pending' | 'Settled'
  final String currency;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerName,
    required this.payerInitials,
    required this.payerColorValue,
    required this.date,
    required this.yourShare,
    this.shareTextPrefix = 'Your share: ',
    required this.status,
    this.currency = 'INR',
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      payerName: json['payer_name'] as String? ?? '',
      payerInitials: json['payer_initials'] as String? ?? '',
      payerColorValue: json['payer_color'] as int? ?? 0xFF87D4F8,
      date: json['date'] as String? ?? '',
      yourShare: (json['your_share'] as num?)?.toDouble() ?? 0.0,
      shareTextPrefix: json['share_text_prefix'] as String? ?? 'Your share: ',
      status: json['status'] as String? ?? 'Pending',
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'payer_name': payerName,
      'payer_initials': payerInitials,
      'payer_color': payerColorValue,
      'date': date,
      'your_share': yourShare,
      'share_text_prefix': shareTextPrefix,
      'status': status,
      'currency': currency,
    };
  }

  bool get isPending => status == 'Pending';
}
