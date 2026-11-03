import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/services/weather_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 17.5 and 7.5 degrees: shown as 17° and 7°.
WeatherReport _report({String? name = 'Paris', int? condition = 500, List<Weather> hourly = const []}) {
  return WeatherReport(
    current: Weather(
      name: name,
      condition: condition,
      temperature: 285.15,
      timezone: 0,
      windSpeed: '3.1',
      humidity: 60,
    ),
    hourly: hourly,
    daily: [Weather(tempMax: 290.65, tempMin: 280.65)],
    source: 'test',
    attribution: '',
  );
}

Map<String, dynamic> _json(String value) => jsonDecode(value) as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));
  final DateTime updated = DateTime(2026, 11, 3, 14, 5);

  // update() does this before building the payload.
  setUpAll(() => initializeDateFormatting('en'));
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('payload', () {
    test('names the city and describes the weather in capitals', () {
      final Map<String, String> data = WeatherWidget.payload(_report(), l10n, 'en', updated);

      final Map<String, dynamic> now = _json(data['now']!);
      expect(data['city'], 'PARIS');
      expect(now['description'], 'LIGHT RAIN');
      expect(now['detail'], 'H 17°  L 7°');
      expect(now['temperature'], '12°');
    });

    test('shows Celsius by default and Fahrenheit when asked', () {
      final Map<String, dynamic> celsius = _json(WeatherWidget.payload(_report(), l10n, 'en', updated)['now']!);
      final Map<String, dynamic> fahrenheit = _json(
        WeatherWidget.payload(_report(), l10n, 'en', updated, unit: TemperatureUnit.fahrenheit)['now']!,
      );

      expect(celsius['temperature'], '12°');
      expect(celsius['detail'], 'H 17°  L 7°');
      expect(fahrenheit['temperature'], '53°');
      expect(fahrenheit['detail'], 'H 63°  L 45°');
    });

    test('shows each hour in the asked unit', () {
      final DateTime from = DateTime.utc(2026, 11, 3, 12);
      final Weather later = Weather(
        date: DateTime.utc(2026, 11, 3, 15).millisecondsSinceEpoch ~/ 1000,
        condition: 800,
        temperature: 285.15,
        timezone: 0,
      );

      final Map<String, String> data =
          WeatherWidget.payload(_report(hourly: [later]), l10n, 'en', from, unit: TemperatureUnit.fahrenheit);

      final List<dynamic> hours = jsonDecode(data['hours']!) as List<dynamic>;
      expect((hours.single as Map<String, dynamic>)['temperature'], '53°');
    });

    test('says MY LOCATION for an unnamed place', () {
      final Map<String, String> data = WeatherWidget.payload(_report(name: ''), l10n, 'en', updated);

      expect(data['city'], 'MY LOCATION');
    });

    test('sends the card titles and the time of the update', () {
      final Map<String, String> data = WeatherWidget.payload(_report(), l10n, 'en', updated);

      expect(_json(data['labels']!), {'now': 'NOW', 'next24Hours': 'NEXT 24 HOURS', 'updated': 'Updated 14:05'});
    });

    test('describes a missing condition as UNKNOWN', () {
      final Map<String, String> data = WeatherWidget.payload(_report(condition: null), l10n, 'en', updated);

      expect(_json(data['now']!)['description'], 'UNKNOWN');
    });

    test('leaves the high and low empty without a forecast day', () {
      final WeatherReport report = WeatherReport(
        current: Weather(condition: 800, timezone: 0),
        hourly: const [],
        daily: const [],
        source: 'test',
        attribution: '',
      );

      final Map<String, String> data = WeatherWidget.payload(report, l10n, 'en', updated);

      expect(_json(data['now']!)['detail'], '');
    });

    test('labels each hour in the locale short form, in the place local time', () {
      final DateTime from = DateTime.utc(2026, 11, 3, 12);
      final Weather later = Weather(
        date: DateTime.utc(2026, 11, 3, 15).millisecondsSinceEpoch ~/ 1000,
        condition: 800,
        temperature: 285.15,
        timezone: 0,
      );

      final Map<String, String> data = WeatherWidget.payload(_report(hourly: [later]), l10n, 'en', from);

      final List<dynamic> hours = jsonDecode(data['hours']!) as List<dynamic>;
      // Recent CLDR data puts a narrow no-break space before PM, so match any space.
      expect((hours.single as Map<String, dynamic>)['label'], matches(RegExp(r'^3\sPM$')));
    });
  });

  group('localizations', () {
    test('follows the language the app saved', () async {
      SharedPreferences.setMockInitialValues({LocaleManager.preferenceKey: 'hi'});

      final AppLocalizations found = await WeatherWidget.localizations();

      expect(found.localeName, 'hi');
    },
        skip: AppLocalizations.supportedLocales.contains(const Locale('hi'))
            ? false
            : 'hi arrives with the translations');

    test('falls back to English for a device language outside the list', () async {
      final AppLocalizations found = await WeatherWidget.localizations(device: const Locale('xx'));

      expect(found.localeName, 'en');
    });

    test('falls back to English when the saved language is not supported', () async {
      SharedPreferences.setMockInitialValues({LocaleManager.preferenceKey: 'xx'});

      final AppLocalizations found = await WeatherWidget.localizations(device: const Locale('xx'));

      expect(found.localeName, 'en');
    });
  });

  group('temperatureUnit', () {
    test('follows the unit the app saved', () async {
      SharedPreferences.setMockInitialValues({UnitManager.preferenceKey: 'fahrenheit'});

      expect(await WeatherWidget.temperatureUnit(device: const Locale('en', 'GB')), TemperatureUnit.fahrenheit);
    });

    test('follows the region when nothing is saved', () async {
      expect(await WeatherWidget.temperatureUnit(device: const Locale('en', 'US')), TemperatureUnit.fahrenheit);
      expect(await WeatherWidget.temperatureUnit(device: const Locale('fr', 'FR')), TemperatureUnit.celsius);
    });
  });

  group('update', () {
    final List<String?> logs = [];
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      logs.clear();
      originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) => logs.add(message);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('home_widget'), null);
    });

    test('logs a failing store and does not throw', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('home_widget'),
        (MethodCall call) async => throw PlatformException(code: 'store', message: 'disk full'),
      );

      await WeatherWidget.update(_report());

      expect(logs.where((String? m) => m != null && m.startsWith('Widget update failed')), hasLength(1));
    });

    test('saves every payload key and refreshes the widget', () async {
      final Map<String, String> saved = {};
      var refreshed = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('home_widget'),
        (MethodCall call) async {
          if (call.method == 'saveWidgetData') {
            saved[call.arguments['id'] as String] = call.arguments['data'] as String;
          } else if (call.method == 'updateWidget') {
            refreshed = true;
          }
          return true;
        },
      );

      await WeatherWidget.update(_report());

      expect(saved.keys, unorderedEquals(['city', 'now', 'hours', 'labels']));
      expect(saved['city'], 'PARIS');
      expect(refreshed, isTrue);
    });
  });
}
