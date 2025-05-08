import 'package:exweather_app/utils/extensions.dart';
import 'package:intl/intl.dart';
import '../utils/temp_converter.dart';

enum WeatherCondition {
  thunderstorm,
  drizzle,
  rain,
  snow,
  mist,
  lightCloud,
  heavyCloud,
  clear,
  unknown
}

class Weather {
  WeatherCondition condition;
  final String description;
  final String temp;
  final String feelLikeTemp;
  final int cloudiness;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String date;
  final String sunrise;
  final String sunset;

  Weather({
    required this.condition,
    required this.description,
    required this.temp,
    required this.feelLikeTemp,
    required this.cloudiness,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.date,
    required this.sunrise,
    required this.sunset,
  });

  static Weather fromCurrentJson(dynamic json, String sunrise, String sunset) {
    try {
      var weather = (json['weather'] != null && json['weather'].isNotEmpty)
          ? json['weather'][0]
          : {'main': 'Clear', 'description': 'clear sky'};

      var main = json['main'] ?? {};
      var wind = json['wind'] ?? {};
      var clouds = json['clouds'] ?? {};
      var dt = json['dt'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return Weather(
        condition: mapStringToWeatherCondition(
          weather['main'] ?? 'Clear',
          int.tryParse(clouds['all']?.toString() ?? '') ?? 0,
        ),
        description: (weather['description'] ?? 'clear sky').toString().capitalize(),
        temp: '${formatTemperature(TempConverter.kelvinToCelsius(_toDouble(main['temp'], fallback: 273.15)))}°',
        feelLikeTemp: '${formatTemperature(TempConverter.kelvinToCelsius(_toDouble(main['feels_like'], fallback: 273.15)))}°',
        cloudiness: int.tryParse(clouds['all']?.toString() ?? '') ?? 0,
        humidity: int.tryParse(main['humidity']?.toString() ?? '') ?? 0,
        windSpeed: _toDouble(wind['speed'], fallback: 0.0),
        pressure: int.tryParse(main['pressure']?.toString() ?? '') ?? 1013,
        date: DateFormat('d EEE').format(
          DateTime.fromMillisecondsSinceEpoch(dt * 1000),
        ),
        sunrise: sunrise,
        sunset: sunset,
      );
    } catch (e) {
      print("❌ Error in fromCurrentJson: $e");
      print("⚠️ Raw JSON: $json");
      rethrow;
    }
  }

  static Weather fromDailyJson(dynamic json, String sunrise, String sunset) {
    try {
      var weather = (json['weather'] != null && json['weather'].isNotEmpty)
          ? json['weather'][0]
          : {'main': 'Clear', 'description': 'clear sky'};

      var main = json['main'] ?? {};
      var wind = json['wind'] ?? {};
      var clouds = json['clouds'] ?? {};
      var dt = json['dt'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return Weather(
        condition: mapStringToWeatherCondition(
          weather['main'] ?? 'Clear',
          int.tryParse(clouds['all']?.toString() ?? '') ?? 0,
        ),
        description: (weather['description'] ?? 'clear sky').toString().capitalize(),
        temp: '${formatTemperature(TempConverter.kelvinToCelsius(_toDouble(main['temp'], fallback: 273.15)))}°',
        feelLikeTemp: '${formatTemperature(TempConverter.kelvinToCelsius(_toDouble(main['feels_like'], fallback: 273.15)))}°',
        cloudiness: int.tryParse(clouds['all']?.toString() ?? '') ?? 0,
        humidity: int.tryParse(main['humidity']?.toString() ?? '') ?? 0,
        windSpeed: _toDouble(wind['speed'], fallback: 0.0),
        pressure: int.tryParse(main['pressure']?.toString() ?? '') ?? 1013,
        date: DateFormat('d EEE').format(
          DateTime.fromMillisecondsSinceEpoch(dt * 1000),
        ),
        sunrise: sunrise,
        sunset: sunset,
      );
    } catch (e) {
      print("❌ Error in fromDailyJson: $e");
      print("⚠️ Raw JSON: $json");
      rethrow;
    }
  }

  static double _toDouble(dynamic value, {required double fallback}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static String formatTemperature(double temp) {
    return temp.round().toString();
  }

  static WeatherCondition mapStringToWeatherCondition(String input, int cloudiness) {
    switch (input) {
      case 'Thunderstorm':
        return WeatherCondition.thunderstorm;
      case 'Drizzle':
        return WeatherCondition.drizzle;
      case 'Rain':
        return WeatherCondition.rain;
      case 'Snow':
        return WeatherCondition.snow;
      case 'Clear':
        return WeatherCondition.clear;
      case 'Clouds':
        return cloudiness >= 85
            ? WeatherCondition.heavyCloud
            : WeatherCondition.lightCloud;
      case 'Mist':
        return WeatherCondition.mist;
      default:
        return WeatherCondition.unknown;
    }
  }
}
