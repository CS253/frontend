import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/features/payments/data/models/expense_model.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';
import 'package:provider/provider.dart';

/// Dialog showing full details for a specific expense.
class PaymentDetailsDialog extends StatefulWidget {
  final String expenseId;
  final String groupId;

  const PaymentDetailsDialog({
    super.key,
    required this.expenseId,
    required this.groupId,
  });

  @override
  State<PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<PaymentDetailsDialog> {
  late Future<Map<String, dynamic>> _detailsFuture;
  late final PaymentService _service;

  @override
  void initState() {
    super.initState();
    _service = context.read<PaymentService>();
    _detailsFuture = _service.fetchExpenseDetails(widget.groupId, widget.expenseId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: 300,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
  
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
  
            final data = snapshot.data?['data'] as Map<String, dynamic>? ?? {};
            final expense = ExpenseModel.fromJson(data);
  
            final currencySymbol = expense.currency == 'INR'
                ? '₹'
                : expense.currency == 'USD'
                ? '\$'
                : expense.currency == 'EUR'
                ? '€'
                : expense.currency == 'GBP'
                ? '£'
                : AppCurrency.symbol;
  
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.close, size: 20, color: Color(0xFF38332E)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          expense.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF38332E),
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Amount', '$currencySymbol${expense.amount.toStringAsFixed(2)}'),
                  _buildInfoRow('Paid by', expense.payerName ?? 'Unknown'),
                  _buildInfoRow('Date', expense.formattedDate.isNotEmpty ? expense.formattedDate : 'N/A'),
                  _buildInfoRow('Split Type', expense.splitType),
                  if (expense.notes != null && expense.notes!.isNotEmpty)
                    _buildInfoRow('Notes', expense.notes!),
                  if (expense.splits.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Splits',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF38332E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...expense.splits.map((split) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                split.userName ?? split.userId,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: const Color(0xFF38332E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$currencySymbol${split.amount.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: const Color(0xFFD1475E),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF8A8075),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF38332E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
