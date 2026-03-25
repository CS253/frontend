import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/features/payments/data/models/group_summary_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/core/services/user_identity_service.dart';

/// The main balance card shown at the top of the payments screen.
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

  @override
  void initState() {
    super.initState();
    _summaryFuture = _fetchSummary();
  }

  Future<GroupSummaryModel?> _fetchSummary() async {
    final userId = await UserIdentityService.instance.getBackendUserId(widget.groupId);
    return _repository.getGroupSummary(widget.groupId, userId: userId.isNotEmpty ? userId : null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GroupSummaryModel?>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildStaticCard(
            isOwe: false,
            amount: '...',
            currencySymbol: AppCurrency.symbol,
          );
        }

        final summary = snapshot.data;
        final currency = summary?.currency ?? AppCurrency.code;
        final currencySymbol = currency == 'INR'
            ? '₹'
            : currency == 'USD'
            ? '\$'
            : currency == 'EUR'
            ? '€'
            : currency == 'GBP'
            ? '£'
            : AppCurrency.symbol;

        // Calculate net balance across all currencies from individual data
        double netBalance = 0.0;
        if (summary?.individual != null) {
          for (final v in summary!.individual!.balance.values) {
            netBalance += v;
          }
        }

        final isOwe = netBalance < 0;
        final displayAmount = netBalance.abs().toStringAsFixed(0);

        return _buildStaticCard(
          isOwe: isOwe,
          amount: displayAmount,
          currencySymbol: currencySymbol,
        );
      },
    );
  }

  Widget _buildStaticCard({
    required bool isOwe,
    required String amount,
    required String currencySymbol,
  }) {
    final bgColor = isOwe ? const Color(0xFFFBE9EC) : const Color(0xFFE0F5EE);
    final textColor = isOwe ? const Color(0xFFD1475E) : const Color(0xFF339977);
    final iconBoxColor = isOwe
        ? const Color.fromRGBO(209, 71, 94, 0.17)
        : const Color.fromRGBO(159, 223, 202, 0.3);
    final iconData = isOwe ? Icons.north_east : Icons.arrow_downward;

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
                Text(
                  'Your balance',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: textColor,
                  ),
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
