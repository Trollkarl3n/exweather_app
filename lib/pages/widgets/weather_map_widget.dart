import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:exweather_app/services/constants.dart';

class WeatherMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;

  const WeatherMapWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 8,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),

          TileLayer(
            urlTemplate: 'https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=$apiKey',
            userAgentPackageName: 'com.example.weatherapp',
            tileProvider: NetworkTileProvider(),
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
