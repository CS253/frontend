import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../../core/constants/route_constants.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const OtpVerificationScreen({super.key, this.arguments});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendCountdown = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _resendCountdown--;
        });
      }
    });
  }

  Future<void> _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    final authProvider = context.read<AuthProvider>();
    
    // Determine context (SignIn vs Enrollment)
    final isSignIn = widget.arguments?['isSignIn'] ?? true;
    
    bool success;
    if (isSignIn) {
      success = await authProvider.resolveMfaSignIn(otp);
    } else {
      success = await authProvider.completeMfaEnrollment(otp);
    }

    if (success && mounted) {
      if (isSignIn) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.trips,
          (route) => false,
        );
      } else {
        Navigator.pop(context, true); // Return to settings/profile
      }
    }
  }

  void _handleResend() {
    if (!_canResend) return;
    
    final authProvider = context.read<AuthProvider>();
    final isSignIn = widget.arguments?['isSignIn'] ?? true;

    if (isSignIn) {
      final hint = authProvider.mfaResolver?.hints.first;
      if (hint != null) {
        authProvider.sendMfaSignInCode(hint);
      }
    } else {
      final phoneNumber = widget.arguments?['phoneNumber'];
      if (phoneNumber != null) {
        authProvider.startMfaEnrollment(phoneNumber);
      }
    }
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = widget.arguments?['phoneNumber'] ?? 'your phone number';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Color(0xFF6BB5E5),
              ),
              const SizedBox(height: 32),
              const Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the 6-digit code sent to\n$phoneNumber',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B8893),
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => _buildOtpField(index),
                ),
              ),
              const SizedBox(height: 48),
              if (context.watch<AuthProvider>().errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    context.watch<AuthProvider>().errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BB5E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Color(0xFF8B8893)),
                  ),
                  GestureDetector(
                    onTap: _canResend ? _handleResend : null,
                    child: Text(
                      _canResend ? 'Resend' : 'Resend in ${_resendCountdown}s',
                      style: TextStyle(
                        color: _canResend
                            ? const Color(0xFF6BB5E5)
                            : const Color(0xFF8B8893),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        autofocus: index == 0,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEDEDED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _handleVerify();
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
