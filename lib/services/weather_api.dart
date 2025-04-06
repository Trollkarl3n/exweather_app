import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/forecast.dart';
import '../models/location.dart';
import 'constants.dart';

abstract class IWeatherApi {
  Future<Forecast> getWeather(Location location);
  Future<Location> getLocation(String city);
}

class WeatherApi extends IWeatherApi {
  final http.Client httpClient;

  WeatherApi(this.httpClient);

  @override
  Future<Location> getLocation(String city) async {
    final requestUrl = '$endPointUrl/weather?q=$city&APPID=$apiKey';
    print("Location request URL: $requestUrl");
    try {
      final response = await httpClient.get(Uri.parse(requestUrl));

      if (response.statusCode != 200) {
        print("Error response: ${response.body}");
        throw Exception(
            'error retrieving location for city $city: ${response.statusCode}');
      }

      return Location.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("Error in getLocation: $e");
      rethrow;
    }
  }

  @override
  Future<Forecast> getWeather(Location location) async {
    final requestUrl =
        '$endPointUrl/forecast?lat=${location.latitude}&lon=${location.longitude}&APPID=$apiKey';
    print("Weather request URL: $requestUrl");

    try {
      final response = await httpClient.get(Uri.parse(requestUrl));

      if (response.statusCode != 200) {
        print("Error response: ${response.body}");
        throw Exception('error retrieving weather: ${response.statusCode}');
      }

      final currentWeatherUrl =
          '$endPointUrl/weather?lat=${location.latitude}&lon=${location.longitude}&APPID=$apiKey';
      final currentResponse = await httpClient.get(Uri.parse(currentWeatherUrl));

      if (currentResponse.statusCode != 200) {
        print("Error response: ${currentResponse.body}");
        throw Exception('error retrieving current weather: ${currentResponse.statusCode}');
      }

      final forecastData = jsonDecode(response.body);
      final currentData = jsonDecode(currentResponse.body);

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
      forecast.city = location.city;
      return forecast;
    } catch (e) {
      print("Error in getWeather: $e");
      rethrow;
    }
  }
}