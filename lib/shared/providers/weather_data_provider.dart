import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherDataProvider extends ChangeNotifier {
  String _temperature = '--°C';
  String _condition = 'Loading weather...';
  String _windSpeed = '--';
  String _uvIndex = '--';
  String _recommendation = 'Checking conditions...';
  bool _isLoading = true;
  String _location = '';

  // Weather API key
  static const String _apiKey = 'd7efc52f9cf0460c8ad02832250409';
  // Use HTTPS to avoid cleartext network issues on Android 9+ and iOS
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  // Getters
  String get temperature => _temperature;
  String get condition => _condition;
  String get windSpeed => _windSpeed;
  String get uvIndex => _uvIndex;
  String get recommendation => _recommendation;
  bool get isLoading => _isLoading;
  String get location => _location;

  // Fetch weather data from API
  Future<void> fetchWeatherData({String? location}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use provided location or default to a major city
      final queryLocation = location ?? 'Lagos'; // Default to Lagos, Nigeria

      // Build HTTPS URI explicitly to ensure TLS and proper encoding
      final uri = Uri.https('api.weatherapi.com', '/v1/current.json', {
        'key': _apiKey,
        'q': queryLocation,
        'aqi': 'yes',
      });

      // Add a timeout to avoid indefinite loading if the network hangs
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['current'] != null) {
          _updateWeatherFromApi(data);
        } else {
          debugPrint('Weather API: unexpected payload: ${response.body}');
          _handleWeatherError();
        }
      } else {
        debugPrint(
          'Weather API error ${response.statusCode}: ${response.body}',
        );
        _handleWeatherError();
      }
    } catch (e) {
      debugPrint('Weather API Error: $e');
      _handleWeatherError();
    }
  }

  void _updateWeatherFromApi(Map<String, dynamic> data) {
    final current = data['current'];
    final location = data['location'];

    _location = '${location['name']}, ${location['country']}';
    _temperature = '${current['temp_c'].round()}°C';
    _condition = current['condition']['text'];

    final windKph = current['wind_kph'];
    if (windKph < 10) {
      _windSpeed = 'Light breeze (${windKph.round()} km/h)';
    } else if (windKph < 25) {
      _windSpeed = 'Moderate wind (${windKph.round()} km/h)';
    } else {
      _windSpeed = 'Strong wind (${windKph.round()} km/h)';
    }

    final uv = current['uv'];
    if (uv <= 2) {
      _uvIndex = 'Low - minimal protection needed';
    } else if (uv <= 5) {
      _uvIndex = 'Moderate - wear sunscreen';
    } else if (uv <= 7) {
      _uvIndex = 'High - extra protection needed';
    } else {
      _uvIndex = 'Very high - avoid midday sun';
    }

    _recommendation = _generateCyclingRecommendation(current);
    _isLoading = false;
    notifyListeners();
  }

  String _generateCyclingRecommendation(Map<String, dynamic> current) {
    final temp = current['temp_c'];
    final windKph = current['wind_kph'];
    final humidity = current['humidity'];
    final condition = current['condition']['text'].toLowerCase();

    // Check for rain
    if (condition.contains('rain') ||
        condition.contains('drizzle') ||
        condition.contains('shower')) {
      return 'Wet conditions - consider indoor training';
    }

    // Check for extreme weather
    if (condition.contains('storm') ||
        condition.contains('snow') ||
        condition.contains('fog')) {
      return 'Poor conditions - indoor training recommended';
    }

    // Temperature recommendations
    if (temp < 5) {
      return 'Very cold - dress warmly and warm up properly';
    } else if (temp < 15) {
      return 'Cool weather - great for cycling with layers';
    } else if (temp > 35) {
      return 'Very hot - stay hydrated and avoid peak hours';
    }

    // Wind recommendations
    if (windKph > 30) {
      return 'Windy conditions - plan route carefully';
    }

    // Good conditions
    if (temp >= 15 && temp <= 25 && windKph < 15) {
      return 'Perfect cycling weather!';
    } else if (temp >= 10 && temp <= 30 && windKph < 20) {
      return 'Good conditions for cycling';
    } else {
      return 'Fair cycling conditions';
    }
  }

  void _handleWeatherError() {
    _temperature = '--°C';
    _condition = 'Unable to load weather';
    _windSpeed = '--';
    _uvIndex = '--';
    _recommendation = 'Weather data unavailable';
    _location = '';
    _isLoading = false;
    notifyListeners();
  }

  // Manual weather update (for testing)
  void updateWeather({
    required String temperature,
    required String condition,
    required String windSpeed,
    required String uvIndex,
    required String recommendation,
  }) {
    _temperature = temperature;
    _condition = condition;
    _windSpeed = windSpeed;
    _uvIndex = uvIndex;
    _recommendation = recommendation;
    _isLoading = false;
    notifyListeners();
  }
}
