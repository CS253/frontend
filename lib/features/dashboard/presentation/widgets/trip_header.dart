import 'package:flutter/material.dart';

/// Dashboard header widget displaying the current trip label and trip name.
///
/// Layout (from Figma):
///   [← BackButton]    Current Trip    [⋯ Options]
///                    The Lyaari Trip
///
/// This widget is purely presentational — it receives all data via
/// constructor parameters and contains no business logic.
class TripHeader extends StatelessWidget {
  /// The name of the current trip (e.g. "The Lyaari Trip").
  final String tripName;

  /// Callback when the back button is pressed.
  final VoidCallback? onBackPressed;

  /// Callback when the options (more) button is pressed.
  final VoidCallback? onOptionsPressed;

  const TripHeader({
    super.key,
    required this.tripName,
    this.onBackPressed,
    this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Centered trip info ─────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF8B8893),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Current Trip',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B8893),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                tripName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212022),
                ),
              ),
            ],
          ),

          // ── Left/Right action buttons ──────────────────────────────
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF212022), size: 20),
              onPressed: onBackPressed,
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.more_horiz, color: Color(0xFF212022)),
              onPressed: onOptionsPressed,
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
