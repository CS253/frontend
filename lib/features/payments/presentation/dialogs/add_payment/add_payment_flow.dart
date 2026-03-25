import 'package:flutter/material.dart';
import 'package:travelly/core/widgets/keyboard_safe_dialog.dart';
import 'payment_details_dialog.dart';
import 'select_people_dialog.dart';
import 'split_amount_dialog.dart';

class AddPaymentFlow {
  static void show(BuildContext context, {required String groupId, VoidCallback? onComplete}) {
    _showDetails(context, groupId, null, null, onComplete);
  }

  static void _showDetails(
    BuildContext context,
    String groupId,
    Map<String, String>? initialDetails,
    List<String>? initialPeopleIds,
    VoidCallback? onComplete,
  ) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: PaymentDetailsDialog(
          groupId: groupId,
          initialDetails: initialDetails,
          onContinue: (details) {
            Navigator.pop(context);
            _showSelectPeople(context, groupId, details, initialPeopleIds, onComplete);
          },
        ),
      ),
    );
  }

  static void _showSelectPeople(
    BuildContext context,
    String groupId,
    Map<String, String> details,
    List<String>? initialPeopleIds,
    VoidCallback? onComplete,
  ) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: SelectPeopleDialog(
          groupId: groupId,
          initialPeopleIds: initialPeopleIds,
          onBack: () {
            Navigator.pop(context);
            _showDetails(context, groupId, details, initialPeopleIds, onComplete);
          },
          onContinue: (peopleIds) {
            Navigator.pop(context);
            _showSplitAmount(context, groupId, details, peopleIds, onComplete);
          },
        ),
      ),
    );
  }

  static void _showSplitAmount(
    BuildContext context,
    String groupId,
    Map<String, String> details,
    List<String> peopleIds,
    VoidCallback? onComplete,
  ) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: SplitAmountDialog(
          groupId: groupId,
          paymentDetails: details,
          selectedPeopleIds: peopleIds,
          onBack: () {
            Navigator.pop(context);
            _showSelectPeople(context, groupId, details, peopleIds, onComplete);
          },
          onComplete: onComplete,
        ),
      ),
    );
  }
}
