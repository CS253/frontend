// =============================================================================
// Auth Repository — Converts raw API data into typed models.
//
// The repository layer sits between the service (raw API calls) and the
// provider (state management). It handles:
//   • JSON → Model conversion
//   • Error wrapping
//   • Token management via ApiClient
//
// Data Flow: Screen → Provider → Repository → Service → API
//
// TODO: When connecting the real backend, the repository code should
//       remain unchanged — only the service needs updating.
// =============================================================================

import '../../../../core/api/api_client.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService service;
  final ApiClient apiClient;

  AuthRepository({required this.service, required this.apiClient});

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Authenticates user with email/password and returns an [AuthResponse].
  ///
  /// On success:
  ///   1. Sets the JWT token on ApiClient for subsequent authenticated requests.
  ///   2. Returns the typed AuthResponse with token and UserModel.
  ///
  /// On failure: throws an exception.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final rawData = await service.login(email: email, password: password);
      final authResponse = AuthResponse.fromJson(rawData);

      // Set auth token for subsequent API calls
      apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Register (Email/Password + Verification)
  // ---------------------------------------------------------------------------

  /// Creates a new user with email and password and sends verification email.
  Future<AuthResponse> registerWithEmailPassword({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final rawData = await service.registerWithEmailPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      final authResponse = AuthResponse.fromJson(rawData);

      // Set auth token for subsequent API calls
      apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Sends a verification email to the current user.
  Future<void> sendVerificationEmail() async {
    try {
      await service.sendVerificationEmail();
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  /// Checks if the user's email is verified.
  Future<bool> checkEmailVerified() async {
    try {
      return await service.checkEmailVerified();
    } catch (e) {
      throw Exception('Failed to check verification status: $e');
    }
  }

  /// Sends a password reset email to the given [email].
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await service.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Authenticates with Google and returns [AuthResponse].
  Future<AuthResponse> googleSignIn() async {
    try {
      final rawData = await service.googleSignIn();
      final authResponse = AuthResponse.fromJson(rawData);

      apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Logs out the current user and clears the auth state.
  Future<void> logout() async {
    try {
      await service.logout();
    } catch (e) {
      // Even if logout API fails, clear local auth state
      apiClient.clearAuthToken();
      throw Exception('Logout failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Update Profile
  // ---------------------------------------------------------------------------

  /// Updates the user's phone number
  Future<void> updatePhone(String phone) async {
    try {
      await service.updatePhone(phone: phone);
    } catch (e) {
      throw Exception('Failed to update phone: $e');
    }
  }
}
