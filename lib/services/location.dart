import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:geolocator/geolocator.dart';

class Location {
  final WeatherReport? report;

  Location([this.report]);

  /// A last-known fix younger than this is used as-is, which makes startup
  /// instant instead of waiting for GPS.
  static const Duration _maxLastKnownAge = Duration(minutes: 30);

  static Future<Position?> currentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && DateTime.now().difference(lastKnown.timestamp) < _maxLastKnownAge) {
        return lastKnown;
      }

      try {
        // `lowest` maps to the passive provider, which never requests a fix on its own.
        return await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } on TimeoutException {
        return lastKnown;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Weather? getWeather() => report?.current;

  List<Weather> getHourly() => report?.hourly ?? [];

  List<Weather> getDaily() => report?.daily ?? [];

  String get attribution => report?.attribution ?? '';

  @override
  String toString() {
    return 'Location(Weather: ${getWeather().toString()}, source: ${report?.source})';
  }
}
