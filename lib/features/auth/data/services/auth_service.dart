import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb 
      ? "545892068210-upjf18pmi2qtflne3qeegj87s3c715o7.apps.googleusercontent.com" 
      : null,
  );

  AuthService({required dynamic apiClient}); // Keep constructor for compatibility
 
   User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      final token = await user?.getIdToken();

      return {
        'token': token,
        'user': {
          'id': user?.uid,
          'name': user?.displayName ?? email.split('@').first,
          'email': user?.email,
          'phone': user?.phoneNumber,
        },
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  // ---------------------------------------------------------------------------
  // Register (Email Magic Link)
  // ---------------------------------------------------------------------------



  /// Sends a Passwordless Sign-in link to the user's email.
  Future<void> sendSignInLink(String email) async {
    try {
      // Dynamic URL for Web support (redirects back to localhost if testing locally)
      // IMPORTANT: This URL MUST be whitelisted in Firebase Console > Auth > Settings > Authorized Domains
      final String baseUrl = kIsWeb ? Uri.base.origin : 'https://travelly-66659.firebaseapp.com';
      final String redirectUrl = '$baseUrl/login';

      var actionCodeSettings = ActionCodeSettings(
        url: redirectUrl, 
        handleCodeInApp: true,
        androidPackageName: 'com.10bit.travelly',
        androidMinimumVersion: '21',
        androidInstallApp: true,
        iOSBundleId: 'com.10bit.travelly',
      );

      await _auth.sendSignInLinkToEmail(
        email: email, 
        actionCodeSettings: actionCodeSettings,
      );
      
      // Persist the email because we need it when the link is clicked
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('magic_link_email', email);
      
      debugPrint('Magic link sent to $email and saved to prefs');
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send magic link');
    }
  }

  /// Completes the sign-in process after the user clicks the link in their email.
  Future<Map<String, dynamic>> signInWithEmailLink(String email, String emailLink) async {
    try {
      final userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      final user = userCredential.user;
      final token = await user?.getIdToken();

      // Clear the persisted email
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('magic_link_email');

      return {
        'token': token,
        'user': {
          'id': user?.uid,
          'name': user?.displayName ?? email.split('@').first,
          'email': user?.email,
        },
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Magic link sign-in failed');
    }
  }

  /// Checks if a dynamic link is actually a sign-in link.
  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  /// Retrieves the persisted magic link email.
  Future<String?> getPersistedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('magic_link_email');
  }

  // ---------------------------------------------------------------------------
  // Create Password
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> createPassword({
    required String password,
    required String confirmPassword,
    required String tempToken,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not signed in');

      await user.updatePassword(password);
      
      final token = await user.getIdToken();

      return {
        'token': token,
        'user': {
          'id': user.uid,
          'name': user.displayName ?? 'Traveller',
          'email': user.email,
          'phone': user.phoneNumber,
        },
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password update failed');
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      final token = await user?.getIdToken();

      return {
        'token': token,
        'user': {
          'id': user?.uid,
          'name': user?.displayName,
          'email': user?.email,
        },
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google Sign-In failed');
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
