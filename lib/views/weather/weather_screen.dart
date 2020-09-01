import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:flutterweather/views/weather/weather_error.dart';
import 'package:flutterweather/views/weather/weather_view.dart';

class LocationScreen extends StatelessWidget {
  final int accent;
  final bool loading;
  final Location location;

  LocationScreen({
    this.location,
    this.loading,
    this.accent = 0,
  });

  @override
  Widget build(BuildContext context) {
    Weather weather = location.getWeather();
    if (loading) {
      return Container(
        margin: EdgeInsets.only(top: 240),
        child: SpinKitPulse(
          size: 100,
          color: GradientValues().gradients[accent].gradient[0],
        ),
      );
    } else {
      if (weather == null) {
        return ErrorView();
      } else {
        return LocationView(
          weather: weather,
          accent: accent,
        );
      }
    }
  }
}
