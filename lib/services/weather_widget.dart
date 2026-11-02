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

  static Future<void> update(WeatherReport report) async {
    if (!_supported) return;
    try {
      final Weather now = report.current;
      final Weather? today = report.daily.isEmpty ? null : report.daily.first;
      final DateTime updated = DateTime.now();

      await Future.wait([
        HomeWidget.saveWidgetData<String>('city', (now.name ?? '').toUpperCase()),
        HomeWidget.saveWidgetData<String>('temperature', _degrees(now.temperature)),
        HomeWidget.saveWidgetData<String>('description', (now.description ?? '').toUpperCase()),
        HomeWidget.saveWidgetData<String>('icon', _emoji(now.getIcon())),
        HomeWidget.saveWidgetData<String>(
          'range',
          today == null ? '' : 'H ${_degrees(today.tempMax)}  L ${_degrees(today.tempMin)}',
        ),
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

  static String _emoji(String icon) {
    final bool night = icon.endsWith('-night');
    switch (icon.replaceAll('-night', '')) {
      case 'thunder':
        return '⛈️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'clear':
        return night ? '🌙' : '☀️';
      case 'sunny':
        return night ? '🌙' : '🌤️';
      case 'foggy':
        return '🌫️';
      case 'broken':
        return '☁️';
      default:
        return night ? '☁️' : '⛅';
    }
  }
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
