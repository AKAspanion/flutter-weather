import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/config/api_keys.dart';
import 'package:flutterweather/services/providers/openweathermap.dart';

void main() {
  group('ApiKeys', () {
    test('openWeatherMap is empty when no OPENWEATHERMAP_KEY is defined', () {
      expect(ApiKeys.openWeatherMap, isEmpty);
    });

    test('an OpenWeatherMapProvider built with the default key is not configured', () {
      expect(OpenWeatherMapProvider(ApiKeys.openWeatherMap).isConfigured, isFalse);
    });
  });
}
