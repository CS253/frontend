import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payments_dialogs.dart';

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
                Center(child: _buildBalanceCard(context)),
                const SizedBox(height: 12),
                Center(child: _buildSummaryCards()),
                const SizedBox(height: 16),
                _buildBalancesHeader(),
                const SizedBox(height: 10),
                _buildBalancesList(),
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
                _buildAllExpensesList(),
                const SizedBox(height: 100), // Space for FAB
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

  Widget _buildBalanceCard(
    BuildContext context, {
    bool isOwe = true,
    String amount = '₹690',
  }) {
    final bgColor = isOwe ? const Color(0xFFFBE9EC) : const Color(0xFFE0F5EE);
    final textColor = isOwe ? const Color(0xFFD1475E) : const Color(0xFF339977);
    final iconBoxColor = isOwe
        ? const Color.fromRGBO(209, 71, 94, 0.17)
        : const Color.fromRGBO(159, 223, 202, 0.3);
    final iconData = isOwe ? Icons.north_east : Icons.arrow_downward;

    return GestureDetector(
      onTap: () {
        if (isOwe) {
          showDialog(
            context: context,
            builder: (context) => const SettleBalanceDialog(),
          );
        }
      },
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
                  amount,
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

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallSummaryCard(
            iconBoxColor: const Color(0xFFD8F1FD),
            iconColor: Colors.blueAccent,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Total Expense',
            amount: '₹19,400',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallSummaryCard(
            iconBoxColor: const Color(0xFFE0F5EE),
            iconColor: const Color(0xFF339977),
            icon: Icons.trending_up,
            title: 'You Paid',
            amount: '₹5,000',
            hasProgressBar: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallSummaryCard(
            iconBoxColor: const Color(0xFFF0E8F7),
            iconColor: Colors.purpleAccent,
            icon: Icons.people_outline,
            title: 'Top Spender',
            amount: '₹8,000',
            dynamicSubtitle: 'Ashish',
          ),
        ),
      ],
    );
  }

  Widget _buildSmallSummaryCard({
    required Color iconBoxColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String amount,
    bool hasProgressBar = false,
    String? dynamicSubtitle,
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
          if (dynamicSubtitle != null)
            Text(
              dynamicSubtitle,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: const Color(0xFF38332E),
              ),
            ),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: dynamicSubtitle != null
                  ? FontWeight.normal
                  : FontWeight.bold,
              fontSize: dynamicSubtitle != null ? 11 : 16.5,
              color: dynamicSubtitle != null
                  ? const Color(0xFF8A8075)
                  : const Color(0xFF38332E),
            ),
          ),
          if (hasProgressBar) ...[
            const SizedBox(height: 6),
            Container(
              height: 5.5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEEECE8),
                borderRadius: BorderRadius.circular(9159),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.26, // approx 5000/19400
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FDFCA),
                    borderRadius: BorderRadius.circular(9159),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBalancesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Balances with friends',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: const Color(0xFF8A8075),
          ),
        ),
        Text(
          'Detailed',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: const Color(0xFF8A8075),
          ),
        ),
      ],
    );
  }

  Widget _buildBalancesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildFriendBalanceCard(
            avatarColor: const Color(0xFF9FDFCA),
            initials: 'AS',
            name: 'Ashish',
            statusColor: const Color(0xFFFBE9EC),
            statusTextColor: const Color(0xFFD1475E),
            statusText: 'You owe ₹500',
          ),
          const SizedBox(width: 10),
          _buildFriendBalanceCard(
            avatarColor: const Color(0xFFFABD9E),
            initials: 'PR',
            name: 'Priya',
            statusColor: const Color(0xFFE0F5EE),
            statusTextColor: const Color(0xFF339977),
            statusText: 'Owes You ₹800',
          ),
          const SizedBox(width: 10),
          _buildFriendBalanceCard(
            avatarColor: const Color(0xFFCCB3E6),
            initials: 'RA',
            name: 'Rahul',
            statusColor: const Color(0xFFFBE9EC),
            statusTextColor: const Color(0xFFD1475E),
            statusText: 'You owe ₹200',
          ),
          const SizedBox(width: 10),
          _buildFriendBalanceCard(
            avatarColor: const Color(0xFFFAE39E),
            initials: 'NH',
            name: 'Neha',
            statusColor: const Color(0xFFE0F5EE),
            statusTextColor: const Color(0xFF339977),
            statusText: 'Settled',
          ),
          const SizedBox(width: 10),
          _buildFriendBalanceCard(
            avatarColor: const Color(0xFF87D4F8),
            initials: 'ME',
            name: 'You',
            statusColor: const Color(0xFFE0F5EE),
            statusTextColor: const Color(0xFF339977),
            statusText: 'Gets ₹50',
          ),
        ],
      ),
    );
  }

  Widget _buildFriendBalanceCard({
    required Color avatarColor,
    required String initials,
    required String name,
    required Color statusColor,
    required Color statusTextColor,
    required String statusText,
  }) {
    return Container(
      width: 136,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEEECE8),
              border: Border.all(
                color: avatarColor,
                width: 2,
              ), // using border as the outer colored circle approximation
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF38332E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: const Color(0xFF38332E),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllExpensesList() {
    return Column(
      children: [
        _buildExpenseCard(
          title: 'Hotel Booking - Snow Valley R...',
          amount: '₹8,000',
          payerName: 'Ashish',
          payerInitials: 'AS',
          payerColor: const Color(0xFF9FDFCA),
          date: 'Dec 20',
          yourShare: '₹500',
          status: 'Pending',
        ),
        const SizedBox(height: 10),
        _buildExpenseCard(
          title: 'Solang Valley Adventure Sports',
          amount: '₹3,200',
          payerName: 'You',
          payerInitials: 'ME',
          payerColor: const Color(0xFF87D4F8),
          date: 'Dec 22',
          yourShare: '₹3,200',
          shareTextPrefix: 'You paid',
          status: 'Settled',
        ),
        const SizedBox(height: 10),
        _buildExpenseCard(
          title: 'Dinner at Cafe 1947',
          amount: '₹2,400',
          payerName: 'Priya',
          payerInitials: 'PR',
          payerColor: const Color(0xFFFABD9E),
          date: 'Dec 23',
          yourShare: '₹600',
          status: 'Pending',
        ),
        const SizedBox(height: 10),
        _buildExpenseCard(
          title: 'Taxi to Rohtang Pass',
          amount: '₹4,000',
          payerName: 'Rahul',
          payerInitials: 'RA',
          payerColor: const Color(0xFFCCB3E6),
          date: 'Dec 24',
          yourShare: '₹1,000',
          status: 'Settled',
        ),
        const SizedBox(height: 10),
        _buildExpenseCard(
          title: 'Breakfast at Johnson\'s Cafe',
          amount: '₹1,800',
          payerName: 'You',
          payerInitials: 'ME',
          payerColor: const Color(0xFF87D4F8),
          date: 'Dec 25',
          yourShare: '₹1,800',
          shareTextPrefix: 'You paid',
          status: 'Settled',
        ),
      ],
    );
  }

  Widget _buildExpenseCard({
    required String title,
    required String amount,
    required String payerName,
    required String payerInitials,
    required Color payerColor,
    required String date,
    required String yourShare,
    String shareTextPrefix = 'Your share: ',
    required String status,
  }) {
    bool isPending = status == 'Pending';
    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E8F7),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Center(
              child: Text('🧾', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.6,
                          color: const Color(0xFF38332E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      amount,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                        color: const Color(0xFF38332E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEECE8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: payerColor,
                          width: 2,
                        ), // simplified colored outline representation
                      ),
                      child: Center(
                        child: Text(
                          payerInitials,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 7, // smaller font for tiny icon
                            color: const Color(0xFF38332E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Paid by ',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 12.8,
                        color: const Color(0xFF8A8075),
                      ),
                    ),
                    Text(
                      payerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.8,
                        color: const Color(0xFF38332E),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '·',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.6,
                        color: const Color(0xFF8A8075),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 12.8,
                        color: const Color(0xFF8A8075),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (shareTextPrefix == 'Your share: ')
                          Text(
                            shareTextPrefix,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.normal,
                              fontSize: 12.8,
                              color: const Color(0xFF8A8075),
                            ),
                          ),
                        Text(
                          shareTextPrefix == 'Your share: '
                              ? yourShare
                              : '$shareTextPrefix $yourShare',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.8,
                            color: shareTextPrefix == 'Your share: '
                                ? const Color(0xFFD1475E)
                                : const Color(0xFF339977),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPending
                            ? const Color(0xFFFDF7E2)
                            : const Color(0xFFE0F5EE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPending
                                ? Icons.access_time
                                : Icons.check_circle_outline,
                            color: isPending
                                ? const Color(0xFFCFA117)
                                : const Color(0xFF339977),
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              color: isPending
                                  ? const Color(0xFFCFA117)
                                  : const Color(0xFF339977),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPaymentButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddPaymentDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF75CCFE),
          borderRadius: BorderRadius.circular(9159),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(56, 51, 46, 0.12),
              blurRadius: 27,
              offset: Offset(0, 7),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Color(0xFF064460), size: 18),
            const SizedBox(width: 8),
            Text(
              'Add Payment',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14.6,
                color: const Color(0xFF064460),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddPaymentDialog();
      },
    );
  }
}
