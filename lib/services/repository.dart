import 'package:exweather_app/services/weather_api.dart';

import '../models/forecast.dart';

abstract class IRepository {
  Future<Forecast> getWeather(String city);
}

class Repository extends IRepository {
  final IWeatherApi weatherApi;

  Repository(this.weatherApi);

  @override
  Future<Forecast> getWeather(String city) async {
    try {
      final location = await weatherApi.getLocation(city);
      final forecast = await weatherApi.getWeather(location);
      forecast.city = location.city;
      return forecast;
    } catch (e) {
      print("Error in repository.getWeather: $e");
      rethrow;
    }
  }
}