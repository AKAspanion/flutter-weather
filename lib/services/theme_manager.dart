import 'package:flutter/material.dart';
import 'package:flutterweather/theme/app_theme.dart';

class ThemeManager with ChangeNotifier {
  ThemeData _themeData;
  AppTheme _theme;

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
    return _theme == AppTheme.White ? Colors.white : Color(0xFF404040);
  }

  Color get textColor {
    return _theme == AppTheme.Dark ? Colors.white : Colors.black87;
  }

  setTheme(AppTheme theme) async {
    print(theme);
    _theme = theme;
    _themeData = appThemeData[theme];

    notifyListeners();
  }
}
