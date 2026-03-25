import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  /// Dynamically switches based on the platform.
  static String get baseUrl {
    // Get from .env file
    String? envBaseUrl = dotenv.env['BASE_URL'];
    
    if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
      // If we are on Android emulator, we might need to swap localhost with 10.0.2.2
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid && envBaseUrl.contains('localhost')) {
            return envBaseUrl.replaceFirst('localhost', '10.0.2.2');
          }
        } catch (_) {}
      }
      return envBaseUrl;
    }

    // Fallback logic if .env is missing or key is empty
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:5000/api';
        }
      } catch (_) {}
      return 'http://localhost:5000/api';
    }
  }

  // ---------------------------------------------------------------------------
  // Auth Endpoints
  // ---------------------------------------------------------------------------

  /// POST — Login with email and password.
  /// Request: { "email": "...", "password": "..." }
  /// Response: { "token": "jwt", "user": { "id", "name", "email" } }
  static const String login = '/auth/login';

  /// POST — Sync Firebase user with backend.
  /// Request: { "idToken": "..." }
  /// Response: { "success": true, "data": { "id", "firebaseUid", "email", "name" } }
  static const String userSync = '/users/sync';

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

  /// POST — Refresh auth token.
  static const String refreshToken = '/auth/refresh';

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

  /// Alias used by DashboardService.updateTrip()
  static String tripById(String id) => '/trips/$id';

  /// GET — Get members of a trip.
  static String tripMembers(String tripId) => '/trips/$tripId/members';

  /// POST — Add members to a trip.
  /// Request: { "members": [{ "name": "...", "phone": "..." }] }
  /// Response: { "members": [...] }
  static String addMembers(String tripId) => '/trips/$tripId/members';

  /// GET — Get members of a trip.
  static String getMembers(String tripId) => '/trips/$tripId/members';

  /// DELETE — Remove a member from a trip.
  static String removeMember(String tripId, String memberId) =>
      '/trips/$tripId/members/$memberId';

  // ---------------------------------------------------------------------------
  // Groups & Payments Endpoints
  // ---------------------------------------------------------------------------

  /// POST — Create a new group.
  static const String groups = '/groups';

  /// GET — Get group details (includes members).
  static String groupDetails(String groupId) => '/groups/$groupId';

  /// PUT — Update group title/currency.
  static String updateGroup(String groupId) => '/groups/$groupId';

  /// POST — Add member to group.
  static String groupMembers(String groupId) => '/groups/$groupId/members';

  /// GET/POST — Group expenses.
  static String groupExpenses(String groupId) => '/groups/$groupId/expenses';

  /// GET/PUT/DELETE — Single expense.
  static String groupExpense(String groupId, String expenseId) =>
      '/groups/$groupId/expenses/$expenseId';

  /// GET — Group balances (per-currency).
  static String groupBalances(String groupId) => '/groups/$groupId/balances';

  /// GET — Group settlements (with optional ?simplifyDebts=true/false).
  static String groupSettlements(String groupId) =>
      '/groups/$groupId/settlements';

  /// POST — Mark a settlement as paid.
  static String markSettlementPaid(String groupId) =>
      '/groups/$groupId/settlements/mark-paid';

  /// POST — Request payment from a debtor.
  static String requestPayment(String groupId) =>
      '/groups/$groupId/settlements/request-payment';

  /// POST — Initiate UPI payment (get deep link).
  static String initiatePayment(String groupId) =>
      '/groups/$groupId/settlements/initiate-payment';

  /// GET — Payment/reimbursement history.
  static String paymentHistory(String groupId) =>
      '/groups/$groupId/payment-history';

  /// GET — Full expense history (chronological).
  static String groupHistory(String groupId) => '/groups/$groupId/history';

  /// GET — Group summary & stats.
  static String groupSummary(String groupId) => '/groups/$groupId/summary';

  /// PUT — Toggle simplify-debts setting.
  static String simplifyDebts(String groupId) =>
      '/groups/$groupId/settings/simplify-debts';

  // ---------------------------------------------------------------------------
  // Documents Endpoints
  // ---------------------------------------------------------------------------

  static const String documents = '/documents';
  static String documentById(String id) => '/documents/$id';

  // ---------------------------------------------------------------------------
  // Dashboard Endpoints
  // ---------------------------------------------------------------------------

  static const String dashboard = '/dashboard';
  static const String recentActivity = '/dashboard/activity';

  // ---------------------------------------------------------------------------
  // Gallery Endpoints
  // ---------------------------------------------------------------------------

  static const String gallery = '/gallery';
  static const String photos = '/photos';
  static const String uploadPhoto = '/photos/upload';
  static const String deletePhotos = '/photos/delete';

  // ---------------------------------------------------------------------------
  // Plan/Route Endpoints
  // ---------------------------------------------------------------------------

  /// POST — Get optimized route and place timings.
  static const String planRoute = '/plan/route';
}
