/// Centralized API endpoint definitions.
///
/// All API paths are defined here so that endpoint changes
/// only need to be updated in one place.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Payments ──────────────────────────────────────────────────────────────
  static const String payments = '/payments';
  static const String expenses = '/payments/expenses';
  static const String balances = '/payments/balances';
  static const String settle = '/payments/settle';

  // ── Documents ─────────────────────────────────────────────────────────────
  static const String documents = '/documents';
  static String documentById(String id) => '/documents/$id';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String recentActivity = '/dashboard/activity';

  // ── Gallery ───────────────────────────────────────────────────────────────
  static const String gallery = '/gallery';

  // ── Trips ─────────────────────────────────────────────────────────────────
  static const String trips = '/trips';
  static String tripById(String id) => '/trips/$id';
  static String tripMembers(String tripId) => '/trips/$tripId/members';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
}
