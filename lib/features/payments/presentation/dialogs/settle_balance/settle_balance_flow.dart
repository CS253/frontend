import 'package:flutter/material.dart';
import 'package:travelly/core/widgets/keyboard_safe_dialog.dart';
import 'select_settle_option_dialog.dart';
import 'mark_as_paid_dialog.dart';
import 'pay_with_upi_dialog.dart';

class SettleBalanceFlow {
  static void show(
    BuildContext context, {
    required String groupId,
    required String name,
    required String initials,
    required String amount,
    required String fromUserId,
    required String toUserId,
    required String currency,
    String? currentUserId,
    VoidCallback? onComplete,
  }) {
    _showSelectOption(context, groupId, name, initials, amount, fromUserId, toUserId, currency, currentUserId, onComplete);
  }

  static void _showSelectOption(
    BuildContext context,
    String groupId,
    String name,
    String initials,
    String amount,
    String fromUserId,
    String toUserId,
    String currency,
    String? currentUserId,
    VoidCallback? onComplete,
  ) {
    // Current user can only pay with UPI if they are the one who owes (fromUserId) and currency is INR
    final bool showPayWithUpi = (currency.toUpperCase() == 'INR') &&
        (currentUserId == null || currentUserId == fromUserId);

    showDialog(
      context: context,
      builder: (ctx) => KeyboardSafeDialog(
        child: SelectSettleOptionDialog(
          name: name,
          initials: initials,
          amount: amount,
          currency: currency,
          showPayWithUpi: showPayWithUpi,
          onMarkAsPaid: () {
            Navigator.pop(ctx);
            _showMarkAsPaid(context, groupId, name, initials, amount, fromUserId, toUserId, currency, currentUserId, onComplete);
          },
          onPayWithUpi: () {
            Navigator.pop(ctx);
            _showPayWithUpi(context, groupId, name, initials, amount, fromUserId, toUserId, currency, currentUserId, onComplete);
          },
        ),
      ),
    );
  }

  static void _showMarkAsPaid(
    BuildContext context,
    String groupId,
    String name,
    String initials,
    String amount,
    String fromUserId,
    String toUserId,
    String currency,
    String? currentUserId,
    VoidCallback? onComplete,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => KeyboardSafeDialog(
        child: MarkAsPaidDialog(
          groupId: groupId,
          name: name,
          initials: initials,
          amount: amount,
          fromUserId: fromUserId,
          toUserId: toUserId,
          currency: currency,
          currentUserId: currentUserId,
          onBack: () {
            Navigator.pop(ctx);
            _showSelectOption(context, groupId, name, initials, amount, fromUserId, toUserId, currency, currentUserId, onComplete);
          },
          onComplete: onComplete,
        ),
      ),
    );
  }

  static void _showPayWithUpi(
    BuildContext context,
    String groupId,
    String name,
    String initials,
    String amount,
    String fromUserId,
    String toUserId,
    String currency,
    String? currentUserId,
    VoidCallback? onComplete,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => KeyboardSafeDialog(
        child: PayWithUpiDialog(
          groupId: groupId,
          name: name,
          initials: initials,
          amount: amount,
          fromUserId: fromUserId,
          toUserId: toUserId,
          currency: currency,
          onBack: () {
            Navigator.pop(ctx);
            _showSelectOption(context, groupId, name, initials, amount, fromUserId, toUserId, currency, currentUserId, onComplete);
          },
          onComplete: onComplete,
        ),
      ),
    );
  }
}
