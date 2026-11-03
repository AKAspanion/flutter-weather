import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A store that fails the way a broken disk would: reads, writes, or both.
class _FailingPreferences implements SharedPreferences {
  final bool failRead;
  final bool failWrite;

  _FailingPreferences({this.failRead = false, this.failWrite = false});

  @override
  String? getString(String key) {
    if (failRead) throw Exception('cannot read');
    return null;
  }

  @override
  Future<bool> setString(String key, String value) {
    if (failWrite) throw Exception('cannot write');
    return Future.value(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UnitManager _manager({Locale device = const Locale('en', 'US'), Future<SharedPreferences> Function()? preferences}) =>
    UnitManager(preferences: preferences, device: () => device);

/// Collects what is logged through debugPrint while a test runs, and restores it afterwards.
List<String?> _captureLogs() {
  final logs = <String?>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) => logs.add(message);
  addTearDown(() => debugPrint = original);
  return logs;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('resolve', () {
    test('follows the region when nothing was saved', () {
      expect(UnitManager.resolve(null, const Locale('en', 'US')), TemperatureUnit.fahrenheit);
      expect(UnitManager.resolve(null, const Locale('en', 'GB')), TemperatureUnit.celsius);
      expect(UnitManager.resolve(null, const Locale('en')), TemperatureUnit.celsius);
    });

    test('uses Fahrenheit in exactly the eight regions that do', () {
      for (final String region in ['US', 'BS', 'BZ', 'KY', 'LR', 'PW', 'FM', 'MH']) {
        expect(UnitManager.resolve(null, Locale('en', region)), TemperatureUnit.fahrenheit, reason: region);
      }
      expect(UnitManager.fahrenheitRegions.length, 8);
      expect(UnitManager.resolve(null, const Locale('en', 'CA')), TemperatureUnit.celsius);
    });

    test('lets a saved unit win over the region', () {
      expect(UnitManager.resolve('celsius', const Locale('en', 'US')), TemperatureUnit.celsius);
      expect(UnitManager.resolve('fahrenheit', const Locale('en', 'GB')), TemperatureUnit.fahrenheit);
    });

    test('follows the region for an unknown saved value', () {
      expect(UnitManager.resolve('kelvin', const Locale('en', 'US')), TemperatureUnit.fahrenheit);
      expect(UnitManager.resolve('kelvin', const Locale('en', 'GB')), TemperatureUnit.celsius);
    });
  });

  group('UnitManager', () {
    test('is the region unit before load', () {
      expect(_manager().unit, TemperatureUnit.fahrenheit);
      expect(_manager(device: const Locale('fr', 'FR')).unit, TemperatureUnit.celsius);
    });

    test('follows the region and notifies once when nothing was saved', () async {
      final manager = _manager();
      var notified = 0;
      manager.addListener(() => notified++);

      await manager.load();

      expect(manager.unit, TemperatureUnit.fahrenheit);
      expect(notified, 1);
    });

    test('restores a saved unit over the region', () async {
      SharedPreferences.setMockInitialValues({UnitManager.preferenceKey: 'celsius'});
      final manager = _manager();

      await manager.load();

      expect(manager.unit, TemperatureUnit.celsius);
    });

    test('saves the chosen unit and restores it in a new manager', () async {
      final manager = _manager();

      await manager.setUnit(TemperatureUnit.celsius);

      expect((await SharedPreferences.getInstance()).getString(UnitManager.preferenceKey), 'celsius');
      final restored = _manager();
      await restored.load();
      expect(restored.unit, TemperatureUnit.celsius);
    });

    test('applies and notifies a new unit once', () async {
      final manager = _manager(device: const Locale('en', 'GB'));
      var notified = 0;
      manager.addListener(() => notified++);

      await manager.setUnit(TemperatureUnit.fahrenheit);

      expect(manager.unit, TemperatureUnit.fahrenheit);
      expect(notified, 1);
    });

    test('does not throw and follows the region when reading fails', () async {
      final logs = _captureLogs();
      final manager = _manager(preferences: () async => _FailingPreferences(failRead: true));
      var notified = 0;
      manager.addListener(() => notified++);

      await manager.load();

      expect(manager.unit, TemperatureUnit.fahrenheit);
      expect(notified, 1);
      expect(logs, isNotEmpty);
    });

    test('keeps the choice, notifies and logs when saving fails', () async {
      final logs = _captureLogs();
      final manager = _manager(
        device: const Locale('en', 'GB'),
        preferences: () async => _FailingPreferences(failWrite: true),
      );
      var notified = 0;
      manager.addListener(() => notified++);

      await manager.setUnit(TemperatureUnit.fahrenheit);

      expect(manager.unit, TemperatureUnit.fahrenheit);
      expect(notified, 1);
      expect(logs, isNotEmpty);
    });
  });

  group('formatTemperature', () {
    test('converts Kelvin to Celsius and Fahrenheit', () {
      expect(formatTemperature(273.15, TemperatureUnit.celsius), '0°C');
      expect(formatTemperature(273.15, TemperatureUnit.fahrenheit), '32°F');
      expect(formatTemperature(300, TemperatureUnit.celsius), '26°C');
      expect(formatTemperature(300, TemperatureUnit.fahrenheit), '80°F');
    });

    test('shows -- for no temperature', () {
      expect(formatTemperature(null, TemperatureUnit.celsius), '--');
      expect(formatTemperature(null, TemperatureUnit.fahrenheit, symbol: false), '--');
    });

    test('shows only the degree sign without the symbol', () {
      expect(formatTemperature(285.15, TemperatureUnit.celsius, symbol: false), '12°');
      expect(formatTemperature(285.15, TemperatureUnit.fahrenheit, symbol: false), '53°');
    });

    test('rounds below zero toward minus infinity, as it always has', () {
      expect(formatTemperature(268.15, TemperatureUnit.celsius), '-5°C');
      expect(formatTemperature(268.15, TemperatureUnit.fahrenheit), '23°F');
      expect(formatTemperature(272.65, TemperatureUnit.celsius), '-1°C');
    });
  });
}
