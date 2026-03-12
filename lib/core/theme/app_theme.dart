import 'package:flutter/material.dart';

/// Centralized theme configuration.
class AppTheme {
  AppTheme._();

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF00A2FF);
  static const Color accentBlue = Color(0xFF6BB5E5);
  static const Color lightBlue = Color(0xFFD9F0FC);
  static const Color darkText = Color(0xFF212022);
  static const Color greyText = Color(0xFF8B8893);
  static const Color warmGrey = Color(0xFF8A8075);
  static const Color warmDark = Color(0xFF38332E);
  static const Color warmBg = Color(0xFFFCFAF8);
  static const Color greenAccent = Color(0xFF9FDFCA);
  static const Color greenText = Color(0xFF339977);
  static const Color redAccent = Color(0xFFD1475E);
  static const Color yellowButton = Color(0xFFF8DA78);
  static const Color borderColor = Color(0xFFEBE7E0);

  // ── Card Colors ───────────────────────────────────────────────────────────
  static const Color cardGreen = Color(0xFFE5F8F1);
  static const Color cardOrange = Color(0xFFFFF0DD);
  static const Color cardCyan = Color(0xFFE7F8FA);
  static const Color cardYellow = Color(0xFFFEF9EA);
  static const Color cardRed = Color(0xFFFBE9EC);
  static const Color cardGreenLight = Color(0xFFE0F5EE);

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: darkText),
      ),
    );
  }
}
