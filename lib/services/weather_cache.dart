import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the user last looked up, so the widget can refresh it in the background
/// without asking for location.
class WeatherQuery {
  final String? city;
  final double? lat;
  final double? lon;

  WeatherQuery.city(String this.city)
      : lat = null,
        lon = null;

  WeatherQuery.coords(double this.lat, double this.lon) : city = null;

  Future<WeatherReport> fetch(WeatherService service) =>
      city != null ? service.fetchByCity(city!) : service.fetchByCoords(lat!, lon!);

  Map<String, dynamic> toJson() => {'city': city, 'lat': lat, 'lon': lon};

  static WeatherQuery fromJson(Map<String, dynamic> json) => json['city'] != null
      ? WeatherQuery.city(json['city'])
      : WeatherQuery.coords(json['lat'].toDouble(), json['lon'].toDouble());
}

/// The last successful report, shown immediately on launch while fresh data loads.
class WeatherCache {
  static const String _reportKey = 'last_report';
  static const String _queryKey = 'last_query';

  static Future<void> save(WeatherReport report, WeatherQuery query) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reportKey, jsonEncode(report.toJson()));
    await prefs.setString(_queryKey, jsonEncode(query.toJson()));
  }

  static Future<WeatherReport?> loadReport() async {
    return _read(_reportKey, (json) => WeatherReport.fromJson(json));
  }

  static Future<WeatherQuery?> loadQuery() async {
    return _read(_queryKey, WeatherQuery.fromJson);
  }

  static Future<T?> _read<T>(String key, T Function(Map<String, dynamic>) parse) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // The widget's background refresh may have written newer values.
    await prefs.reload();
    final String? raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return parse(jsonDecode(raw));
    } catch (e) {
      // A cache written by an older app version; ignore it.
      debugPrint('Discarding cached $key: $e');
      return null;
    }
  }
}
