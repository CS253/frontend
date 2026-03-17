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
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  /// Form key for OTP validation.
  /// The Continue button will NOT proceed if the OTP is invalid.
  final _formKey = GlobalKey<FormState>();

  /// Controllers for each OTP digit box.
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  /// Error message displayed below the OTP boxes when validation fails.
  String? _otpError;

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Collects OTP from all 6 text fields.
  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  /// Validates the OTP using Validators.validateOtp.
  /// Returns true if OTP passes all checks:
  ///   • Not empty
  ///   • Exactly 6 digits
  ///   • Numeric only
  bool _validateOtp() {
    final otp = _getOtpCode();
    final error = Validators.validateOtp(otp);
    setState(() {
      _otpError = error;
    });
    return error == null;
  }

  /// Handles OTP verification via AuthProvider.
  ///
  /// BACKEND CALL: Sends OTP verification request to server
  /// POST /auth/verify-otp with { otp, tempToken }
  /// TODO: Replace mock data once backend API is connected
  Future<void> _handleVerifyOtp() async {
    // Validation gate — blocks submission if OTP is invalid
    if (!_validateOtp()) return;

    final otpCode = _getOtpCode();

    // BACKEND CALL: AuthProvider.verifyOtp() → AuthRepository → AuthService → POST /auth/verify-otp
    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyOtp(otp: otpCode);

    if (!mounted) return;

    if (authProvider.isOtpVerified) {
      Navigator.pushNamed(context, RouteConstants.createPassword);
    } else if (authProvider.errorMessage != null) {
      Helpers.showErrorSnackbar(context, authProvider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
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
                    'Enter OTP',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // OTP field label with required indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'OTP Code',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5A7184),
                            ),
                          ),
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 6 Box OTP Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        height: 55,
                        child: TextField(
                          controller: _otpControllers[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _otpError != null ? Colors.red : const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 2),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                          ),
                          onChanged: (value) {
                            // Clear error when user types
                            if (_otpError != null) {
                              setState(() => _otpError = null);
                            }
                            if (value.isNotEmpty && index < 5) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  // OTP validation error message
                  if (_otpError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _otpError!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Continue Button — BLOCKED if OTP validation fails
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleVerifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6BB5E5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                  // Terms and Policies
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF828282),
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'By clicking continue, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(color: Colors.black),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: '\nand '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(color: Colors.black),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
