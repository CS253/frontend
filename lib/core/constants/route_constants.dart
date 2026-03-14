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
  static const String otp = '/otp';
  static const String createPassword = '/create-password';
  static const String googleSignIn = '/google-sign-in';

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

  static const String dashboard = '/dashboard';
}
