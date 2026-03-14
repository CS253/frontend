import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/widgets/emoji_picker_dialog.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/payment_amount_field.dart';

class PaymentDetailsDialog extends StatefulWidget {
  final Map<String, String>? initialDetails;
  final Function(Map<String, String>) onContinue;

  const PaymentDetailsDialog({
    super.key,
    this.initialDetails,
    required this.onContinue,
  });

  @override
  State<PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<PaymentDetailsDialog> {
  String? selectedPayer;
  String _selectedEmoji = '✈️';
  late TextEditingController amountController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;

  List<MemberModel> _members = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    selectedPayer = widget.initialDetails?['payer'];
    _selectedEmoji = widget.initialDetails?['emoji'] ?? '✈️';
    amountController = TextEditingController(text: widget.initialDetails?['amount'] ?? '');
    descriptionController = TextEditingController(text: widget.initialDetails?['description'] ?? '');
    dateController = TextEditingController(text: widget.initialDetails?['date'] ?? '');
    _fetchMembers();
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
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
              prefixText: '${AppCurrency.symbol}   ',
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
                    hintText: 'Select Date',
                    controller: dateController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DialogPrimaryButton(
              text: 'Continue',
              onPressed: () {
                if (amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
                  return;
                }
                if (descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a description')));
                  return;
                }
                if (selectedPayer == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select who paid for this')));
                  return;
                }
                widget.onContinue({
                  'amount': amountController.text,
                  'description': descriptionController.text,
                  'emoji': _selectedEmoji,
                  'payer': selectedPayer!,
                  'date': dateController.text,
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
    required String? value,
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
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text('Select Person', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8A8075), fontSize: 14)),
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
      ),
    );
  }
}
