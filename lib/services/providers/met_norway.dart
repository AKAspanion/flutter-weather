import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';

/// MET Norway (api.met.no): free, keyless, commercial use allowed with
/// attribution. Needs an identifying User-Agent and coordinates with at most
/// four decimals. Returns no place name or timezone.
class MetNorwayProvider extends WeatherProvider {
  static const String _host = 'api.met.no';
  static const Map<String, String> _headers = {
    'User-Agent': 'BeautifulWeather/4.3 https://github.com/AKAspanion/flutter-weather',
  };

  @override
  String get name => 'MET Norway';

  @override
  String get attribution => 'Weather data: MET Norway (CC BY 4.0)';

  @override
  bool get supportsCitySearch => false;

  @override
  Future<WeatherReport> fetchByCoords(double lat, double lon, {required int timezone}) async {
    final Map<String, String> coords = {'lat': lat.toStringAsFixed(4), 'lon': lon.toStringAsFixed(4)};
    final forecast = await getJson(Uri.https(_host, '/weatherapi/locationforecast/2.0/compact', coords), headers: _headers);

    int? sunrise;
    int? sunset;
    try {
      final DateTime today = DateTime.now().toUtc();
      final sun = await getJson(
        Uri.https(_host, '/weatherapi/sunrise/3.0/sun', {
          ...coords,
          'date': '${today.year}-${_twoDigits(today.month)}-${_twoDigits(today.day)}',
          'offset': '+00:00',
        }),
        headers: _headers,
      );
      sunrise = epochSeconds(DateTime.parse(sun['properties']['sunrise']['time']));
      sunset = epochSeconds(DateTime.parse(sun['properties']['sunset']['time']));
    } catch (_) {
      // Sunrise is a nice-to-have; polar day/night responses have no times.
    }

    final List<Weather> series = [];
    for (final entry in forecast['properties']['timeseries']) {
      final data = entry['data'];
      final summary = (data['next_1_hours'] ?? data['next_6_hours'] ?? data['next_12_hours'])?['summary'];
      if (summary == null) continue;
      final details = data['instant']['details'];
      final String symbol = (summary['symbol_code'] as String).split('_').first;

      series.add(Weather(
        name: '',
        timezone: timezone,
        date: epochSeconds(DateTime.parse(entry['time'])),
        humidity: (details['relative_humidity'] as num).round(),
        condition: _conditionCode(symbol),
        temperature: (details['air_temperature'] as num) + kelvinOffset,
        windSpeed: formatWind(details['wind_speed'] as num),
        description: _describe(symbol),
        latitude: lat,
        longitude: lon,
      ));
    }
    if (series.isEmpty) throw ProviderException('MET Norway returned no forecast');

    final Weather now = series.first
      ..sunrise = sunrise
      ..sunset = sunset;

    return WeatherReport(
      current: now,
      // Hourly steps for roughly the first two days, then 6-hour steps.
      hourly: series.take(48).toList(),
      daily: dailyFromSeries(series, timezone: timezone, sunrise: sunrise, sunset: sunset),
      source: name,
      attribution: attribution,
    );
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// Maps MET symbol codes (e.g. "lightrainshowersandthunder") to the
  /// OpenWeatherMap condition codes the icons are keyed on.
  static int _conditionCode(String symbol) {
    if (symbol.contains('thunder')) return 200;
    if (symbol.contains('sleet')) return 611;
    if (symbol.contains('snow')) return 600;
    if (symbol.contains('rain')) return symbol.startsWith('heavy') ? 502 : (symbol.startsWith('light') ? 500 : 501);
    switch (symbol) {
      case 'clearsky':
        return 800;
      case 'fair':
        return 801;
      case 'partlycloudy':
        return 802;
      case 'fog':
        return 741;
      default:
        return 804;
    }
  }

  /// "lightrainshowersandthunder" -> "light rain showers and thunder".
  static String _describe(String symbol) => symbol
      .replaceAllMapped(
        RegExp('light|heavy|rain|sleet|snow|showers|and|thunder|partly|cloudy|clear|sky|fair|fog'),
        (m) => '${m[0]} ',
      )
      .trim();
}
