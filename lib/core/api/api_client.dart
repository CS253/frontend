// =============================================================================
// API Client — Centralized HTTP client for all backend communication.
//
// This class provides a reusable, interceptor-ready HTTP client with:
//   • Auth token injection (Bearer token)
//   • Request/response logging (debug mode)
//   • Standardized error handling via ApiException
//   • Multipart file upload support
//   • Mock data fallbacks for development
//
// TODO: Replace baseUrl with real backend URL once backend is deployed.
// =============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

/// Custom exception for API errors with structured error data.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Centralized API client for all HTTP requests.
///
/// Usage:
/// ```dart
/// final client = ApiClient(baseUrl: 'https://api.travelly.app/v1');
/// client.setAuthToken('jwt-token-here');
/// final result = await client.get('/trips');
/// ```
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? ApiEndpoints.baseUrl,
        _client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // Auth Token Management
  // ---------------------------------------------------------------------------

  /// Sets the JWT auth token for authenticated requests.
  /// Called after successful login/register.
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clears the auth token on logout.
  void clearAuthToken() {
    _authToken = null;
  }

  /// Returns true if the client has an auth token set.
  bool get isAuthenticated => _authToken != null;

  // ---------------------------------------------------------------------------
  // Request Headers
  // ---------------------------------------------------------------------------

  /// Builds default headers with optional auth token injection.
  Map<String, String> _buildHeaders({Map<String, String>? customHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Inject Bearer token if available
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    // Merge any custom headers (custom headers take precedence)
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  // ---------------------------------------------------------------------------
  // Logging (Debug Only)
  // ---------------------------------------------------------------------------

  /// Logs request details in debug mode.
  void _logRequest(String method, String url, {dynamic body}) {
    if (kDebugMode) {
      debugPrint('┌── API REQUEST ──────────────────────────────');
      debugPrint('│ $method $url');
      if (body != null) {
        debugPrint('│ Body: ${jsonEncode(body)}');
      }
      debugPrint('└─────────────────────────────────────────────');
    }
  }

  /// Logs response details in debug mode.
  void _logResponse(http.Response response) {
    if (kDebugMode) {
      debugPrint('┌── API RESPONSE ─────────────────────────────');
      debugPrint('│ Status: ${response.statusCode}');
      debugPrint('│ Body: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
      debugPrint('└─────────────────────────────────────────────');
    }
  }

  // ---------------------------------------------------------------------------
  // HTTP Methods
  // ---------------------------------------------------------------------------

  /// Performs a GET request.
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    // Mock handling — Gallery photos
    if (endpoint == ApiEndpoints.photos) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _mockGetPhotos(queryParams);
    }

    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    _logRequest('GET', uri.toString());

    try {
      final response = await _client.get(uri, headers: _buildHeaders(customHeaders: headers));
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  /// Performs a POST request.
  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    // Mock handling — Gallery delete photos
    if (endpoint == ApiEndpoints.deletePhotos) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'status': 'success', 'deleted': body?['ids'] ?? []};
    }

    final url = '$baseUrl$endpoint';
    _logRequest('POST', url, body: body);

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _buildHeaders(customHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  /// Performs a PATCH request from HEAD.
  Future<dynamic> patch(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final url = '$baseUrl$endpoint';
    _logRequest('PATCH', url, body: body);

    try {
      final response = await _client.patch(
        Uri.parse(url),
        headers: _buildHeaders(customHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  /// Performs a PUT request.
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final url = '$baseUrl$endpoint';
    _logRequest('PUT', url, body: body);

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: _buildHeaders(customHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  /// Performs a DELETE request.
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    // Mock delete support — Gallery photos
    if (endpoint.startsWith(ApiEndpoints.photos)) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'status': 'success'};
    }

    final url = '$baseUrl$endpoint';
    _logRequest('DELETE', url);

    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: _buildHeaders(customHeaders: headers),
      );
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  /// Performs a simple multipart POST request (single file, no extra fields).
  ///
  /// Used by Gallery photo uploads.
  Future<dynamic> postMultipart(
    String endpoint,
    String filePath,
  ) async {
    // Mock handling — Gallery upload photo
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

    final url = '$baseUrl$endpoint';
    _logRequest('MULTIPART POST', url);

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      final authHeaders = _buildHeaders();
      authHeaders.remove('Content-Type'); // Let multipart set its own content-type
      request.headers.addAll(authHeaders);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Upload failed: $e');
    }
  }

  /// Performs a multipart POST request (for file uploads with fields).
  ///
  /// Used for trip cover image uploads.
  /// TODO: Replace with real file upload logic once backend supports it.
  Future<dynamic> uploadMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    _logRequest('MULTIPART POST', url, body: fields);

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add auth headers
      final authHeaders = _buildHeaders(customHeaders: headers);
      authHeaders.remove('Content-Type'); // Let multipart set its own content-type
      request.headers.addAll(authHeaders);

      // Add text fields
      request.fields.addAll(fields);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Upload failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Response Handling
  // ---------------------------------------------------------------------------

  /// Handles HTTP response and throws [ApiException] on error status codes.
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      // Success — parse JSON body
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    }

    // Error — attempt to parse error message from response body
    String errorMessage = 'Request failed with status $statusCode';
    dynamic errorData;

    try {
      final errorBody = jsonDecode(response.body);
      errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
      errorData = errorBody;
    } catch (_) {
      // Response body is not JSON, use default message
    }

    throw ApiException(
      statusCode: statusCode,
      message: errorMessage,
      data: errorData,
    );
  }

  // ---------------------------------------------------------------------------
  // Mock Data — Gallery Feature
  // DELETE AFTER BACKEND IS IMPLEMENTED
  // ---------------------------------------------------------------------------

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
