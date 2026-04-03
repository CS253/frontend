import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/dashboard_provider.dart';
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
/// Navigation is handled by pushing routes to the root navigator.
class ExploreGrid extends StatelessWidget {
  final String tripId;

  const ExploreGrid({super.key, required this.tripId});

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
              onTap: () {
                final dsProvider = context.read<DashboardProvider>();
                Navigator.of(context, rootNavigator: true).pushNamed(
                  RouteConstants.payments,
                  arguments: {'groupId': tripId},
                ).then((_) => dsProvider.refreshActivities(tripId));
              },
            ),
            ExploreCard(
              title: 'Gallery',
              subtitle: 'Shared Album',
              icon: Icons.image_outlined,
              iconBgColor: const Color(0xFFFFCA9B),
              cardBgColor: const Color(0xFFFFF0DD),
              onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(
                RouteConstants.gallery,
                arguments: {'groupId': tripId},
              ),
            ),
            ExploreCard(
              title: 'Plan',
              subtitle: 'Customize your route',
              icon: Icons.map_outlined,
              iconBgColor: const Color(0xFF7DD2ED),
              cardBgColor: const Color(0xFFE7F8FA),
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(RouteConstants.plan),
            ),
            ExploreCard(
              title: 'Documents',
              subtitle: 'All your file',
              icon: Icons.description_outlined,
              iconBgColor: const Color(0xFFFFE591),
              cardBgColor: const Color(0xFFFEF9EA),
              onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(
                RouteConstants.documents,
                arguments: {'groupId': tripId},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
