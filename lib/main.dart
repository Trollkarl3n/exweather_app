import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'cubit/favourite_cubit.dart';
import 'cubit/weather_cubit.dart';
import 'di/initialize_dependency.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC_P1bcCTLXat7UdDw4VJ0cQhuLrsARP-c",
      appId: "1:461763758704:android:4f1ab9f6189d9f9418c2b5",
      messagingSenderId: "461763758704",
      projectId: "exweatherapp-d55d3",
      storageBucket: "exweatherapp-d55d3.appspot.com",
    ),
  );

  initializeDependency();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppView();
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) =>
              WeatherCubit(injector.get<IRepository>()),
        ),
        BlocProvider(
          create: (BuildContext context) => FavouriteCubit()..getFavorite(),
        ),
      ],
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}
