import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutterweather/services/calendar.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/services/weather_cache.dart';
import 'package:flutterweather/services/weather_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// Feeds the Android home-screen widget (WeatherWidgetProvider.kt).
class WeatherWidget {
  // Qualified because the Kotlin package differs from the application ID.
  static const String _androidName = 'com.example.flutterweather.WeatherWidgetProvider';
  static const String _refreshTask = 'refresh-weather-widget';

  static bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// How many upcoming forecast entries the widget's card stack holds.
  static const int _hourCards = 12;

  static Future<void> update(WeatherReport report) async {
    if (!_supported) return;
    try {
      final Weather now = report.current;
      final Weather? today = report.daily.isEmpty ? null : report.daily.first;
      final DateTime updated = DateTime.now();
      final int nowSeconds = updated.millisecondsSinceEpoch ~/ 1000;

      final List<Map<String, String>> hours = report.hourly
          .where((w) => (w.date ?? 0) > nowSeconds)
          .take(_hourCards)
          .map((w) => {
                'label': _hourLabel(w),
                'temperature': _degrees(w.temperature),
                'icon': w.getIcon(overrideNight: _isNight(w) ? '-night' : ''),
                'description': (w.description ?? '').toUpperCase(),
                'detail': 'HUMIDITY ${w.humidity ?? '--'}%',
                'aside': 'WIND ${w.windSpeed ?? '--'}m/s',
              })
          .toList();

      // The current weather comes first. The widget's looping StackView reveals
      // the previous card on a swipe up, so the hours go in reverse after it:
      // swiping up then steps forward through the next hours.
      final List<Map<String, String>> cards = [
        {
          'label': 'NOW',
          'temperature': _degrees(now.temperature),
          'icon': now.getIcon(),
          'description': (now.description ?? '').toUpperCase(),
          'detail': today == null ? '' : 'H ${_degrees(today.tempMax)}  L ${_degrees(today.tempMin)}',
        },
        ...hours.reversed,
      ];

      await Future.wait([
        HomeWidget.saveWidgetData<String>('city', (now.name ?? '').toUpperCase()),
        HomeWidget.saveWidgetData<String>('cards', jsonEncode(cards)),
        HomeWidget.saveWidgetData<String>(
          'updated',
          '${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}',
        ),
      ]);
      await HomeWidget.updateWidget(qualifiedAndroidName: _androidName);
    } catch (e) {
      debugPrint('Widget update failed: $e');
    }
  }

  static DateTime _localTime(Weather w) =>
      DateTime.fromMillisecondsSinceEpoch(w.date! * 1000, isUtc: true).add(Duration(seconds: w.timezone ?? 0));

  /// "3 PM", or "TUE 3 AM" once the forecast reaches the next day.
  static String _hourLabel(Weather w) {
    final DateTime time = _localTime(w);
    final DateTime placeNow = DateTime.now().toUtc().add(Duration(seconds: w.timezone ?? 0));
    final String hour = '${(time.hour + 11) % 12 + 1} ${time.hour >= 12 ? 'PM' : 'AM'}';
    if (time.day == placeNow.day) return hour;
    return '${CalendarHelper.weekdays[time.weekday - 1].substring(0, 3).toUpperCase()} $hour';
  }

  // Same rule as the hourly forecast chips.
  static bool _isNight(Weather w) {
    final int hour = _localTime(w).hour;
    return hour > 18 || hour <= 6;
  }

  static Future<bool>? _canPin;

  /// Whether the launcher can add the widget from inside the app. Cached, as
  /// the menu asks on every rebuild.
  static Future<bool> canPin() => _canPin ??= _checkCanPin();

  static Future<bool> _checkCanPin() async {
    if (!_supported) return false;
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Asks the launcher to add the widget to the home screen.
  static Future<void> pin() => HomeWidget.requestPinWidget(qualifiedAndroidName: _androidName);

  /// Refreshes the widget about once an hour, for the place last viewed in the
  /// app. Background location is deliberately not used.
  static Future<void> scheduleRefresh() async {
    if (!_supported) return;
    try {
      await Workmanager().initialize(widgetRefreshDispatcher);
      await Workmanager().registerPeriodicTask(
        _refreshTask,
        _refreshTask,
        frequency: const Duration(hours: 1),
        // The app itself just refreshed the widget; don't start a second engine during launch.
        initialDelay: const Duration(hours: 1),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (e) {
      debugPrint('Scheduling widget refresh failed: $e');
    }
  }

  static String _degrees(double? kelvin) => kelvin == null ? '--' : '${(kelvin - kelvinOffset).floor()}°';

}

/// Runs in a background isolate started by WorkManager.
@pragma('vm:entry-point')
void widgetRefreshDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final WeatherQuery? query = await WeatherCache.loadQuery();
      if (query == null) return true;

      final WeatherReport report = await query.fetch(WeatherService.withDefaultProviders());
      await WeatherCache.save(report, query);
      await WeatherWidget.update(report);
      return true;
    } catch (e) {
      debugPrint('Background widget refresh failed: $e');
      return false; // WorkManager retries with backoff
    }
  });
}
