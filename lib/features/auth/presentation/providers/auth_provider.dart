// =============================================================================
// Auth Provider — State management for all authentication operations.
//
// This provider manages:
//   • User authentication state (logged in / logged out)
//   • Loading states for UI (login, register, verification, etc.)
//   • Error messages for UI display
//   • Current user data caching
//
// Data Flow: Screen → AuthProvider → AuthRepository → AuthService → API
// =============================================================================

import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/auth_response.dart';
import '../../data/repositories/auth_repository.dart';

/// Enum representing the current authentication status.
enum AuthStatus {
  /// Initial state — checking for stored session.
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
        isEmailVerified: currentUser.emailVerified,
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
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _user != null;

  /// Returns true if the user's email is verified.
  bool get isEmailVerified => _user?.isEmailVerified ?? false;

  // ---------------------------------------------------------------------------
  // Auth Operations
  // ---------------------------------------------------------------------------

  /// Logs in with email and password.
  Future<void> login({required String email, required String password}) async {
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

  /// Registers a new user with email and password.
  Future<void> register({
    required String email, 
    required String password,
    String? name,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final AuthResponse response = await repository.registerWithEmailPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
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

  /// Resends the verification email to the current user.
  Future<void> resendVerificationEmail() async {
    _setLoading(true);
    _clearError();

    try {
      await repository.sendVerificationEmail();
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    }

    _setLoading(false);
  }

  /// Checks the current user's email verification status by reloading.
  Future<void> checkVerificationStatus() async {
    _clearError();

    try {
      final isVerified = await repository.checkEmailVerified();
      if (_user != null) {
        _user = _user!.copyWith(isEmailVerified: isVerified);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    }
  }

  /// Signs in with Google OAuth.
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

  /// Logs out the current user and resets all auth state.
  Future<void> logout() async {
    _setLoading(true);

    try {
      await repository.logout();
    } catch (_) {
      // Proceed with local logout even if API fails
    }

    _user = null;
    _token = null;
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
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    return message;
  }
}
