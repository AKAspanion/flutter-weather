import 'package:flutter/material.dart';
import 'package:flutterweather/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  ThemeData _themeData;
  AppTheme _theme;

  final _kThemePreference = "theme_preference";

  ThemeManager() {
    _loadTheme();
  }

  void _loadTheme() {
    SharedPreferences.getInstance().then((prefs) {
      int preferredTheme = prefs.getInt(_kThemePreference) ?? 0;
      _theme = AppTheme.values[preferredTheme];
      _themeData = appThemeData[AppTheme.values[preferredTheme]];
      notifyListeners();
    });
  }

  ThemeData get themeData {
    if (_themeData == null) {
      _theme = AppTheme.White;
      _themeData = appThemeData[AppTheme.White];
    }
    return _themeData;
  }

  AppTheme get theme {
    if (_theme == null) {
      _theme = AppTheme.White;
    }
    return _theme;
  }

  Color get bgColor {
    return _theme == AppTheme.White ? Color(0xFFF2F7FB) : Color(0xFF3E4551);
  }

  Color get textColor {
    return _theme == AppTheme.Dark ? Color(0xFFFAFAFB) : Colors.black87;
  }

  setTheme(AppTheme theme) async {
    _theme = theme;
    _themeData = appThemeData[theme];

    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_kThemePreference, AppTheme.values.indexOf(theme));

    notifyListeners();
  }
}
