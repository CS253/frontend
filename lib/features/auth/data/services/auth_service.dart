// =============================================================================
// Auth Service — Handles all authentication-related API calls.
//
// This service communicates with the backend via ApiClient.
// It does NOT transform data — that's the repository's job.
//
// BACKEND TRIGGER POINTS:
//   • login()          → POST /auth/login
//   • register()       → POST /auth/register
//   • verifyOtp()      → POST /auth/verify-otp
//   • createPassword() → POST /auth/create-password
//   • googleSignIn()   → POST /auth/google
//   • logout()         → POST /auth/logout
//
// TODO: Replace mock implementations with real API calls when backend is ready.
// =============================================================================

import '../../../../core/api/api_client.dart';
// NOTE: ApiEndpoints import should be uncommented when real API calls are enabled.
// import '../../../../core/api/api_endpoints.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Sends login credentials to the backend.
  ///
  /// BACKEND CALL: Sends login request to server
  /// POST /auth/login
  /// Request: { "email": "...", "password": "..." }
  /// Response: { "token": "jwt", "user": { ... } }
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // Simulates a successful login response with a delay.
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(seconds: 1));
    return {
      'token': 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'user-001',
        'name': email.split('@').first,
        'email': email,
        'phone': '+1234567890',
      },
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: POST /auth/login with { email, password }
    // return await apiClient.post(
    //   ApiEndpoints.login,
    //   body: {
    //     'email': email,
    //     'password': password,
    //   },
    // );
    // -------------------------------------------------------------------------
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  /// Sends registration data to the backend.
  ///
  /// BACKEND CALL: Sends registration request to server
  /// POST /auth/register
  /// Request: { "email": "...", "phone": "..." }
  /// Response: { "message": "OTP sent", "tempToken": "..." }
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
  }) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(seconds: 1));
    return {
      'message': 'OTP sent successfully',
      'tempToken': 'mock-temp-token-${DateTime.now().millisecondsSinceEpoch}',
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: POST /auth/register with { email, phone }
    // return await apiClient.post(
    //   ApiEndpoints.register,
    //   body: {
    //     'email': email,
    //     'phone': phone,
    //   },
    // );
    // -------------------------------------------------------------------------
  }

  // ---------------------------------------------------------------------------
  // Verify OTP
  // ---------------------------------------------------------------------------

  /// Verifies the OTP code sent during registration.
  ///
  /// BACKEND CALL: Sends OTP verification request to server
  /// POST /auth/verify-otp
  /// Request: { "otp": "123456", "tempToken": "..." }
  /// Response: { "verified": true }
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String tempToken,
  }) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // Accepts any 6-digit OTP as valid in mock mode.
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(seconds: 1));
    return {
      'verified': true,
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: POST /auth/verify-otp with { otp, tempToken }
    // return await apiClient.post(
    //   ApiEndpoints.verifyOtp,
    //   body: {
    //     'otp': otp,
    //     'tempToken': tempToken,
    //   },
    // );
    // -------------------------------------------------------------------------
  }

  // ---------------------------------------------------------------------------
  // Create Password
  // ---------------------------------------------------------------------------

  /// Creates a password after OTP verification.
  ///
  /// BACKEND CALL: Sends password creation request to server
  /// POST /auth/create-password
  /// Request: { "password": "...", "confirmPassword": "...", "tempToken": "..." }
  /// Response: { "token": "jwt", "user": { ... } }
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> createPassword({
    required String password,
    required String confirmPassword,
    required String tempToken,
  }) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(seconds: 1));
    return {
      'token': 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'user-001',
        'name': 'Traveller',
        'email': 'user@travelly.dev',
        'phone': '+1234567890',
      },
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: POST /auth/create-password with { password, confirmPassword, tempToken }
    // return await apiClient.post(
    //   ApiEndpoints.createPassword,
    //   body: {
    //     'password': password,
    //     'confirmPassword': confirmPassword,
    //     'tempToken': tempToken,
    //   },
    // );
    // -------------------------------------------------------------------------
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Signs in with a Google ID token.
  ///
  /// BACKEND CALL: Sends Google sign-in request to server
  /// POST /auth/google
  /// Request: { "idToken": "google-id-token" }
  /// Response: { "token": "jwt", "user": { ... } }
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
  }) async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(seconds: 1));
    return {
      'token': 'mock-google-jwt-token',
      'user': {
        'id': 'google-user-001',
        'name': 'Google User',
        'email': 'user@gmail.com',
      },
    };
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: POST /auth/google with { idToken }
    // return await apiClient.post(
    //   ApiEndpoints.googleSignIn,
    //   body: {
    //     'idToken': idToken,
    //   },
    // );
    // -------------------------------------------------------------------------
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Logs out the current user and invalidates the token.
  ///
  /// BACKEND CALL: Sends logout request to server
  /// POST /auth/logout
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<void> logout() async {
    // -------------------------------------------------------------------------
    // MOCK DATA — REMOVE AFTER BACKEND CONNECTED
    // TODO: Replace mock data once backend API is connected
    // -------------------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 500));
    apiClient.clearAuthToken();
    // -------------------------------------------------------------------------
    // REAL API CALL — Uncomment when backend is ready:
    //
    // BACKEND CALL: POST /auth/logout
    // await apiClient.post(ApiEndpoints.logout);
    // apiClient.clearAuthToken();
    // -------------------------------------------------------------------------
  }
}
