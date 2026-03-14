// =============================================================================
// API Endpoints — Single source of truth for all backend route paths.
//
// All endpoint strings are defined here so that:
//   • Typos are caught at compile time
//   • Changing a backend route only requires updating one place
//   • Developers can quickly see which endpoints the app uses
//
// TODO: Update these paths if backend URL structure changes.
// =============================================================================

class ApiEndpoints {
  // Prevent instantiation
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Base URL
  // ---------------------------------------------------------------------------

  /// Base URL for the API server.
  /// TODO: Replace with real backend URL before production deployment.
  static const String baseUrl = 'https://api.travelly.dev/v1';

  // ---------------------------------------------------------------------------
  // Auth Endpoints
  // ---------------------------------------------------------------------------

  /// POST — Login with email and password.
  /// Request: { "email": "...", "password": "..." }
  /// Response: { "token": "jwt", "user": { "id", "name", "email" } }
  static const String login = '/auth/login';

  /// POST — Register a new user.
  /// Request: { "email": "...", "phone": "..." }
  /// Response: { "message": "OTP sent", "tempToken": "..." }
  static const String register = '/auth/register';

  /// POST — Verify OTP during registration.
  /// Request: { "otp": "123456", "tempToken": "..." }
  /// Response: { "verified": true }
  static const String verifyOtp = '/auth/verify-otp';

  /// POST — Create password after OTP verification.
  /// Request: { "password": "...", "confirmPassword": "...", "tempToken": "..." }
  /// Response: { "token": "jwt", "user": { "id", "name", "email" } }
  static const String createPassword = '/auth/create-password';

  /// POST — Google OAuth sign-in.
  /// Request: { "idToken": "google-id-token" }
  /// Response: { "token": "jwt", "user": { "id", "name", "email" } }
  static const String googleSignIn = '/auth/google';

  /// POST — Forgot password request.
  /// Request: { "email": "..." }
  /// Response: { "message": "Reset link sent" }
  static const String forgotPassword = '/auth/forgot-password';

  /// GET — Get current user profile.
  /// Headers: `Authorization: Bearer <token>`
  /// Response: { "user": { "id", "name", "email", "phone" } }
  static const String profile = '/auth/profile';

  /// POST — Logout and invalidate token.
  /// Headers: `Authorization: Bearer <token>`
  static const String logout = '/auth/logout';

  // ---------------------------------------------------------------------------
  // Trips Endpoints
  // ---------------------------------------------------------------------------

  /// GET — Fetch list of trips (supports pagination).
  /// Query params: ?page=1&limit=10
  /// Response: { "trips": [...], "total": 20, "page": 1, "limit": 10 }
  ///
  /// POST — Create a new trip. (Multipart for cover image upload)
  /// Fields: name, destination, startDate, endDate, tripType
  /// File: coverImage
  /// Response: { "trip": { ... } }
  static const String trips = '/trips';

  /// GET — Fetch details of a specific trip.
  /// Response: { "trip": { "id", "name", "destination", ... } }
  static String tripDetail(String tripId) => '/trips/$tripId';

  /// PUT — Update a specific trip.
  static String updateTrip(String tripId) => '/trips/$tripId';

  /// DELETE — Delete a specific trip.
  static String deleteTrip(String tripId) => '/trips/$tripId';

  /// POST — Add members to a trip.
  /// Request: { "members": [{ "name": "...", "phone": "..." }] }
  /// Response: { "members": [...] }
  static String addMembers(String tripId) => '/trips/$tripId/members';

  /// GET — Get members of a trip.
  static String getMembers(String tripId) => '/trips/$tripId/members';

  /// DELETE — Remove a member from a trip.
  static String removeMember(String tripId, String memberId) =>
      '/trips/$tripId/members/$memberId';
}
