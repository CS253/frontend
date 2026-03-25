import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';

/// Reusable dialog that shows a per-currency breakdown of amounts.
/// Used by "Total Expense" and "You Paid" summary cards.
class CurrencyBreakdownDialog extends StatelessWidget {
  final String title;
  final Map<String, double> currencyAmounts;

  const CurrencyBreakdownDialog({
    super.key,
    required this.title,
    required this.currencyAmounts,
  });

  static void show(BuildContext context, {required String title, required Map<String, double> currencyAmounts}) {
    showDialog(
      context: context,
      builder: (_) => CurrencyBreakdownDialog(title: title, currencyAmounts: currencyAmounts),
    );
  }

  String _getSymbol(String code) {
    switch (code) {
      case 'INR': return '₹';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return AppCurrency.symbol;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final entries = currencyAmounts.entries.toList();

    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF38332E),
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Color(0xFF8A8075)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (entries.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No data available',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF8A8075),
                    ),
                  ),
                ),
              )
            else
              ...entries.map((e) {
                final symbol = _getSymbol(e.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEECE8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  symbol,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: const Color(0xFF38332E),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              e.key,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: const Color(0xFF38332E),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$symbol${_formatAmount(e.value)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF38332E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
