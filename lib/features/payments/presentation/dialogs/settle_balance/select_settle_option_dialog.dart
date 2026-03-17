import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';

class SelectSettleOptionDialog extends StatelessWidget {
  final VoidCallback onPayViaUPI;
  final VoidCallback onMarkAsPaid;
  final String name;
  final String initials;
  final String amount;

  const SelectSettleOptionDialog({
    super.key,
    required this.onPayViaUPI,
    required this.onMarkAsPaid,
    required this.name,
    required this.initials,
    required this.amount,
  });

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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Settle Balance',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF38332E),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEEECE8)),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF38332E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You owe $name',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: const Color(0xFF8A8075),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppCurrency.symbol}$amount',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: const Color(0xFFD1475E),
              ),
            ),
            const SizedBox(height: 32),
            _buildOptionCard(
              context: context,
              icon: Icons.phone_android,
              title: 'Pay via UPI',
              subtitle: 'Use Google Pay, PhonePe, Paytm, etc.',
              onTap: onPayViaUPI,
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context: context,
              icon: Icons.payments_outlined,
              title: 'Mark as Paid',
              subtitle: 'Already paid? Use this if you paid by cash or another method',
              onTap: onMarkAsPaid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAF8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6BB5E5)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF38332E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF8A8075),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Color(0xFF8A8075), size: 20),
          ],
        ),
      ),
    );
  }
}
