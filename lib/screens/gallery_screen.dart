import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _buildPhotoGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddMediaFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.88, vertical: 9.66),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEDED), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
            onPressed: () {
              // Usually pop, but Since it's a tab, maybe do nothing or switch tab
            },
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gallery',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF212022),
                  height: 1.38,
                ),
              ),
              Text(
                '6 photos shared',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8B8893),
                  height: 1.29,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final List<Map<String, dynamic>> photos = [
      {
        'image': 'assets/images/gallery/photo_1-56586a.png',
        'name': 'Rahul',
        'likes': '5',
      },
      {
        'image': 'assets/images/gallery/photo_2-56586a.png',
        'name': 'Priya',
        'likes': '8',
      },
      {
        'image': 'assets/images/gallery/photo_3-56586a.png',
        'name': 'Amit',
        'likes': '3',
      },
      {
        'image': 'assets/images/gallery/photo_4-56586a.png',
        'name': 'You',
        'likes': '6',
      },
      {
        'image': 'assets/images/gallery/photo_5-56586a.png',
        'name': 'Rahul',
        'likes': '4',
      },
      {
        'image': 'assets/images/gallery/photo_6-56586a.png',
        'name': 'Priya',
        'likes': '7',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _buildPhotoCard(photo['image'], photo['name'], photo['likes']);
      },
    );
  }

  Widget _buildPhotoCard(String imagePath, String name, String likes) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.66),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.08),
            offset: const Offset(0, 3.22),
            blurRadius: 16.09,
            spreadRadius: -3.22,
          ),
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay for text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(9.66),
                  bottomRight: Radius.circular(9.66),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Text and Icon
          Positioned(
            left: 8.0,
            bottom: 8.0,
            right: 8.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likes,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMediaFab() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD297),
        borderRadius: BorderRadius.circular(9159.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38332E).withValues(alpha: 0.12),
            offset: const Offset(0, 7.33),
            blurRadius: 27.48,
            spreadRadius: -5.50,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9159.9),
          onTap: () {
            // Add Media action
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 13.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add,
                  color: Color(0xFF534027),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Media',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.66,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF534027),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
