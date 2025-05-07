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
    const cetOffset = Duration(
        hours: 2); // Adjust to 1 hour if not using daylight saving

    var weather = json['current']['weather'][0];
    var date = DateTime
        .fromMillisecondsSinceEpoch(json['current']['dt'] * 1000)
        .add(cetOffset);
    var sunrise = DateTime.fromMillisecondsSinceEpoch(
        json['current']['sunrise'] * 1000).add(cetOffset);
    var sunset = DateTime.fromMillisecondsSinceEpoch(
        json['current']['sunset'] * 1000).add(cetOffset);
    bool isDay = date.isAfter(sunrise) && date.isBefore(sunset);

    List<Weather> tempDaily = [];
    if (json['list'] != null) {
      List items = json['list'];
      for (int i = 0; i < items.length; i += 8) {
        if (i < items.length) {
          tempDaily.add(Weather.fromDailyJson(items[i]));
        }
      }
    }

    var currentForecast = Weather(
      cloudiness: int.parse(json['current']['clouds'].toString()),
      temp: '${Weather.formatTemperature(TempConverter.kelvinToCelsius(
          double.parse(json['current']['temp'].toString())))}°',
      condition: Weather.mapStringToWeatherCondition(
          weather['main'], int.parse(json['current']['clouds'].toString())),
      description: weather['description'].toString().capitalize(),
      feelLikeTemp: '${Weather.formatTemperature(TempConverter.kelvinToCelsius(
          double.parse(json['current']['feels_like'].toString())))}°',
      date: DateFormat('d EEE').format(date),
      sunrise: DateFormat.jm().format(sunrise),
      sunset: DateFormat.jm().format(sunset),
    );

    return Forecast(
      lastUpdated: TimeOfDay.fromDateTime(DateTime.now().add(cetOffset)),
      current: currentForecast,
      daily: tempDaily,
      isDayTime: isDay,
      city: json['city']?['name'] ?? '',
      sunset: DateFormat.jm().format(sunset),
      sunrise: DateFormat.jm().format(sunrise),
      date: DateFormat('d EEE').format(date),
      lat: json['city']?['coord']?['lat']?.toDouble() ?? 0,
      lon: json['city']?['coord']?['lon']?.toDouble() ?? 0,
    );
  }
}
