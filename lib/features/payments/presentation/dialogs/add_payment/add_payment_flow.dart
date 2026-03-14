import 'package:flutter/material.dart';
import 'package:travelly/core/widgets/keyboard_safe_dialog.dart';
import 'payment_details_dialog.dart';
import 'select_people_dialog.dart';
import 'split_amount_dialog.dart';

class AddPaymentFlow {
  static void show(BuildContext context) {
    _showDetails(context);
  }

  static void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: PaymentDetailsDialog(
          onContinue: (details) {
            Navigator.pop(context);
            _showSelectPeople(context, details);
          },
        ),
      ),
    );
  }

  static void _showSelectPeople(BuildContext context, Map<String, String> details) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: SelectPeopleDialog(
          onBack: () {
            Navigator.pop(context);
            _showDetails(context);
          },
          onContinue: (people) {
            Navigator.pop(context);
            _showSplitAmount(context, details, people);
          },
        ),
      ),
    );
  }

  static void _showSplitAmount(
    BuildContext context,
    Map<String, String> details,
    List<String> people,
  ) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: SplitAmountDialog(
          paymentDetails: details,
          selectedPeopleNames: people,
          onBack: () {
            Navigator.pop(context);
            _showSelectPeople(context, details);
          },
        ),
      ),
    );
  }
}
