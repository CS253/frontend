import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentAmountField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool isNumber;
  final String? prefixText;
  final Widget? prefixIcon;
  final Color? filledColor;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const PaymentAmountField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.isNumber = false,
    this.prefixText,
    this.prefixIcon,
    this.filledColor,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        SizedBox(
          height: maxLines == 1 ? 42 : null,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            inputFormatters: isNumber
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: filledColor ?? const Color(0xFFFCFAF8),
              prefixText: prefixIcon != null ? null : prefixText,
              prefixIcon: prefixIcon,
              prefixStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF38332E),
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: const Color(0xFF8A8075),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: maxLines == 1 ? 0 : 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: Color(0xFFEBE7E0),
                  width: 0.75,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: readOnly
                      ? const Color(0xFFEBE7E0)
                      : const Color(0xFF6BB5E5),
                  width: readOnly ? 0.75 : 1,
                ),
              ),
            ),
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: const Color(0xFF38332E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: const Color(0xFF38332E),
      ),
    );
  }
}
