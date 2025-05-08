import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/favourite_cubit.dart';
import '../cubit/favourite_state.dart';
import '../models/forecast.dart';
import '../models/weather.dart';
import 'settings_page.dart';
import 'favourite_page.dart';
import 'widgets/city_information_widget.dart';
import 'widgets/city_entry_widget.dart';
import 'widgets/daily_summary_widget.dart';
import 'widgets/gradient_container_widget.dart';
import 'widgets/indicator_widget.dart';
import 'widgets/last_update_widget.dart';
import 'widgets/weather_description_widget.dart';
import 'widgets/weather_summary_widget.dart';
import 'widgets/weather_map_widget.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Completer<void>? _refreshCompleter;
  Forecast? _forecast;
  bool isSelectedDate = false;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    final state = context.read<WeatherCubit>().state;
    if (state is WeatherLoaded) {
      setState(() {
        _forecast = state.forecast;
        isSelectedDate = false;
      });
    }
  }

  void searchCity() {
    isSelectedDate = false;
    _forecast = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavouritePage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          if (state is WeatherInitial) {
            return _buildGradientContainer(
              WeatherCondition.clear,
              false,
              Column(
                children: [
                  const SizedBox(height: 20),
                  CityEntryWidget(callBackFunction: searchCity),
                  buildMessageText(state.message),
                ],
              ),
            );
          } else if (state is WeatherLoading) {
            return _buildGradientContainer(
              WeatherCondition.clear,
              false,
              Column(
                children: [
                  const SizedBox(height: 20),
                  CityEntryWidget(callBackFunction: searchCity),
                  const IndicatorWidget(),
                ],
              ),
            );
          } else if (state is WeatherLoaded) {
            _forecast = state.forecast;
            isSelectedDate = false;
            return _buildGradientContainer(
              _forecast!.current.condition,
              _forecast!.isDayTime,
              buildContent(),
            );
          } else if (state is WeatherError) {
            return _buildGradientContainer(
              WeatherCondition.clear,
              false,
              Column(
                children: [
                  const SizedBox(height: 20),
                  CityEntryWidget(callBackFunction: searchCity),
                  buildMessageText(state.message),
                ],
              ),
            );
          } else {
            return _buildGradientContainer(
              WeatherCondition.clear,
              false,
              Column(
                children: [
                  const SizedBox(height: 20),
                  CityEntryWidget(callBackFunction: searchCity),
                  const IndicatorWidget(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildContent() {
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: RefreshIndicator(
        color: Colors.transparent,
        backgroundColor: Colors.transparent,
        onRefresh: () => refreshWeather(_forecast!),
        child: ListView(
          children: <Widget>[
            CityEntryWidget(callBackFunction: searchCity),
            buildFavoriteCityList(context),
            if (isGuest)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Guest Mode – changes won’t be saved",
                  style: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            CityInformationWidget(
              city: _forecast!.city,
              sunrise: _forecast!.current.sunrise,
              sunset: _forecast!.current.sunset,
            ),
            const SizedBox(height: 40),
            WeatherSummaryWidget(
              date: _forecast!.date,
              condition: _forecast!.current.condition,
              temp: _forecast!.current.temp,
              feelsLike: _forecast!.current.feelLikeTemp,
            ),
            const SizedBox(height: 20),
            WeatherDescriptionWidget(
              weatherDescription: _forecast!.current.description,
            ),
            const SizedBox(height: 40),
            buildTodayDetails(),
            buildDailySummary(_forecast!.daily),
            LastUpdatedWidget(lastUpdatedOn: _forecast!.lastUpdated),
            if (_forecast?.lat != null && _forecast?.lon != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Weather Map",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        height: 200,
                        child: WeatherMapWidget(
                          latitude: _forecast!.lat,
                          longitude: _forecast!.lon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTodayDetails() {
    final details = [
      {"label": "Cloudiness", "value": "${_forecast!.current.cloudiness}%"},
      {"label": "Humidity", "value": "${_forecast!.current.humidity}%"},
      {"label": "Pressure", "value": "${_forecast!.current.pressure} hPa"},
      {"label": "Feels Like", "value": _forecast!.current.feelLikeTemp},
      {"label": "Wind", "value": "${_forecast!.current.windSpeed} m/s"},


    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: details.map((item) {
              return Container(
                width: MediaQuery.of(context).size.width / 2 - 22,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['label']!, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(item['value']!, style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildMessageText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 21, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildDailySummary(List<Weather> dailyForecast) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: dailyForecast.length,
        itemBuilder: (BuildContext context, int index) {
          return DailySummaryWidget(weather: dailyForecast[index]);
        },
      ),
    );
  }

  Future<void> refreshWeather(Forecast forecast) {
    return BlocProvider.of<WeatherCubit>(context)
        .getWeather(forecast.city, false);
  }

  Widget buildFavoriteCityList(BuildContext context) {
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? false;
    if (isGuest) return const SizedBox.shrink();

    return BlocBuilder<FavouriteCubit, FavouriteState>(
      builder: (context, state) {
        if (state is FavouriteLoaded && state.favoriteList.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Favorite Cities",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
              Wrap(
                spacing: 10,
                children: state.favoriteList.map((fav) {
                  return ActionChip(
                    label: Text(fav.city),
                    onPressed: () {
                      BlocProvider.of<WeatherCubit>(context)
                          .getWeather(fav.city, true);
                    },
                    backgroundColor: Colors.white24,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  GradientContainerWidget _buildGradientContainer(
      WeatherCondition condition, bool isDayTime, Widget child) {
    if (!isDayTime) {
      return GradientContainerWidget(color: Colors.blueGrey, child: child);
    }

    switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.lightCloud:
        return GradientContainerWidget(color: Colors.yellow, child: child);
      case WeatherCondition.rain:
      case WeatherCondition.drizzle:
      case WeatherCondition.mist:
      case WeatherCondition.heavyCloud:
        return GradientContainerWidget(color: Colors.indigo, child: child);
      case WeatherCondition.snow:
        return GradientContainerWidget(color: Colors.lightBlue, child: child);
      case WeatherCondition.thunderstorm:
        return GradientContainerWidget(color: Colors.deepPurple, child: child);
      default:
        return GradientContainerWidget(color: Colors.lightBlue, child: child);
    }
  }
}