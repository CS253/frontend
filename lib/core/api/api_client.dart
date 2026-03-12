import 'dart:convert';
import 'dart:io';

/// Centralized HTTP client for all API calls.
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// final response = await client.get('/payments');
/// ```
class ApiClient {
  final String baseUrl;
  final HttpClient _httpClient;

  ApiClient({
    String? baseUrl,
  })  : baseUrl = baseUrl ?? const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://api.travelly.dev/v1',
          ),
        _httpClient = HttpClient();

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Set the auth token for all subsequent requests.
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  /// Remove the auth token.
  void clearAuthToken() {
    _defaultHeaders.remove('Authorization');
  }

  // ---------------------------------------------------------------------------
  // HTTP Methods
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final request = await _httpClient.getUrl(uri);
    _applyHeaders(request);
    return _processResponse(await request.close());
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    final request = await _httpClient.postUrl(uri);
    _applyHeaders(request);
    if (body != null) {
      request.write(jsonEncode(body));
    }
    return _processResponse(await request.close());
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    final request = await _httpClient.putUrl(uri);
    _applyHeaders(request);
    if (body != null) {
      request.write(jsonEncode(body));
    }
    return _processResponse(await request.close());
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = _buildUri(endpoint);
    final request = await _httpClient.deleteUrl(uri);
    _applyHeaders(request);
    return _processResponse(await request.close());
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final url = '$baseUrl$endpoint';
    if (queryParams != null && queryParams.isNotEmpty) {
      return Uri.parse(url).replace(queryParameters: queryParams);
    }
    return Uri.parse(url);
  }

  void _applyHeaders(HttpClientRequest request) {
    _defaultHeaders.forEach((key, value) {
      request.headers.set(key, value);
    });
  }

  Future<Map<String, dynamic>> _processResponse(
    HttpClientResponse response,
  ) async {
    final body = await response.transform(utf8.decoder).join();

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

/// Exception thrown when an API call fails.
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
