import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelly/features/dashboard/data/models/weather_model.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

/// Frontend-only service for fetching weather data.
/// Uses Nominatim for geocoding and Open-Meteo for weather forecasts.
/// Includes an in-memory cache to prevent excessive API calls.
class WeatherService {
  // Singleton pattern
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  // In-memory cache: destination string -> CachedWeather
  final Map<String, CachedWeather> _cache = {};

  /// Computes weather for a destination.
  /// First checks the cache (<15 mins old). If invalid/missing, fetches via APIs.
  Future<WeatherData?> getWeather(String destination) async {
    if (destination.isEmpty) return null;

    final trimmedDest = destination.trim().toLowerCase();

    // 1. Check cache
    if (_cache.containsKey(trimmedDest)) {
      final cached = _cache[trimmedDest]!;
      if (!cached.isExpired) {
        debugPrint('WeatherService: Using cached data for "$trimmedDest"');
        return cached.data;
      } else {
        debugPrint('WeatherService: Cache expired for "$trimmedDest"');
        _cache.remove(trimmedDest);
      }
    }

    // 2. Fetch new data
    try {
      debugPrint('WeatherService: Fetching new data for "$trimmedDest"');
      final coords = await _geocode(destination);
      if (coords == null) {
        debugPrint('WeatherService: Geocoding failed for "$destination"');
        return null;
      }

      final weatherData = await _fetchWeather(coords.lat, coords.lng);
      if (weatherData != null) {
        // Save to cache
        _cache[trimmedDest] = CachedWeather(weatherData, DateTime.now());
      }
      return weatherData;
    } catch (e) {
      debugPrint('WeatherService: Error fetching weather for "$destination": $e');
      return null;
    }
  }

  /// Step 1: Convert destination string to Lat/Lng via Nominatim OpenStreetMap
  Future<LatLng?> _geocode(String destination) async {
    final uri = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(destination)}&format=json&limit=1");
    
    try {
      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'TravellyApp/1.0 (contact@travelly.app)',
        },
      ).timeout(const Duration(seconds: 10)); // Timeouts are critical for external APIs

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isNotEmpty) {
          return LatLng(
            double.parse(data[0]['lat']),
            double.parse(data[0]['lon']),
          );
        }
      }
    } catch (e) {
      debugPrint('WeatherService _geocode error: $e');
    }
    return null;
  }

  /// Step 2: Fetch weather via Open-Meteo API using coordinates
  Future<WeatherData?> _fetchWeather(double lat, double lng) async {
    final url = "https://api.open-meteo.com/v1/forecast"
        "?latitude=$lat"
        "&longitude=$lng"
        "&current_weather=true"
        "&hourly=temperature_2m,weathercode"
        "&timezone=auto";

    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return WeatherData.fromJson(data);
      }
    } catch (e) {
       debugPrint('WeatherService _fetchWeather error: $e');
    }
    return null;
  }
}
