import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/payment_split_row.dart';

class SplitAmountDialog extends StatefulWidget {
  final Map<String, String> paymentDetails;
  final List<String> selectedPeopleNames;
  final VoidCallback onBack;

  const SplitAmountDialog({
    super.key,
    required this.paymentDetails,
    required this.selectedPeopleNames,
    required this.onBack,
  });

  @override
  State<SplitAmountDialog> createState() => _SplitAmountDialogState();
}

class _SplitAmountDialogState extends State<SplitAmountDialog> {
  bool splitEqually = true;
  late Map<String, TextEditingController> controllers;
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<MemberModel> _members = [];

  @override
  void initState() {
    super.initState();
    controllers = {};
    for (var name in widget.selectedPeopleNames) {
      controllers[name] = TextEditingController();
    }
    _recalculateSplits();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final members = await PaymentRepository().getTripMembers();
      if (mounted) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _recalculateSplits() {
    if (!splitEqually) return;

    double total = double.tryParse(widget.paymentDetails['amount'] ?? '0') ?? 0.0;
    int divisor = widget.selectedPeopleNames.length;
    double splitVal = divisor > 0 ? total / divisor : 0.0;

    for (var name in widget.selectedPeopleNames) {
      if (controllers.containsKey(name)) {
        controllers[name]!.text = splitVal.toStringAsFixed(0);
      }
    }
  }

  Future<void> _submitExpense() async {
    setState(() => _isSubmitting = true);

    final body = {
      'amount': widget.paymentDetails['amount'],
      'description': widget.paymentDetails['description'],
      'emoji': widget.paymentDetails['emoji'],
      'payer': widget.paymentDetails['payer'],
      'date': widget.paymentDetails['date'],
      'transaction_id': widget.paymentDetails['transaction_id'],
      'splits': controllers.entries.map((e) => {'name': e.key, 'amount': e.value.text}).toList(),
    };

    try {
      await PaymentService().createExpense(body);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst); // Close all dialogs
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding expense: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeMembers = _members
        .where((m) => widget.selectedPeopleNames.contains(m.name))
        .toList();

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
                    '₹${widget.paymentDetails['amount']}',
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
                    const Icon(Icons.people_outline, size: 16, color: Color(0xFF8A8075)),
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
                      color: splitEqually ? const Color(0xFF9FDFCA) : const Color(0xFFEBE7E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: splitEqually ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _isLoading
                ? ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => PaymentSplitRow.buildLoading(),
                  )
                : ListView.builder(
                    itemCount: activeMembers.length,
                    itemBuilder: (context, index) {
                      final member = activeMembers[index];
                      final controller = controllers[member.name]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PaymentSplitRow(
                          member: member,
                          controller: controller,
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
