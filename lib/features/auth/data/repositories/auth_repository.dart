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

  AuthRepository({
    required this.service,
    required this.apiClient,
  });

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
  // Register (Magic Link)
  // ---------------------------------------------------------------------------

  /// Sends a sign-in link to the email.
  Future<void> sendSignInLink(String email) async {
    try {
      await service.sendSignInLink(email);
    } catch (e) {
      throw Exception('Failed to send magic link: $e');
    }
  }

  /// Completes sign-in with the email link.
  Future<AuthResponse> signInWithEmailLink(String email, String emailLink) async {
    try {
      final rawData = await service.signInWithEmailLink(email, emailLink);
      final authResponse = AuthResponse.fromJson(rawData);

      // Set auth token for subsequent API calls
      apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      throw Exception('Email link sign-in failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Create Password
  // ---------------------------------------------------------------------------

  /// Creates a password after OTP verification and returns [AuthResponse].
  ///
  /// This completes the registration flow — the user is now fully logged in.
  Future<AuthResponse> createPassword({
    required String password,
    required String confirmPassword,
    required String tempToken,
  }) async {
    try {
      final rawData = await service.createPassword(
        password: password,
        confirmPassword: confirmPassword,
        tempToken: tempToken,
      );
      final authResponse = AuthResponse.fromJson(rawData);

      // Set auth token for subsequent API calls
      apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      throw Exception('Password creation failed: $e');
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
}
