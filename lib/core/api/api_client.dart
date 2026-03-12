import 'dart:convert';
import 'package:http/http.dart' as http;

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
    final uri = _buildUri(endpoint, queryParams);
    final response = await _client.get(uri, headers: _headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
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
