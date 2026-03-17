import 'package:flutter/material.dart';
import 'explore_card.dart';

/// 2×2 grid of explore navigation cards on the dashboard.
///
/// Layout (from Figma):
///   Explore
///   ┌──────────┐  ┌──────────┐
///   │ Payments │  │ Gallery  │
///   └──────────┘  └──────────┘
///   ┌──────────┐  ┌──────────┐
///   │ Plan     │  │ Documents│
///   └──────────┘  └──────────┘
///
/// Navigation is handled by calling [onNavigate] with the target
/// bottom navigation index. This avoids coupling the widget to
/// any particular navigation implementation.
///
/// These cards do NOT require backend data — they use static
/// configuration defined in this widget.
class ExploreGrid extends StatelessWidget {
  /// Callback to navigate to a feature screen.
  /// The [int] parameter represents the bottom nav bar index:
  ///   0 = Home (Dashboard)
  ///   1 = Payments
  ///   2 = Plan
  ///   3 = Gallery
  ///   4 = Documents
  final void Function(int tabIndex)? onNavigate;

  const ExploreGrid({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section heading ────────────────────────────────────────
        const Text(
          'Explore',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212022),
          ),
        ),
        const SizedBox(height: 12),

        // ── 2×2 card grid ──────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 172 / 112, // Figma w/h ratio
          children: [
            ExploreCard(
              title: 'Payments',
              subtitle: 'Split & Settle',
              icon: Icons.account_balance_wallet_outlined,
              iconBgColor: const Color(0xFF7EF1CB),
              cardBgColor: const Color(0xFFE5F8F1),
              onTap: () => onNavigate?.call(1),
            ),
            ExploreCard(
              title: 'Gallery',
              subtitle: 'Shared Album',
              icon: Icons.image_outlined,
              iconBgColor: const Color(0xFFFFCA9B),
              cardBgColor: const Color(0xFFFFF0DD),
              onTap: () => onNavigate?.call(3),
            ),
            ExploreCard(
              title: 'Plan',
              subtitle: 'Customize your route',
              icon: Icons.map_outlined,
              iconBgColor: const Color(0xFF7DD2ED),
              cardBgColor: const Color(0xFFE7F8FA),
              onTap: () => onNavigate?.call(2),
            ),
            ExploreCard(
              title: 'Documents',
              subtitle: 'All your file',
              icon: Icons.description_outlined,
              iconBgColor: const Color(0xFFFFE591),
              cardBgColor: const Color(0xFFFEF9EA),
              onTap: () => onNavigate?.call(4),
            ),
          ],
        ),
      ],
    );
  }
}
