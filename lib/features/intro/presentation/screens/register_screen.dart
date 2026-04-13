// =============================================================================
// Register Screen — Account registration page.
//
// VALIDATION:
//   • Name *     — Required
//   • Email *    — Required, must be valid email format
//   • Password * — Required, min 6 characters
//   • Continue button is BLOCKED until form validation passes
//
// Data Flow: RegisterScreen → AuthProvider.register() → AuthRepository → AuthService
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Handles the registration action via AuthProvider.
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    final authProvider = context.read<AuthProvider>();
    await authProvider.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      // Navigate to the "Verify Email" screen and clear the stack
      // so user can't press back to bypass verification
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteConstants.verifyEmail,
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      Helpers.showErrorSnackbar(context, authProvider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standard defensive check for newly added fields during Hot Reload
    final bool passwordVisible = _isPasswordVisible;
    final bool confirmVisible = _isConfirmPasswordVisible;

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
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.asset(
                        'assets/images/signin_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    validator: (v) => Validators.required(v, 'Name'),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: !passwordVisible,
                    validator: Validators.validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF828282),
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: !confirmVisible,
                    validator: (v) => Validators.validateConfirmPassword(
                      v,
                      _passwordController.text,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        confirmVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF828282),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'This phone number must be unique and cannot already belong to another account.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6A6A6A),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleRegister,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Register',
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

                  const SizedBox(height: 24),

                  // Already have an account?
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF828282),
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign In',
                          style: const TextStyle(
                            color: Color(0xFF6BB5E5),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.pushReplacementNamed(
                              context,
                              RouteConstants.login,
                            ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

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
                        const TextSpan(
                          text: 'By clicking register, you agree to our ',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(color: Colors.black),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(color: Colors.black),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Color(0xFF828282),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6BB5E5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
