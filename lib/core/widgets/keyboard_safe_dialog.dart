import 'package:flutter/material.dart';

/// A reusable wrapper that makes dialogs keyboard-safe.
///
/// Features:
/// - Dismisses keyboard when tapping outside text fields.
/// - Adjusts padding using [MediaQuery.viewInsets.bottom] to move content above keyboard.
/// - Wraps content in [SingleChildScrollView] to prevent overflow errors.
/// - Limits dialog height to 85% of the screen height.
class KeyboardSafeDialog extends StatelessWidget {
  final Widget child;

  const KeyboardSafeDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop();
      },
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                // Catch clicks inside the dialog so it doesn't close,
                // but still dismiss the keyboard.
                FocusScope.of(context).unfocus();
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
