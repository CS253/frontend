// =============================================================================
// App Theme — Centralized theming tokens extracted from Figma design.
//
// All color tokens, typography, and component styles are defined here so
// that the entire app uses a consistent design language.
// =============================================================================

import 'package:flutter/material.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Color Tokens (extracted from Figma)
  // ---------------------------------------------------------------------------

  /// Primary brand color — sky blue used for buttons, links, highlights.
  static const Color primaryColor = Color(0xFF6BB5E5);

  /// Light variant of primary for backgrounds and badges.
  static const Color primaryLight = Color(0xFFBCE3F7);

  /// Very light primary for subtle backgrounds.
  static const Color primarySurface = Color(0xFFD9F0FC);

  /// Dark text color.
  static const Color textDark = Color(0xFF282828);

  /// Medium text/icon color.
  static const Color textSecondary = Color(0xFF6A6A6A);

  /// Light grey text for hints and placeholders.
  static const Color textHint = Color(0xFF828282);

  /// Light grey for subtitle text.
  static const Color textSubtitle = Color(0xFF5A7184);

  /// Border/divider color.
  static const Color borderColor = Color(0xFFE0E0E0);

  /// Light divider color.
  static const Color dividerColor = Color(0xFFE6E6E6);

  /// Card/surface background.
  static const Color surfaceColor = Color(0xFFFDFDFD);

  /// Button secondary background.
  static const Color buttonSecondaryBg = Color(0xFFEEEEEE);

  /// Chip/tag background.
  static const Color chipBg = Color(0xFFF7F7F7);

  /// Success/checklist item green.
  static const Color successColor = Color(0xFF20B95B);

  /// Success background.
  static const Color successBg = Color(0xFFEBF6F0);

  /// Trip card info background.
  static const Color tripCardInfoBg = Color(0xFFEEF5FA);

  /// Floating action button background.
  static const Color fabColor = Color(0xFF9DD4F9);

  // ---------------------------------------------------------------------------
  // Typography
  // ---------------------------------------------------------------------------

  static const String fontFamily = 'Inter';

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textHint,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle labelText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSubtitle,
  );

  // ---------------------------------------------------------------------------
  // Input Decoration
  // ---------------------------------------------------------------------------

  static InputDecoration inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        color: textHint,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      suffixIcon: suffixIcon,
    );
  }

  // ---------------------------------------------------------------------------
  // ThemeData
  // ---------------------------------------------------------------------------

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }
}
