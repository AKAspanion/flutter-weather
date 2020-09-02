import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:flutterweather/views/weather/weather_detail_chip.dart';

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(children: <Widget>[
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
        ]),
        Container(
          width: 200,
          height: 200,
          padding: EdgeInsets.only(
            bottom: 16,
          ),
          child: FlareActor(
            "assets/animations/cloudy.flr",
            alignment: Alignment.center,
            animation: 'cloudy-${weather.getIcon()}',
          ),
        ),
        Column(children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 16,
            ),
            child: Text(
              '${(weather.temperature - 273.15).floor()}°C',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${getGreeting()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            '${weather.description.toUpperCase()}',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ]),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4,
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
