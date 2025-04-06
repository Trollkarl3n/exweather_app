import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/forecast.dart';
import '../services/repository.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final IRepository _repository;
  WeatherCubit(this._repository)
      : super(WeatherInitial('Please enter city name.'));

  Future<void> getWeather(String cityName, bool isFavourite) async {
    try {
      emit(WeatherLoading());
      final forecast = await _repository.getWeather(cityName.trim());
      forecast.city = cityName;
      forecast.isFavourite = isFavourite;
      emit(WeatherLoaded(forecast: forecast));
    } catch (e) {
      print("Error in getWeather: $e");
      if (cityName.isEmpty) {
        emit(WeatherError("Please enter city name."));
      } else if (e.toString().contains('error retrieving location for city')) {
        emit(WeatherError("City not found."));
      } else {
        emit(WeatherError("Network error, please try again: ${e.toString().substring(0, min(50, e.toString().length))}..."));
      }
    }
  }
}