import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/weather_cubit.dart';

class CityEntryWidget extends StatefulWidget {
  const CityEntryWidget({Key? key, required this.callBackFunction})
      : super(key: key);

  final Function callBackFunction;

  @override
  _CityEntryWidgetState createState() => _CityEntryWidgetState();
}

class _CityEntryWidgetState extends State<CityEntryWidget> {
  late TextEditingController cityEditController;

  @override
  void initState() {
    super.initState();
    cityEditController = TextEditingController();
  }

  void submitCityName(BuildContext context, String cityName) {
    if (cityName.trim().isEmpty) return;

    BlocProvider.of<WeatherCubit>(context).getWeather(cityName.trim(), false);

    widget.callBackFunction();

    cityEditController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 15, right: 10),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                submitCityName(context, cityEditController.text),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: cityEditController,
              decoration: const InputDecoration.collapsed(hintText: "Enter City"),
              onSubmitted: (String city) =>
                  submitCityName(context, city),
            ),
          ),
        ],
      ),
    );
  }
}
