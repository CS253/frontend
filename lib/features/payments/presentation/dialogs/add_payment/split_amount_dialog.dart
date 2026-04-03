import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:provider/provider.dart';
import 'package:travelly/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/payment_split_row.dart';
import 'package:travelly/core/constants/currency.dart';

class SplitAmountDialog extends StatefulWidget {
  final String groupId;
  final Map<String, String> paymentDetails;
  final List<String> selectedPeopleIds;
  final VoidCallback onBack;
  final void Function(Map<String, dynamic>)? onComplete;

  const SplitAmountDialog({
    super.key,
    required this.groupId,
    required this.paymentDetails,
    required this.selectedPeopleIds,
    required this.onBack,
    this.onComplete,
  });

  @override
  State<SplitAmountDialog> createState() => _SplitAmountDialogState();
}

class _SplitAmountDialogState extends State<SplitAmountDialog> {
  bool splitEqually = true;
  late Map<String, TextEditingController> controllers; // keyed by userId
  bool _isSubmitting = false;
  List<MemberModel> _members = [];

  @override
  void initState() {
    super.initState();
    controllers = {};
    for (var id in widget.selectedPeopleIds) {
      controllers[id] = TextEditingController();
    }
    _recalculateSplits();
    
    final participants = context.read<DashboardProvider>().participants;
    _members = participants.map((p) => MemberModel(
      id: p.id,
      userId: p.id,
      name: p.name,
      avatarColor: const Color(0xFFD9F0FC)
    )).toList();
  }

  void _recalculateSplits() {
    if (!splitEqually) return;

    double total =
        double.tryParse(widget.paymentDetails['amount'] ?? '0') ?? 0.0;
    int divisor = widget.selectedPeopleIds.length;
    if (divisor == 0) return;

    int totalCents = (total * 100).round();
    int fCents = totalCents ~/ divisor;
    int remainder = totalCents % divisor;

    int y = remainder;
    int x = divisor - y;

    double f = fCents / 100.0;
    double c = (fCents + 1) / 100.0;

    List<String> ids = List.from(widget.selectedPeopleIds);
    ids.shuffle();

    for (int i = 0; i < ids.length; i++) {
      String id = ids[i];
      if (controllers.containsKey(id)) {
        if (i < x) {
          controllers[id]!.text = f.toStringAsFixed(2);
        } else {
          controllers[id]!.text = c.toStringAsFixed(2);
        }
      }
    }
  }

  Future<void> _submitExpense() async {
    int totalCents =
        ((double.tryParse(widget.paymentDetails['amount'] ?? '0') ?? 0.0) * 100)
            .round();
    int currentSumCents = 0;
    for (var controller in controllers.values) {
      currentSumCents += ((double.tryParse(controller.text) ?? 0.0) * 100)
          .round();
    }

    if (currentSumCents != totalCents) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Split amounts must equal total payment amount'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Build the API-compliant payload
    final Map<String, dynamic> body = {
      'title': widget.paymentDetails['description'] ?? '',
      'amount': double.tryParse(widget.paymentDetails['amount'] ?? '0') ?? 0.0,
      'paidBy': widget.paymentDetails['payerId'] ?? '',
      'currency': widget.paymentDetails['currency'] ?? AppCurrency.code,
    };

    // Add date if provided
    final dateStr = widget.paymentDetails['date'] ?? '';
    if (dateStr.isNotEmpty) {
      body['date'] = dateStr;
    }

    // Build split payload
    if (splitEqually) {
      body['split'] = {
        'type': 'EQUAL',
        'participants': widget.selectedPeopleIds,
      };
    } else {
      body['split'] = {
        'type': 'CUSTOM',
        'splits': controllers.entries
            .map((e) => {
                  'userId': e.key,
                  'amount': double.tryParse(e.value.text) ?? 0.0,
                })
            .toList(),
      };
    }

    try {
      if (!mounted) return;
      
      // Bubble the payload up to be handled optimistically by the Provider
      Navigator.of(context).pop();
      if (widget.onComplete != null) {
        widget.onComplete!(body);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding expense: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeMembers = _members
        .where((m) => widget.selectedPeopleIds.contains(m.userId))
        .toList();

    final currencyCode = widget.paymentDetails['currency'] ?? AppCurrency.code;
    final currencySymbol = currencyCode == 'INR'
        ? '₹'
        : currencyCode == 'USD'
        ? '\$'
        : currencyCode == 'EUR'
        ? '€'
        : currencyCode == 'GBP'
        ? '£'
        : AppCurrency.symbol;

    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: widget.onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xFF38332E),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Split Expense',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF38332E),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAF8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: const Color(0xFF38332E),
                    ),
                  ),
                  Text(
                    '$currencySymbol${widget.paymentDetails['amount']}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF38332E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Color(0xFF8A8075),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Split equally',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: const Color(0xFF38332E),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      splitEqually = !splitEqually;
                      if (splitEqually) _recalculateSplits();
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 20,
                    decoration: BoxDecoration(
                      color: splitEqually
                          ? const Color(0xFF9FDFCA)
                          : const Color(0xFFEBE7E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: splitEqually
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: activeMembers.length,
                itemBuilder: (context, index) {
                  final member = activeMembers[index];
                  final controller = controllers[member.userId]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PaymentSplitRow(
                      member: member,
                      controller: controller,
                      currencySymbol: currencySymbol,
                      onManualEdit: () {
                        if (splitEqually) {
                          setState(() {
                            splitEqually = false;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            DialogPrimaryButton(
              text: 'Add Expense',
              isLoading: _isSubmitting,
              onPressed: _submitExpense,
              backgroundColor: const Color(0xFF9FDFCA),
              textColor: const Color(0xFF339977),
              icon: Icons.check,
            ),
          ],
        ),
      ),
    );
  }
}
