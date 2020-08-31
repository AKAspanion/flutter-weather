import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/gradients.dart';

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
          color: Colors.blue,
        ),
      );
    } else {
      if (weather == null) {
        return Text("Help");
      } else {
        return LocationView(
          weather: weather,
          accent: accent,
        );
      }
    }
  }
}

class LocationView extends StatelessWidget {
  final int accent;
  final Weather weather;

  LocationView({this.weather, this.accent = 0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      verticalDirection: VerticalDirection.down,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 32,
            bottom: 4,
          ),
          child: Text(
            '${weather.name.toUpperCase()}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '${getDateTime()}',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        Container(
          width: 220,
          height: 220,
          margin: EdgeInsets.only(
            top: 32,
            bottom: 32,
          ),
          child: FlareActor(
            "assets/animations/cloudy.flr",
            alignment: Alignment.center,
            animation: 'cloudy-rain',
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            bottom: 16,
          ),
          child: Text(
            '${(weather.temperature - 273.15).floor()}°C',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '${getGreeting()}',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            top: 64,
            left: 8,
            right: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WeatherDetailChip(
                icon: "sun",
                text: "sunrise",
                value: '${getSunriseTime(weather.sunrise)}',
                gradient: GradientValues().gradients[accent].gradient,
              ),
              WeatherDetailChip(
                icon: "wind",
                text: "wind",
                value: '${weather.windSpeed}m/s',
                gradient: GradientValues().gradients[accent].gradient,
              ),
              WeatherDetailChip(
                icon: "drop",
                text: "humidity",
                value: '${weather.humidity}%',
                gradient: GradientValues().gradients[accent].gradient,
              ),
            ],
          ),
        )
      ],
    );
  }

  String getSunriseTime(int date) {
    DateTime now = DateTime.fromMicrosecondsSinceEpoch(date, isUtc: false);
    final int hour = now.hour > 12 ? now.hour - 12 : now.hour;
    return '$hour:${now.minute}'.toUpperCase();
  }

  String getDateTime() {
    DateTime now = DateTime.now();
    List<String> weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    final String ampm = now.hour >= 12 ? 'pm' : 'am';
    final int hour = now.hour > 12 ? now.hour - 12 : now.hour;
    return '${weekdays[now.weekday - 1]} $hour $ampm'.toUpperCase();
  }

  String getGreeting() {
    DateTime now = DateTime.now();
    final int hour = now.hour;

    if (hour > 19 || hour <= 3) {
      return "GOOD NIGHT";
    } else if (hour > 3 && hour < 12) {
      return "GOOD MORNING";
    } else if (hour >= 12 && hour < 16) {
      return "GOOD AFTERNOON";
    } else {
      return "GOOD EVENING";
    }
  }
}

class WeatherDetailChip extends StatelessWidget {
  final String text;
  final String icon;
  final String value;
  final List<Color> gradient;

  WeatherDetailChip({
    this.text,
    this.icon,
    this.value,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: EdgeInsets.only(
        top: 12,
        left: 4,
        right: 4,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black12, blurRadius: 6.0)
        ],
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(2, 0.0),
          colors: gradient,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            child: FlareActor(
              "assets/animations/icons.flr",
              alignment: Alignment.center,
              animation: icon,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 12,
            ),
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
          Container(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}
