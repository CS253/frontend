import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal scrollable friend balance cards.
class FriendBalances extends StatelessWidget {
  const FriendBalances({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _card(avatarColor: const Color(0xFF9FDFCA), initials: 'AS', name: 'Ashish',
              statusColor: const Color(0xFFFBE9EC), statusTextColor: const Color(0xFFD1475E), statusText: 'You owe ₹500'),
          const SizedBox(width: 10),
          _card(avatarColor: const Color(0xFFFABD9E), initials: 'PR', name: 'Priya',
              statusColor: const Color(0xFFE0F5EE), statusTextColor: const Color(0xFF339977), statusText: 'Owes You ₹800'),
          const SizedBox(width: 10),
          _card(avatarColor: const Color(0xFFCCB3E6), initials: 'RA', name: 'Rahul',
              statusColor: const Color(0xFFFBE9EC), statusTextColor: const Color(0xFFD1475E), statusText: 'You owe ₹200'),
          const SizedBox(width: 10),
          _card(avatarColor: const Color(0xFFFAE39E), initials: 'NH', name: 'Neha',
              statusColor: const Color(0xFFE0F5EE), statusTextColor: const Color(0xFF339977), statusText: 'Settled'),
          const SizedBox(width: 10),
          _card(avatarColor: const Color(0xFF87D4F8), initials: 'ME', name: 'You',
              statusColor: const Color(0xFFE0F5EE), statusTextColor: const Color(0xFF339977), statusText: 'Gets ₹50'),
        ],
      ),
    );
  }

  Widget _card({
    required Color avatarColor, required String initials, required String name,
    required Color statusColor, required Color statusTextColor, required String statusText,
  }) {
    return Container(
      width: 136,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB), borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromRGBO(235, 231, 224, 0.5), width: 1),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(56, 51, 46, 0.08), blurRadius: 18, offset: Offset(0, 3.6))],
      ),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: const Color(0xFFEEECE8),
              border: Border.all(color: avatarColor, width: 2),
            ),
            child: Center(child: Text(initials, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF38332E)))),
          ),
          const SizedBox(height: 8),
          Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xFF38332E))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
            child: Text(statusText, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 11, color: statusTextColor)),
          ),
        ],
      ),
    );
  }
}
