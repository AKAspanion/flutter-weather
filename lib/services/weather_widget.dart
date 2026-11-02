import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  /// The second widget card shows the next 24 hours as 8 columns, 3 hours apart.
  static const int _hourColumns = 8;
  static const int _hourStep = 3 * 3600;

  static Future<void> update(WeatherReport report) async {
    if (!_supported) return;
    try {
      final Weather now = report.current;
      final Weather? today = report.daily.isEmpty ? null : report.daily.first;
      final DateTime updated = DateTime.now();

      await Future.wait([
        HomeWidget.saveWidgetData<String>('city', (now.name ?? '').toUpperCase()),
        HomeWidget.saveWidgetData<String>(
          'now',
          jsonEncode({
            'temperature': _degrees(now.temperature),
            'icon': now.getIcon(),
            'description': (now.description ?? '').toUpperCase(),
            'detail': today == null ? '' : 'H ${_degrees(today.tempMax)}  L ${_degrees(today.tempMin)}',
          }),
        ),
        HomeWidget.saveWidgetData<String>('hours', jsonEncode(_nextDay(report.hourly, updated))),
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

  /// Picks forecast entries at least 3 hours apart across the next 24 hours.
  /// OpenWeatherMap already steps by 3 hours; hourly providers get thinned out.
  static List<Map<String, String>> _nextDay(List<Weather> hourly, DateTime from) {
    final int start = from.millisecondsSinceEpoch ~/ 1000;
    final List<Map<String, String>> picked = [];
    int? last;
    for (final Weather w in hourly) {
      final int date = w.date ?? 0;
      if (date <= start || date > start + Duration.secondsPerDay) continue;
      if (last != null && date - last < _hourStep - 60) continue;
      picked.add({
        'label': _hourLabel(w),
        'icon': w.getIcon(overrideNight: _isNight(w) ? '-night' : ''),
        'temperature': _degrees(w.temperature),
      });
      last = date;
      if (picked.length == _hourColumns) break;
    }
    return picked;
  }

  static DateTime _localTime(Weather w) =>
      DateTime.fromMillisecondsSinceEpoch(w.date! * 1000, isUtc: true).add(Duration(seconds: w.timezone ?? 0));

  /// Compact hour for a narrow column: "12P", "3A".
  static String _hourLabel(Weather w) {
    final DateTime time = _localTime(w);
    return '${(time.hour + 11) % 12 + 1}${time.hour >= 12 ? 'P' : 'A'}';
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
