import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/features/payments/data/models/group_summary_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/core/services/user_identity_service.dart';

/// Scrollable per-currency balance card.
/// Shows one "page" per currency with the user's net balance.
/// Green = you are owed, Red = you owe.
class BalanceCard extends StatefulWidget {
  final String groupId;
  final VoidCallback? onSettleTap;

  const BalanceCard({super.key, required this.groupId, this.onSettleTap});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  late Future<GroupSummaryModel?> _summaryFuture;
  final PaymentRepository _repository = PaymentRepository();
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _fetchSummary();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<GroupSummaryModel?> _fetchSummary() async {
    final userId = await UserIdentityService.instance.getBackendUserId(widget.groupId);
    return _repository.getGroupSummary(widget.groupId, userId: userId.isNotEmpty ? userId : null);
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'INR': return '₹';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return AppCurrency.symbol;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GroupSummaryModel?>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSingleCard(
            isOwe: false,
            amount: '...',
            currencySymbol: AppCurrency.symbol,
            currencyCode: AppCurrency.code,
          );
        }

        final summary = snapshot.data;
        final balanceMap = summary?.individual?.balance ?? {};

        // If no individual balance data, show a single card with 0
        if (balanceMap.isEmpty) {
          final currency = summary?.currency ?? AppCurrency.code;
          return _buildSingleCard(
            isOwe: false,
            amount: '0',
            currencySymbol: _getCurrencySymbol(currency),
            currencyCode: currency,
          );
        }

        // Build list of per-currency balance entries
        final entries = balanceMap.entries.toList();

        return Column(
          children: [
            SizedBox(
              height: 110,
              child: PageView.builder(
                controller: _pageController,
                itemCount: entries.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final currency = entries[index].key;
                  final balance = entries[index].value;
                  final isOwe = balance < 0;
                  final symbol = _getCurrencySymbol(currency);
                  final displayAmount = balance.abs().toStringAsFixed(0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildSingleCard(
                      isOwe: isOwe,
                      amount: displayAmount,
                      currencySymbol: symbol,
                      currencyCode: currency,
                    ),
                  );
                },
              ),
            ),
            if (entries.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(entries.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? const Color(0xFF38332E)
                          : const Color(0xFFD5D0CA),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSingleCard({
    required bool isOwe,
    required String amount,
    required String currencySymbol,
    required String currencyCode,
  }) {
    final bgColor = isOwe ? const Color(0xFFFBE9EC) : const Color(0xFFE0F5EE);
    final textColor = isOwe ? const Color(0xFFD1475E) : const Color(0xFF339977);
    final iconBoxColor = isOwe
        ? const Color.fromRGBO(209, 71, 94, 0.17)
        : const Color.fromRGBO(159, 223, 202, 0.3);
    final iconData = isOwe ? Icons.north_east : Icons.arrow_downward;
    final subtitle = isOwe ? 'You owe' : 'You are owed';

    return GestureDetector(
      onTap: isOwe ? widget.onSettleTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        currencyCode,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$currencySymbol$amount',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 27,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBoxColor,
              ),
              child: Icon(iconData, color: textColor, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
