import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../providers/gallery_provider.dart';

class FullPhotoScreen extends StatefulWidget {
  final int initialIndex;

  const FullPhotoScreen({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<FullPhotoScreen> createState() => _FullPhotoScreenState();
}

class _FullPhotoScreenState extends State<FullPhotoScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _deleteCurrentPhoto(BuildContext context, GalleryProvider provider) {
    if (provider.photos.isEmpty) return;

    final photoToDelete = provider.photos[_currentIndex];
    
    // We update local index logic before the UI rebuilds from provider
    if (_currentIndex == provider.photos.length - 1 && _currentIndex > 0) {
      // If we are deleting the last item and there are more before it, shift back
      _currentIndex--;
    }
    
    provider.deletePhoto(photoToDelete.id);

    // If that was the last photo in the entire list, pop the screen
    if (provider.photos.isEmpty) {
      Navigator.of(context).pop();
    } else {
      // Otherwise, the PageView will rebuild naturally at the same/shifted index
      setState(() {}); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GalleryProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _deleteCurrentPhoto(context, provider),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: provider.photos.isEmpty
          ? const SizedBox() // Empty state flashes briefly before pop
          : PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: provider.photos.length,
              itemBuilder: (context, index) {
                final photo = provider.photos[index];
                final isCurrent = _currentIndex == index;
                
                Widget imageWidget = photo.localPath != null
                    ? Image.file(
                        File(photo.localPath!),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : CachedNetworkImage(
                        imageUrl: photo.imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 50,
                        ),
                      );

                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  clipBehavior: Clip.none,
                  child: isCurrent 
                    ? Hero(
                        tag: 'photo_${photo.id}',
                        child: imageWidget,
                      )
                    : imageWidget,
                );
              },
            ),
    );
  }
}

