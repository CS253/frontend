import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';

class PaymentDetailsDialog extends StatefulWidget {
  final String expenseId;
  
  const PaymentDetailsDialog({super.key, required this.expenseId});

  @override
  State<PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<PaymentDetailsDialog> {
  Map<String, dynamic>? _expenseDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final details = await PaymentService().fetchExpenseDetails(widget.expenseId);
      if (mounted) {
        setState(() {
          _expenseDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF9FDFCA))),
      );
    }

    final title = _expenseDetails?['title'] ?? 'Payment Name';
    final date = _expenseDetails?['date'] ?? 'Date';
    final amount = _expenseDetails?['amount'] ?? '0';
    final payerName = _expenseDetails?['payer_name'] ?? _expenseDetails?['payerName'] ?? 'Unknown';
    final splits = _expenseDetails?['splits'] as List<dynamic>? ?? [];

    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Details',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF38332E),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: const Icon(Icons.close, size: 20, color: Color(0xFF38332E)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(date, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8A8075))),
            const SizedBox(height: 8),
            Text('Paid By: $payerName', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            Text('Split Between:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...splits.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s['name'].toString(), style: GoogleFonts.plusJakartaSans()),
                  Text('₹${s['amount']}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEBE7E0)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                Text('₹$amount', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
