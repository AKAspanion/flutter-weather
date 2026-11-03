import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/services/weather_widget.dart';

const String _provider = 'com.example.flutterweather.WeatherWidgetProvider';
const MethodChannel _channel = MethodChannel('home_widget');
const MethodChannel _pinChannel = MethodChannel('in.spanion.weather/widget');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  List<String> savedIds() => [
        for (final MethodCall c in calls)
          if (c.method == 'saveWidgetData') c.arguments['id'] as String,
      ];

  WeatherReport report() => WeatherReport(
        current: Weather(name: 'Lisbon', temperature: 295, condition: 800),
        hourly: [Weather(date: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600, temperature: 294)],
        daily: [],
        source: 'Fake',
        attribution: 'Fake',
      );

  test('update saves the city, now and updated, but not the hours, then updates the widget', () async {
    await WeatherWidget.update(report());

    expect(savedIds(), unorderedEquals(['city', 'now', 'updated']));
    expect(calls.firstWhere((MethodCall c) => c.arguments['id'] == 'city').arguments['data'], 'LISBON');
    final MethodCall refresh = calls.last;
    expect(refresh.method, 'updateWidget');
    expect(refresh.arguments['qualifiedAndroidName'], _provider);
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
}
