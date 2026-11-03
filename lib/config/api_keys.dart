/// API keys, supplied at build time so they stay out of git:
///
///   flutter build appbundle --dart-define-from-file=keys.json
///
/// See keys.example.json. Providers whose key is empty are skipped.
class ApiKeys {
  static const String openWeatherMap = String.fromEnvironment('OPENWEATHERMAP_KEY');
  static const String weatherApi = String.fromEnvironment('WEATHERAPI_KEY');
  static const String tomorrowIo = String.fromEnvironment('TOMORROW_IO_KEY');
}
