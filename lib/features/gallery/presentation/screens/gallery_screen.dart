import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';

import '../providers/gallery_provider.dart';
import '../widgets/photo_card.dart';

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
    // Fetch photos on init
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDEDED), width: 0.8),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                right: 16.0,
                top: 22.0,
                bottom: 8.0,
              ),
              child: inSelectionMode
                  ? _buildSelectionHeader(provider)
                  : _buildStandardHeader(provider),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildGrid(provider),
          if (!inSelectionMode)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(child: _buildAddButton()),
            ),
        ],
      ),
    );
  }

  Widget _buildStandardHeader(GalleryProvider provider) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF212022), size: 20),
          onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Color(0xFF212022), size: 24),
          onPressed: () {
            context.findRootAncestorStateOfType<ScaffoldState>()?.openEndDrawer();
          },
        ),
      ],
    );
  }

  Widget _buildSelectionHeader(GalleryProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF212022)),
              onPressed: () {
                provider.clearSelection();
              },
            ),
            const SizedBox(width: 8),
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
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            provider.deleteSelected();
          },
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ).copyWith(bottom: 100),
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
