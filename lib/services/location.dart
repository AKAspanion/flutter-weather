import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/services/api_helper.dart';
import 'package:geolocator/geolocator.dart';

class Location {
  double lat;
  double lon;
  Weather weather;

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
      lat = position.latitude;
      lon = position.longitude;
    } catch (e) {
      print(e);
    }
  }

  Future<void> getLocationData() async {
    if (lat == null || lon == null) {
      throw ("No lat or lon data found");
    }
    APIService apiService = APIService(
      url:
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=ee3ea3c138da18505bb8125cb2d16611",
    );
    var decoded = await apiService.fetchData();

    weather = Weather(
      name: decoded['name'],
      condition: decoded['weather'][0]['id'],
      temperature: decoded['main']['temp'],
      humidity: decoded['main']['humidity'],
      windSpeed: decoded['wind']['speed'],
      sunrise: decoded['sys']['sunrise'],
      sunset: decoded['sys']['sunset'],
      icon: decoded['weather'][0]['icon'],
    );
  }

  Future<void> getCityData(String cityName) async {
    APIService apiService = APIService(
      url:
          "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=ee3ea3c138da18505bb8125cb2d16611",
    );
    var decoded = await apiService.fetchData();

    weather = Weather(
      name: decoded['name'],
      condition: decoded['weather'][0]['id'],
      temperature: decoded['main']['temp'],
    );
  }

  getWeather() => weather;

  @override
  String toString() {
    return 'Location(lat: $lat, long: $lon, Weather: ${weather.toString()})';
  }
}
