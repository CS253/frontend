// =============================================================================
// My Trips Screen — Dashboard showing the user's trip list.
//
// Uses TripsProvider for trip data instead of hardcoded cards.
// The UI layout remains identical to the original Figma design.
//
// Data Flow: MyTripsScreen → TripsProvider.loadTrips() → TripsRepository → TripsService
//
// Previously: Hardcoded 5 TripCard widgets with static data.
// Now: Provider-driven list loaded from TripsProvider.trips.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../trips/presentation/providers/trips_provider.dart';
import 'package:travelly/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelly/core/constants/route_constants.dart';
import '../widgets/trip_card.dart';
import '../widgets/create_trip_dialog.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  @override
  void initState() {
    super.initState();
    // Load trips when screen initializes — this calls the provider
    // which calls the repository → service → API (or mock).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripsProvider>().loadTrips(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
          children: [
            // Background Design — subtle dots pattern
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPatternPainter(),
              ),
            ),
            
            Column(
              children: [
                // Custom App Bar — now uses TripsProvider for trip count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/launch_icon.png',
                            height: 28,
                            width: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.location_on, color: Color(0xFF6BB5E5)),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'My Trips',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF282828),
                            ),
                          ),
                        ],
                      ),
                      // Trip count badge — dynamically reflects provider state
                      Consumer<TripsProvider>(
                        builder: (context, tripsProvider, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBCE3F7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_border, size: 14, color: Color(0xFF4A4A4A)),
                                const SizedBox(width: 4),
                                Text(
                                  '${tripsProvider.tripCount} Trips',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF282828), size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) async {
                          if (value == 'account_settings') {
                            Navigator.of(context, rootNavigator: true).pushNamed(RouteConstants.accountSettings);
                          } else if (value == 'logout') {
                            await context.read<AuthProvider>().logout();
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                                RouteConstants.login,
                                (route) => false,
                              );
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'account_settings',
                            height: 40,
                            child: Row(
                              children: [
                                Icon(Icons.settings_outlined, color: Color(0xFF4A4A4A), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Account Settings', 
                                  style: TextStyle(
                                    color: Color(0xFF4A4A4A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'logout',
                            height: 40,
                            child: Row(
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Logout', 
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Content — Provider-driven trip list
                Expanded(
                  child: Consumer<TripsProvider>(
                    builder: (context, tripsProvider, _) {
                      // Loading state
                      if (tripsProvider.isLoading && tripsProvider.trips.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6BB5E5)),
                          ),
                        );
                      }

                      // Error state
                      if (tripsProvider.errorMessage != null && tripsProvider.trips.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Color(0xFFB0B0B0)),
                              const SizedBox(height: 16),
                              Text(
                                tripsProvider.errorMessage ?? 'Failed to load trips',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  color: Color(0xFF828282),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => tripsProvider.loadTrips(refresh: true),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Empty state
                      if (tripsProvider.trips.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flight_takeoff, size: 64, color: Color(0xFFB0B0B0)),
                              SizedBox(height: 16),
                              Text(
                                'No trips yet',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF828282),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap + to create your first trip!',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFFB0B0B0),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Trip cards — dynamically generated from provider data
                      final trips = tripsProvider.trips;
                      final cardPositions = _calculateCardPositions(trips.length);

                      return SingleChildScrollView(
                        child: SizedBox(
                          height: (trips.length * 170.0).clamp(400, double.infinity),
                          child: Stack(
                            children: [
                              // Abstract background curve
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: CustomPaint(
                                  painter: TripTimelinePainter(tripCount: trips.length),
                                ),
                              ),
                              
                              // Trip cards from provider data
                              ...List.generate(trips.length, (index) {
                                final trip = trips[index];
                                final position = cardPositions[index];
                                final isRight = index % 2 != 0;

                                return TripCard(
                                  parentContext: context,
                                  title: trip.name,
                                  location: trip.destination,
                                  date: trip.formattedDateRange,
                                  imageUrl: trip.coverImage ?? '',
                                  top: position,
                                  left: isRight ? null : 20,
                                  right: isRight ? 20 : null,
                                  isRightAligned: isRight,
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            builder: (context) => const CreateTripDialog(),
          );
        },
        backgroundColor: const Color(0xFF9DD4F9),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  /// Calculates vertical positions for trip cards in the staggered layout.
  List<double> _calculateCardPositions(int count) {
    return List.generate(count, (index) => 30.0 + (index * 170.0));
  }
}

// =============================================================================
// Trip Timeline Painter — Draws curved path connecting trip nodes.
// =============================================================================
class TripTimelinePainter extends CustomPainter {
  final int tripCount;

  TripTimelinePainter({required this.tripCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (tripCount < 2) return;

    final paint = Paint()
      ..color = const Color(0xFF6BB5E5).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    const double verticalSpacing = 170.0;
    const double startTop = 30.0;
    const double nodeRadius = 45.0; 
    const double horizontalMargin = 20.0;
    
    final double leftX = horizontalMargin + nodeRadius;
    final double rightX = size.width - horizontalMargin - nodeRadius;

    for (int i = 0; i < tripCount - 1; i++) {
      final bool isCurrentRight = i % 2 != 0;
      final bool isNextRight = (i + 1) % 2 != 0;

      final double currentX = isCurrentRight ? rightX : leftX;
      final double currentY = startTop + (i * verticalSpacing) + nodeRadius;
      
      final double nextX = isNextRight ? rightX : leftX;
      final double nextY = startTop + ((i + 1) * verticalSpacing) + nodeRadius;

      if (i == 0) {
        path.moveTo(currentX, currentY);
      }

      final double midY = (currentY + nextY) / 2;
      
      path.cubicTo(
        currentX, midY,
        nextX, midY,
        nextX, nextY,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TripTimelinePainter oldDelegate) {
    return oldDelegate.tripCount != tripCount;
  }
}

// =============================================================================
// Background Pattern Painter — Draws subtle decorative patterns.
// =============================================================================
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6BB5E5).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    const double spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw small dots
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
