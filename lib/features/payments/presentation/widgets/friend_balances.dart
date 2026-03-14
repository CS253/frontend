import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/data/models/balance_model.dart';

/// Horizontal scrollable friend balance cards with dynamic data.
class FriendBalances extends StatefulWidget {
  final Function(String name, String initials, String amount)? onSettle;

  const FriendBalances({super.key, this.onSettle});

  @override
  State<FriendBalances> createState() => _FriendBalancesState();
}

class _FriendBalancesState extends State<FriendBalances> {
  late Future<List<BalanceModel>> _balancesFuture;
  final PaymentRepository _repository = PaymentRepository();

  @override
  void initState() {
    super.initState();
    _balancesFuture = _repository.getBalances();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BalanceModel>>(
      future: _balancesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No balances found.'));
        }

        final balances = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: balances.asMap().entries.map((entry) {
              final index = entry.key;
              final balance = entry.value;
              final isLast = index == balances.length - 1;

              // Check if "You owe" is in the status text to enable settlement
              final isOwe = balance.statusText.toLowerCase().contains('you owe');
              String amount = '';
              if (isOwe) {
                // Extract amount from "You owe ₹500"
                amount = balance.statusText.split('₹').last;
              }

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _card(
                  avatarColor: Color(balance.avatarColorValue),
                  initials: balance.initials,
                  name: balance.name,
                  statusColor: Color(balance.statusColorValue),
                  statusTextColor: Color(balance.statusTextColorValue),
                  statusText: balance.statusText,
                  onTap: isOwe ? () => widget.onSettle?.call(balance.name, balance.initials, amount) : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _card({
    required Color avatarColor,
    required String initials,
    required String name,
    required Color statusColor,
    required Color statusTextColor,
    required String statusText,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 136,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFB),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color.fromRGBO(235, 231, 224, 0.5), width: 1),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(56, 51, 46, 0.08), blurRadius: 18, offset: Offset(0, 3.6))
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
                border: Border.all(color: avatarColor, width: 2),
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
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
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
      ),
    );
  }
}
