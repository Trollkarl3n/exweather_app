import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/favourite_cubit.dart';
import '../cubit/favourite_state.dart';
import '../cubit/weather_cubit.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user?.isAnonymous ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text("Favourite Cities")),
      body: isGuest
          ? const Center(
        child: Text(
          "You are not logged in.\nPlease log in to view favorites.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      )
          : BlocBuilder<FavouriteCubit, FavouriteState>(
        builder: (context, state) {
          if (state is FavouriteInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavouriteLoaded) {
            final cities = state.favoriteList;
            if (cities.isEmpty) {
              return const Center(child: Text("No favorites saved."));
            }
            return ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index].city;
                return ListTile(
                  title: Text(city),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<FavouriteCubit>().deleteFavorite(city);
                    },
                  ),
                  onTap: () {
                    context.read<WeatherCubit>().getWeather(city, true);
                    Navigator.pop(context); // go back to HomePage
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("Something went wrong."));
          }
        },
      ),
    );
  }
}
