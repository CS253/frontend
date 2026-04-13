import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ApiClient _apiClient;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "545892068210-upjf18pmi2qtflne3qeegj87s3c715o7.apps.googleusercontent.com",
  );

  AuthService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

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

      // Reload user to get latest emailVerified status
      await user?.reload();
      final refreshedUser = _auth.currentUser;

      // If the email is NOT verified, treat this account as non-existent:
      // delete the stale Firebase account and reject the login.
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        await refreshedUser.delete();
        await _auth.signOut();
        throw Exception(
          'Account not found. Please register first.',
        );
      }

      final token = await refreshedUser?.getIdToken();

      if (token != null) {
        await syncWithBackend(
          token: token,
          name: refreshedUser?.displayName,
          phone: refreshedUser?.phoneNumber,
        );
      }

      return {
        'token': token,
        'user': {
          'id': refreshedUser?.uid,
          'name': refreshedUser?.displayName ?? email.split('@').first,
          'email': refreshedUser?.email,
          'phone': refreshedUser?.phoneNumber,
          'avatarUrl': refreshedUser?.photoURL,
          'isEmailVerified': refreshedUser?.emailVerified ?? false,
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
      return await _createAndSetupUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
    } on FirebaseAuthException catch (e) {
      // If the email is already in use, check if the existing account is
      // unverified. If so, delete the stale account and retry registration.
      if (e.code == 'email-already-in-use') {
        try {
          final existing = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          final existingUser = existing.user;
          if (existingUser != null) {
            await existingUser.reload();
            final refreshed = _auth.currentUser;
            if (refreshed != null && !refreshed.emailVerified) {
              // Old unverified account — delete and retry
              await refreshed.delete();
              await _auth.signOut();
              return await _createAndSetupUser(
                email: email,
                password: password,
                name: name,
                phone: phone,
              );
            }
          }
          // Account exists and IS verified (or sign-in succeeded) — sign out
          // and report the conflict.
          await _auth.signOut();
        } catch (_) {
          // Sign-in failed (e.g. wrong password) — the email truly belongs
          // to another verified account.
        }
        throw Exception('This email is already in use by a verified account.');
      }
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  /// Helper: creates a Firebase user, sets display name, sends verification
  /// email, syncs with backend, and returns the auth response map.
  Future<Map<String, dynamic>> _createAndSetupUser({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    final user = userCredential.user;

    // Update display name if provided
    if (name != null && user != null) {
      await user.updateDisplayName(name);
      await user.reload();
    }

    // Send verification email
    await user?.sendEmailVerification();

    // Force a fresh token so the backend gets the updated display name
    final token = await user?.getIdToken(true);

    if (token != null) {
      // Sync with backend but don't fail registration if backend is
      // unreachable — the sync will be retried at login.
      await syncWithBackend(
        token: token,
        name: name,
        phone: phone,
        throwOnError: false,
      );
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
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign-In cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      final token = await user?.getIdToken();

      Map<String, dynamic>? neonUser;
      if (token != null) {
        neonUser = await syncWithBackend(
          token: token,
          name: user?.displayName,
          phone: user?.phoneNumber,
        );
      }

      return {
        'token': token,
        'user': {
          'id': neonUser?['firebaseUid'] ?? user?.uid,
          'name': neonUser?['name'] ?? user?.displayName,
          'email': neonUser?['email'] ?? user?.email,
          'phone': neonUser?['phoneNumber'] ?? user?.phoneNumber,
          'avatarUrl': user?.photoURL,
        },
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google Sign-In failed');
    }
  }

  // ---------------------------------------------------------------------------
  // Delete Current User
  // ---------------------------------------------------------------------------

  /// Deletes the currently signed-in Firebase user account.
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _apiClient.clearAuthToken();
  }

  // ---------------------------------------------------------------------------
  // Update Profile
  // ---------------------------------------------------------------------------

  Future<void> updatePhone({required String phone}) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateUserProfile,
        body: {'phoneNumber': phone},
      );

      if (response == null || response['success'] != true) {
        throw Exception(response?['error'] ?? 'Failed to update phone number');
      }
    } catch (e) {
      if (e is ApiException) {
        throw Exception(e.message);
      }
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ---------------------------------------------------------------------------
  // Backend Synchronization
  // ---------------------------------------------------------------------------

  /// Syncs the Firebase user with the backend Neon DB and returns Neon user.
  Future<Map<String, dynamic>?> syncWithBackend({
    required String token,
    String? name,
    String? phone,
    bool throwOnError = false,
  }) async {
    debugPrint('DEBUG: Starting backend sync...');
    debugPrint('DEBUG: Sync Params - Name: $name, Phone: $phone');
    try {
      final response = await _apiClient.post(
        ApiEndpoints.userSync,
        body: {
          'idToken': token,
          if (name != null && name.isNotEmpty) 'name': name,
          if (phone != null && phone.isNotEmpty) 'phoneNumber': phone,
        },
      );

      debugPrint('DEBUG: Sync response: $response');

      if (response != null && response['success'] == true) {
        debugPrint('DEBUG: Sync successful, setting auth token');
        _apiClient.setAuthToken(token);
        return response['data'] as Map<String, dynamic>?;
      } else {
        debugPrint('DEBUG: Sync failed: ${response?['error']}');
        if (throwOnError) {
          throw Exception(response?['error'] ?? 'Backend sync failed');
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Backend sync error: $e');
      if (throwOnError) {
        if (e is ApiException) {
          throw Exception(e.message);
        }
        throw Exception(e.toString().replaceFirst('Exception: ', ''));
      }
    }
    return null;
  }
}
