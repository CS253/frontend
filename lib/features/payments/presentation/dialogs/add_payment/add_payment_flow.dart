import 'package:flutter/material.dart';
import 'package:travelly/core/widgets/keyboard_safe_dialog.dart';
import 'payment_details_dialog.dart';
import 'select_people_dialog.dart';
import 'split_amount_dialog.dart';

class AddPaymentFlow {
  static void show(BuildContext context) {
    _showDetails(context, null, null);
  }

  static void _showDetails(
    BuildContext context,
    Map<String, String>? initialDetails,
    List<String>? initialPeople,
  ) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: PaymentDetailsDialog(
          initialDetails: initialDetails,
          onContinue: (details) {
            Navigator.pop(context);
            _showSelectPeople(context, details, initialPeople);
          },
        ),
      ),
    );
  }

  static void _showSelectPeople(
    BuildContext context,
    Map<String, String> details,
    List<String>? initialPeople,
  ) {
    showDialog(
      context: context,
      builder: (context) => KeyboardSafeDialog(
        child: SelectPeopleDialog(
          initialPeople: initialPeople,
          onBack: () {
            Navigator.pop(context);
            _showDetails(context, details, initialPeople);
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
            _showSelectPeople(context, details, people);
          },
        ),
      ),
    );
  }
}
