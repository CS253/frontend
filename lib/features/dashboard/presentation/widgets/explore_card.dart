import 'package:flutter/material.dart';

/// A single explore navigation card in the dashboard grid.
///
/// Layout (from Figma):
///   ┌─────────────────┐
///   │ [icon]           │
///   │                  │
///   │ Title            │
///   │ Subtitle         │
///   └─────────────────┘
///
/// This widget is reusable and stateless — it receives all
/// configuration through constructor parameters.
class ExploreCard extends StatelessWidget {
  /// Card title (e.g. "Payments", "Gallery").
  final String title;

  /// Card subtitle (e.g. "Split & Settle", "Shared Album").
  final String subtitle;

  /// Material icon displayed in the top-left badge.
  final IconData icon;

  /// Background color of the icon badge.
  final Color iconBgColor;

  /// Background color of the entire card.
  final Color cardBgColor;

  /// Callback when the card is tapped. Used for navigation.
  final VoidCallback? onTap;

  const ExploreCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.cardBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(19.16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF262F40).withValues(alpha: 0.17),
              blurRadius: 13.6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.only(left: 13, top: 9, right: 10, bottom: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon badge ───────────────────────────────────────────
            Container(
              width: 44,
              height: 46,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(15.97),
              ),
              child: Center(
                child: Icon(icon, size: 24, color: Colors.white),
              ),
            ),
            const Spacer(),
            // ── Title ────────────────────────────────────────────────
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: Color(0xCC212022),
              ),
            ),
            const SizedBox(height: 2),
            // ── Subtitle ─────────────────────────────────────────────
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                fontFamily: 'Nunito',
                color: Color(0x99212022),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
