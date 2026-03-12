import 'package:flutter/material.dart';

/// A reusable floating action button used across features
/// (e.g. "Add Document", "Add Payment").
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon = Icons.add,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFF8DA78),
    this.foregroundColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38332E).withValues(alpha: 0.12),
              blurRadius: 27.5,
              offset: const Offset(0, 7.3),
              spreadRadius: -5.5,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: foregroundColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
