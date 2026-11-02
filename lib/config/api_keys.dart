/// API keys, supplied at build time so they stay out of git:
///
///   flutter build appbundle --dart-define-from-file=keys.json
///
/// See keys.example.json. Providers whose key is empty are skipped.
class ApiKeys {
  static const String _openWeatherMap = String.fromEnvironment('OPENWEATHERMAP_KEY');
  // A blank value in keys.json falls back to the app's existing key.
  static const String openWeatherMap =
      _openWeatherMap == '' ? 'ee3ea3c138da18505bb8125cb2d16611' : _openWeatherMap;
  static const String weatherApi = String.fromEnvironment('WEATHERAPI_KEY');
  static const String tomorrowIo = String.fromEnvironment('TOMORROW_IO_KEY');
}
