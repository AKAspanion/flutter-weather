import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';

/// Tomorrow.io free plan: hourly and daily forecast in a single call.
/// Times are UTC and coordinate lookups come back without a place name.
class TomorrowIoProvider extends WeatherProvider {
  final String apiKey;

  TomorrowIoProvider(this.apiKey);

  @override
  String get name => 'Tomorrow.io';

  @override
  String get attribution => 'Powered by Tomorrow.io';

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  @override
  bool get supportsCitySearch => true;

  @override
  Future<WeatherReport> fetchByCoords(double lat, double lon, {required int timezone}) =>
      _fetch('$lat,$lon', timezone);

  @override
  Future<WeatherReport> fetchByCity(String city, {required int timezone}) => _fetch(city, null);

  Future<WeatherReport> _fetch(String location, int? knownTimezone) async {
    final data = await getJson(Uri.https('api.tomorrow.io', '/v4/weather/forecast', {
      'location': location,
      'apikey': apiKey,
      'units': 'metric',
      'timesteps': '1h,1d',
    }));
    final String name = data['location']['name'] ?? '';
    final double lat = (data['location']['lat'] as num).toDouble();
    final double lon = (data['location']['lon'] as num).toDouble();
    // Responses carry no timezone; estimate it from the longitude for city searches.
    final int timezone = knownTimezone ?? (lon / 15).round() * 3600;

    final List<Weather> hourly = (data['timelines']['hourly'] as List).take(48).map((hour) {
      final values = hour['values'];
      final int code = _conditionCode(values['weatherCode']);
      return Weather(
        name: name,
        timezone: timezone,
        date: epochSeconds(DateTime.parse(hour['time'])),
        humidity: (values['humidity'] as num).round(),
        condition: code,
        temperature: (values['temperature'] as num) + kelvinOffset,
        windSpeed: formatWind(values['windSpeed'] as num),
        description: _describe(values['weatherCode']),
        latitude: lat,
        longitude: lon,
      );
    }).toList();
    if (hourly.isEmpty) throw ProviderException('Tomorrow.io returned no forecast');

    final List<Weather> daily = (data['timelines']['daily'] as List).map((day) {
      final values = day['values'];
      return Weather(
        name: name,
        timezone: timezone,
        date: epochSeconds(DateTime.parse(day['time'])) + 12 * 3600,
        sunrise: _epochOrNull(values['sunriseTime']),
        sunset: _epochOrNull(values['sunsetTime']),
        humidity: (values['humidityAvg'] as num).round(),
        condition: _conditionCode(values['weatherCodeMax']),
        tempMin: (values['temperatureMin'] as num) + kelvinOffset,
        tempMax: (values['temperatureMax'] as num) + kelvinOffset,
        windSpeed: formatWind(values['windSpeedAvg'] as num),
        description: _describe(values['weatherCodeMax']),
      );
    }).toList();

    final Weather now = hourly.first
      ..sunrise = daily.isEmpty ? null : daily.first.sunrise
      ..sunset = daily.isEmpty ? null : daily.first.sunset;

    return WeatherReport(current: now, hourly: hourly, daily: daily, source: this.name, attribution: attribution);
  }

  static int? _epochOrNull(String? time) => time == null ? null : epochSeconds(DateTime.parse(time));

  static const Map<int, String> _descriptions = {
    1000: 'clear',
    1100: 'mostly clear',
    1101: 'partly cloudy',
    1102: 'mostly cloudy',
    1001: 'cloudy',
    2000: 'fog',
    2100: 'light fog',
    4000: 'drizzle',
    4001: 'rain',
    4200: 'light rain',
    4201: 'heavy rain',
    5000: 'snow',
    5001: 'flurries',
    5100: 'light snow',
    5101: 'heavy snow',
    6000: 'freezing drizzle',
    6001: 'freezing rain',
    6200: 'light freezing rain',
    6201: 'heavy freezing rain',
    7000: 'ice pellets',
    7101: 'heavy ice pellets',
    7102: 'light ice pellets',
    8000: 'thunderstorm',
  };

  static String _describe(int code) => _descriptions[code] ?? 'unknown';

  /// Maps Tomorrow.io weather codes to OpenWeatherMap ones.
  static int _conditionCode(int code) {
    if (code == 8000) return 200;
    if (code >= 6000) return 611;
    if (code >= 5000) return 600;
    if (code == 4000) return 300;
    if (code >= 4000) return code == 4201 ? 502 : 500;
    if (code >= 2000) return 741;
    switch (code) {
      case 1000:
        return 800;
      case 1100:
        return 801;
      case 1101:
        return 802;
      case 1102:
        return 803;
      default:
        return 804;
    }
  }
}
