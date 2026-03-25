import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/settlement_model.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/core/services/user_identity_service.dart';

/// Horizontal scrollable friend balance cards with dynamic data.
class FriendBalances extends StatefulWidget {
  final String groupId;
  final Function(String name, String initials, String amount, {String? fromUserId, String? toUserId, String? currency})? onSettle;

  const FriendBalances({super.key, required this.groupId, this.onSettle});

  @override
  State<FriendBalances> createState() => _FriendBalancesState();
}

class _FriendBalancesState extends State<FriendBalances> {
  late Future<_SettlementsData> _dataFuture;
  final PaymentRepository _repository = PaymentRepository();

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<_SettlementsData> _fetchData() async {
    final results = await Future.wait([
      _repository.getSettlements(widget.groupId, simplifyDebts: false),
      UserIdentityService.instance.getBackendUserId(widget.groupId),
      _repository.getGroupMembers(widget.groupId),
    ]);
    return _SettlementsData(
      settlements: results[0] as List<SettlementModel>,
      currentUserId: results[1] as String,
      members: results[2] as List<MemberModel>,
    );
  }

  /// Resolve a user's display name: use settlement name if available,
  /// otherwise look up from group members by userId.
  String _resolveName(String nameFromApi, String userId, List<MemberModel> members) {
    if (nameFromApi.isNotEmpty) return nameFromApi;
    for (final m in members) {
      if (m.userId == userId) return m.name;
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SettlementsData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.settlements.isEmpty) {
          return const Center(child: Text('All settled up! 🎉'));
        }

        final settlements = snapshot.data!.settlements;
        final currentUserId = snapshot.data!.currentUserId;
        final members = snapshot.data!.members;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: settlements.asMap().entries.map((entry) {
              final index = entry.key;
              final settlement = entry.value;
              final isLast = index == settlements.length - 1;

              final currencySymbol = _getCurrencySymbol(settlement.currency);

              // Resolve names with member fallback
              final fromName = _resolveName(settlement.fromUserName, settlement.fromUserId, members);
              final toName = _resolveName(settlement.toUserName, settlement.toUserId, members);

              // Determine direction relative to current user
              final bool iOwe = settlement.fromUserId == currentUserId;
              final bool owesMe = settlement.toUserId == currentUserId;

              String displayName;
              String statusText;
              Color statusColor;
              Color statusTextColor;

              if (iOwe) {
                displayName = toName;
                statusText = 'I owe $currencySymbol${settlement.amount.toStringAsFixed(0)}';
                statusColor = const Color(0xFFFDE8E8);
                statusTextColor = const Color(0xFFD1475E);
              } else if (owesMe) {
                displayName = fromName;
                statusText = 'Owes you $currencySymbol${settlement.amount.toStringAsFixed(0)}';
                statusColor = const Color(0xFFE0F5EE);
                statusTextColor = const Color(0xFF339977);
              } else {
                displayName = '$fromName → $toName';
                statusText = '$currencySymbol${settlement.amount.toStringAsFixed(0)}';
                statusColor = const Color(0xFFF0ECE8);
                statusTextColor = const Color(0xFF8A8075);
              }

              final initials = _getInitials(displayName);

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _card(
                  initials: initials,
                  name: displayName,
                  statusText: statusText,
                  statusColor: statusColor,
                  statusTextColor: statusTextColor,
                  onTap: () => widget.onSettle?.call(
                    displayName,
                    initials,
                    settlement.amount.toStringAsFixed(2),
                    fromUserId: settlement.fromUserId,
                    toUserId: settlement.toUserId,
                    currency: settlement.currency,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
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

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _card({
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEEECE8),
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
              overflow: TextOverflow.ellipsis,
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

class _SettlementsData {
  final List<SettlementModel> settlements;
  final String currentUserId;
  final List<MemberModel> members;

  _SettlementsData({required this.settlements, required this.currentUserId, required this.members});
}
