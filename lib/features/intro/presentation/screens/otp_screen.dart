// =============================================================================
// OTP Screen — OTP verification page for registration flow.
//
// VALIDATION:
//   • OTP * — Required, must be numeric, must be exactly 6 digits
//   • Continue button is BLOCKED until OTP validation passes
//
// BACKEND CALL: AuthProvider.verifyOtp() → AuthRepository → AuthService
//   • Triggers POST /auth/verify-otp
//   • TODO: Replace mock data once backend API is connected
//
// Data Flow: OtpScreen → AuthProvider.verifyOtp() → AuthRepository → AuthService
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for authentication changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToAuth();
    });
  }

  void _listenToAuth() {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    
    // Check initial state
    if (authProvider.isAuthenticated) {
      _navigateToCreatePassword();
      return;
    }

    // Listen for future changes
    authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      authProvider.removeListener(_onAuthChanged);
      _navigateToCreatePassword();
    }
  }

  void _navigateToCreatePassword() {
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteConstants.createPassword,
      (route) => false,
    );
  }

  @override
  void dispose() {
    // Make sure to remove listener to avoid memory leaks
    context.read<AuthProvider>().removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.magicLinkEmail ?? 'your email';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context) 
            ? const BackButton(color: Colors.black) 
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: 243,
                    height: 243,
                    child: Image.asset(
                      'assets/images/signin_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Check Your Email',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ve sent a verification link to\n$email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF828282),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please click the link in the email to complete your registration. This screen will automatically update once you\'re verified.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF5A7184),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Loading indicator to show we're waiting for verification
                const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6BB5E5)),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // Navigate back to register to try another email
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Try another email',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6BB5E5),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
