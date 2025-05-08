import 'package:exweather_app/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/temp_converter.dart';
import 'weather.dart';

class Forecast {
  final TimeOfDay lastUpdated;
  final List<Weather> daily;
  Weather current;
  bool isDayTime;
  String city;
  String sunset;
  String sunrise;
  String date;
  double lat;
  double lon;
  bool isFavourite = false;

  Forecast({
    required this.lastUpdated,
    this.daily = const [],
    required this.current,
    required this.city,
    required this.isDayTime,
    required this.sunrise,
    required this.sunset,
    required this.date,
    required this.lat,
    required this.lon,
  });

  static Forecast fromJson(dynamic json) {
    const cetOffset = Duration(hours: 2);

    var currentJson = json['current'];
    var weather = (currentJson['weather'] != null &&
        currentJson['weather'].isNotEmpty)
        ? currentJson['weather'][0]
        : {'main': 'Clear', 'description': 'clear sky'};

    var date = DateTime.fromMillisecondsSinceEpoch(
        (currentJson['dt'] ?? 0) * 1000).add(cetOffset);
    var sunriseTime = DateTime.fromMillisecondsSinceEpoch(
        (currentJson['sunrise'] ?? 0) * 1000).add(cetOffset);
    var sunsetTime = DateTime.fromMillisecondsSinceEpoch(
        (currentJson['sunset'] ?? 0) * 1000).add(cetOffset);
    bool isDay = date.isAfter(sunriseTime) && date.isBefore(sunsetTime);

    final formattedSunrise = DateFormat.jm().format(sunriseTime);
    final formattedSunset = DateFormat.jm().format(sunsetTime);

    List<Weather> tempDaily = [];
    Weather? todayForecast;

    if (json['list'] != null) {
      final seenDays = <String>{};
      final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var item in json['list']) {
        final time = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).add(
            cetOffset);
        final dayKey = DateFormat('yyyy-MM-dd').format(time);

        if (!seenDays.contains(dayKey) && time.hour >= 11 && time.hour <= 13) {
          tempDaily.add(
              Weather.fromDailyJson(item, formattedSunrise, formattedSunset));
          seenDays.add(dayKey);
        }

        if (dayKey == todayDate && time.hour >= 11 && time.hour <= 13) {
          todayForecast =
              Weather.fromDailyJson(item, formattedSunrise, formattedSunset);
        }
      }
    }

    // 🔍 Optional debug to track current JSON structure
    print("🔥 fallback forecast data: $currentJson");

    var fallbackForecast = Weather(
      condition: Weather.mapStringToWeatherCondition(
        weather['main'] ?? 'Clear',
        currentJson['clouds'] ?? 0,
      ),
      description: (weather['description'] ?? 'clear sky')
          .toString()
          .capitalize(),
      temp: '${Weather.formatTemperature(
          TempConverter.kelvinToCelsius(currentJson['temp'] ?? 273.15))}°',
      feelLikeTemp: '${Weather.formatTemperature(TempConverter.kelvinToCelsius(
          currentJson['feels_like'] ?? 273.15))}°',
      cloudiness: currentJson['clouds'] ?? 0,
      humidity: currentJson['humidity'] ?? 0,
      windSpeed: (currentJson['wind']?['speed'] ?? 0).toDouble(),
      pressure: currentJson['pressure'] ?? 1013,
      date: DateFormat('d EEE').format(date),
      sunrise: formattedSunrise,
      sunset: formattedSunset,
    );

    var currentForecast = todayForecast ?? fallbackForecast;

    return Forecast(
      lastUpdated: TimeOfDay.fromDateTime(DateTime.now().add(cetOffset)),
      current: currentForecast,
      daily: tempDaily,
      isDayTime: isDay,
      city: json['city']?['name'] ?? '',
      sunset: formattedSunset,
      sunrise: formattedSunrise,
      date: DateFormat('d EEE').format(date),
      lat: json['city']?['coord']?['lat']?.toDouble() ?? 0,
      lon: json['city']?['coord']?['lon']?.toDouble() ?? 0,
    );
  }
}
