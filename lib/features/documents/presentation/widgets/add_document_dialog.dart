import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:travelly/core/widgets/emoji_picker_dialog.dart';
import 'package:travelly/core/widgets/keyboard_safe_dialog.dart';

/// Dialog shown when user taps "Add Document".
/// Includes a name field, emoji selector, description field,
/// upload area, and a Continue button.
class AddDocumentDialog extends StatefulWidget {
  const AddDocumentDialog({super.key});

  @override
  State<AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<AddDocumentDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedEmoji = '📄';
  String? _selectedFileName;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: KeyboardSafeDialog(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Add  Document',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF38332E),
                    letterSpacing: -0.38,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Name field ──────────────────────────────────────────
            Text(
              'Name*',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: const Color(0xFF38332E),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 42,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFCFAF8),
                  hintText: 'Train to Lyari',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: const Color(0xFF8A8075),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: Color(0xFFEBE7E0), width: 0.75),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 1),
                  ),
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: const Color(0xFF38332E),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Emoji + Description row ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Emoji selector box
                GestureDetector(
                  onTap: () async {
                    final emoji = await showEmojiPicker(context);
                    if (emoji != null) {
                      setState(() => _selectedEmoji = emoji);
                    }
                  },
                  child: Container(
                    width: 61,
                    height: 61,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF8),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Description field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description *',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: const Color(0xFF38332E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFCFAF8),
                            hintText: 'Train',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: const Color(0xFF8A8075),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(color: Color(0xFFEBE7E0), width: 0.75),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 1),
                            ),
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: const Color(0xFF38332E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Dashed upload area ──────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      _selectedFileName = result.files.single.name;
                    });
                  }
                },
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: const Color(0xFFEDEDED),
                    strokeWidth: 1.6,
                    radius: 13,
                    dashLength: 6,
                    gapLength: 4,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 123,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9EA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.description_outlined,
                              size: 24,
                              color: Color(0xFFC9A94E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFileName ?? 'Tap the Add button to upload',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Nunito',
                            color: const Color(0xFF8B8893),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Continue button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'name': _nameController.text,
                    'description': _descriptionController.text,
                    'emoji': _selectedEmoji,
                    'fileName': _selectedFileName,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8DA78),
                  foregroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


}

/// Custom painter for dashed rounded rectangle border.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    // Compute dashed path
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
