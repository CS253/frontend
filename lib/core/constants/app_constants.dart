// =============================================================================
// App Constants — Global constants used across the application.
// =============================================================================

class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // ---------------------------------------------------------------------------
  // App Info
  // ---------------------------------------------------------------------------

  static const String appName = 'Travelly';
  static const String appTagline =
      'Plan, chat, split expenses, store documents,\nand relive memories — all in one beautiful space.';

  // ---------------------------------------------------------------------------
  // Defaults (HEAD branch)
  // ---------------------------------------------------------------------------

  static const String defaultCurrency = '₹'; // Default symbol, used for fallbacks
  static const int defaultAnimationDurationMs = 300;

  // ---------------------------------------------------------------------------
  // Storage Keys (for SharedPreferences / secure storage)
  // ---------------------------------------------------------------------------

  /// Key for storing JWT auth token.
  static const String authTokenKey = 'auth_token';

  /// Key for storing "remember me" preference.
  static const String rememberMeKey = 'remember_me';

  /// Key for storing cached user data.
  static const String userDataKey = 'user_data';

  // ---------------------------------------------------------------------------
  // Pagination Defaults
  // ---------------------------------------------------------------------------

  /// Default page size for paginated API requests.
  static const int defaultPageSize = 10;

  /// Default starting page number.
  static const int defaultPage = 1;

  // ---------------------------------------------------------------------------
  // Timeouts
  // ---------------------------------------------------------------------------

  /// Connection timeout in seconds.
  static const int connectionTimeout = 30;

  /// Receive timeout in seconds.
  static const int receiveTimeout = 30;

  // ---------------------------------------------------------------------------
  // OTP
  // ---------------------------------------------------------------------------

  /// Number of OTP digits.
  static const int otpLength = 6;

  /// OTP resend cooldown in seconds.
  static const int otpResendCooldown = 60;

  // ---------------------------------------------------------------------------
  // Trip Types
  // ---------------------------------------------------------------------------

  static const List<Map<String, String>> tripTypes = [
    {'label': 'Beach', 'emoji': '🏖️'},
    {'label': 'Mountain', 'emoji': '⛰️'},
    {'label': 'City', 'emoji': '🏙️'},
    {'label': 'Nature', 'emoji': '🌿'},
    {'label': 'Island', 'emoji': '🏝️'},
    {'label': 'Other', 'emoji': '🌍'},
  ];
}
