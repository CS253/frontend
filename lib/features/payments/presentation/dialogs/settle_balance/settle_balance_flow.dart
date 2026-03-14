import 'package:flutter/material.dart';
import 'package:travelly/core/widgets/keyboard_safe_dialog.dart';
import 'select_settle_option_dialog.dart';
import 'pay_with_upi_dialog.dart';
import 'mark_as_paid_dialog.dart';

class SettleBalanceFlow {
  static void show(
    BuildContext context, {
    required String name,
    required String initials,
    required String amount,
  }) {
    _showOptions(context, name: name, initials: initials, amount: amount);
  }

  static void _showOptions(
    BuildContext context, {
    required String name,
    required String initials,
    required String amount,
  }) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: SelectSettleOptionDialog(
          name: name,
          initials: initials,
          amount: amount,
          onPayViaUPI: () {
            Navigator.pop(context);
            _showPayWithUPI(context, name: name, amount: amount);
          },
          onMarkAsPaid: () {
            Navigator.pop(context);
            _showMarkAsPaid(context, name: name, amount: amount, initials: initials);
          },
        ),
      ),
    );
  }

  static void _showPayWithUPI(
    BuildContext context, {
    required String name,
    required String amount,
  }) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: PayWithUPIDialog(
          name: name,
          amount: amount,
          onBack: () {
            Navigator.pop(context);
            // Assuming we need initials to go back to options, but for now just pass a dummy or keep track
            // Better: pass it along
          },
          onMarkAsPaid: () {
            Navigator.pop(context);
            _showMarkAsPaid(context, name: name, amount: amount, initials: ''); // Initials not needed for mark as paid?
          },
        ),
      ),
    );
  }

  static void _showMarkAsPaid(
    BuildContext context, {
    required String name,
    required String amount,
    required String initials,
  }) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: MarkAsPaidDialog(
          onBack: () {
            Navigator.pop(context);
            _showOptions(context, name: name, amount: amount, initials: initials);
          },
        ),
      ),
    );
  }
}
