import 'package:flutter/material.dart';

/// Dashboard header widget displaying the current trip label and trip name.
///
/// Layout: Centered column with "Current Trip" and the trip name.
///
/// This widget is purely presentational — it receives all data via
/// constructor parameters and contains no business logic.
class TripHeader extends StatelessWidget {
  /// The name of the current trip (e.g. "The Lyaari Trip").
  final String tripName;

  const TripHeader({
    super.key,
    required this.tripName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
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
    );
  }
}
