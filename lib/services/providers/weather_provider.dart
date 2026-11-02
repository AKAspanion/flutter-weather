import 'dart:async';
import 'dart:convert';

import 'package:flutterweather/services/weather.dart';
import 'package:http/http.dart' as HTTP;

/// Offset between Celsius and the Kelvin values the UI expects.
const double kelvinOffset = 273.15;

/// Current conditions plus forecasts, normalised to what the UI expects:
/// temperatures in Kelvin, wind in m/s and OpenWeatherMap condition codes.
class WeatherReport {
  final Weather current;
  final List<Weather> hourly;
  final List<Weather> daily;

  /// Name of the provider that produced this report.
  final String source;

  /// Text the provider's terms ask us to show next to its data.
  final String attribution;

  WeatherReport({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.source,
    required this.attribution,
  });

  /// Fills in the place name on every entry, for providers that don't return one.
  void setName(String name) {
    current.name = name;
    for (final Weather w in [...hourly, ...daily]) {
      w.name = name;
    }
  }

  Map<String, dynamic> toJson() => {
        'current': current.toJson(),
        'hourly': hourly.map((e) => e.toJson()).toList(),
        'daily': daily.map((e) => e.toJson()).toList(),
        'source': source,
        'attribution': attribution,
      };

  factory WeatherReport.fromJson(Map<String, dynamic> json) => WeatherReport(
        current: Weather.fromJson(json['current']),
        hourly: (json['hourly'] as List).map((e) => Weather.fromJson(e)).toList(),
        daily: (json['daily'] as List).map((e) => Weather.fromJson(e)).toList(),
        source: json['source'],
        attribution: json['attribution'],
      );
}

class ProviderException implements Exception {
  final String message;

  ProviderException(this.message);

  @override
  String toString() => 'ProviderException: $message';
}

/// A place found by name or by coordinates.
class Place {
  final String name;
  final double lat;
  final double lon;

  Place({required this.name, required this.lat, required this.lon});
}

/// Providers that can turn a city name into coordinates and back.
abstract class Geocoder {
  Future<Place?> search(String city);

  Future<Place?> reverse(double lat, double lon);
}

abstract class WeatherProvider {
  String get name;

  String get attribution;

  /// False when the provider needs an API key that wasn't supplied.
  bool get isConfigured => true;

  /// Whether [fetchByCity] works; otherwise the service geocodes first.
  bool get supportsCitySearch;

  /// [timezone] is a best-guess UTC offset in seconds, used only by
  /// providers whose responses don't include one.
  Future<WeatherReport> fetchByCoords(double lat, double lon, {required int timezone});

  Future<WeatherReport> fetchByCity(String city, {required int timezone}) {
    throw UnsupportedError('$name does not support city search');
  }
}

Future<dynamic> getJson(Uri uri, {Map<String, String>? headers}) async {
  final HTTP.Response response = await HTTP.get(uri, headers: headers).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw ProviderException('${uri.host}${uri.path} returned ${response.statusCode}');
  }
  return jsonDecode(response.body);
}

int epochSeconds(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;

String formatWind(num metresPerSecond) => metresPerSecond.toStringAsFixed(1);

/// Builds one entry per local day from a time series, using the reading
/// closest to midday for the condition. [sunrise] and [sunset] give today's
/// values; later days reuse them shifted by whole days.
List<Weather> dailyFromSeries(
  List<Weather> series, {
  required int timezone,
  int? sunrise,
  int? sunset,
}) {
  final Map<String, List<Weather>> days = {};
  for (final Weather w in series) {
    final DateTime local = DateTime.fromMillisecondsSinceEpoch(w.date! * 1000, isUtc: true).add(Duration(seconds: timezone));
    days.putIfAbsent('${local.year}-${local.month}-${local.day}', () => []).add(w);
  }

  int dayIndex = 0;
  return days.values.map((readings) {
    int localHour(Weather w) => DateTime.fromMillisecondsSinceEpoch(w.date! * 1000, isUtc: true).add(Duration(seconds: timezone)).hour;
    final Weather midday = readings.reduce((a, b) => (localHour(a) - 12).abs() <= (localHour(b) - 12).abs() ? a : b);
    final List<double> temps = readings.map((w) => w.temperature!).toList();
    final double wind = readings.map((w) => double.tryParse(w.windSpeed ?? '') ?? 0).reduce((a, b) => a > b ? a : b);
    final int humidity = (readings.map((w) => w.humidity ?? 0).reduce((a, b) => a + b) / readings.length).round();
    final int shift = dayIndex++ * Duration.secondsPerDay;

    return Weather(
      name: midday.name,
      timezone: timezone,
      date: midday.date,
      sunrise: sunrise == null ? null : sunrise + shift,
      sunset: sunset == null ? null : sunset + shift,
      humidity: humidity,
      condition: midday.condition,
      tempMin: temps.reduce((a, b) => a < b ? a : b),
      tempMax: temps.reduce((a, b) => a > b ? a : b),
      windSpeed: formatWind(wind),
      description: midday.description,
    );
  }).toList();
}
