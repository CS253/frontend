import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const GlassBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          if (onPressed != null) {
            onPressed!();
          } else {
            Navigator.maybePop(context);
          }
        },
        child: Container(
          margin: const EdgeInsets.all(12),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF212022),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
