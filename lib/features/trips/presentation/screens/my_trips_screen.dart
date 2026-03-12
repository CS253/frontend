import 'package:flutter/material.dart';
import '../widgets/trip_card.dart';
import '../widgets/create_trip_dialog.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Light background
      body: SafeArea(
        child: Stack(
          children: [
            // Background Pattern Placeholder (Could be an image asset in the future)
            Opacity(
              opacity: 0.05,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                itemBuilder: (context, index) {
                  List<IconData> icons = [
                    Icons.flight_takeoff,
                    Icons.explore_outlined,
                    Icons.map_outlined,
                    Icons.camera_alt_outlined,
                  ];
                  return Icon(icons[index % icons.length]);
                },
              ),
            ),
            
            Column(
              children: [
                // Custom App Bar
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBCE3F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star_border, size: 14, color: Color(0xFF4A4A4A)),
                            SizedBox(width: 4),
                            Text(
                              '5 Trips',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.menu, color: Color(0xFF282828), size: 28),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 800, // Fixed height for absolute positioned items
                      child: Stack(
                        children: [
                          // Abstract Background curve approximation (represented as an SVG/Image in Figma)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: CustomPaint(
                              painter: PathPainter(),
                            ),
                          ),
                          
                          // Cards
                          TripCard(
                            parentContext: context,
                            title: 'Santorini Dreams',
                            location: 'Santorini, Greece',
                            date: 'May 2024',
                            imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                            top: 30,
                            left: 20,
                          ),
                          TripCard(
                            parentContext: context,
                            title: 'Paris Escape',
                            location: 'Paris, France',
                            date: 'July 2024',
                            imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                            top: 200,
                            right: 20,
                            isRightAligned: true,
                          ),
                          TripCard(
                            parentContext: context,
                            title: 'Mountain Trek',
                            location: 'Swiss Alps',
                            date: 'June 2024',
                            imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                            top: 360,
                            left: 20,
                          ),
                          TripCard(
                            parentContext: context,
                            title: 'Jungle Safari',
                            location: 'Costa Rica',
                            date: 'March 2024',
                            imageUrl: 'https://images.unsplash.com/photo-1518182170546-076616fd6cbf?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                            top: 530,
                            right: 20,
                            isRightAligned: true,
                          ),
                          TripCard(
                            parentContext: context,
                            title: 'Beach Bliss',
                            location: 'Maldives',
                            date: 'January 2024',
                            imageUrl: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                            top: 700,
                            left: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.5),
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
}
