import 'package:flutter/material.dart';
import 'package:travelly/features/dashboard/data/models/activity_model.dart';

/// A single activity feed tile displaying an emoji icon,
/// description text, and relative timestamp.
///
/// Layout (from Figma):
///   ┌────────────────────────────────────────┐
///   │ [💵]  Ronit added ₹10000 for Hotel    │
///   │        2h ago                          │
///   └────────────────────────────────────────┘
///
/// This widget receives a typed [ActivityModel] and uses its
/// computed properties ([emoji], [displayText], [timeAgo]).
class ActivityTile extends StatelessWidget {
  /// The activity model containing all display data.
  final ActivityModel activity;

  const ActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ── Emoji icon badge ──────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD9F0FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                activity.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Text content ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.displayText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212022),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.timeAgo,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8B8893),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
