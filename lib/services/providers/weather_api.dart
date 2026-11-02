import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';

/// WeatherAPI.com free plan: current weather and a 3-day hourly forecast.
class WeatherApiProvider extends WeatherProvider implements Geocoder {
  static const String _host = 'api.weatherapi.com';

  final String apiKey;

  WeatherApiProvider(this.apiKey);

  @override
  String get name => 'WeatherAPI.com';

  @override
  String get attribution => 'Powered by WeatherAPI.com';

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  @override
  bool get supportsCitySearch => true;

  @override
  Future<WeatherReport> fetchByCoords(double lat, double lon, {required int timezone}) => _fetch('$lat,$lon');

  @override
  Future<WeatherReport> fetchByCity(String city, {required int timezone}) => _fetch(city);

  Future<WeatherReport> _fetch(String query) async {
    final data = await getJson(Uri.https(_host, '/v1/forecast.json', {
      'key': apiKey,
      'q': query,
      'days': '3',
      'aqi': 'no',
      'alerts': 'no',
    }));
    final location = data['location'];
    final String name = location['name'];
    final int timezone = _utcOffset(location['localtime'], location['localtime_epoch']);
    final List forecastDays = data['forecast']['forecastday'];
    final astro = forecastDays.first['astro'];
    final current = data['current'];

    final Weather now = Weather(
      name: name,
      timezone: timezone,
      sunrise: _localTimeToEpoch(forecastDays.first['date'], astro['sunrise'], timezone),
      sunset: _localTimeToEpoch(forecastDays.first['date'], astro['sunset'], timezone),
      humidity: (current['humidity'] as num).round(),
      condition: _conditionCode(current['condition']['code']),
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lon'] as num).toDouble(),
      windSpeed: formatWind(current['wind_kph'] / 3.6),
      temperature: (current['temp_c'] as num) + kelvinOffset,
      description: (current['condition']['text'] as String).toLowerCase(),
    );

    final int from = epochSeconds(DateTime.now()) - 3600;
    final List<Weather> hourly = forecastDays
        .expand((day) => day['hour'] as List)
        .where((hour) => hour['time_epoch'] >= from)
        .take(48)
        .map((hour) => Weather(
              name: name,
              timezone: timezone,
              date: hour['time_epoch'],
              humidity: (hour['humidity'] as num).round(),
              condition: _conditionCode(hour['condition']['code']),
              temperature: (hour['temp_c'] as num) + kelvinOffset,
              windSpeed: formatWind(hour['wind_kph'] / 3.6),
              description: (hour['condition']['text'] as String).toLowerCase(),
            ))
        .toList();

    final List<Weather> daily = forecastDays.map((day) {
      final summary = day['day'];
      return Weather(
        name: name,
        timezone: timezone,
        date: day['date_epoch'] + 12 * 3600,
        sunrise: _localTimeToEpoch(day['date'], day['astro']['sunrise'], timezone),
        sunset: _localTimeToEpoch(day['date'], day['astro']['sunset'], timezone),
        humidity: (summary['avghumidity'] as num).round(),
        condition: _conditionCode(summary['condition']['code']),
        tempMin: (summary['mintemp_c'] as num) + kelvinOffset,
        tempMax: (summary['maxtemp_c'] as num) + kelvinOffset,
        windSpeed: formatWind(summary['maxwind_kph'] / 3.6),
        description: (summary['condition']['text'] as String).toLowerCase(),
      );
    }).toList();

    return WeatherReport(current: now, hourly: hourly, daily: daily, source: this.name, attribution: attribution);
  }

  /// WeatherAPI gives local time as "2026-11-02 9:05" alongside the epoch;
  /// the difference is the UTC offset, rounded to the nearest 15 minutes.
  static int _utcOffset(String localtime, int epoch) {
    final List<String> parts = localtime.split(' ');
    final List<int> date = parts[0].split('-').map(int.parse).toList();
    final List<int> time = parts[1].split(':').map(int.parse).toList();
    final int localAsUtc = epochSeconds(DateTime.utc(date[0], date[1], date[2], time[0], time[1]));
    return ((localAsUtc - epoch) / 900).round() * 900;
  }

  /// Converts "2026-11-02" + "06:45 AM" in the location's timezone to epoch seconds.
  static int? _localTimeToEpoch(String date, String time, int timezone) {
    final RegExpMatch? match = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)$').firstMatch(time);
    if (match == null) return null; // e.g. "No sunrise" near the poles
    final int hour = int.parse(match[1]!) % 12 + (match[3] == 'PM' ? 12 : 0);
    final List<int> d = date.split('-').map(int.parse).toList();
    return epochSeconds(DateTime.utc(d[0], d[1], d[2], hour, int.parse(match[2]!))) - timezone;
  }

  /// Maps WeatherAPI condition codes to OpenWeatherMap ones.
  static int _conditionCode(int code) {
    switch (code) {
      case 1000:
        return 800;
      case 1003:
        return 802;
      case 1006:
        return 803;
      case 1009:
        return 804;
      case 1030:
      case 1135:
      case 1147:
        return 741;
      case 1087:
      case 1273:
      case 1276:
      case 1279:
      case 1282:
        return 200;
      case 1069:
      case 1204:
      case 1207:
      case 1249:
      case 1252:
      case 1237:
      case 1261:
      case 1264:
        return 611;
      case 1066:
      case 1114:
      case 1117:
      case 1210:
      case 1213:
      case 1216:
      case 1219:
      case 1222:
      case 1225:
      case 1255:
      case 1258:
        return 600;
      default:
        return 500; // the remaining codes are drizzle and rain
    }
  }

  @override
  Future<Place?> search(String city) async {
    final List results = await getJson(Uri.https(_host, '/v1/search.json', {'key': apiKey, 'q': city}));
    if (results.isEmpty) return null;
    return Place(name: results[0]['name'], lat: results[0]['lat'].toDouble(), lon: results[0]['lon'].toDouble());
  }

  @override
  Future<Place?> reverse(double lat, double lon) async {
    final List results = await getJson(Uri.https(_host, '/v1/search.json', {'key': apiKey, 'q': '$lat,$lon'}));
    if (results.isEmpty) return null;
    return Place(name: results[0]['name'], lat: lat, lon: lon);
  }
}
