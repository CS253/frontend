import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayWithUPIDialog extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMarkAsPaid;
  final String name;
  final String amount;

  const PayWithUPIDialog({
    super.key,
    required this.onBack,
    required this.onMarkAsPaid,
    required this.name,
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
                  onTap: onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pay Via UPI',
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
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF8A8075)),
                children: [
                  const TextSpan(text: "You're paying "),
                  TextSpan(
                    text: '₹$amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD1475E),
                    ),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A8075),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_android, color: Color(0xFF6BB5E5), size: 28),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward, color: Color(0xFF8A8075), size: 24),
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.currency_rupee, color: Color(0xFF6BB5E5), size: 28),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Complete the payment in your UPI app\nOnce done, come back and confirm below',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: const Color(0xFF8A8075),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new, color: Color(0xFF1B75D0), size: 18),
                label: Text(
                  'Open UPI App to Pay',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF1B75D0),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEBE7E0), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onMarkAsPaid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BB5E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  elevation: 0,
                ),
                child: Text(
                  'Mark as Paid',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
