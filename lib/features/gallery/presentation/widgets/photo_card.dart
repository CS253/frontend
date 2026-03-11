import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/photo_model.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;

  const PhotoCard({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffEDEDED), // lovable.dev/Gallery (loader background)
        borderRadius: BorderRadius.circular(9.66), // 9.656249046325684px
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(38, 47, 64, 0.08),
            blurRadius: 16.09,
            offset: Offset(0, 3.22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.66),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: photo.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error, color: Colors.grey),
              ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            // Text and Button Overlay
            Positioned(
              bottom: 15,
              left: 6.44,
              right: 6.44,
              child: Text(
                photo.authorName,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 9.66,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
