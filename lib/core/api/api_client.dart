import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_endpoints.dart';

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

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? ApiEndpoints.baseUrl,
      _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  bool get isAuthenticated => _authToken != null;

  Map<String, String> _buildHeaders({Map<String, String>? customHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  void _logRequest(String method, String url, {dynamic body}) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('API REQUEST: $method $url');
    if (body != null) {
      debugPrint('API REQUEST BODY: ${jsonEncode(body)}');
    }
  }

  void _logResponse(http.Response response) {
    if (!kDebugMode) {
      return;
    }

    final preview = response.body.length > 500
        ? '${response.body.substring(0, 500)}...'
        : response.body;

    debugPrint('API RESPONSE STATUS: ${response.statusCode}');
    debugPrint('API RESPONSE BODY: $preview');
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    _logRequest('GET', uri.toString());

    try {
      final response = await _client.get(
        uri,
        headers: _buildHeaders(customHeaders: headers),
      );
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
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
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

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
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
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
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> postMultipart(String endpoint, String filePath) async {
    final url = '$baseUrl$endpoint';
    _logRequest('MULTIPART POST', url);

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      final authHeaders = _buildHeaders();
      authHeaders.remove('Content-Type');
      request.headers.addAll(authHeaders);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Upload failed: $e');
    }
  }

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
      final authHeaders = _buildHeaders(customHeaders: headers);
      authHeaders.remove('Content-Type');
      request.headers.addAll(authHeaders);
      request.fields.addAll(fields);
      request.files.add(
        await http.MultipartFile.fromPath(fileFieldName, filePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Upload failed: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }

      return null;
    }

    String errorMessage = 'Request failed with status $statusCode';
    dynamic errorData;

    try {
      final errorBody = jsonDecode(response.body);
      errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
      errorData = errorBody;
    } catch (_) {
      // Ignore invalid JSON error bodies.
    }

    throw ApiException(
      statusCode: statusCode,
      message: errorMessage,
      data: errorData,
    );
  }
}
