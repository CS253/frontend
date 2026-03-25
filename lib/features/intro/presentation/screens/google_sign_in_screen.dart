import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  @override
  void initState() {
    super.initState();
    // Start Google Sign-In process as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleGoogleSignIn());
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    
    await authProvider.googleSignIn();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      final user = authProvider.user;
      final bool isProfileIncomplete = user?.phone == null || 
                                       user?.phone?.isEmpty == true || 
                                       user?.name == null || 
                                       user?.name == 'Traveller';
      
      if (isProfileIncomplete) {
        // Missing name or phone: Navigate to Complete Profile screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.completeProfile,
          (route) => false,
        );
      } else {
        // Profile complete: Navigate to Trips screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.trips,
          (route) => false,
        );
      }
    } else {
      // Failure: Show error and go back
      if (authProvider.errorMessage != null) {
        Helpers.showErrorSnackbar(context, authProvider.errorMessage!);
      }
      Navigator.pop(context);
    }
  }

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
