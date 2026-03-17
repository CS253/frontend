class LatLng {
  final double lat;
  final double lng;

  const LatLng(this.lat, this.lng);
}

class WeatherData {
  final double currentTemp;
  final int currentWeatherCode;
  final int utcOffsetSeconds;
  final List<HourlyWeather> hourlyForecast;

  const WeatherData({
    required this.currentTemp,
    required this.currentWeatherCode,
    required this.utcOffsetSeconds,
    required this.hourlyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    
    final times = List<String>.from(hourly['time']);
    final temps = List<num>.from(hourly['temperature_2m']);
    final codes = List<num>.from(hourly['weathercode']);

    final hourlyForecast = <HourlyWeather>[];
    for (int i = 0; i < times.length; i++) {
      hourlyForecast.add(HourlyWeather(
        timeIso: times[i],
        temperature: temps[i].toDouble(),
        weatherCode: codes[i].toInt(),
      ));
    }

    return WeatherData(
      currentTemp: (current['temperature'] as num).toDouble(),
      currentWeatherCode: (current['weathercode'] as num).toInt(),
      utcOffsetSeconds: (json['utc_offset_seconds'] as num).toInt(),
      hourlyForecast: hourlyForecast,
    );
  }

  /// Maps Open-Meteo weather codes to emoji icons
  String get currentConditionIcon => getWeatherIcon(currentWeatherCode);

  static String getWeatherIcon(int code) {
    if (code == 0) return "☀️";
    if (code <= 3) return "☁️";
    if (code >= 61 && code <= 67) return "🌧";
    if (code >= 71 && code <= 77) return "❄️";
    if (code >= 95) return "⛈️"; // Thunderstorm
    return "🌤";
  }

  /// Returns a descriptive string for the weather code
  String get currentConditionText => getWeatherDescription(currentWeatherCode);

  static String getWeatherDescription(int code) {
    if (code == 0) return "Clear Sky";
    if (code == 1) return "Mainly Clear";
    if (code == 2) return "Partly Cloudy";
    if (code == 3) return "Overcast";
    if (code >= 45 && code <= 48) return "Fog";
    if (code >= 51 && code <= 55) return "Drizzle";
    if (code >= 61 && code <= 67) return "Rain";
    if (code >= 71 && code <= 77) return "Snow";
    if (code >= 80 && code <= 82) return "Showers";
    if (code >= 95) return "Thunderstorm";
    return "Unknown";
  }
}

class HourlyWeather {
  final String timeIso;
  final double temperature;
  final int weatherCode;

  const HourlyWeather({
    required this.timeIso,
    required this.temperature,
    required this.weatherCode,
  });

  String get conditionIcon => WeatherData.getWeatherIcon(weatherCode);
}

class CachedWeather {
  final WeatherData data;
  final DateTime cachedAt;

  const CachedWeather(this.data, this.cachedAt);

  bool get isExpired {
    // Cache expires after 15 minutes
    return DateTime.now().difference(cachedAt).inMinutes >= 15;
  }
}
