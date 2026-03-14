// =============================================================================
// Loading Indicator — Reusable loading overlay/widget.
// =============================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Branded circular loading indicator.
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 36,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}

/// Full-screen loading overlay that can be shown over content.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const LoadingIndicator(),
          ),
      ],
    );
  }
}
