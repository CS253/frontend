import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/gallery_provider.dart';
import '../widgets/photo_card.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gallery',
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF212022), // lovable.dev/Baltic Sea
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '6 photos shared',
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF8B8893), // lovable.dev/Mountain Mist
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz, color: Colors.black, size: 24),
                ],
              ),
            ),
            
            // Grid
            Expanded(
              child: Consumer<GalleryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (provider.error != null) {
                    return Center(
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  
                  if (provider.photos.isEmpty) {
                    return const Center(child: Text("No photos available"));
                  }
                  
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 170 / 191.52, // From Figma layout_CCOCAC dimensions
                    ),
                    itemCount: provider.photos.length,
                    itemBuilder: (context, index) {
                      return PhotoCard(photo: provider.photos[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Add Media FAB
      floatingActionButton: Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Future upload logic triggers here
          },
          backgroundColor: const Color(0xFF000000), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9159.92),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: Text(
            'Add Media',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12, 
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

