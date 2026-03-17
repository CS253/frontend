import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/presentation/dialogs/add_payment/add_payment_flow.dart';
import 'package:travelly/features/payments/presentation/dialogs/settle_balance/settle_balance_flow.dart';
import 'package:travelly/features/payments/presentation/widgets/balance_card.dart';
import 'package:travelly/features/payments/presentation/widgets/summary_cards.dart';
import 'package:travelly/features/payments/presentation/widgets/friend_balances.dart';
import 'package:travelly/features/payments/presentation/widgets/expense_card.dart';

class PaymentsScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const PaymentsScreen({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDEDED), width: 0.8),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                right: 16.0,
                top: 22.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF212022), size: 20),
                    onPressed: onBackPressed ?? () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Payments & Expenses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212022),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Track and split expenses',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B8893),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Color(0xFF212022), size: 24),
                    onPressed: () {
                      context.findRootAncestorStateOfType<ScaffoldState>()?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                BalanceCard(),
                const SizedBox(height: 12),
                const Center(child: SummaryCards()),
                const SizedBox(height: 16),
                _buildBalancesHeader(),
                const SizedBox(height: 10),
                FriendBalances(
                  onSettle: (name, initials, amount) {
                    SettleBalanceFlow.show(context, name: name, initials: initials, amount: amount);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'All Expenses',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: const Color(0xFF8A8075),
                  ),
                ),
                const SizedBox(height: 10),
                const AllExpensesList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(child: _buildAddPaymentButton(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildBalancesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Balances with friends',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xFF8A8075))),
        Text('Detailed',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xFF8A8075))),
      ],
    );
  }

  Widget _buildAddPaymentButton(BuildContext context) {
    return GestureDetector(
      onTap: () => AddPaymentFlow.show(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF75CCFE),
          borderRadius: BorderRadius.circular(9159),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(56, 51, 46, 0.12), blurRadius: 27, offset: Offset(0, 7)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Color(0xFF064460), size: 18),
            const SizedBox(width: 8),
            Text('Add Payment',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold, fontSize: 14.6, color: const Color(0xFF064460))),
          ],
        ),
      ),
    );
  }
}
