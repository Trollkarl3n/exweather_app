class Location {
  final double longitude;
  final double latitude;
  final String city;

  Location({
    required this.longitude,
    required this.latitude,
    required this.city
  });

  static Location fromJson(dynamic json) {
    return Location(
        longitude: json['coord']['lon'].toDouble(),
        latitude: json['coord']['lat'].toDouble(),
        city: json['name'] ?? '');
  }
}