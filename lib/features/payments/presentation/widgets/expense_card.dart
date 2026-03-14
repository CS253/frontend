import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';
import 'package:travelly/features/payments/presentation/dialogs/expense_details/payment_details_dialog.dart';

/// List of all expense cards with dynamic data fetching.
class AllExpensesList extends StatefulWidget {
  const AllExpensesList({super.key});

  @override
  State<AllExpensesList> createState() => _AllExpensesListState();
}

class _AllExpensesListState extends State<AllExpensesList> {
  late Future<Map<String, dynamic>> _expensesFuture;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  void _refreshExpenses() {
    setState(() {
      _expensesFuture = _paymentService.fetchExpenses();
    });
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await _paymentService.deleteExpense(id);
      _refreshExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting expense: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || (snapshot.data!['expenses'] as List).isEmpty) {
          return const Center(child: Text('No expenses found.'));
        }

        final expenses = snapshot.data!['expenses'] as List;

        return Column(
          children: expenses.map((expense) {
            return Column(
              children: [
                ExpenseCard(
                  id: expense['id'],
                  title: expense['title'],
                  amount: expense['amount'],
                  payerName: expense['payer_name'],
                  payerInitials: expense['payer_initials'],
                  payerColor: Color(expense['payer_color']),
                  date: expense['date'],
                  yourShare: expense['your_share'],
                  status: expense['status'],
                  onDelete: () => _deleteExpense(expense['id']),
                ),
                const SizedBox(height: 10),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

/// Individual expense card widget.
class ExpenseCard extends StatelessWidget {
  final String id, title, amount, payerName, payerInitials, date, yourShare, status;
  final String shareTextPrefix;
  final Color payerColor;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.id,
    required this.title,
    required this.amount,
    required this.payerName,
    required this.payerInitials,
    required this.payerColor,
    required this.date,
    required this.yourShare,
    this.shareTextPrefix = 'Your share: ',
    required this.status,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => PaymentDetailsDialog(expenseId: id),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFB),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color.fromRGBO(235, 231, 224, 0.5), width: 1),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(56, 51, 46, 0.08), blurRadius: 18, offset: Offset(0, 3.6))
          ],
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF0E8F7), borderRadius: BorderRadius.circular(11)),
            child: const Center(child: Text('🧾', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.6,
                          color: const Color(0xFF38332E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Text(
                          amount,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                            color: const Color(0xFF38332E),
                          ),
                        ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEECE8),
                        shape: BoxShape.circle,
                        border: Border.all(color: payerColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          payerInitials,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 7,
                            color: const Color(0xFF38332E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Paid by ',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 12.8,
                        color: const Color(0xFF8A8075),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        payerName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.8,
                          color: const Color(0xFF38332E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '·',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.6,
                        color: const Color(0xFF8A8075),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 12.8,
                        color: const Color(0xFF8A8075),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          if (shareTextPrefix == 'Your share: ')
                            Flexible(
                              child: Text(
                                shareTextPrefix,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.8,
                                  color: const Color(0xFF8A8075),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              shareTextPrefix == 'Your share: ' ? yourShare : '$shareTextPrefix $yourShare',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.8,
                                color: shareTextPrefix == 'Your share: '
                                    ? const Color(0xFFD1475E)
                                    : const Color(0xFF339977),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
