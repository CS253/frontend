import 'package:flutter/material.dart';
import 'package:travelly/features/dashboard/data/models/activity_model.dart';
import 'activity_tile.dart';

/// Recent activity feed section on the dashboard.
///
/// Layout (from Figma):
///   Recent Activity
///   ┌──────────────────────────────────┐
///   │ 💵 Ronit added ₹10000 for Hotel │
///   │    2h ago                        │
///   └──────────────────────────────────┘
///   ┌──────────────────────────────────┐
///   │ 📷 Sarim shared 12 photos       │
///   │    5h ago                        │
///   └──────────────────────────────────┘
///   ...
///
/// Renders a vertical list of [ActivityTile] widgets from the
/// provided [activities] list. Displays a placeholder message
/// when the list is empty.
class ActivityList extends StatelessWidget {
  /// List of activity models to display.
  final List<ActivityModel> activities;

  const ActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section heading ────────────────────────────────────────
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212022),
          ),
        ),
        const SizedBox(height: 12),

        // ── Activity tiles or empty state ──────────────────────────
        if (activities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No recent activity',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8B8893),
                ),
              ),
            ),
          )
        else
          ...activities.asMap().entries.map((entry) {
            return Padding(
              // Add spacing between tiles (not after the last one)
              padding: EdgeInsets.only(
                bottom: entry.key < activities.length - 1 ? 12 : 0,
              ),
              child: ActivityTile(activity: entry.value),
            );
          }),
      ],
    );
  }
}
