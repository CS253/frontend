import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/widgets/emoji_picker_dialog.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/payment_amount_field.dart';

class PaymentDetailsDialog extends StatefulWidget {
  final Function(Map<String, String>) onContinue;

  const PaymentDetailsDialog({
    super.key,
    required this.onContinue,
  });

  @override
  State<PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<PaymentDetailsDialog> {
  String selectedPayer = 'Rushabh';
  String _selectedEmoji = '✈️';
  final TextEditingController amountController = TextEditingController(text: '19000');
  final TextEditingController descriptionController = TextEditingController(text: 'Flights');
  final TextEditingController dateController = TextEditingController(text: '29/02/2024');
  final TextEditingController transactionIdController = TextEditingController(text: '124421');

  List<MemberModel> _members = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final members = await PaymentRepository().getTripMembers();
      if (mounted) {
        setState(() {
          _members = members;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => Navigator.pop(context),
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
                  'Add Payment',
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
            PaymentAmountField(
              label: 'Amount *',
              hintText: 'e.g., 2000',
              controller: amountController,
              isNumber: true,
              prefixText: '₹   ',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final emoji = await showEmojiPicker(context);
                    if (emoji != null) {
                      setState(() => _selectedEmoji = emoji);
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF8),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: const Color(0xFFEBE7E0),
                        width: 0.75,
                      ),
                    ),
                    child: Center(
                      child: Text(_selectedEmoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PaymentAmountField(
                    label: 'Description *',
                    hintText: 'Flights',
                    controller: descriptionController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Paid by *'),
            const SizedBox(height: 8),
            _isLoadingMembers
                ? Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF8),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8A8075)),
                      ),
                    ),
                  )
                : _buildDropdown(
                    value: selectedPayer,
                    items: _members.map((e) => e.name).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPayer = val);
                    },
                  ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PaymentAmountField(
                    label: 'Date',
                    hintText: '29/02/2024',
                    controller: dateController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PaymentAmountField(
                    label: 'Transaction ID',
                    hintText: '124421',
                    controller: transactionIdController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DialogPrimaryButton(
              text: 'Continue',
              onPressed: () {
                widget.onContinue({
                  'amount': amountController.text.isNotEmpty ? amountController.text : '0',
                  'description': descriptionController.text,
                  'emoji': _selectedEmoji,
                  'payer': selectedPayer,
                  'date': dateController.text,
                  'transaction_id': transactionIdController.text,
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: const Color(0xFF38332E),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF8A8075),
            size: 16,
          ),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFF38332E),
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
        ),
      ),
    );
  }
}
