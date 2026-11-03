import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A language the app is translated into.
class Language {
  final String code;
  final String nativeName;

  const Language(this.code, this.nativeName);
}

/// The languages the user can pick, English first (the source and fallback).
const List<Language> supportedLanguages = [
  Language('en', 'English'),
  Language('zh', '中文'),
  Language('hi', 'हिन्दी'),
  Language('es', 'Español'),
  Language('ar', 'العربية'),
  Language('fr', 'Français'),
  Language('bn', 'বাংলা'),
  Language('pt', 'Português'),
  Language('ru', 'Русский'),
  Language('ur', 'اردو'),
];

bool _isSupported(String? code) => supportedLanguages.any((l) => l.code == code);

/// The language the user picked, or null to follow the phone ("System default").
class LocaleManager extends ChangeNotifier {
  static const String preferenceKey = 'language_preference';

  /// Tests swap this for a store that fails.
  final Future<SharedPreferences> Function() _preferences;
  Locale? _locale;

  LocaleManager({Future<SharedPreferences> Function()? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance;

  /// Null means System default.
  Locale? get locale => _locale;

  /// Restores the saved choice. An unknown or unreadable one means System default.
  Future<void> load() async {
    try {
      final String? code = (await _preferences()).getString(preferenceKey);
      _locale = _isSupported(code) ? Locale(code!) : null;
    } catch (e) {
      debugPrint('Could not read the saved language: $e');
      _locale = null;
    }
    notifyListeners();
  }

  /// Applies [locale] at once and saves it (null removes the saved choice). A failed save is logged and not thrown:
  /// the choice still holds until the app closes.
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final SharedPreferences prefs = await _preferences();
      if (locale == null) {
        await prefs.remove(preferenceKey);
      } else {
        await prefs.setString(preferenceKey, locale.languageCode);
      }
    } catch (e) {
      debugPrint('Could not save the language: $e');
    }
  }

  /// The locale to use without a BuildContext (the widget's background refresh): the saved code if supported, else
  /// the device's language if supported, else English.
  static Locale resolve(String? savedCode, Locale device) {
    if (_isSupported(savedCode)) return Locale(savedCode!);
    if (_isSupported(device.languageCode)) return Locale(device.languageCode);
    return const Locale('en');
  }
}
