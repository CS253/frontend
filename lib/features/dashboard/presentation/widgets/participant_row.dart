import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:travelly/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';
import 'package:travelly/features/dashboard/data/models/weather_model.dart';
import 'package:travelly/features/dashboard/data/services/weather_service.dart';


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
class ParticipantRow extends StatefulWidget {
  final TripModel trip;
  final List<ParticipantModel> participants;
  final int maxVisibleAvatars;
  final VoidCallback? onTap;
  /// Overrides participants.length in the info bar when the real list is still loading.
  /// Typically the membersCount from the TripCache shell (known before any fetch).
  final int? memberCountOverride;

  const ParticipantRow({
    super.key,
    required this.trip,
    required this.participants,
    this.maxVisibleAvatars = 4,
    this.onTap,
    this.memberCountOverride,
  });

  @override
  State<ParticipantRow> createState() => _ParticipantRowState();
}

class _ParticipantRowState extends State<ParticipantRow> {
  final PageController _pageController = PageController(initialPage: 1000);
  int _currentPage = 0;

  // Weather State
  bool _isLoadingWeather = true;
  WeatherData? _weatherData;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  @override
  void didUpdateWidget(covariant ParticipantRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousDestination = oldWidget.trip.destination.isNotEmpty
        ? oldWidget.trip.destination
        : oldWidget.trip.location;
    final nextDestination = widget.trip.destination.isNotEmpty
        ? widget.trip.destination
        : widget.trip.location;

    if (previousDestination != nextDestination) {
      setState(() {
        _isLoadingWeather = true;
        _weatherData = null;
      });
      _loadWeather();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    final destination = widget.trip.destination.isNotEmpty 
        ? widget.trip.destination 
        : widget.trip.location;
        
    if (destination.isEmpty) {
      if (mounted) setState(() => _isLoadingWeather = false);
      return;
    }

    final data = await WeatherService().getWeather(destination);
    
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    }
  }

  // ── Stock Photo Mapping ─────────────────────────────────────────────

  /// Defines high-quality stock photo URLs for each trip type.
  /// Used as a fallback when no custom cover photo is uploaded.
  String _getStockPhotoForTripType(String tripType) {
    switch (tripType) {
      case 'Beach':
        return 'assets/images/Beach.png';
      case 'Mountain':
        return 'assets/images/Mountain.png';
      case 'City':
        return 'assets/images/City.png';
      case 'Nature':
        return 'assets/images/Nature.png';
      case 'Island':
        return 'assets/images/Island.png';
      case 'Other':
      default:
        return 'assets/images/Other.png';
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
      widget.trip.coverImage != null && widget.trip.coverImage!.isNotEmpty;

  /// Trip duration in days from start → end date.
  int get _tripDurationDays {
    final start = DateTime.tryParse(widget.trip.startDate);
    final end = DateTime.tryParse(widget.trip.endDate);
    if (start != null && end != null) {
      return end.difference(start).inDays;
    }
    return widget.trip.daysRemaining;
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
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return GestureDetector(
      onTap: widget.onTap,
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

            // ── Layer 3: Swipeable Content (Vertical Infinite PageView) ──────────────
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: null, // Infinite scrolling
              onPageChanged: (index) {
                // Ensure page indicators update correctly (0 or 1)
                setState(() => _currentPage = index % 2);
              },
              itemBuilder: (context, index) {
                final pageIndex = index % 2;

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      // Clamp the value to [-1, 1] range to prevent overscaling
                      value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                    } else {
                      // Initial render fallback
                      final isInitial = index == _pageController.initialPage;
                      value = isInitial ? 1.0 : 0.8;
                    }

                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        // Fade out slightly when scaled down
                        opacity: value.clamp(0.5, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: pageIndex == 0 ? _buildTripInfoPage() : _buildWeatherPage(),
                );
              },
            ),

            // ── Layer 4: Vertical Page Indicators ───────────────────────────
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDotIndicator(0),
                  const SizedBox(height: 4),
                  _buildDotIndicator(1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _currentPage == index ? 16 : 6,
      width: 6,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? Colors.white 
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // ── Pages ───────────────────────────────────────────────────────────

  Widget _buildTripInfoPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
    );
  }

  Widget _buildWeatherPage() {
    final destination = widget.trip.destination.isNotEmpty
        ? widget.trip.destination
        : widget.trip.location.isNotEmpty
            ? widget.trip.location
            : 'Unknown';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: App-style header
          Row(
            children: [
              const Icon(Icons.cloud_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'Weather Forecast',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          // Location string clearly mapped to trip.location
          Text(
            destination,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          if (_isLoadingWeather)
            const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else if (_weatherData == null)
            Center(
              child: Text(
                'Weather unavailable\nfor this destination.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            )
          else
            // Weather Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left: Current Weather
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_weatherData!.currentTemp.round()}°',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _weatherData!.currentConditionIcon,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _weatherData!.currentConditionText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Right: Hourly Forecast (Next 4 hours)
                _buildHourlyForecast(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    if (_weatherData == null || _weatherData!.hourlyForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine current hour in the local timezone of the destination
    final now = DateTime.now().toUtc().add(Duration(seconds: _weatherData!.utcOffsetSeconds));
    
    // Find the next 4 hours
    final upcomingHourly = _weatherData!.hourlyForecast.where((h) {
      final hourTime = DateTime.tryParse(h.timeIso);
      if (hourTime == null) return false;
      return hourTime.isAfter(now.subtract(const Duration(hours: 1)));
    }).take(4).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: upcomingHourly.map((hour) {
              final isFirst = upcomingHourly.indexOf(hour) == 0;
              final time = DateTime.parse(hour.timeIso);
              
              return Padding(
                padding: EdgeInsets.only(left: isFirst ? 0 : 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isFirst ? 'Now' : '${time.hour}:00',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hour.conditionIcon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hour.temperature.round()}°',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ─────────────────────────────────────────────────────

  /// Frosted glass pill showing 📍 destination at the top of the card.
  Widget _buildDestinationPill() {
    final destination = widget.trip.destination.isNotEmpty
        ? widget.trip.destination
        : widget.trip.location.isNotEmpty
            ? widget.trip.location
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
                '${_formatShortDate(widget.trip.startDate)} – ${_formatShortDate(widget.trip.endDate)}',
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
              Builder(builder: (context) {
                // Use override (from cache shell) when the real list is still loading
                final count = widget.memberCountOverride ?? widget.participants.length;
                return Text(
                  '$count ${count == 1 ? 'member' : 'members'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                );
              }),
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
      final coverImage = widget.trip.coverImage!;

      if (coverImage.startsWith('http')) {
        final token = Provider.of<AuthProvider>(context, listen: false).token;
        return CachedNetworkImage(
          imageUrl: coverImage,
          httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
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
    final stockAsset = _getStockPhotoForTripType(widget.trip.tripType);

    return Image.asset(
      stockAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildGradientBackground(),
    );
  }

  /// Last resort gradient fallback.
  Widget _buildGradientBackground() {
    final gradientColors = _getGradientForTripType(widget.trip.tripType);
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
