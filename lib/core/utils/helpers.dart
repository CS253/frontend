// =============================================================================
// Helpers — General utility functions used across the application.
// =============================================================================

import 'package:flutter/material.dart';


class Helpers {
  // Prevent instantiation
  Helpers._();

  // ---------------------------------------------------------------------------
  // Date Formatting
  // ---------------------------------------------------------------------------

  /// Formats a DateTime to a display-friendly string (e.g., "May 2024").
  static String formatMonthYear(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Formats a DateTime to "Mar 14, 2026" format.
  static String formatDisplayDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a DateTime to "Dec 31 - Jan 22" range format.
  static String formatDateRange(DateTime start, DateTime end) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[start.month - 1]} ${start.day} - ${months[end.month - 1]} ${end.day}';
  }

  /// Formats a DateTime to ISO8601 string for API requests.
  static String toIso8601(DateTime date) {
    return date.toIso8601String();
  }

  /// Parses an ISO8601 string from API responses.
  static DateTime fromIso8601(String dateString) {
    return DateTime.parse(dateString);
  }

  // ---------------------------------------------------------------------------
  // Snackbar Helpers
  // ---------------------------------------------------------------------------

  /// Shows an error snackbar.
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Shows a success snackbar.
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF20B95B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // String Helpers
  // ---------------------------------------------------------------------------

  /// Truncates a string with ellipsis if it exceeds maxLength.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Pluralizes a word based on count (e.g., "1 member", "5 members").
  static String pluralize(int count, String singular, {String? plural}) {
    final pluralWord = plural ?? '${singular}s';
    return '$count ${count == 1 ? singular : pluralWord}';
  }
}
