import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';

class MarkAsPaidDialog extends StatefulWidget {
  final VoidCallback onBack;

  const MarkAsPaidDialog({
    super.key,
    required this.onBack,
  });

  @override
  State<MarkAsPaidDialog> createState() => _MarkAsPaidDialogState();
}

class _MarkAsPaidDialogState extends State<MarkAsPaidDialog> {
  final TextEditingController txnController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    txnController.dispose();
    dateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _markAsPaid() async {
    if (dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date & Time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final body = {
      'transaction_id': txnController.text,
      'date_time': dateController.text,
      'notes': notesController.text,
      'status': 'completed',
    };

    try {
      await PaymentService().markAsPaid(body);
      
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment marked as paid')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
                  onTap: widget.onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Mark as Paid',
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
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF9FDFCA).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF45B08C), size: 40),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Payment Completed?',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF38332E),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Confirm the details below',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF8A8075)),
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('Transaction ID', optional: true),
            const SizedBox(height: 8),
            _buildTextField(hintText: 'e.g., UPI123456789', controller: txnController),
            const SizedBox(height: 16),
            _buildLabel('Date & Time'),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: 'Select Date & Time',
              filledColor: const Color(0xFFF3F2F0),
              controller: dateController,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  if (!context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null && context.mounted) {
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    setState(() {
                      dateController.text = "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}, ${time.format(context)}";
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Notes', optional: true),
            const SizedBox(height: 8),
            _buildTextArea(hintText: 'Any additional notes...', controller: notesController),
            const SizedBox(height: 24),
            DialogPrimaryButton(
              text: 'Done',
              isLoading: _isLoading,
              onPressed: _markAsPaid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool optional = false}) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: const Color(0xFF38332E),
        ),
        children: [
          TextSpan(text: text),
          if (optional)
            TextSpan(
              text: ' (optional)',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.normal,
                color: const Color(0xFF8A8075),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hintText, Color? filledColor, TextEditingController? controller, bool readOnly = false, VoidCallback? onTap}) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          filled: true,
          fillColor: filledColor ?? const Color(0xFFFCFAF8),
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: const Color(0xFF8A8075),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFFEBE7E0), width: 0.75),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(
              color: readOnly ? const Color(0xFFEBE7E0) : const Color(0xFF6BB5E5),
              width: readOnly ? 0.75 : 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea({required String hintText, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFCFAF8),
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: const Color(0xFF8A8075),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFEBE7E0), width: 0.75),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 1),
        ),
      ),
    );
  }
}
