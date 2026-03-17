import 'dart:convert';
import 'package:flutter/foundation.dart';

// You would add http or dio package here
// import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = 'https://api.travelly.com/v1/'});

  Future<Map<String, dynamic>> get(String endpoint) async {
    // Example implementation
    debugPrint('GET request to $baseUrl$endpoint');
    return {'status': 'success', 'data': {}};
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    debugPrint('POST request to $baseUrl$endpoint with body: ${jsonEncode(body)}');
    return {'status': 'success', 'data': body ?? {}};
  }

  Future<Map<String, dynamic>> patch(String endpoint, {Map<String, dynamic>? body}) async {
    debugPrint('PATCH request to $baseUrl$endpoint with body: ${jsonEncode(body)}');
    return {'status': 'success', 'data': body ?? {}};
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    debugPrint('DELETE request to $baseUrl$endpoint');
    return {'status': 'success', 'data': null};
  }
}
