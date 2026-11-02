import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';

/// OpenWeatherMap free tier: current weather plus the 5 day / 3 hour forecast.
/// (The One Call 2.5 API the app used before was retired in 2024.)
class OpenWeatherMapProvider extends WeatherProvider implements Geocoder {
  static const String _host = 'api.openweathermap.org';

  final String apiKey;

  OpenWeatherMapProvider(this.apiKey);

  @override
  String get name => 'OpenWeatherMap';

  @override
  String get attribution => 'Weather data: OpenWeatherMap';

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  @override
  bool get supportsCitySearch => true;

  @override
  Future<WeatherReport> fetchByCoords(double lat, double lon, {required int timezone}) =>
      _fetch({'lat': '$lat', 'lon': '$lon'});

  @override
  Future<WeatherReport> fetchByCity(String city, {required int timezone}) => _fetch({'q': city});

  Future<WeatherReport> _fetch(Map<String, String> query) async {
    final Map<String, String> params = {...query, 'appid': apiKey};
    final List<dynamic> responses = await Future.wait([
      getJson(Uri.https(_host, '/data/2.5/weather', params)),
      getJson(Uri.https(_host, '/data/2.5/forecast', params)),
    ]);
    final current = responses[0];
    final forecast = responses[1];

    final Weather now = Weather(
      name: current['name'],
      timezone: current['timezone'],
      sunset: current['sys']['sunset'],
      sunrise: current['sys']['sunrise'],
      humidity: current['main']['humidity'],
      condition: current['weather'][0]['id'],
      latitude: current['coord']['lat'].toDouble(),
      longitude: current['coord']['lon'].toDouble(),
      windSpeed: current['wind']['speed'].toString(),
      temperature: current['main']['temp'].toDouble(),
      description: current['weather'][0]['description'],
    );

    final List<Weather> series = (forecast['list'] as List)
        .map((data) => Weather(
              name: now.name,
              timezone: now.timezone,
              date: data['dt'],
              humidity: data['main']['humidity'],
              condition: data['weather'][0]['id'],
              temperature: data['main']['temp'].toDouble(),
              windSpeed: data['wind']['speed'].toString(),
              description: data['weather'][0]['description'],
            ))
        .toList();

    return WeatherReport(
      current: now,
      // 3-hour steps, so 16 entries cover the next 48 hours.
      hourly: series.take(16).toList(),
      daily: dailyFromSeries(series, timezone: now.timezone ?? 0, sunrise: now.sunrise, sunset: now.sunset),
      source: name,
      attribution: attribution,
    );
  }

  @override
  Future<Place?> search(String city) async {
    final List results = await getJson(Uri.https(_host, '/geo/1.0/direct', {'q': city, 'limit': '1', 'appid': apiKey}));
    if (results.isEmpty) return null;
    return Place(name: results[0]['name'], lat: results[0]['lat'].toDouble(), lon: results[0]['lon'].toDouble());
  }

  @override
  Future<Place?> reverse(double lat, double lon) async {
    final List results = await getJson(Uri.https(_host, '/geo/1.0/reverse', {'lat': '$lat', 'lon': '$lon', 'limit': '1', 'appid': apiKey}));
    if (results.isEmpty) return null;
    return Place(name: results[0]['name'], lat: lat, lon: lon);
  }
}
