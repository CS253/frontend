import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/route_constants.dart';

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
          // Navigate using named routes instead of direct widget import
          Navigator.pushNamed(
            parentContext,
            RouteConstants.dashboard,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRightAligned) _buildCardInfo(),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    if (imageUrl.startsWith('http')) {
                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFF3F3F3),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFF3F3F3),
                          child: const Icon(Icons.broken_image, color: Color(0xFFB0B0B0)),
                        ),
                      );
                    } else if (imageUrl.isNotEmpty) {
                      // Attempt to show local file or fallback
                      return Image.network(
                        imageUrl, // This might still fail but we can't easily check for File Existence across platforms without more logic
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFBCE3F7),
                          child: const Icon(Icons.location_on, color: Color(0xFF6BB5E5)),
                        ),
                      );
                    } else {
                      // Fallback for no image
                      return Container(
                        color: const Color(0xFFBCE3F7),
                        child: const Icon(Icons.location_on, color: Color(0xFF6BB5E5)),
                      );
                    }
                  },
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


