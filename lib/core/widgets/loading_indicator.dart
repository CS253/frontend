import 'package:flutter/material.dart';
import 'package:travelly/core/theme/app_theme.dart';

/// Standard loading indicator for async operations.
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppTheme.accentBlue,
          ),
        ),
      ),
    );
  }
}
