import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/weather.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool error = false;
  bool loading = true;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    Weather weather = location.getWeather();
    return loading
        ? SpinKitChasingDots(
            color: Colors.blue,
          )
        : Text(error || weather == null ? "Help" : weather.toString());
  }

  void getLocation() async {
    try {
      await location.getCurrentLocation();
      await location.getLocationData();
      // await location.getCityData("Kolkata");
    } catch (e) {
      print(e);
      setState(() {
        error = true;
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
}
