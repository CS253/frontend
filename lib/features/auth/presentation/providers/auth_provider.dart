// =============================================================================
// Auth Provider — State management for all authentication operations.
//
// This provider manages:
//   • User authentication state (logged in / logged out)
//   • Loading states for UI (login, register, OTP, etc.)
//   • Error messages for UI display
//   • Registration flow temporary data (tempToken)
//   • Current user data caching
//
// BACKEND TRIGGER POINTS (UI Action → Provider Method → API Endpoint):
//   • Login Button    → login()          → POST /auth/login
//   • Register Button → register()       → POST /auth/register
//   • OTP Continue    → verifyOtp()      → POST /auth/verify-otp
//   • Start Travelling→ createPassword() → POST /auth/create-password
//   • Google Button   → googleSignIn()   → POST /auth/google
//   • Logout Button   → logout()         → POST /auth/logout
//
// Data Flow: Screen → AuthProvider → AuthRepository → AuthService → API
//
// The UI screens should ONLY interact with this provider.
// They should NEVER make direct API calls.
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../data/models/user_model.dart';
import '../../data/models/auth_response.dart';
import '../../data/repositories/auth_repository.dart';

/// Enum representing the current authentication status.
enum AuthStatus {
  /// Initial state — checking for stored token.
  initial,

  /// User is authenticated.
  authenticated,

  /// User is not authenticated.
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({required this.repository});

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// Current authentication status.
  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  /// Current authenticated user (null if not logged in).
  UserModel? _user;
  UserModel? get user => _user;

  /// Auth token (null if not logged in).
  String? _token;
  String? get token => _token;

  /// Whether an async operation is in progress.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message from the last failed operation.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Temporary token used during registration flow (register → OTP → create password).
  String? _tempToken;
  String? get tempToken => _tempToken;

  /// Whether OTP has been verified (used in registration flow).
  bool _isOtpVerified = false;
  bool get isOtpVerified => _isOtpVerified;

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Returns true if the user is currently authenticated.
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Logs in with email and password.
  ///
  /// BACKEND CALL: Login Button → AuthProvider.login()
  ///   → AuthRepository.login() → AuthService.login()
  ///   → POST /auth/login with { email, password }
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final AuthResponse response = await repository.login(
        email: email,
        password: password,
      );

      _token = response.token;
      _user = response.user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _status = AuthStatus.unauthenticated;
    }

    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  /// Registers a new user and stores the temp token for OTP flow.
  ///
  /// BACKEND CALL: Register Button → AuthProvider.register()
  ///   → AuthRepository.register() → AuthService.register()
  ///   → POST /auth/register with { email, phone }
  ///
  /// After calling this, navigate to the OTP screen.
  Future<void> register({
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _tempToken = await repository.register(email: email, phone: phone);
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    }

    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Verify OTP
  // ---------------------------------------------------------------------------

  /// Verifies the OTP entered by the user.
  ///
  /// BACKEND CALL: OTP Continue → AuthProvider.verifyOtp()
  ///   → AuthRepository.verifyOtp() → AuthService.verifyOtp()
  ///   → POST /auth/verify-otp with { otp, tempToken }
  ///
  /// After calling this, navigate to the Create Password screen.
  Future<void> verifyOtp({required String otp}) async {
    _setLoading(true);
    _clearError();

    try {
      if (_tempToken == null) {
        throw Exception('No registration session found. Please register again.');
      }

      _isOtpVerified = await repository.verifyOtp(
        otp: otp,
        tempToken: _tempToken!,
      );

      if (!_isOtpVerified) {
        _errorMessage = 'Invalid OTP. Please try again.';
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isOtpVerified = false;
    }

    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Create Password
  // ---------------------------------------------------------------------------

  /// Creates a password and completes the registration flow.
  ///
  /// BACKEND CALL: Start Travelling → AuthProvider.createPassword()
  ///   → AuthRepository.createPassword() → AuthService.createPassword()
  ///   → POST /auth/create-password with { password, confirmPassword, tempToken }
  ///
  /// After calling this, navigate to the Trips screen.
  Future<void> createPassword({
    required String password,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_tempToken == null) {
        throw Exception('No registration session found. Please register again.');
      }

      final AuthResponse response = await repository.createPassword(
        password: password,
        confirmPassword: confirmPassword,
        tempToken: _tempToken!,
      );

      _token = response.token;
      _user = response.user;
      _status = AuthStatus.authenticated;

      // Clear registration flow data
      _tempToken = null;
      _isOtpVerified = false;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    }

    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Signs in with Google OAuth.
  ///
  /// BACKEND CALL: Google Button → AuthProvider.googleSignIn()
  ///   → AuthRepository.googleSignIn() → AuthService.googleSignIn()
  ///   → POST /auth/google with { idToken }
  Future<void> googleSignIn({required String idToken}) async {
    _setLoading(true);
    _clearError();

    try {
      final AuthResponse response = await repository.googleSignIn(idToken: idToken);

      _token = response.token;
      _user = response.user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _status = AuthStatus.unauthenticated;
    }

    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Logs out the current user and resets all auth state.
  ///
  /// BACKEND CALL: Logout Button → AuthProvider.logout()
  ///   → AuthRepository.logout() → AuthService.logout()
  ///   → POST /auth/logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await repository.logout();
    } catch (_) {
      // Proceed with local logout even if API fails
    }

    _user = null;
    _token = null;
    _tempToken = null;
    _isOtpVerified = false;
    _status = AuthStatus.unauthenticated;
    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Extracts a user-friendly error message from an exception.
  String _extractErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    final message = error.toString();
    // Remove "Exception: " prefix if present
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    return message;
  }
}

