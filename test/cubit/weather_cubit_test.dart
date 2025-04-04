import 'package:exweather_app/cubit/weather_cubit.dart';
import 'package:exweather_app/models/forecast.dart';
import 'package:exweather_app/models/weather.dart';
import 'package:exweather_app/services/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockWeatherRepository extends Mock implements IRepository {}

void main() {
  MockWeatherRepository? mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
  });
  group('GetWether', () {
    final forecast = Forecast(
        lastUpdated: TimeOfDay.fromDateTime(DateTime.now()),
        current: Weather(
            cloudiness: 1,
            condition: WeatherCondition.clear,
            temp: '',
            feelLikeTemp: '',
            description: '',
            sunrise: '',
            sunset: '',
            date: ''),
        isDayTime: false,
        sunrise: '',
        sunset: '',
        date: '');
    when(mockWeatherRepository!.getWeather('London'))
        .thenAnswer((_) async => forecast);

    final cubit = WeatherCubit(mockWeatherRepository!);
    cubit.getWeather('London', false);

    expectLater(
        cubit,
        emitsInOrder([
          WeatherInitial('Please enter city name.'),
          WeatherLoading(),
          WeatherLoaded(forecast: forecast)
        ]));
  });
}