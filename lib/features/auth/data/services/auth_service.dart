import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ApiClient _apiClient;

  // GoogleSignIn is now a singleton in version 7.x
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

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

      if (token != null) {
        await syncWithBackend(token);
      }

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

      if (token != null) {
        await syncWithBackend(token);
      }

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

      if (token != null) {
        await syncWithBackend(token);
      }

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
    _apiClient.clearAuthToken();
  }

  // ---------------------------------------------------------------------------
  // Backend Synchronization
  // ---------------------------------------------------------------------------

  /// Syncs the Firebase user with the backend Neon DB.
  Future<void> syncWithBackend(String token) async {
    debugPrint('DEBUG: Starting backend sync...');
    debugPrint('DEBUG: Token: ${token.substring(0, 10)}...');
    try {
      final response = await _apiClient.post(
        ApiEndpoints.userSync,
        body: {'idToken': token},
      );

      debugPrint('DEBUG: Sync response: $response');

      if (response != null && response['success'] == true) {
        debugPrint('DEBUG: Sync successful, setting auth token');
        _apiClient.setAuthToken(token);
      } else {
        debugPrint('DEBUG: Sync failed: ${response?['error']}');
      }
    } catch (e) {
      debugPrint('DEBUG: Backend sync error: $e');
    }
  }
}
