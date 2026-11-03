import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/services/weather_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _provider = 'com.example.flutterweather.WeatherWidgetProvider';
const MethodChannel _channel = MethodChannel('home_widget');
const MethodChannel _pinChannel = MethodChannel('in.spanion.weather/widget');

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

    test('says MY LOCATION for an unnamed place', () {
      final Map<String, String> data = WeatherWidget.payload(_report(name: ''), l10n, 'en', updated);

      expect(data['city'], 'MY LOCATION');
    });

    test('sends the card titles and the time of the update', () {
      final Map<String, String> data = WeatherWidget.payload(_report(), l10n, 'en', updated);

      expect(_json(data['labels']!), {'now': 'NOW', 'updated': 'Updated 14:05'});
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

      // One Now card: the hours page and its data are gone.
      expect(saved.keys, unorderedEquals(['city', 'now', 'labels']));
      expect(saved['city'], 'PARIS');
      expect(refreshed, isTrue);
    });
  });

  group('accent and pin', () {
    final List<MethodCall> calls = [];
    Object? Function(MethodCall call)? onCall;
    final List<MethodCall> pinCalls = [];
    Object? Function(MethodCall call)? onPinCall;

    setUp(() {
      calls.clear();
      pinCalls.clear();
      onCall = null;
      onPinCall = null;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (
        MethodCall call,
      ) async {
        calls.add(call);
        return onCall?.call(call) ?? true;
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_pinChannel, (
        MethodCall call,
      ) async {
        pinCalls.add(call);
        return onPinCall?.call(call) ?? true;
      });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_pinChannel, null);
    });


    test('setAccent saves the accent index, then updates the widget', () async {
      await WeatherWidget.setAccent(3);

      expect(calls.map((MethodCall c) => c.method), ['saveWidgetData', 'updateWidget']);
      expect(calls.first.arguments['id'], 'accent');
      expect(calls.first.arguments['data'], 3);
      expect(calls.last.arguments['qualifiedAndroidName'], _provider);
    });

    test('setAccent does nothing off Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await WeatherWidget.setAccent(3);

      expect(calls, isEmpty);
    });

    test('setAccent carries on when the channel fails', () async {
      onCall = (MethodCall call) => throw PlatformException(code: 'boom');

      await expectLater(WeatherWidget.setAccent(3), completes);
      expect(calls.map((MethodCall c) => c.method), ['saveWidgetData']);
    });

    test('pin asks MainActivity to pin, and does not go through home_widget', () async {
      await WeatherWidget.pin();

      expect(pinCalls.map((MethodCall c) => c.method), ['pin']);
      expect(calls.where((MethodCall c) => c.method == 'requestPinWidget'), isEmpty);
    });

    test('pin carries on when the channel fails', () async {
      onPinCall = (MethodCall call) => throw PlatformException(code: 'boom');

      await expectLater(WeatherWidget.pin(), completes);
      expect(pinCalls, hasLength(1));
    });

    test('pin does nothing off Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await WeatherWidget.pin();

      expect(pinCalls, isEmpty);
      expect(calls, isEmpty);
    });
  });
}
