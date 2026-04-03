import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';
import '../models/route_model.dart';

class PlanService {
  final ApiClient _apiClient;

  PlanService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Sends a route planning request to the backend and returns the optimized itinerary.
  Future<RouteResponse> planRoute(RouteRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.planRoute,
      body: request.toJson(),
    );

    if (response == null) {
      throw Exception('No response from server');
    }

    // Handle both { success: true, data: {...} } and direct response shapes
    final isSuccess = response['success'] == true ||
        (response['data'] != null && response['error'] == null);

    if (isSuccess) {
      return RouteResponse.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception(response['error'] ?? response['message'] ?? 'Failed to plan route');
    }
  }
}
