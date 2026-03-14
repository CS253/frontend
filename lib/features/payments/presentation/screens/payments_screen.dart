import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/presentation/dialogs/add_payment/add_payment_flow.dart';
import 'package:travelly/features/payments/presentation/dialogs/settle_balance/settle_balance_flow.dart';
import 'package:travelly/features/payments/presentation/widgets/balance_card.dart';
import 'package:travelly/features/payments/presentation/widgets/summary_cards.dart';
import 'package:travelly/features/payments/presentation/widgets/friend_balances.dart';
import 'package:travelly/features/payments/presentation/widgets/expense_card.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 14.6,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payments & Expenses',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: const Color(0xFF38332E),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'The Manali Trip',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.normal,
                fontSize: 11,
                color: const Color(0xFF8A8075),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF38332E)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color.fromRGBO(235, 231, 224, 0.5),
            height: 1,
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
                const Center(child: BalanceCard()),
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
