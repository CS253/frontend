import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/models/photo_model.dart';
import '../providers/gallery_provider.dart';
import '../screens/full_photo_screen.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;

  const PhotoCard({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GalleryProvider>();
    final isSelected = provider.selectedPhotoIds.contains(photo.id);
    final inSelectionMode = provider.isSelectionMode;

    return GestureDetector(
      onLongPress: () {
        provider.toggleSelection(photo.id);
      },
      onTap: () {
        if (inSelectionMode) {
          provider.toggleSelection(photo.id);
        } else {
          final index = provider.photos.indexWhere((p) => p.id == photo.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullPhotoScreen(initialIndex: index == -1 ? 0 : index),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9.66),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16.11,
              offset: const Offset(0, 3.22),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9.66),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Remote Image with Hero
              Hero(
                tag: 'photo_${photo.id}',
                child: photo.localPath != null
                    ? Image.file(
                        File(photo.localPath!),
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: photo.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFE0E0E0),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFE0E0E0),
                          child: const Center(
                            child: Icon(Icons.error_outline, color: Colors.grey),
                          ),
                        ),
                      ),
              ),

              // 2. Linear Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.0), // ~0% at top
                        Colors.black.withValues(alpha: 0.6), // ~60% at bottom
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Selection Checkbox Overlay
              if (inSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.blue : Colors.white.withValues(alpha: 0.5),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : const SizedBox(width: 16, height: 16),
                  ),
                ),

              // 4. Details overlaid on the image
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photo.authorName,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
