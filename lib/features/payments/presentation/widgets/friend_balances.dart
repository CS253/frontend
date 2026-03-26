import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/settlement_model.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/core/services/user_identity_service.dart';
import 'package:provider/provider.dart';
import 'package:travelly/features/dashboard/presentation/providers/dashboard_provider.dart';

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
  late final PaymentRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = context.read<PaymentRepository>();
    _dataFuture = _fetchData();
  }

  Future<_SettlementsData> _fetchData() async {
    final participants = context.read<DashboardProvider>().participants;
    final fetchMembers = participants.map((p) => MemberModel(
      id: p.id,
      userId: p.id,
      name: p.name,
      avatarColor: const Color(0xFFD9F0FC)
    )).toList();

    final results = await Future.wait([
      _repository.getSettlements(widget.groupId, simplifyDebts: false),
      UserIdentityService.instance.getBackendUserId(widget.groupId, _repository),
    ]);

    return _SettlementsData(
      settlements: results[0] as List<SettlementModel>,
      currentUserId: results[1] as String,
      members: fetchMembers,
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
        } else if (!snapshot.hasData) {
          return const Center(child: Text('All settled up! 🎉'));
        }

        final settlements = snapshot.data!.settlements;
        final currentUserId = snapshot.data!.currentUserId;
        final members = snapshot.data!.members;

        final userSettlements = currentUserId.isNotEmpty
            ? settlements.where((s) => s.fromUserId == currentUserId || s.toUserId == currentUserId).toList()
            : <SettlementModel>[];

        if (userSettlements.isEmpty) {
          return const Center(child: Text('All settled up! 🎉'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: userSettlements.asMap().entries.map((entry) {
              final index = entry.key;
              final settlement = entry.value;
              final isLast = index == userSettlements.length - 1;

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
                statusText = 'I owe $currencySymbol${settlement.amount.toStringAsFixed(2)}';
                statusColor = const Color(0xFFFDE8E8);
                statusTextColor = const Color(0xFFD1475E);
              } else if (owesMe) {
                displayName = fromName;
                statusText = 'Owes you $currencySymbol${settlement.amount.toStringAsFixed(2)}';
                statusColor = const Color(0xFFE0F5EE);
                statusTextColor = const Color(0xFF339977);
              } else {
                displayName = '$fromName → $toName';
                statusText = '$currencySymbol${settlement.amount.toStringAsFixed(2)}';
                statusColor = const Color(0xFFF0ECE8);
                statusTextColor = const Color(0xFF8A8075);
              }

              final initials = _getInitials(displayName);

              Color avatarColor = const Color(0xFFEEECE8);
              if (iOwe) {
                avatarColor = _getMemberColor(settlement.toUserId, members);
              } else if (owesMe) {
                avatarColor = _getMemberColor(settlement.fromUserId, members);
              } else {
                avatarColor = _getMemberColor(settlement.fromUserId, members);
              }

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _card(
                  initials: initials,
                  name: displayName,
                  statusText: statusText,
                  statusColor: statusColor,
                  statusTextColor: statusTextColor,
                  avatarColor: avatarColor,
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
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  Color _getMemberColor(String userId, List<MemberModel> members) {
    for (final m in members) {
      if (m.userId == userId) return m.avatarColor;
    }
    return const Color(0xFFD9F0FC);
  }

  Widget _card({
    required String initials,
    required String name,
    required Color statusColor,
    required Color statusTextColor,
    required String statusText,
    required Color avatarColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
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
                color: avatarColor,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    color: Color(0xFF074066),
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
