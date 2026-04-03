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
        message: 'Server can\'t be reached',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
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
        message: 'Server can\'t be reached',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
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
        message: 'Server can\'t be reached',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

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
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final url = '$baseUrl$endpoint';
    _logRequest('DELETE', url, body: body);

    try {
      final request = http.Request('DELETE', Uri.parse(url));
      request.headers.addAll(_buildHeaders(customHeaders: headers));
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
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
        message: 'Server can\'t be reached',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Upload failed: $e');
    }
  }

  Future<dynamic> _sendMultipart(
    String method,
    String endpoint, {
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    _logRequest('MULTIPART $method', url, body: fields);

    try {
      final request = http.MultipartRequest(method, Uri.parse(url));
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
        message: 'Server can\'t be reached',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message: 'Server can\'t be reached',
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
    return _sendMultipart(
      'POST',
      endpoint,
      fields: fields,
      fileFieldName: fileFieldName,
      filePath: filePath,
      headers: headers,
    );
  }

  Future<dynamic> putMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
    Map<String, String>? headers,
  }) async {
    return _sendMultipart(
      'PUT',
      endpoint,
      fields: fields,
      fileFieldName: fileFieldName,
      filePath: filePath,
      headers: headers,
    );
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

      // 409 Conflict — server detected optimistic locking violation.
      // Throw a typed ConflictException carrying fresh server data.
      if (statusCode == 409 && errorBody['error'] == 'CONFLICT') {
        throw ConflictException(
          message: 'Trip was modified by someone else.',
          freshData: errorBody['freshData'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      if (e is ConflictException) rethrow;
      // Ignore invalid JSON error bodies.
    }

    throw ApiException(
      statusCode: statusCode,
      message: errorMessage,
      data: errorData,
    );
  }
}

/// Thrown when the server returns HTTP 409 due to an optimistic locking conflict.
///
/// Carries [freshData] — the current server version of the resource —
/// so the caller can update its local cache without needing a separate fetch.
class ConflictException implements Exception {
  final String message;
  final Map<String, dynamic>? freshData;

  const ConflictException({required this.message, this.freshData});

  @override
  String toString() => 'ConflictException: $message';
}

