import 'package:flutter/foundation.dart';
import 'package:flutterweather/config/api_keys.dart';
import 'package:flutterweather/services/providers/met_norway.dart';
import 'package:flutterweather/services/providers/openweathermap.dart';
import 'package:flutterweather/services/providers/tomorrow_io.dart';
import 'package:flutterweather/services/providers/weather_api.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';

/// Fetches weather from the first provider that answers. The provider that
/// last worked is tried first; one that fails is moved to the back of the
/// queue for [cooldown] so a broken or rate-limited API stops slowing us down.
class WeatherService {
  static const Duration cooldown = Duration(minutes: 15);

  final List<WeatherProvider> providers;
  final Map<String, DateTime> _failedAt = {};
  String? _preferred;

  WeatherService(List<WeatherProvider> providers) : providers = providers.where((p) => p.isConfigured).toList();

  /// Providers in the order they are tried when nothing has failed yet.
  factory WeatherService.withDefaultProviders() => WeatherService([
        OpenWeatherMapProvider(ApiKeys.openWeatherMap),
        WeatherApiProvider(ApiKeys.weatherApi),
        TomorrowIoProvider(ApiKeys.tomorrowIo),
        MetNorwayProvider(),
      ]);

  Iterable<Geocoder> get _geocoders => providers.whereType<Geocoder>();

  Future<WeatherReport> fetchByCoords(double lat, double lon) async {
    // The user is at these coordinates, so the device offset is their timezone.
    final int timezone = DateTime.now().timeZoneOffset.inSeconds;
    final WeatherReport report = await _run((p) => p.fetchByCoords(lat, lon, timezone: timezone));

    if ((report.current.name ?? '').isEmpty) {
      final Place? place = await _firstGeocoder((g) => g.reverse(lat, lon));
      // An unnamed place stays '' so the screens can show "My location" in the user's language.
      report.setName(place?.name ?? '');
    }
    return report;
  }

  Future<WeatherReport> fetchByCity(String city) async {
    Place? place;

    return _run((p) async {
      if (p.supportsCitySearch) {
        final WeatherReport report = await p.fetchByCity(city, timezone: 0);
        if ((report.current.name ?? '').isEmpty) report.setName(city);
        return report;
      }

      place ??= await _firstGeocoder((g) => g.search(city));
      if (place == null) throw ProviderException('No geocoder could find "$city"');
      // No timezone from these providers; estimate it from the longitude.
      final int timezone = (place!.lon / 15).round() * 3600;
      final WeatherReport report = await p.fetchByCoords(place!.lat, place!.lon, timezone: timezone);
      report.setName(place!.name);
      return report;
    });
  }

  List<WeatherProvider> _ordered() {
    final DateTime now = DateTime.now();
    bool coolingDown(WeatherProvider p) {
      final DateTime? failed = _failedAt[p.name];
      return failed != null && now.difference(failed) < cooldown;
    }

    final List<WeatherProvider> healthy = providers.where((p) => !coolingDown(p)).toList()
      ..sort((a, b) => (b.name == _preferred ? 1 : 0) - (a.name == _preferred ? 1 : 0));
    // Providers in cooldown are still tried, last, rather than giving up.
    return [...healthy, ...providers.where(coolingDown)];
  }

  Future<WeatherReport> _run(Future<WeatherReport> Function(WeatherProvider) fetch) async {
    final List<String> errors = [];
    for (final WeatherProvider provider in _ordered()) {
      try {
        final WeatherReport report = await fetch(provider);
        _preferred = provider.name;
        _failedAt.remove(provider.name);
        return report;
      } catch (e) {
        debugPrint('${provider.name} failed: $e');
        errors.add('${provider.name}: $e');
        _failedAt[provider.name] = DateTime.now();
      }
    }
    throw ProviderException('All weather providers failed (${errors.join('; ')})');
  }

  Future<Place?> _firstGeocoder(Future<Place?> Function(Geocoder) lookup) async {
    for (final Geocoder geocoder in _geocoders) {
      try {
        final Place? place = await lookup(geocoder);
        if (place != null) return place;
      } catch (e) {
        debugPrint('Geocoding failed: $e');
      }
    }
    return null;
  }
}
