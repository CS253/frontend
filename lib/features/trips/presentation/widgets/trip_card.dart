import 'package:flutter/material.dart';
import '../../../dashboard/presentation/screens/main_screen.dart';

class TripCard extends StatelessWidget {
  final BuildContext parentContext;
  final String title;
  final String location;
  final String date;
  final String imageUrl;
  final double top;
  final double? left;
  final double? right;
  final bool isRightAligned;

  const TripCard({
    super.key,
    required this.parentContext,
    required this.title,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.top,
    this.left,
    this.right,
    this.isRightAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRightAligned) _buildCardInfo(),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (!isRightAligned) _buildCardInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    return Container(
      width: 140,
      padding: EdgeInsets.only(
        left: isRightAligned ? 0 : 12,
        right: isRightAligned ? 12 : 0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF5FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF282828),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF6A6A6A)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: Color(0xFF6A6A6A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 10, color: Color(0xFF6A6A6A)),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: Color(0xFF6A6A6A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    var path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.8, size.height * 0.6);
    path.quadraticBezierTo(size.width * 1.1, size.height * 0.8, size.width * 0.5, size.height);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
