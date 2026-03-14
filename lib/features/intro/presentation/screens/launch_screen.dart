// =============================================================================
// Launch Screen — Landing page for the Travelly app.
//
// No backend required for this screen.
// Navigates to Login screen on "Start Your Trip" button press.
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/route_constants.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Center(
                child: SizedBox(
                  width: 248,
                  height: 278,
                  child: Image.asset(
                    'assets/images/launch_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              const Text(
                'Plan, chat, split expenses, store documents,\nand relive memories — all in one beautiful space.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  color: Color(0xFF6A6A6A),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Login screen using named routes
                    Navigator.pushNamed(context, RouteConstants.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BB5E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Start Your Trip',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
