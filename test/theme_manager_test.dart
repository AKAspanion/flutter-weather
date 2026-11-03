import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets the manager's asynchronous prefs load finish.
Future<void> settle(WidgetTester tester) => tester.runAsync(() => Future<void>.delayed(Duration.zero));

void main() {
  group('resolveTheme', () {
    test('follows the system when there is no override', () {
      expect(resolveTheme(Brightness.dark, null, null), AppTheme.Dark);
      expect(resolveTheme(Brightness.light, null, null), AppTheme.White);
    });

    test('keeps the override set against the current system brightness', () {
      expect(resolveTheme(Brightness.light, AppTheme.Dark, Brightness.light), AppTheme.Dark);
    });

    test('drops an override set against the other brightness', () {
      expect(resolveTheme(Brightness.dark, AppTheme.White, Brightness.light), AppTheme.Dark);
    });
  });

  group('ThemeManager', () {
    testWidgets('matches a dark system on the first frame, before prefs load', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final manager = ThemeManager();
      addTearDown(manager.dispose);

      expect(manager.theme, AppTheme.Dark);
      expect(manager.themeData.brightness, Brightness.dark);
    });

    testWidgets('treats a saved theme without a system brightness as set against the current one', (tester) async {
      SharedPreferences.setMockInitialValues({'theme_preference': 1});
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final manager = ThemeManager();
      addTearDown(manager.dispose);
      await settle(tester);

      expect(manager.theme, AppTheme.Dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_preference_system'), Brightness.light.index);
    });

    testWidgets('clears the override when the system brightness changes', (tester) async {
      SharedPreferences.setMockInitialValues({'theme_preference': 1});
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final manager = ThemeManager();
      addTearDown(manager.dispose);
      await settle(tester);
      var notified = 0;
      manager.addListener(() => notified++);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await settle(tester);
      expect(manager.theme, AppTheme.Dark);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await settle(tester);
      expect(manager.theme, AppTheme.White);
      expect(notified, 2);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('theme_preference'), isFalse);
      expect(prefs.containsKey('theme_preference_system'), isFalse);
    });

    testWidgets('setTheme saves the override with the current system brightness', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final manager = ThemeManager();
      addTearDown(manager.dispose);
      await settle(tester);
      var notified = 0;
      manager.addListener(() => notified++);

      await tester.runAsync(() => manager.setTheme(AppTheme.Dark));

      expect(manager.theme, AppTheme.Dark);
      expect(notified, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_preference'), 1);
      expect(prefs.getInt('theme_preference_system'), Brightness.light.index);
    });
  });
}
