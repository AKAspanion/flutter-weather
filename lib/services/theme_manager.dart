import 'package:flutter/material.dart';
import 'package:flutterweather/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The theme to show: [override] while it was set against the current [system] brightness, else the theme
/// matching [system]. A system change thereby ends an override without the caller tracking it.
AppTheme resolveTheme(Brightness system, AppTheme? override, Brightness? overrideSystem) {
  if (override != null && overrideSystem == system) return override;
  return system == Brightness.dark ? AppTheme.Dark : AppTheme.White;
}

/// Holds the theme: it follows the system brightness, and the theme button sets an override that holds until the
/// system brightness changes.
class ThemeManager with ChangeNotifier, WidgetsBindingObserver {
  static const _kThemePreference = 'theme_preference';
  static const _kThemePreferenceSystem = 'theme_preference_system';

  late Brightness _system;
  AppTheme? _override;
  Brightness? _overrideSystem;
  late AppTheme _theme;
  late ThemeData _themeData;

  ThemeManager() {
    // Read here so the first frame already matches the system when there is no override.
    _system = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _apply();
    WidgetsBinding.instance.addObserver(this);
    _loadTheme();
  }

  void _apply() {
    _theme = resolveTheme(_system, _override, _overrideSystem);
    _themeData = appThemeData[_theme]!;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_kThemePreference);
    if (saved == null || saved < 0 || saved >= AppTheme.values.length) return;
    _override = AppTheme.values[saved];

    final savedSystem = prefs.getInt(_kThemePreferenceSystem);
    if (savedSystem == null || savedSystem < 0 || savedSystem >= Brightness.values.length) {
      // Saved before the system was followed: take it as set against the brightness now showing.
      _overrideSystem = _system;
      await prefs.setInt(_kThemePreferenceSystem, _system.index);
    } else {
      _overrideSystem = Brightness.values[savedSystem];
    }

    if (_overrideSystem != _system) {
      // The system changed while the app was closed, so the override is over.
      await _clearOverride(prefs);
    }
    _apply();
    notifyListeners();
  }

  Future<void> _clearOverride([SharedPreferences? loaded]) async {
    _override = null;
    _overrideSystem = null;
    final prefs = loaded ?? await SharedPreferences.getInstance();
    await prefs.remove(_kThemePreference);
    await prefs.remove(_kThemePreferenceSystem);
  }

  ThemeData get themeData => _themeData;

  AppTheme get theme => _theme;

  Color get bgColor {
    return _theme == AppTheme.White ? Colors.white : Color(0xFF3E4551);
  }

  Color get textColor {
    return _theme == AppTheme.Dark ? Colors.white : Colors.black87;
  }

  Future<void> setTheme(AppTheme theme) async {
    _override = theme;
    _overrideSystem = _system;
    _apply();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemePreference, AppTheme.values.indexOf(theme));
    await prefs.setInt(_kThemePreferenceSystem, _system.index);
  }

  @override
  void didChangePlatformBrightness() {
    _system = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _override = null;
    _overrideSystem = null;
    _apply();
    notifyListeners();
    _clearOverride();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
