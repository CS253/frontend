import 'package:flutter/material.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';

/// Trip info card displaying days remaining, trip emoji badge,
/// and an overlapping row of participant avatars.
///
/// Layout (from Figma):
///   ┌──────────────────────────────────────┐
///   │  Trip starts in            [♠️]      │
///   │  5 Days                              │
///   │                                      │
///   │  😊 😎 🤗 😄  +2 travelers           │
///   └──────────────────────────────────────┘
///
/// This widget is purely presentational.
class ParticipantRow extends StatelessWidget {
  /// Current trip data for the info card header.
  final TripModel trip;

  /// List of participants to display as avatar bubbles.
  final List<ParticipantModel> participants;

  /// Maximum number of avatars to show before "+N travelers" text.
  final int maxVisibleAvatars;

  const ParticipantRow({
    super.key,
    required this.trip,
    required this.participants,
    this.maxVisibleAvatars = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC1EAFF), Color(0xFFD9F0FC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.1),
            blurRadius: 13.6,
            offset: const Offset(0, 4),
            spreadRadius: -6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // ── Top row: days remaining + emoji badge ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip starts in',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0x99212022),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trip.daysRemaining} Days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212022),
                      ),
                    ),
                  ],
                ),
              ),
              // Emoji badge in frosted container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF262F40).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    trip.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Bottom row: participant avatars ───────────────────────
          _buildAvatarRow(),
        ],
      ),
    );
  }

  /// Builds the overlapping avatar row with a "+N travelers" label.
  Widget _buildAvatarRow() {
    final visible = participants.take(maxVisibleAvatars).toList();
    final remaining = participants.length - visible.length;

    return Row(
      children: [
        // Overlapping emoji avatars
        ...visible.asMap().entries.map((entry) {
          final isLast = entry.key == visible.length - 1;
          final participant = entry.value;
          return Align(
            widthFactor: isLast ? 1.0 : 0.7,
            child: _buildEmojiAvatar(participant.emoji),
          );
        }),

        // "+N travelers" text
        if (remaining > 0) ...[
          const SizedBox(width: 8),
          Text(
            '+$remaining travelers',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xB3212022),
            ),
          ),
        ],
      ],
    );
  }

  /// Individual circular emoji avatar matching Figma spec.
  Widget _buildEmojiAvatar(String emoji) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 3),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 11))),
    );
  }
}
