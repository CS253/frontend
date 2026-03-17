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
  // Register (Phone Verification)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
  }) async {
    final completer = Completer<Map<String, dynamic>>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This can happen automatically on some Android devices
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError(Exception(e.message ?? 'Verification failed'));
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete({
            'message': 'OTP sent successfully',
            'tempToken': verificationId, // Use verificationId as tempToken
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return completer.future;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Verify OTP
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String tempToken,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: tempToken,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      return {
        'verified': true,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'OTP verification failed');
    }
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
