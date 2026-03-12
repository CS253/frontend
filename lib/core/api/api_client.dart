import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

/// Centralized HTTP client for all API calls.
class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://api.travelly.dev/v1',
          ),
        _client = client ?? http.Client();

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    // Mock handling from develop branch
    if (endpoint == ApiEndpoints.photos) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _mockGetPhotos(queryParams);
    }

    final uri = _buildUri(endpoint, queryParams);
    final response = await _client.get(uri, headers: _headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    // Mock handling from develop branch
    if (endpoint == ApiEndpoints.deletePhotos) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'status': 'success', 'deleted': body?['ids'] ?? []};
    }

    final uri = _buildUri(endpoint);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    String filePath,
  ) async {
    // Mock handling from develop branch
    if (endpoint == ApiEndpoints.uploadPhoto) {
      await Future.delayed(const Duration(seconds: 1));

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

    final uri = _buildUri(endpoint);

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers)
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await _client.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    // Mock delete support from develop
    if (endpoint.startsWith(ApiEndpoints.photos)) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'status': 'success'};
    }

    final uri = _buildUri(endpoint);
    final response = await _client.delete(uri, headers: _headers);
    return _processResponse(response);
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final url = '$baseUrl$endpoint';
    if (queryParams != null && queryParams.isNotEmpty) {
      return Uri.parse(url).replace(queryParameters: queryParams);
    }
    return Uri.parse(url);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final body = response.body;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return {};
      return jsonDecode(body) as Map<String, dynamic>;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body.isNotEmpty
          ? (jsonDecode(body)['message'] ?? 'Unknown error')
          : 'Request failed with status ${response.statusCode}',
    );
  }

  // -------------------------
  // Mock data from develop
  // -------------------------
  Map<String, dynamic> _mockGetPhotos(Map<String, String>? queryParams) {
    int page = int.tryParse(queryParams?['page'] ?? '1') ?? 1;
    int limit = int.tryParse(queryParams?['limit'] ?? '20') ?? 20;

    List<Map<String, dynamic>> mockData = [
      {
        'id': '1',
        'imageUrl':
            'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?q=80&w=600&auto=format&fit=crop',
        'authorName': 'Rahul',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'imageUrl':
            'https://images.unsplash.com/photo-1708534272224-a3094a51b1eb?w=700&auto=format&fit=crop&q=60',
        'authorName': 'Priya',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'imageUrl':
            'https://images.unsplash.com/photo-1494500764479-0c8f2919a3d8?q=80&w=600&auto=format&fit=crop',
        'authorName': 'Amit',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '4',
        'imageUrl':
            'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=600&auto=format&fit=crop',
        'authorName': 'You',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '5',
        'imageUrl':
            'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=600&auto=format&fit=crop',
        'authorName': 'Rahul',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '6',
        'imageUrl':
            'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=600&auto=format&fit=crop',
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

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}