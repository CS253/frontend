// Use http package or dio optionally for a real backend
import 'api_endpoints.dart';

/// Reusable API Client to handle base URL configuration and generic error handling.
class ApiClient {
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    // For now, if no real http client is initialized, simulate delay like previous ApiService.
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulation mapping based on endpoint for our mock architecture
    if (endpoint == ApiEndpoints.photos) {
      return _mockGetPhotos(queryParams);
    }
    
    throw Exception('Endpoint not found');
  }

  Future<Map<String, dynamic>> postMultipart(String endpoint, String filePath) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (endpoint == ApiEndpoints.uploadPhoto) {
      return {
        'status': 'success',
        'photo': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'imageUrl': 'https://placehold.co/600x600/png',
          'authorName': 'You',
          'createdAt': DateTime.now().toIso8601String(),
        }
      };
    }

    throw Exception('Endpoint not found');
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (endpoint == ApiEndpoints.deletePhotos) {
      return {'status': 'success', 'deleted': body?['ids'] ?? []};
    }

    throw Exception('Endpoint not found');
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Supports deleting a single photo by ID, e.g. /photos/123
    if (endpoint.startsWith(ApiEndpoints.photos)) {
      return {'status': 'success'};
    }

    throw Exception('Endpoint not found');
  }

  // --- Mock Data Generators Below ---

  Map<String, dynamic> _mockGetPhotos(Map<String, String>? queryParams) {
    int page = int.tryParse(queryParams?['page'] ?? '1') ?? 1;
    int limit = int.tryParse(queryParams?['limit'] ?? '20') ?? 20;

    List<Map<String, dynamic>> mockData = [
      {
        'id': '1',
        'imageUrl': 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?q=80&w=600&auto=format&fit=crop',
        'authorName': 'Rahul',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'imageUrl': 'https://images.unsplash.com/photo-1708534272224-a3094a51b1eb?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDF8fHxlbnwwfHx8fHw%3D',
        'authorName': 'Priya',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'imageUrl': 'https://images.unsplash.com/photo-1494500764479-0c8f2919a3d8?q=80&w=600&auto=format&fit=crop',
        'authorName': 'Amit',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '4',
        'imageUrl': 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=600&auto=format&fit=crop',
        'authorName': 'You',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '5',
        'imageUrl': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=600&auto=format&fit=crop',
        'authorName': 'Rahul',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '6',
        'imageUrl': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=600&auto=format&fit=crop',
        'authorName': 'Priya',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    return {
      'data': mockData,
      'meta': {
        'page': page,
        'limit': limit,
        'total': 6,
      }
    };
  }
}
