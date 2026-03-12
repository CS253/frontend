import 'package:flutter/material.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
              width: 64,
              height: 64,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Colors.black, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Signing in with Google...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6BB5E5)),
            ),
          ],
        ),
      ),
    );
  }
}
