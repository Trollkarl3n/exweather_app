import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forecast.dart';
import '../models/location.dart';
import '../services/constants.dart';

class WeatherApi {
  final http.Client client;

  WeatherApi(this.client);

  Future<Forecast> getWeather(String cityName) async {
    try {
      final location = await getLocation(cityName);
      final forecastData = await _getForecast(location);
      final currentData = await _getCurrent(location);

      final combinedData = {
        'list': forecastData['list'],
        'city': forecastData['city'],
        'current': {
          'dt': currentData['dt'],
          'sunrise': currentData['sys']['sunrise'],
          'sunset': currentData['sys']['sunset'],
          'temp': currentData['main']['temp'],
          'feels_like': currentData['main']['feels_like'],
          'clouds': currentData['clouds']['all'],
          'weather': currentData['weather']
        }
      };

      final forecast = Forecast.fromJson(combinedData);
      return forecast;
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<Location> getLocation(String cityName) async {
    final url = Uri.parse('$endPointUrl/weather?q=$cityName&appid=$apiKey');
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw Exception('Error getting location: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return Location.fromJson(data);
  }

  Future<Map<String, dynamic>> _getCurrent(Location location) async {
    final url = Uri.parse(
        '$endPointUrl/weather?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey');
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw Exception('Error getting current weather: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> _getForecast(Location location) async {
    final url = Uri.parse(
        '$endPointUrl/forecast?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey');
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw Exception('Error getting forecast: ${response.body}');
    }

    return jsonDecode(response.body);
  }
}
