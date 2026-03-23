import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';

class PaymentSplitRow extends StatelessWidget {
  final MemberModel member;
  final TextEditingController controller;
  final VoidCallback onManualEdit;
  final String currencySymbol;

  const PaymentSplitRow({
    super.key,
    required this.member,
    required this.controller,
    required this.onManualEdit,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color.fromRGBO(235, 231, 224, 0.5),
          width: 0.75,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEEECE8),
              border: Border.all(color: member.avatarColor, width: 2),
            ),
            child: Center(
              child: Text(
                member.initials,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                  color: const Color(0xFF38332E),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.name,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: const Color(0xFF38332E),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            height: 32,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => onManualEdit(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFCFAF8),
                prefixText: '$currencySymbol ',
                prefixStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: const Color(0xFF8A8075),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEBE7E0),
                    width: 0.75,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF6BB5E5),
                    width: 1,
                  ),
                ),
              ),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: const Color(0xFF8A8075),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildLoading() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color.fromRGBO(235, 231, 224, 0.5),
          width: 0.75,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEEEEEE),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 90,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
