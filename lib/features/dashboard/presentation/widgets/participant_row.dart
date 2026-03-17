import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';

// =============================================================================
// ParticipantRow — Premium trip info card on the dashboard.
//
// Visual Design:
//   • Cover photo or stock fallback as background
//   • Always-present dark gradient overlay ensures text readability
//   • Frosted-glass pill for destination at the top
//   • Bold trip duration headline
//   • Glassmorphic info bar with date range + member count at the bottom
//
// Fallback Logic:
//   1. Custom Cover Photo: User-uploaded (network or local file)
//   2. Stock Photo: High-quality Unsplash image based on tripType
//   3. Gradient fallback: Last resort if network fails
//
// Layout:
//   ┌──────────────────────────────────────┐
//   │  📍 Lahore, Pakistan        (pill)   │
//   │                                      │
//   │  10 Days Trip                        │
//   │                                      │
//   │  ┌─[glass bar]───────────────────┐   │
//   │  │ 📅 Apr 10 – Apr 20  👥 6     │   │
//   │  └───────────────────────────────┘   │
//   └──────────────────────────────────────┘
// =============================================================================

/// Premium trip info card with dynamic background (Cover photo or Stock fallback),
/// destination pill, trip duration, and glassmorphic info bar.
///
/// Text is always white with a dark gradient overlay applied regardless
/// of the background, ensuring premium aesthetics and consistent readability.
///
/// Tapping opens the [TripDetailsDialog] via [onTap].
class ParticipantRow extends StatelessWidget {
  final TripModel trip;
  final List<ParticipantModel> participants;
  final int maxVisibleAvatars;
  final VoidCallback? onTap;

  const ParticipantRow({
    super.key,
    required this.trip,
    required this.participants,
    this.maxVisibleAvatars = 4,
    this.onTap,
  });

  // ── Stock Photo Mapping ─────────────────────────────────────────────

  /// Defines high-quality stock photo URLs for each trip type.
  /// Used as a fallback when no custom cover photo is uploaded.
  String _getStockPhotoForTripType(String tripType) {
    switch (tripType) {
      case 'Beach':
        return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80';
      case 'Mountain':
        return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80';
      case 'City':
        return 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=800&q=80';
      case 'Nature':
        return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80';
      case 'Island':
        return 'https://images.unsplash.com/photo-1559128192-d7379f65c711?auto=format&fit=crop&w=800&q=80';
      case 'Other':
      default:
        return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=800&q=80';
    }
  }

  // ── Gradient Mapping (Last resort fallback) ──────────────────────────

  List<Color> _getGradientForTripType(String tripType) {
    switch (tripType) {
      case 'Beach':
        return [const Color(0xFFF9D29D), const Color(0xFFE8875C)];
      case 'Mountain':
        return [const Color(0xFF8ECFAB), const Color(0xFF3B7A5A)];
      case 'City':
        return [const Color(0xFF94B3D4), const Color(0xFF4A6FA5)];
      case 'Nature':
        return [const Color(0xFFA5D6A7), const Color(0xFF388E3C)];
      case 'Island':
        return [const Color(0xFF80DEEA), const Color(0xFF00897B)];
      default:
        return [const Color(0xFF90CAF9), const Color(0xFF42A5F5)];
    }
  }

  // ── Computed properties ─────────────────────────────────────────────

  bool get _hasCoverImage =>
      trip.coverImage != null && trip.coverImage!.isNotEmpty;

  /// Trip duration in days from start → end date.
  int get _tripDurationDays {
    final start = DateTime.tryParse(trip.startDate);
    final end = DateTime.tryParse(trip.endDate);
    if (start != null && end != null) {
      return end.difference(start).inDays;
    }
    return trip.daysRemaining;
  }

  /// "Apr 10" format.
  String _formatShortDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF262F40).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Layer 1: Background photo (Cover or Stock) ───────────
            _buildBackground(),

            // ── Layer 2: Dark gradient overlay (always present) ───
            // Ensures white text is readable on ANY background.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.60),
                  ],
                ),
              ),
            ),

            // ── Layer 3: Content ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top: destination pill ────────────────────────
                  _buildDestinationPill(),

                  const Spacer(),

                  // ── Middle: trip duration ────────────────────────
                  Text(
                    '$_tripDurationDays Days Trip',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Bottom: glassmorphic info bar ────────────────
                  _buildInfoBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ─────────────────────────────────────────────────────

  /// Frosted glass pill showing 📍 destination at the top of the card.
  Widget _buildDestinationPill() {
    final destination = trip.destination.isNotEmpty
        ? trip.destination
        : trip.location.isNotEmpty
            ? trip.location
            : 'Unknown';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                size: 13,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  destination,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Glassmorphic bar at the bottom showing date range and member count.
  Widget _buildInfoBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Date range
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatShortDate(trip.startDate)} – ${_formatShortDate(trip.endDate)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),

              const Spacer(),

              // Divider dot
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),

              const Spacer(),

              // Member count
              const Icon(
                Icons.people_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                '${participants.length} ${participants.length == 1 ? 'member' : 'members'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Background builders ─────────────────────────────────────────────

  /// Builds the background layer:
  /// 1. User specified Cover Photo (Custom)
  /// 2. Stock Photo Fallback based on tripType (Dynamic)
  /// 3. Gradient Fallback (Last resort)
  Widget _buildBackground() {
    // 1. Check for user-uploaded cover photo
    if (_hasCoverImage) {
      final coverImage = trip.coverImage!;

      if (coverImage.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: coverImage,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildStockFallback(),
          errorWidget: (context, url, error) => _buildStockFallback(),
        );
      }

      return Image.file(
        File(coverImage),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildStockFallback(),
      );
    }

    // 2 & 3. Fallback to Stock Photo or Gradient
    return _buildStockFallback();
  }

  /// Builds the stock photo fallback based on tripType.
  /// Falls back to gradient if network image fails.
  Widget _buildStockFallback() {
    final stockUrl = _getStockPhotoForTripType(trip.tripType);

    return CachedNetworkImage(
      imageUrl: stockUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildGradientBackground(),
      errorWidget: (context, url, error) => _buildGradientBackground(),
    );
  }

  /// Last resort gradient fallback.
  Widget _buildGradientBackground() {
    final gradientColors = _getGradientForTripType(trip.tripType);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
    );
  }
}
