import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PayWithUpiDialog extends StatefulWidget {
  final String groupId;
  final String name;
  final String initials;
  final String amount;
  final String fromUserId;
  final String toUserId;
  final String currency;
  final VoidCallback onBack;
  final VoidCallback? onComplete;

  const PayWithUpiDialog({
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
  State<PayWithUpiDialog> createState() => _PayWithUpiDialogState();
}

class _PayWithUpiDialogState extends State<PayWithUpiDialog> {
  bool _isLoading = false;
  bool _isSettling = false;
  String? _paymentLink;
  String? _error;

  Future<void> _markAsPaid() async {
    final amount = double.tryParse(widget.amount) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _isSettling = true);

    try {
      if (!mounted) return;
      await context.read<PaymentRepository>().markSettlementPaid(
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
        setState(() => _isSettling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error settling: $e')),
        );
      }
    }
  }

  Future<void> _initiatePayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (!mounted) return;
      
      // Debug: Log the Firebase ID token for Postman testing
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      debugPrint("DEBUG_TOKEN: Bearer $token");
      
      if (!mounted) return;
      final result = await context.read<PaymentRepository>().initiatePayment(
        widget.groupId,
        toUserId: widget.toUserId,
        amount: double.tryParse(widget.amount) ?? 0.0,
        currency: widget.currency,
      );
      if (mounted) {
        final link = result['paymentLink'] as String? ?? '';
        if (link.isNotEmpty) {
          setState(() {
            _paymentLink = link;
            _isLoading = false;
          });
          // try to launch immediately
          await _launchUpiLink(link);
        } else {
          setState(() {
            _error = 'No payment link received';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          String errMsg = e.toString();
          if (errMsg.contains('ApiException')) {
            final parts = errMsg.split(': ');
            if (parts.length > 1) {
              errMsg = parts.sublist(1).join(': ');
            }
          }
          _error = errMsg;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUpiLink(String link) async {
    String finalLink = link;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Force Google Pay on iOS using its custom scheme
      if (finalLink.toLowerCase().startsWith('upi:')) {
        finalLink = finalLink.replaceFirst(RegExp(r'upi://?', caseSensitive: false), 'gpay://upi/');
      }
    }

    final uri = Uri.parse(finalLink);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No UPI app found to handle this payment')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No UPI app found to handle this payment')),
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
                  'Pay with UPI',
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
            Center(
              child: Text(
                '$currencySymbol${widget.amount}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: const Color(0xFFD1475E),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFFD1475E),
                  ),
                ),
              ),
            if (_paymentLink != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _launchUpiLink(_paymentLink!),
                  child: Text(
                    'Tap here to try opening UPI again',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF339977),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            DialogPrimaryButton(
              text: _paymentLink != null ? 'Open UPI App' : 'Generate UPI Link',
              isLoading: _isLoading,
              onPressed: _paymentLink != null
                  ? () => _launchUpiLink(_paymentLink!)
                  : _initiatePayment,
              backgroundColor: const Color(0xFF87D4F8),
              textColor: const Color(0xFF1A6B9C),
              icon: Icons.account_balance_outlined,
            ),
            if (_paymentLink != null) ...[
              const SizedBox(height: 12),
              DialogPrimaryButton(
                text: 'Mark as Paid',
                isLoading: _isSettling,
                onPressed: _markAsPaid,
                backgroundColor: const Color(0xFF9FDFCA),
                textColor: const Color(0xFF339977),
                icon: Icons.check,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
