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
//   • Register Button → sendSignInLink()   → GET /auth/send-link
//   • Link Clicked     → signInWithEmailLink() → GET /auth/verify-link
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

  /// Email to which the magic link was sent.
  String? _magicLinkEmail;
  String? get magicLinkEmail => _magicLinkEmail;

  /// Whether a magic link has been sent successfully.
  bool _linkSent = false;
  bool get linkSent => _linkSent;

  // ---------------------------------------------------------------------------
  // Session Persistence
  // ---------------------------------------------------------------------------
  
  /// Checks if a user is already logged in on app startup.
  Future<void> initialize() async {
    _status = AuthStatus.initial;
    final currentUser = repository.service.currentUser;

    if (currentUser != null) {
      final token = await currentUser.getIdToken();
      _token = token;
      _user = UserModel(
        id: currentUser.uid,
        name: currentUser.displayName ?? 'Traveller',
        email: currentUser.email ?? '',
        phone: currentUser.phoneNumber,
      );
      _status = AuthStatus.authenticated;
      repository.apiClient.setAuthToken(token ?? '');
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

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

  // ---------------------------------------------------------------------------
  // Register (Magic Link)
  // ---------------------------------------------------------------------------

  /// Sends a magic link to the provided email.
  Future<void> sendSignInLink(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await repository.sendSignInLink(email);
      _magicLinkEmail = email;
      _linkSent = true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _linkSent = false;
    }

    _setLoading(false);
  }

  /// Completes sign-in using the email link received in the email.
  Future<void> signInWithEmailLink(String email, String emailLink) async {
    _setLoading(true);
    _clearError();

    try {
      final AuthResponse response = await repository.signInWithEmailLink(email, emailLink);
      _token = response.token;
      _user = response.user;
      _status = AuthStatus.authenticated;
      _linkSent = false;
      _magicLinkEmail = null;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _status = AuthStatus.unauthenticated;
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
      if (_magicLinkEmail == null) {
        throw Exception('No registration session found. Please register again.');
      }

      final AuthResponse response = await repository.createPassword(
        password: password,
        confirmPassword: confirmPassword,
        tempToken: _magicLinkEmail!,
      );

      _token = response.token;
      _user = response.user;
      _status = AuthStatus.authenticated;

    // Reset registration flow data
    _magicLinkEmail = null;
    _linkSent = false;
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
  Future<void> googleSignIn() async {
    _setLoading(true);
    _clearError();

    try {
      final AuthResponse response = await repository.googleSignIn();

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
    _magicLinkEmail = null;
    _linkSent = false;
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

