import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../trips/presentation/screens/my_trips_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
                  'Create Password',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                
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
                      hintText: 'Enter a Password',
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
                const SizedBox(height: 16),
                
                // Confirm Password Field
                SizedBox(
                  height: 40,
                  child: TextField(
                    obscureText: !_isConfirmPasswordVisible,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
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
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF828282),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
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
                      'Start Travelling',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
    );
  }
}
