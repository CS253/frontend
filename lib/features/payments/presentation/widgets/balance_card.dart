import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The main balance card shown at the top of the payments screen.
class BalanceCard extends StatelessWidget {
  final VoidCallback? onSettleTap;
  final bool isOwe;
  final String amount;

  const BalanceCard({
    super.key,
    this.onSettleTap,
    this.isOwe = true,
    this.amount = '₹690',
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isOwe ? const Color(0xFFFBE9EC) : const Color(0xFFE0F5EE);
    final textColor = isOwe ? const Color(0xFFD1475E) : const Color(0xFF339977);
    final iconBoxColor = isOwe
        ? const Color.fromRGBO(209, 71, 94, 0.17)
        : const Color.fromRGBO(159, 223, 202, 0.3);
    final iconData = isOwe ? Icons.north_east : Icons.arrow_downward;

    return GestureDetector(
      onTap: isOwe ? onSettleTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your balance',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500, fontSize: 13, color: textColor)),
                const SizedBox(height: 4),
                Text(amount,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 27, color: textColor)),
              ],
            ),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBoxColor),
              child: Icon(iconData, color: textColor, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
