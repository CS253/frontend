import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn is now a singleton in version 7.x
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;
  RecaptchaVerifier? _webRecaptchaVerifier;

  AuthService({
    required dynamic apiClient,
  }); // Keep constructor for compatibility

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;

    await _googleSignIn.initialize(
      clientId: kIsWeb
          ? "545892068210-upjf18pmi2qtflne3qeegj87s3c715o7.apps.googleusercontent.com"
          : null,
    );
    _isGoogleSignInInitialized = true;
  }

  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      final token = await user?.getIdToken();

      return {
        'token': token,
        'user': {
          'id': user?.uid,
          'name': user?.displayName ?? email.split('@').first,
          'email': user?.email,
          'phone': user?.phoneNumber,
          'avatarUrl': user?.photoURL,
        },
      };
    } on FirebaseAuthMultiFactorException catch (_) {
      // Re-throw specific MFA exception to be handled by the provider/UI
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  // ---------------------------------------------------------------------------
  // Multi-Factor Authentication (MFA)
  // ---------------------------------------------------------------------------

  /// Sends a verification code to the given phone number for MFA enrollment.
  Future<void> verifyPhoneNumberForMfa({
    required MultiFactorSession session,
    String? phoneNumber,
    MultiFactorInfo? hint,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    // Web requires a RecaptchaVerifier to be initialized even if not passed to verifyPhoneNumber
    if (kIsWeb && _webRecaptchaVerifier == null) {
      _webRecaptchaVerifier = RecaptchaVerifier(
        container: 'auth-container', // This ID must exist in your index.html
        size: RecaptchaVerifierSize.compact,
        auth: _auth as dynamic,
      );
      // On web, the verifier needs to be rendered
      _webRecaptchaVerifier?.render();
    }

    try {
      if (phoneNumber != null) {
        // For enrollment
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          multiFactorSession: session,
          verificationCompleted: (_) {},
          verificationFailed: onVerificationFailed,
          codeSent: onCodeSent,
          codeAutoRetrievalTimeout: (_) {},
        );
      } else if (hint != null) {
        // For sign-in challenge
        await _auth.verifyPhoneNumber(
          multiFactorInfo: hint as PhoneMultiFactorInfo,
          multiFactorSession: session,
          verificationCompleted: (_) {},
          verificationFailed: onVerificationFailed,
          codeSent: onCodeSent,
          codeAutoRetrievalTimeout: (_) {},
        );
      } else {
        throw Exception('Either phoneNumber or hint must be provided');
      }
    } catch (e) {
      throw Exception('Failed to send verification code: $e');
    }
  }

  /// Completes the MFA enrollment process.
  Future<void> enrollMfa({
    required String verificationId,
    required String smsCode,
    String? displayName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      await user.multiFactor.enroll(assertion, displayName: displayName);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'MFA enrollment failed');
    }
  }

  /// Resolves an MFA sign-in challenge.
  Future<UserCredential> resolveMfaSignIn({
    required MultiFactorResolver resolver,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      return await resolver.resolveSignIn(assertion);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'MFA verification failed');
    }
  }

  /// Helper to get MultiFactorResolver from a FirebaseAuthMultiFactorException
  MultiFactorResolver getResolver(FirebaseAuthMultiFactorException e) {
    return e.resolver;
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
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

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
          'avatarUrl': user?.photoURL,
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
  // Password Reset
  // ---------------------------------------------------------------------------

  /// Sends a password reset email to the specified email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email');
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
  // Change Password
  // ---------------------------------------------------------------------------

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not signed in');
      }

      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect current password');
      }
      throw Exception(e.message ?? 'Failed to change password');
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> googleSignIn() async {
    try {
      await _ensureGoogleSignInInitialized();

      final googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
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
          'avatarUrl': user?.photoURL,
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
    await _ensureGoogleSignInInitialized();
    await _googleSignIn.signOut();
  }
}
