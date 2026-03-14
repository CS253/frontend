import 'package:travelly/features/dashboard/data/models/dashboard_response_model.dart';
import 'package:travelly/features/dashboard/data/services/dashboard_service.dart';

/// Repository layer that transforms raw API JSON into typed models.
///
/// Architecture role:
///   DashboardScreen → Provider → **Repository** → Service → ApiClient
///
/// The repository is the single entry point for the provider to obtain
/// dashboard data. It delegates HTTP concerns to [DashboardService]
/// and JSON parsing to [DashboardResponseModel].
///
/// This separation allows:
///   • Swapping the service implementation for testing
///   • Centralizing JSON-to-model transformation
///   • Adding caching or offline-first logic in the future
class DashboardRepository {
  final DashboardService _service;

  DashboardRepository({DashboardService? service})
      : _service = service ?? DashboardService();

  /// Fetches and parses the full dashboard data.
  ///
  /// Returns a [DashboardResponseModel] containing the current trip,
  /// participants, and recent activities.
  ///
  /// Throws on unrecoverable errors (the provider must handle these).
  Future<DashboardResponseModel> getDashboard() async {
    final response = await _service.fetchDashboard();
    return DashboardResponseModel.fromJson(response);
  }
}
