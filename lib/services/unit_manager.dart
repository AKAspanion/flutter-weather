import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The unit temperatures are shown in. Providers always hand over Kelvin; this only changes what is displayed.
enum TemperatureUnit { celsius, fahrenheit }

/// The temperature unit the user picked, or the one their phone's region uses until they pick.
class UnitManager extends ChangeNotifier {
  /// Holds `celsius` or `fahrenheit`. Absent means the region decides.
  static const String preferenceKey = 'temperature_unit';

  /// The countries that use Fahrenheit for everyday weather.
  static const Set<String> fahrenheitRegions = {'US', 'BS', 'BZ', 'KY', 'LR', 'PW', 'FM', 'MH'};

  /// Tests swap these for a store that fails and a chosen region.
  final Future<SharedPreferences> Function() _preferences;
  final Locale Function() _device;
  late TemperatureUnit _unit;

  /// [preferences] and [device] are for tests; [device] defaults to the phone's locale.
  UnitManager({Future<SharedPreferences> Function()? preferences, Locale Function()? device})
      : _preferences = preferences ?? SharedPreferences.getInstance,
        _device = device ?? (() => PlatformDispatcher.instance.locale) {
    _unit = resolve(null, _device());
  }

  /// Before [load] this is the region's unit.
  TemperatureUnit get unit => _unit;

  /// Restores the saved unit. Nothing saved, an unknown value or an unreadable store means the region's unit.
  Future<void> load() async {
    String? saved;
    try {
      saved = (await _preferences()).getString(preferenceKey);
    } catch (e) {
      debugPrint('Could not read the saved temperature unit: $e');
    }
    _unit = resolve(saved, _device());
    notifyListeners();
  }

  /// Applies [unit] at once and saves it. A failed save is logged and not thrown: the choice still holds until the
  /// app closes.
  Future<void> setUnit(TemperatureUnit unit) async {
    _unit = unit;
    notifyListeners();
    try {
      await (await _preferences()).setString(preferenceKey, unit.name);
    } catch (e) {
      debugPrint('Could not save the temperature unit: $e');
    }
  }

  /// The unit to use without a BuildContext (the widget's background refresh): the saved one when it is valid, else
  /// Fahrenheit in the regions that use it, else Celsius.
  static TemperatureUnit resolve(String? saved, Locale device) {
    for (final TemperatureUnit unit in TemperatureUnit.values) {
      if (unit.name == saved) return unit;
    }
    return fahrenheitRegions.contains(device.countryCode) ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;
  }
}

/// The one place Kelvin becomes shown text. `--` for no temperature, else the value rounded down, with `°C` / `°F`,
/// or only `°` when [symbol] is false (the widget has no room for the letter).
String formatTemperature(double? kelvin, TemperatureUnit unit, {bool symbol = true}) {
  if (kelvin == null) return '--';
  final double celsius = kelvin - kelvinOffset;
  final int degrees = switch (unit) {
    TemperatureUnit.celsius => celsius.floor(),
    TemperatureUnit.fahrenheit => (celsius * 9 / 5 + 32).floor(),
  };
  final String letter = unit == TemperatureUnit.celsius ? 'C' : 'F';
  return symbol ? '$degrees°$letter' : '$degrees°';
}
