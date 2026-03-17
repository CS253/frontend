import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

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
  // Register (Email/Password + Verification)
  // ---------------------------------------------------------------------------

  /// Creates a new user with email and password and sends verification email.
  Future<Map<String, dynamic>> registerWithEmailPassword({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      
      // Update display name if provided
      if (name != null && user != null) {
        await user.updateDisplayName(name);
      }

      // Send verification email
      await user?.sendEmailVerification();

      final token = await user?.getIdToken();

      return {
        'token': token,
        'user': {
          'id': user?.uid,
          'name': user?.displayName ?? name ?? email.split('@').first,
          'email': user?.email,
          'phone': phone ?? user?.phoneNumber,
          'isEmailVerified': user?.emailVerified ?? false,
        },
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  /// Sends a verification email to the currently signed-in user.
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      await user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send verification email');
    }
  }

  /// Reloads the user and checks if the email is verified.
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
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
