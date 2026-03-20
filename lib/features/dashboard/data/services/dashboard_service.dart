import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';
import 'package:travelly/core/constants/currency.dart';

/// Service layer responsible for fetching dashboard data from the backend.
///
/// Architecture role:
///   DashboardScreen → Provider → Repository → **Service** → ApiClient
///
/// This service attempts a real HTTP request first. If the backend is
/// unavailable or returns an error, it falls back to mock data so the
/// app remains functional during development.
///
/// The mock fallback strategy mirrors the Documents feature pattern.
class DashboardService {
  final ApiClient _apiClient;

  DashboardService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches the full dashboard payload from GET /dashboard.
  ///
  /// Returns a JSON map matching the [DashboardResponseModel.fromJson]
  /// contract. On backend failure, returns mock data instead.
  Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      // ── Real API call ──────────────────────────────────────────────
      final response = await _apiClient.get(ApiEndpoints.dashboard);

      // If the response contains valid trip data, return it directly.
      if (response.containsKey('currentTrip') && response['currentTrip'] != null) {
        return response;
      }
    } catch (e) {
      // Backend unavailable — fall through to mock data below.
      // This is expected during development before the backend exists.
    }

    // ── MOCK DATA — DELETE AFTER BACKEND IS IMPLEMENTED ────────────
    // The mock data below replicates the Figma design content exactly.
    // Once the backend GET /dashboard endpoint is live and tested,
    // delete everything from this comment to the closing brace and
    // simply `return response;` from the try block above.
    return _getMockDashboardData();
    // ── END MOCK DATA ──────────────────────────────────────────────
  }

  /// Returns hardcoded mock dashboard data matching the API contract.
  ///
  /// MOCK DATA — DELETE AFTER BACKEND IS IMPLEMENTED
  ///
  /// Includes all trip fields used in the Trip Details dialog:
  ///   • name, destination, startDate, endDate, tripType, coverImage
  Map<String, dynamic> _getMockDashboardData() {
    return {
      'currentTrip': {
        'id': 'trip_mock_001',
        'name': 'Less Gooo',
        'location': 'Maldives',
        'destination': 'Maldives',
        'startDate': '2026-04-10',
        'endDate': '2026-04-20',
        'daysRemaining': 5,
        'emoji': '♠️',
        'tripType': 'Island',
        'coverImage': null, // No cover photo — will use trip-type default
        'participants': [
          {
            'id': 'user_mock_1',
            'name': 'Ronit',
            'avatarUrl': '',
            'emoji': '😊',
          },
          {
            'id': 'user_mock_2',
            'name': 'Sarim',
            'avatarUrl': '',
            'emoji': '😎',
          },
          {
            'id': 'user_mock_3',
            'name': 'Rigved',
            'avatarUrl': '',
            'emoji': '🤗',
          },
          {
            'id': 'user_mock_4',
            'name': 'Amit',
            'avatarUrl': '',
            'emoji': '😄',
          },
          {
            'id': 'user_mock_5',
            'name': 'Priya',
            'avatarUrl': '',
            'emoji': '🙂',
          },
          {
            'id': 'user_mock_6',
            'name': 'Rahul',
            'avatarUrl': '',
            'emoji': '😃',
          },
        ],
      },
      'recentActivities': [
        {
          'id': 'activity_mock_1',
          'type': 'payment_added',
          'actor': 'Ronit',
          'description': 'added ${AppCurrency.symbol}10000 for Hotel',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'iconType': 'payment',
        },
        {
          'id': 'activity_mock_2',
          'type': 'photo_shared',
          'actor': 'Sarim',
          'description': 'shared 12 photos',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
          'iconType': 'photo',
        },
        {
          'id': 'activity_mock_3',
          'type': 'document_uploaded',
          'actor': 'Rigved',
          'description': 'uploaded Flight Tickets',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'iconType': 'document',
        },
      ],
    };
  }
  // ── END MOCK DATA — DELETE AFTER BACKEND IS IMPLEMENTED ──────────

  /// Updates trip details via PUT /trips/:tripId.
  ///
  /// Sends all editable trip fields to the backend:
  ///   • name, destination, startDate, endDate, tripType, emoji
  ///   • coverImagePath (optional) — for multipart/form-data upload
  ///
  /// Falls back to a mock success response if the backend is unavailable.
  ///
  /// Architecture note: This method is called by DashboardRepository,
  /// which is called by DashboardProvider.updateTrip().
  ///
  /// BACKEND CALL: PUT /trips/:tripId
  /// TODO: When coverImagePath is provided, switch to multipart/form-data
  ///       upload instead of JSON body.
  Future<Map<String, dynamic>> updateTrip({
    required String tripId,
    required String name,
    required String destination,
    required String startDate,
    required String endDate,
    required String tripType,
    required String emoji,
    String? coverImagePath,
  }) async {
    try {
      // ── Real API call ──────────────────────────────────────────────
      // TODO: If coverImagePath is not null, use multipart/form-data
      //       to upload the cover image file along with trip data.
      final response = await _apiClient.put(
        ApiEndpoints.tripById(tripId),
        body: {
          'name': name,
          'destination': destination,
          'startDate': startDate,
          'endDate': endDate,
          'tripType': tripType,
          'emoji': emoji,
        },
      );
      return response;
    } catch (e) {
      // Backend unavailable — fall through to mock response below.
    }

    // ── MOCK DATA — DELETE AFTER BACKEND IS IMPLEMENTED ────────────
    // Simulates a successful update response.
    // Once PUT /trips/:id is implemented, delete this block.
    return {
      'status': 'success',
      'trip': {
        'id': tripId,
        'name': name,
        'destination': destination,
        'startDate': startDate,
        'endDate': endDate,
        'tripType': tripType,
        'emoji': emoji,
        'coverImage': coverImagePath,
      },
    };
    // ── END MOCK DATA ──────────────────────────────────────────────
  }
}
