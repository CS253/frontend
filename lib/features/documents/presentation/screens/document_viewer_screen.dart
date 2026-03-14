import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF212022),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF212022)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFEDEDED),
            height: 0.8,
          ),
        ),
      ),
      body: const PDF(
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
      ).fromUrl(
        url,
        placeholder: (double progress) => Center(
          child: CircularProgressIndicator(
            value: progress / 100,
            color: const Color(0xFF9FDFCA),
          ),
        ),
        errorWidget: (dynamic error) => Center(
           child: Text(
             error.toString(),
             textAlign: TextAlign.center,
             style: const TextStyle(color: Colors.red),
           ),
        ),
      ),
    );
  }
}
