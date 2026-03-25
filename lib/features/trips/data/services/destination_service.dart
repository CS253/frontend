import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for fetching destination/city suggestions from an external API.
/// Uses the GeoDB Cities API (Free tier).
class DestinationService {
  static const String _baseUrl = 'http://geodb-free-service.wirefreethought.com/v1/geo';
  
  // Simple in-memory cache to avoid repeated calls for the same query
  static final Map<String, List<String>> _cache = {};

  /// Searches for cities matching the given [query].
  /// Returns a list of strings in the format: "City, Region, Country"
  static Future<List<String>> searchCities(String query) async {
    if (query.length < 2) return [];
    
    final normalizedQuery = query.trim().toLowerCase();
    if (_cache.containsKey(normalizedQuery)) {
      return _cache[normalizedQuery]!;
    }

    try {
      final url = Uri.parse('$_baseUrl/places?namePrefix=$query&limit=5&offset=0');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> places = data['data'] ?? [];
        
        final List<String> results = places.map<String>((item) {
          final String name = item['name'] ?? item['city'] ?? '';
          final String region = item['region'] ?? '';
          final String country = item['country'] ?? '';
          
          if (region.isNotEmpty) {
            return '$name, $region, $country';
          }
          return '$name, $country';
        }).toList();

        _cache[normalizedQuery] = results;
        return results;
      }
      return [];
    } catch (e) {
      // In case of error (timeout, no internet, etc.), return empty list
      return [];
    }
  }
}
