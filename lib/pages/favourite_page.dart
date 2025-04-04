import 'package:exweather_app/pages/widgets/indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/favourite_cubit.dart';
import '../cubit/weather_cubit.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<FavouriteCubit>(context).getFavorite();
    return Scaffold(
        appBar: AppBar(
            title: const Text('Favourite Cities'),
            backgroundColor: Colors.blueGrey.shade800),
        body: Container(
            decoration: const BoxDecoration(color: Colors.blueGrey),
            height: MediaQuery.of(context).size.height,
            child: BlocBuilder<FavouriteCubit, FavouriteState>(
                builder: (context, state) {
                  if (state is FavouriteInitial) {
                    return const IndicatorWidget();
                  } else if (state is FavouriteLoaded) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.favoriteList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                BlocProvider.of<WeatherCubit>(context).getWeather(
                                    state.favoriteList[index].city, true);
                                Navigator.pop(context);
                              },
                              child: Card(
                                  color: Colors.blueGrey,
                                  child: ListTile(
                                      title: Center(
                                          child: Text(
                                              state.favoriteList[index].city,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold))))));
                        });
                  } else {
                    return const IndicatorWidget();
                  }
                })));
  }
}