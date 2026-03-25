import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Fetches coordinates (lat, lng) for a given address string.
  /// Returns a Map with 'lat' and 'lng' as doubles, or null if not found.
  static Future<Map<String, double>?> getCoordinates(String address) async {
    if (address.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?q=${Uri.encodeComponent(address)}&format=json&limit=1',
        ),
        headers: {
          'User-Agent':
              'TravellyApp/1.0', // Required by OSM Nominatim usage policy
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final first = data[0];
          return {
            'lat': double.parse(first['lat']),
            'lng': double.parse(first['lon']),
          };
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }
}
