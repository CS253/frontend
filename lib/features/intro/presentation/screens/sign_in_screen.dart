import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../trips/presentation/screens/my_trips_screen.dart';
import 'register_screen.dart';
import 'google_sign_in_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Welcome back! Please sign in to continue.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Email Field
                SizedBox(
                  height: 40,
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'email@domain.com',
                      hintStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF828282),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6BB5E5)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Password Field
                SizedBox(
                  height: 40,
                  child: TextField(
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF828282),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6BB5E5)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF828282),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: const BorderSide(color: Color(0xFF828282)),
                            activeColor: const Color(0xFF6BB5E5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember Me',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF828282),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF828282),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyTripsScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BB5E5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE6E6E6),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF828282),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE6E6E6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Create an Account
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEEEEE),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_outline, color: Colors.black, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Create an Account',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Continue with Google
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoogleSignInScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEEEEE),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Normally Google logo here, substituting with Flutter's standard if needed
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata, color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Terms
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
                      const TextSpan(text: 'By clicking continue, you agree to our\n'),
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
