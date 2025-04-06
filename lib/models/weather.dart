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
  final String date;
  final String sunrise;
  final String sunset;

  Weather(
      {required this.condition,
        required this.description,
        required this.temp,
        required this.feelLikeTemp,
        required this.cloudiness,
        required this.date,
        required this.sunrise,
        required this.sunset});

  static Weather fromDailyJson(dynamic dailyForecast) {
    var weather = dailyForecast['weather'][0];
    var cloudiness = dailyForecast['clouds']['all'];
    var dt = dailyForecast['dt'];

    var now = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    var sunrise = now.subtract(const Duration(hours: 6));
    var sunset = now.add(const Duration(hours: 6));

    return Weather(
        condition: mapStringToWeatherCondition(weather['main'], cloudiness),
        description: weather['description'].toString().capitalize(),
        cloudiness: cloudiness,
        temp:
        '${formatTemperature(TempConverter.kelvinToCelsius(double.parse(dailyForecast['main']['temp'].toString())))}°',
        date: DateFormat('d EEE')
            .format(DateTime.fromMillisecondsSinceEpoch(dt * 1000)),
        sunrise: DateFormat.jm().format(sunrise),
        sunset: DateFormat.jm().format(sunset),
        feelLikeTemp:
        '${formatTemperature(TempConverter.kelvinToCelsius(double.parse(dailyForecast['main']['feels_like'].toString())))}°');
  }

  static String formatTemperature(double t) {
    var temp = (t == null ? '' : t.round().toString());
    return temp;
  }

  static WeatherCondition mapStringToWeatherCondition(
      String input, int cloudiness) {
    WeatherCondition condition;
    switch (input) {
      case 'Thunderstorm':
        condition = WeatherCondition.thunderstorm;
        break;
      case 'Drizzle':
        condition = WeatherCondition.drizzle;
        break;
      case 'Rain':
        condition = WeatherCondition.rain;
        break;
      case 'Snow':
        condition = WeatherCondition.snow;
        break;
      case 'Clear':
        condition = WeatherCondition.clear;
        break;
      case 'Clouds':
        condition = (cloudiness >= 85)
            ? WeatherCondition.heavyCloud
            : WeatherCondition.lightCloud;
        break;
      case 'Mist':
        condition = WeatherCondition.mist;
        break;
      default:
        condition = WeatherCondition.unknown;
    }

    return condition;
  }
}