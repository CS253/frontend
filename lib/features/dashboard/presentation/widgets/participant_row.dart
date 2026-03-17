import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';

// =============================================================================
// ParticipantRow — Trip info card on the dashboard.
//
// Displays:
//   • Cover photo background (if uploaded) or trip-type default gradient
//   • Days remaining counter
//   • Trip type emoji badge
//   • Overlapping participant avatars
//
// Cover Photo Logic:
//   1. If trip.coverImage is set and is a network URL → show CachedNetworkImage
//   2. If trip.coverImage is set and is a local file  → show Image.file
//   3. If no cover image → show a trip-type themed gradient
//
// Trip-type gradient mapping:
//   Beach   → sandy (#FFE4B5 → #F4A460)
//   Mountain → alpine (#A8D5BA → #4A8C6F)
//   City    → urban (#B0C4DE → #6A89CC)
//   Nature  → forest (#C8E6C9 → #66BB6A)
//   Island  → tropical (#B2EBF2 → #26C6DA)
//   Other   → default blue (#C1EAFF → #D9F0FC)
// =============================================================================

/// Trip info card displaying days remaining, trip type emoji badge,
/// and an overlapping row of participant avatars.
///
/// Background shows the trip's cover photo (if uploaded) or a themed
/// gradient based on the trip type.
///
/// Layout:
///   ┌──────────────────────────────────────┐
///   │  [Cover Photo / Trip-Type Gradient]  │
///   │  Trip starts in            [🏖️]      │
///   │  5 Days                              │
///   │                                      │
///   │  😊 😎 🤗 😄  +2 travelers           │
///   └──────────────────────────────────────┘
///
/// Tapping this card opens the [TripDetailsDialog] via [onTap].
class ParticipantRow extends StatelessWidget {
  /// Current trip data for the info card header.
  final TripModel trip;

  /// List of participants to display as avatar bubbles.
  final List<ParticipantModel> participants;

  /// Maximum number of avatars to show before "+N travelers" text.
  final int maxVisibleAvatars;

  /// Callback when the entire card is tapped.
  /// Used to open the Trip Details floating dialog.
  final VoidCallback? onTap;

  const ParticipantRow({
    super.key,
    required this.trip,
    required this.participants,
    this.maxVisibleAvatars = 4,
    this.onTap,
  });

  /// Returns the gradient colors for a given trip type.
  /// Used as fallback when no cover photo is uploaded.
  List<Color> _getGradientForTripType(String tripType) {
    switch (tripType) {
      case 'Beach':
        return [const Color(0xFFFFE4B5), const Color(0xFFF4A460)];
      case 'Mountain':
        return [const Color(0xFFA8D5BA), const Color(0xFF4A8C6F)];
      case 'City':
        return [const Color(0xFFB0C4DE), const Color(0xFF6A89CC)];
      case 'Nature':
        return [const Color(0xFFC8E6C9), const Color(0xFF66BB6A)];
      case 'Island':
        return [const Color(0xFFB2EBF2), const Color(0xFF26C6DA)];
      default:
        return [const Color(0xFFC1EAFF), const Color(0xFFD9F0FC)];
    }
  }

  /// Returns the emoji icon for a given trip type.
  String _getEmojiForTripType(String tripType) {
    switch (tripType) {
      case 'Beach':
        return '🏖️';
      case 'Mountain':
        return '⛰️';
      case 'City':
        return '🏙️';
      case 'Nature':
        return '🌿';
      case 'Island':
        return '🏝️';
      default:
        return '🌍';
    }
  }

  /// Whether the trip has a valid cover image (network or local file).
  bool get _hasCoverImage =>
      trip.coverImage != null && trip.coverImage!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
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
        child: Stack(
          children: [
            // ── Background: cover photo or trip-type gradient ──────────
            Positioned.fill(
              child: _buildBackground(),
            ),

            // ── Dark overlay for text readability on photos ───────────
            if (_hasCoverImage)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Content ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // ── Top row: days remaining + emoji badge ──────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip starts in',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _hasCoverImage
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : const Color(0x99212022),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${trip.daysRemaining} Days',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _hasCoverImage
                                    ? Colors.white
                                    : const Color(0xFF212022),
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
                          color: _hasCoverImage
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.8),
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
                            trip.emoji.isNotEmpty
                                ? trip.emoji
                                : _getEmojiForTripType(trip.tripType),
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Bottom row: participant avatars ────────────────
                  _buildAvatarRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the card background: cover photo or trip-type gradient.
  Widget _buildBackground() {
    // 1. Cover photo is available
    if (_hasCoverImage) {
      final coverImage = trip.coverImage!;

      // Network image (URL from backend)
      if (coverImage.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: coverImage,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildGradientBackground(),
          errorWidget: (context, url, error) => _buildGradientBackground(),
        );
      }

      // Local file image (just uploaded, not yet synced)
      return Image.file(
        File(coverImage),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildGradientBackground(),
      );
    }

    // 2. No cover photo — use trip-type themed gradient
    return _buildGradientBackground();
  }

  /// Trip-type themed gradient fallback.
  Widget _buildGradientBackground() {
    final gradientColors = _getGradientForTripType(trip.tripType);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: _hasCoverImage
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xB3212022),
            ),
          ),
        ],
      ],
    );
  }

  /// Individual circular emoji avatar.
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
