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
  bool isFavourite = false;

  Forecast(
      {required this.lastUpdated,
        this.daily = const [],
        required this.current,
        this.city = '',
        required this.isDayTime,
        required this.sunrise,
        required this.sunset,
        required this.date});

  static Forecast fromJson(dynamic json) {
    var weather = json['current']['weather'][0];
    var date =
    DateTime.fromMillisecondsSinceEpoch(json['current']['dt'] * 1000);
    var sunrise =
    DateTime.fromMillisecondsSinceEpoch(json['current']['sunrise'] * 1000);
    var sunset =
    DateTime.fromMillisecondsSinceEpoch(json['current']['sunset'] * 1000);
    bool isDay = date.isAfter(sunrise) && date.isBefore(sunset);
    bool hasList = json['list'] != null;
    List<Weather> tempDaily = [];
    if (hasList) {
      List items = json['list'];
      for (int i = 0; i < items.length; i += 8) {
        if (i < items.length) {
          tempDaily.add(Weather.fromDailyJson(items[i]));
        }
      }
    }
    var currentForcast = Weather(
        cloudiness: int.parse(json['current']['clouds'].toString()),
        temp:
        '${Weather.formatTemperature(TempConverter.kelvinToCelsius(double.parse(json['current']['temp'].toString())))}°',
        condition: Weather.mapStringToWeatherCondition(
            weather['main'], int.parse(json['current']['clouds'].toString())),
        description: weather['description'].toString().capitalize(),
        feelLikeTemp:
        '${Weather.formatTemperature(TempConverter.kelvinToCelsius(double.parse(json['current']['feels_like'].toString())))}°',
        date: DateFormat('d EEE').format(date),
        sunrise: DateFormat.jm().format(sunrise),
        sunset: DateFormat.jm().format(sunset));
    String cityName = '';
    if (json['city'] != null && json['city']['name'] != null) {
      cityName = json['city']['name'];
    }
    return Forecast(
        lastUpdated: TimeOfDay.fromDateTime(DateTime.now()),
        current: currentForcast,
        daily: tempDaily,
        isDayTime: isDay,
        city: cityName,
        sunset: DateFormat.jm().format(sunset),
        sunrise: DateFormat.jm().format(sunrise),
        date: DateFormat('d EEE').format(date));
  }
}