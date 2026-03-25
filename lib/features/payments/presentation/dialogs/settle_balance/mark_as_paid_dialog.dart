import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';

class MarkAsPaidDialog extends StatefulWidget {
  final String groupId;
  final String name;
  final String initials;
  final String amount;
  final String fromUserId;
  final String toUserId;
  final String currency;
  final VoidCallback onBack;
  final VoidCallback? onComplete;

  const MarkAsPaidDialog({
    super.key,
    required this.groupId,
    required this.name,
    required this.initials,
    required this.amount,
    required this.fromUserId,
    required this.toUserId,
    required this.currency,
    required this.onBack,
    this.onComplete,
  });

  @override
  State<MarkAsPaidDialog> createState() => _MarkAsPaidDialogState();
}

class _MarkAsPaidDialogState extends State<MarkAsPaidDialog> {
  late TextEditingController _amountController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _markAsPaid() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await PaymentRepository().markSettlementPaid(
        widget.groupId,
        fromUserId: widget.fromUserId,
        toUserId: widget.toUserId,
        amount: amount,
        currency: widget.currency,
      );
      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onComplete != null) widget.onComplete!();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment marked as settled')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error settling: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = widget.currency == 'INR'
        ? '₹'
        : widget.currency == 'USD'
        ? '\$'
        : widget.currency == 'EUR'
        ? '€'
        : widget.currency == 'GBP'
        ? '£'
        : AppCurrency.symbol;

    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: widget.onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Mark as Paid',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF38332E),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEEECE8),
                ),
                child: Center(
                  child: Text(
                    widget.initials,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF38332E),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Paying ${widget.name}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: const Color(0xFF38332E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: const Color(0xFF38332E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF38332E),
                ),
                decoration: InputDecoration(
                  prefixText: '$currencySymbol ',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            DialogPrimaryButton(
              text: 'Confirm Payment',
              isLoading: _isSubmitting,
              onPressed: _markAsPaid,
              backgroundColor: const Color(0xFF9FDFCA),
              textColor: const Color(0xFF339977),
              icon: Icons.check,
            ),
          ],
        ),
      ),
    );
  }
}
