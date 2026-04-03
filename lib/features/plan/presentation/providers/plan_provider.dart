import 'package:flutter/material.dart';
import 'package:travelly/core/api/api_client.dart';
import '../../data/models/route_model.dart';
import '../../data/services/plan_service.dart';

class PlanProvider with ChangeNotifier {
  final PlanService _service;

  PlanProvider({required PlanService service}) : _service = service;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RouteResponse? _routeResponse;
  RouteResponse? get routeResponse => _routeResponse;

  // ---------------------------------------------------------------------------
  // Operations
  // ---------------------------------------------------------------------------

  /// Plans an optimized route based on the provided request.
  Future<void> planRoute(RouteRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routeResponse = await _service.planRoute(request);
    } catch (e) {
      if (e is ApiException && e.statusCode == 400 ||
          e.toString().toLowerCase().contains('bad request')) {
        _errorMessage = 'Invalid stop name entered';
      } else {
        _errorMessage = e.toString();
      }
      debugPrint('Route Planning Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current route data.
  void clearRoute() {
    _routeResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
