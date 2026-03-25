import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';

class SelectSettleOptionDialog extends StatelessWidget {
  final String name;
  final String initials;
  final String amount;
  final String currency;
  final VoidCallback onMarkAsPaid;
  final VoidCallback onPayWithUpi;

  const SelectSettleOptionDialog({
    super.key,
    required this.name,
    required this.initials,
    required this.amount,
    required this.currency,
    required this.onMarkAsPaid,
    required this.onPayWithUpi,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol = currency == 'INR'
        ? '₹'
        : currency == 'USD'
        ? '\$'
        : currency == 'EUR'
        ? '€'
        : currency == 'GBP'
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(
              'Settle Up',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF38332E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEEECE8),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF38332E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF38332E),
              ),
            ),
            Text(
              '$currencySymbol$amount',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: const Color(0xFFD1475E),
              ),
            ),
            const SizedBox(height: 24),
            _buildButton(
              'Mark as Paid',
              'Record a cash or other payment',
              Icons.check_circle_outline,
              const Color(0xFF9FDFCA),
              onMarkAsPaid,
            ),
            const SizedBox(height: 10),
            _buildButton(
              'Pay with UPI',
              'Open UPI app to make payment',
              Icons.account_balance_outlined,
              const Color(0xFF87D4F8),
              onPayWithUpi,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAF8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF38332E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      color: const Color(0xFF8A8075),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF8A8075),
            ),
          ],
        ),
      ),
    );
  }
}
