import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showEmojiPicker(BuildContext context) {
  final List<String> emojis = [
    '✈️', '🏨', '🚌', '🚗', '🎫', '🗺️', '💳', '🧳',
    '🍔', '☕', '🎭', '🎢', '⛺', '🚁', '🚲', '⛽',
    '💊', '🩺', '📞', '🔑', '🪪', '📦', '🎒', '👕',
    '📄', '🚂', '📋', '📑', '🔖', '🛂', '🎟️', '🛳️',
    '🏠', '📝', '🗓️', '💰', '🧾', '📸', '🏔️', '🏖️',
  ];

  String? selectedEmoji;

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: const Color(0xFFFCFAF8),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Emoji',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: const Color(0xFF38332E),
                          letterSpacing: -0.38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = emojis[index];
                      final isSelected = emoji == selectedEmoji;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx, emoji);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF8DA78).withValues(alpha: 0.3)
                                : const Color(0xFFFDFDFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFF8DA78)
                                  : const Color(0xFFEBE7E0),
                              width: isSelected ? 1.5 : 0.75,
                            ),
                          ),
                          child: Center(
                            child: Text(emoji, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
