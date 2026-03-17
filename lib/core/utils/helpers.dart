// =============================================================================
// Helpers — General utility functions used across the application.
// =============================================================================

import 'package:flutter/material.dart';
import '../constants/currency.dart';

class Helpers {
  // Prevent instantiation
  Helpers._();

  // ---------------------------------------------------------------------------
  // Currency Formatting (HEAD branch — Payments/Dashboard)
  // ---------------------------------------------------------------------------

  /// Format a number as a currency string.
  /// Example: `formatCurrency(19400)` → `₹19,400`
  static String formatCurrency(double amount, {String? symbol}) {
    final currencySymbol = symbol ?? AppCurrency.symbol;
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    // Indian numbering system: last 3 digits then groups of 2
    final intPart = absAmount.truncate().toString();
    final decimalPart = (absAmount - absAmount.truncate())
        .toStringAsFixed(2)
        .substring(2);
    final hasDecimals = decimalPart != '00';

    String formatted;
    if (intPart.length <= 3) {
      formatted = intPart;
    } else {
      formatted = _addIndianCommas(intPart);
    }

    final result = hasDecimals ? '$formatted.$decimalPart' : formatted;
    return '${isNegative ? '-' : ''}$currencySymbol$result';
  }

  static String _addIndianCommas(String number) {
    if (number.length <= 3) return number;

    final lastThree = number.substring(number.length - 3);
    final remaining = number.substring(0, number.length - 3);

    final buffer = StringBuffer();
    for (int i = remaining.length - 1; i >= 0; i--) {
      buffer.write(remaining[i]);
      final posFromEnd = remaining.length - 1 - i;
      if (posFromEnd % 2 == 1 && i != 0) {
        buffer.write(',');
      }
    }

    return '${buffer.toString().split('').reversed.join()},$lastThree';
  }

  /// Format a relative time string.
  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // ---------------------------------------------------------------------------
  // Date Formatting (Sarim branch — Trips/Auth)
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
