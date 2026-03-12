import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Summary cards row (Total Expense, You Paid, Top Spender).
class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _card(
          iconBoxColor: const Color(0xFFD8F1FD), iconColor: Colors.blueAccent,
          icon: Icons.account_balance_wallet_outlined, title: 'Total Expense', amount: '₹19,400',
        )),
        const SizedBox(width: 10),
        Expanded(child: _card(
          iconBoxColor: const Color(0xFFE0F5EE), iconColor: const Color(0xFF339977),
          icon: Icons.trending_up, title: 'You Paid', amount: '₹5,000', hasProgressBar: true,
        )),
        const SizedBox(width: 10),
        Expanded(child: _card(
          iconBoxColor: const Color(0xFFF0E8F7), iconColor: Colors.purpleAccent,
          icon: Icons.people_outline, title: 'Top Spender', amount: '₹8,000', dynamicSubtitle: 'Ashish',
        )),
      ],
    );
  }

  Widget _card({
    required Color iconBoxColor, required Color iconColor, required IconData icon,
    required String title, required String amount, bool hasProgressBar = false, String? dynamicSubtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB), borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromRGBO(235, 231, 224, 0.5), width: 1),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(56, 51, 46, 0.08), blurRadius: 18, offset: Offset(0, 3.6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBoxColor, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.normal, fontSize: 11, color: const Color(0xFF8A8075)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          if (dynamicSubtitle != null)
            Text(dynamicSubtitle, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF38332E))),
          Text(amount, style: GoogleFonts.plusJakartaSans(
            fontWeight: dynamicSubtitle != null ? FontWeight.normal : FontWeight.bold,
            fontSize: dynamicSubtitle != null ? 11 : 16.5,
            color: dynamicSubtitle != null ? const Color(0xFF8A8075) : const Color(0xFF38332E),
          )),
          if (hasProgressBar) ...[
            const SizedBox(height: 6),
            Container(
              height: 5.5, width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFEEECE8), borderRadius: BorderRadius.circular(9159)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft, widthFactor: 0.26,
                child: Container(decoration: BoxDecoration(color: const Color(0xFF9FDFCA), borderRadius: BorderRadius.circular(9159))),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
