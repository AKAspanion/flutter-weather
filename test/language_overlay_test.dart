import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/l10n/app_localizations_en.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/views/home/language_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// English text for every language, so these tests don't depend on which translations exist yet.
class _EnglishForAll extends LocalizationsDelegate<AppLocalizations> {
  const _EnglishForAll();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizationsEn();

  @override
  bool shouldReload(_EnglishForAll old) => false;
}

Future<LocaleManager> _pump(WidgetTester tester, {Locale? chosen, required void Function() onClose}) async {
  final manager = LocaleManager();
  await manager.load();
  if (chosen != null) await manager.setLocale(chosen);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider<LocaleManager>.value(value: manager),
      ],
      child: Consumer<LocaleManager>(
        builder: (_, m, __) => MaterialApp(
          localizationsDelegates: const [
            _EnglishForAll(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [for (final l in supportedLanguages) Locale(l.code)],
          locale: m.locale,
          home: Scaffold(
            body: Stack(children: [LanguageOverlay(accent: 0, onClose: onClose)]),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return manager;
}

/// The row of the picker that shows [label].
Finder _row(String label) => find.ancestor(of: find.text(label), matching: find.byType(ListTile));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('lists System default, then the ten languages by native name, with a check on System default',
      (tester) async {
    await _pump(tester, onClose: () {});

    final labels = ['System default', for (final l in supportedLanguages) l.nativeName];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    final tops = [for (final label in labels) tester.getTopLeft(find.text(label)).dy];
    expect(tops, orderedEquals([...tops]..sort()));

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.descendant(of: _row('System default'), matching: find.byIcon(Icons.check)), findsOneWidget);
  });

  testWidgets('tapping a language applies it and closes', (tester) async {
    var closed = 0;
    final manager = await _pump(tester, onClose: () => closed++);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(manager.locale, const Locale('es'));
    expect(closed, 1);
  });

  testWidgets('tapping System default clears the choice and closes', (tester) async {
    var closed = 0;
    final manager = await _pump(tester, chosen: const Locale('es'), onClose: () => closed++);
    expect(find.descendant(of: _row('Español'), matching: find.byIcon(Icons.check)), findsOneWidget);

    // System default is the first row; its words change with the language, so it is found by position.
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(manager.locale, isNull);
    expect(closed, 1);
  });

  testWidgets('the close button closes without changing the language', (tester) async {
    var closed = 0;
    final manager = await _pump(tester, chosen: const Locale('es'), onClose: () => closed++);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(manager.locale, const Locale('es'));
    expect(closed, 1);
  });

  testWidgets('in Arabic it reads right to left', (tester) async {
    await _pump(tester, chosen: const Locale('ar'), onClose: () {});

    expect(tester.takeException(), isNull);
    expect(Directionality.of(tester.element(find.byType(LanguageOverlay))), TextDirection.rtl);
  });
}
