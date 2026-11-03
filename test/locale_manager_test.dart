import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('has no language when nothing was saved', () async {
    final manager = LocaleManager();
    await manager.load();

    expect(manager.locale, isNull);
  });

  test('saves the chosen language, restores it, and notifies once', () async {
    final manager = LocaleManager();
    var notified = 0;
    manager.addListener(() => notified++);

    await manager.setLocale(const Locale('es'));

    expect(notified, 1);
    expect((await SharedPreferences.getInstance()).getString(LocaleManager.preferenceKey), 'es');
    final restored = LocaleManager();
    await restored.load();
    expect(restored.locale, const Locale('es'));
  });

  test('System default removes the saved language', () async {
    SharedPreferences.setMockInitialValues({LocaleManager.preferenceKey: 'es'});
    final manager = LocaleManager();
    await manager.load();

    await manager.setLocale(null);

    expect(manager.locale, isNull);
    expect((await SharedPreferences.getInstance()).containsKey(LocaleManager.preferenceKey), isFalse);
  });

  test('treats an unknown saved code as System default', () async {
    SharedPreferences.setMockInitialValues({LocaleManager.preferenceKey: 'xx'});
    final manager = LocaleManager();
    await manager.load();

    expect(manager.locale, isNull);
  });

  test('keeps the choice, notifies and logs when saving fails', () async {
    final manager = LocaleManager(preferences: () async => throw Exception('disk full'));
    var notified = 0;
    manager.addListener(() => notified++);
    final logs = <String?>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => logs.add(message);
    addTearDown(() => debugPrint = original);

    await manager.setLocale(const Locale('fr'));

    expect(manager.locale, const Locale('fr'));
    expect(notified, 1);
    expect(logs, isNotEmpty);
  });

  test('resolves a locale without a BuildContext', () {
    expect(LocaleManager.resolve('hi', const Locale('fr')), const Locale('hi'));
    expect(LocaleManager.resolve(null, const Locale('fr')), const Locale('fr'));
    expect(LocaleManager.resolve(null, const Locale('de')), const Locale('en'));
    expect(LocaleManager.resolve('xx', const Locale('de')), const Locale('en'));
  });

  test('lists the ten languages in order', () {
    expect(supportedLanguages.map((l) => l.code), ['en', 'zh', 'hi', 'es', 'ar', 'fr', 'bn', 'pt', 'ru', 'ur']);
    expect(
      supportedLanguages.map((l) => l.nativeName),
      ['English', '中文', 'हिन्दी', 'Español', 'العربية', 'Français', 'বাংলা', 'Português', 'Русский', 'اردو'],
    );
  });
}
