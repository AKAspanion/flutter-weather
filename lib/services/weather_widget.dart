import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/l10n/conditions.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/services/weather_cache.dart';
import 'package:flutterweather/services/weather_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// The words the widget shows: the language saved by the app, else the phone's, else English. Works without a
  /// BuildContext, as the background refresh has none. [device] is only for tests.
  static Future<AppLocalizations> localizations({@visibleForTesting Locale? device}) async {
    String? saved;
    try {
      saved = (await SharedPreferences.getInstance()).getString(LocaleManager.preferenceKey);
    } catch (e) {
      debugPrint('Could not read the saved language for the widget: $e');
    }
    final Locale locale = LocaleManager.resolve(saved, device ?? PlatformDispatcher.instance.locale);
    return lookupAppLocalizations(locale);
  }

  /// The unit the widget shows: the saved one, else the region's. Works without a BuildContext, as the background
  /// refresh has none. [device] is only for tests.
  static Future<TemperatureUnit> temperatureUnit({@visibleForTesting Locale? device}) async {
    String? saved;
    try {
      saved = (await SharedPreferences.getInstance()).getString(UnitManager.preferenceKey);
    } catch (e) {
      debugPrint('Could not read the saved temperature unit for the widget: $e');
    }
    return UnitManager.resolve(saved, device ?? PlatformDispatcher.instance.locale);
  }

  static Future<void> update(WeatherReport report) async {
    if (!_supported) return;
    try {
      final AppLocalizations l10n = await localizations();
      // Date formats of a language other than English need its symbols loaded first.
      await initializeDateFormatting(l10n.localeName);
      final TemperatureUnit unit = await temperatureUnit();
      final Map<String, String> data = payload(report, l10n, l10n.localeName, DateTime.now(), unit: unit);

      await Future.wait([
        for (final MapEntry<String, String> entry in data.entries)
          HomeWidget.saveWidgetData<String>(entry.key, entry.value),
      ]);
      await HomeWidget.updateWidget(qualifiedAndroidName: _androidName);
    } catch (e) {
      debugPrint('Widget update failed: $e');
    }
  }

  /// What [update] saves, keyed by widget data name, each value a String. The widget shows the city, description
  /// and card titles in capitals, so they are upper-cased here. Callers load the date symbols of [locale] first.
  @visibleForTesting
  static Map<String, String> payload(
    WeatherReport report,
    AppLocalizations l10n,
    String locale,
    DateTime updated, {
    TemperatureUnit unit = TemperatureUnit.celsius,
  }) {
    final Weather now = report.current;
    final Weather? today = report.daily.isEmpty ? null : report.daily.first;
    final String name = now.name ?? '';

    return {
      'city': (name.isEmpty ? l10n.myLocation : name).toUpperCase(),
      'now': jsonEncode({
        'temperature': formatTemperature(now.temperature, unit, symbol: false),
        'icon': _icon(now),
        'description': describeCondition(l10n, now.condition).toUpperCase(),
        'detail': today == null
            ? ''
            : l10n.widgetHighLow(
                formatTemperature(today.tempMax, unit, symbol: false),
                formatTemperature(today.tempMin, unit, symbol: false),
              ),
        'sunrise': _clock(now.sunrise, now.timezone),
        'wind': '${now.windSpeed ?? '--'} m/s',
        'humidity': '${now.humidity ?? '--'}%',
      }),
      'hours': jsonEncode(_nextDay(report.hourly, updated, locale, unit)),
      'labels': jsonEncode({
        'now': l10n.widgetNow.toUpperCase(),
        'next24Hours': l10n.widgetNext24Hours.toUpperCase(),
        'updated': l10n.widgetUpdated(DateFormat.Hm(locale).format(updated)),
      }),
    };
  }

  /// Picks forecast entries at least 3 hours apart across the next 24 hours.
  /// OpenWeatherMap already steps by 3 hours; hourly providers get thinned out.
  static List<Map<String, String>> _nextDay(List<Weather> hourly, DateTime from, String locale, TemperatureUnit unit) {
    final int start = from.millisecondsSinceEpoch ~/ 1000;
    final List<Map<String, String>> picked = [];
    int? last;
    for (final Weather w in hourly) {
      final int date = w.date ?? 0;
      if (date <= start || date > start + Duration.secondsPerDay) continue;
      if (last != null && date - last < _hourStep - 60) continue;
      picked.add({
        'label': _hourLabel(w, locale),
        'icon': _icon(w, overrideNight: _isNight(w) ? '-night' : ''),
        'temperature': formatTemperature(w.temperature, unit, symbol: false),
      });
      last = date;
      if (picked.length == _hourColumns) break;
    }
    return picked;
  }

  /// The icon name, empty without a condition (the widget then falls back to its default icon).
  static String _icon(Weather w, {String? overrideNight}) =>
      w.condition == null ? '' : w.getIcon(overrideNight: overrideNight);

  /// Same format as the app's sunrise chip, e.g. "5:50".
  static String _clock(int? epochSeconds, int? timezone) {
    if (epochSeconds == null) return '--';
    final DateTime time =
        DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000, isUtc: true).add(Duration(seconds: timezone ?? 0));
    final int hour = time.hour > 12 ? time.hour - 12 : time.hour;
    return '$hour:${time.minute.toString().padLeft(2, '0')}';
  }

  static DateTime _localTime(Weather w) =>
      DateTime.fromMillisecondsSinceEpoch(w.date! * 1000, isUtc: true).add(Duration(seconds: w.timezone ?? 0));

  /// The hour in the locale's short form for a narrow column, e.g. "3 PM" or "15".
  static String _hourLabel(Weather w, String locale) => DateFormat.j(locale).format(_localTime(w));

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
