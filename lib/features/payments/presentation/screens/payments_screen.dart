import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelly/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/presentation/dialogs/add_payment/add_payment_flow.dart';
import 'package:travelly/features/payments/presentation/dialogs/settle_balance/settle_balance_flow.dart';
import 'package:travelly/features/payments/presentation/providers/payments_provider.dart';
import 'package:travelly/features/payments/presentation/widgets/balance_card.dart';
import 'package:travelly/features/payments/presentation/widgets/summary_cards.dart';
import 'package:travelly/features/payments/presentation/widgets/friend_balances.dart';
import 'package:travelly/features/payments/presentation/widgets/expense_card.dart';
import 'package:travelly/core/widgets/glass_back_button.dart';

class PaymentsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final String groupId;

  const PaymentsScreen({super.key, this.onBackPressed, required this.groupId});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late final PaymentsProvider _paymentsProvider;

  @override
  void initState() {
    super.initState();
    _paymentsProvider = PaymentsProvider(
      repository: context.read<PaymentRepository>(),
    );
    _loadData();
  }

  @override
  void dispose() {
    _paymentsProvider.dispose();
    super.dispose();
  }

  void _loadData() {
    final dashboardProvider = context.read<DashboardProvider>();
    final currentTrip = dashboardProvider.currentTrip;
    final participants = dashboardProvider.participants;

    _paymentsProvider.loadAll(
      groupId: widget.groupId,
      simplifyDebts: currentTrip?.simplifyDebts ?? false,
      participants: participants.map((p) => MemberModel(
        id: p.id,
        userId: p.id,
        name: p.name,
        avatarColor: const Color(0xFFD9F0FC),
      )).toList(),
    );
  }

  void _reload() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _paymentsProvider,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF8),
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Consumer<PaymentsProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 14.6,
                    right: 14.6,
                    top: MediaQuery.of(context).padding.top + 120,
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BalanceCard(
                        groupId: widget.groupId,
                        summary: provider.summary,
                        isLoading: provider.isLoading,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: SummaryCards(
                          groupId: widget.groupId,
                          summary: provider.summary,
                          isLoading: provider.isLoading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBalancesHeader(),
                      const SizedBox(height: 10),
                      FriendBalances(
                        groupId: widget.groupId,
                        settlements: provider.settlements,
                        currentUserId: provider.currentUserId,
                        members: provider.members,
                        isLoading: provider.isLoading,
                        onSettle: (name, initials, amount, {String? fromUserId, String? toUserId, String? currency}) {
                          SettleBalanceFlow.show(
                            context,
                            groupId: widget.groupId,
                            name: name,
                            initials: initials,
                            amount: amount,
                            fromUserId: fromUserId ?? '',
                            toUserId: toUserId ?? '',
                            currency: currency ?? 'INR',
                            onComplete: _reload,
                          );
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
                      AllExpensesList(
                        groupId: widget.groupId,
                        expenses: provider.expenses,
                        currentUserId: provider.currentUserId,
                        isLoading: provider.isLoading,
                        onDelete: (expenseId) async {
                          try {
                            final dashProvider = context.read<DashboardProvider>();
                            await provider.deleteExpense(
                              widget.groupId,
                              expenseId,
                              simplifyDebts: dashProvider.currentTrip?.simplifyDebts ?? false,
                              participants: dashProvider.participants.map((p) => MemberModel(
                                id: p.id,
                                userId: p.id,
                                name: p.name,
                                avatarColor: const Color(0xFFD9F0FC),
                              )).toList(),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Expense deleted successfully')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting expense: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: _buildGlassyHeader(),
            ),
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Center(child: _buildAddPaymentButton(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassyHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GlassBackButton(onPressed: widget.onBackPressed),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
            ],
          ),
        ),
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
      onTap: () => AddPaymentFlow.show(context, groupId: widget.groupId, onComplete: _reload),
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
