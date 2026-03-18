import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gallery_provider.dart';
import '../widgets/photo_card.dart';
import '../../../../core/widgets/glass_back_button.dart';

class GalleryScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const GalleryScreen({super.key, this.onBackPressed});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryProvider>().fetchPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GalleryProvider>();
    final inSelectionMode = provider.isSelectionMode;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildGrid(provider),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: _buildGlassyHeader(provider, inSelectionMode),
          ),
          if (!inSelectionMode)
            Positioned(
              bottom: 70, // lower
              left: 0,
              right: 0,
              child: Center(child: _buildAddButton()),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassyHeader(GalleryProvider provider, bool inSelectionMode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: inSelectionMode
            ? _buildSelectionHeaderContent(provider)
            : _buildStandardHeaderContent(provider),
        ),
      ),
    );
  }

  Widget _buildStandardHeaderContent(GalleryProvider provider) {
    return Row(
      children: [
        GlassBackButton(onPressed: widget.onBackPressed),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212022),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${provider.photos.length} photos shared',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8B8893),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionHeaderContent(GalleryProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                provider.clearSelection();
              },
              child: const Icon(Icons.close, color: Color(0xFF212022)),
            ),
            const SizedBox(width: 12),
            Text(
              '${provider.selectedPhotoIds.length} Selected',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212022),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            provider.deleteSelected();
          },
          child: const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildGrid(GalleryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (provider.photos.isEmpty) {
      return const Center(child: Text("No photos available"));
    }

    return GridView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 120,
        bottom: 120, // ample space for fab
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 170 / 191.52,
      ),
      itemCount: provider.photos.length,
      itemBuilder: (context, index) {
        return PhotoCard(photo: provider.photos[index]);
      },
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 209, 150, 1),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38332E).withValues(alpha: 0.12),
            blurRadius: 27.5,
            offset: const Offset(0, 7.3),
            spreadRadius: -5.5,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: GestureDetector(
        onTap: () {
          context.read<GalleryProvider>().pickAndUploadMedia();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (context.watch<GalleryProvider>().isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
            ] else ...[
              const Icon(Icons.add, size: 20, color: Color(0xFF1A1A1A)),
              const SizedBox(width: 8),
            ],
            const Text(
              'Add Media',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
