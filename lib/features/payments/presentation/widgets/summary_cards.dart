import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/group_summary_model.dart';
import 'package:travelly/features/payments/presentation/dialogs/currency_breakdown_dialog.dart';
import 'package:travelly/features/payments/presentation/dialogs/members_list_dialog.dart';
import 'package:provider/provider.dart';
import 'package:travelly/features/payments/presentation/providers/payments_provider.dart';

/// Summary cards row (Total Expense, You Paid, Members).
class SummaryCards extends StatelessWidget {
  final String groupId;
  final GroupSummaryModel? summary;
  final bool isLoading;

  const SummaryCards({
    super.key,
    required this.groupId,
    this.summary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Per-currency maps for dialogs
    final totalExpensesByCurrency = summary?.individual?.totalExpensesByPaymentCurrency ?? {};
    final youPaidByCurrency = summary?.individual?.paid ?? {};

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 8),
          _buildSummaryCard(
            context: context,
            iconBoxColor: const Color(0xFFD8F1FD),
            iconColor: Colors.blueAccent,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Total Expense',
            subtitle: 'Tap to view',
            onTap: () => CurrencyBreakdownDialog.show(
              context,
              title: 'Total Expenses',
              currencyAmounts: totalExpensesByCurrency,
            ),
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            context: context,
            iconBoxColor: const Color(0xFFE0F5EE),
            iconColor: const Color(0xFF339977),
            icon: Icons.trending_up,
            title: 'You Paid',
            subtitle: 'Tap to view',
            onTap: () => CurrencyBreakdownDialog.show(
              context,
              title: 'You Paid',
              currencyAmounts: youPaidByCurrency,
            ),
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            context: context,
            iconBoxColor: const Color(0xFFF0E8F7),
            iconColor: Colors.purpleAccent,
            icon: Icons.people_outline,
            title: 'Members',
            // memberCount uses TripCache shell as fallback for zero-latency display
            amount: '${context.watch<PaymentsProvider>().memberCount}',
            onTap: () => MembersListDialog.show(context, groupId: groupId),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required Color iconBoxColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    String? amount,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: _card(
          iconBoxColor: iconBoxColor,
          iconColor: iconColor,
          icon: icon,
          title: title,
          amount: amount,
          subtitle: subtitle,
        ),
      ),
    );
  }

  Widget _card({
    required Color iconBoxColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    String? amount,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color.fromRGBO(235, 231, 224, 0.5),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(56, 51, 46, 0.08),
            blurRadius: 18,
            offset: Offset(0, 3.6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBoxColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.normal,
              fontSize: 11,
              color: const Color(0xFF8A8075),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          if (amount != null)
            Text(
              amount,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                color: const Color(0xFF38332E),
              ),
            )
          else if (subtitle != null)
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: const Color(0xFFABA49C),
              ),
            ),
        ],
      ),
    );
  }
}
