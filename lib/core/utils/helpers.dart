/// Shared utility helpers.
class Helpers {
  Helpers._();

  /// Format a number as a currency string.
  /// Example: `formatCurrency(19400)` → `₹19,400`
  static String formatCurrency(double amount, {String symbol = '₹'}) {
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
    return '${isNegative ? '-' : ''}$symbol$result';
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
}
