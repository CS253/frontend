// =============================================================================
// Route Constants — All named routes used in the application.
//
// Using named routes for type-safe, centralized navigation.
// =============================================================================

class RouteConstants {
  // Prevent instantiation
  RouteConstants._();

  // ---------------------------------------------------------------------------
  // Auth Flow Routes
  // ---------------------------------------------------------------------------

  static const String launch = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String googleSignIn = '/google-sign-in';
  static const String forgotPassword = '/forgot-password';
  static const String providePhone = '/provide-phone';

  // ---------------------------------------------------------------------------
  // Trip Routes
  // ---------------------------------------------------------------------------

  static const String trips = '/trips';
  static const String createTrip = '/trips/create';
  static const String addMembers = '/trips/add-members';
  static const String reviewTrip = '/trips/review';

  // ---------------------------------------------------------------------------
  // Dashboard Routes
  // ---------------------------------------------------------------------------

  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // ---------------------------------------------------------------------------
  // Feature Routes
  // ---------------------------------------------------------------------------

  static const String payments = '/payments';
  static const String plan = '/plan';
  static const String gallery = '/gallery';
  static const String documents = '/documents';

  // ---------------------------------------------------------------------------
  // Settings Routes
  // ---------------------------------------------------------------------------

  static const String accountSettings = '/account-settings';
  static const String personalInfo = '/account-settings/personal-info';
  static const String changePassword = '/account-settings/change-password';

  static const String tripSettings = '/trip-settings';
  static const String tripNotifications = '/trip-settings/notifications';
  static const String manageMembers = '/trip-settings/members';
}
