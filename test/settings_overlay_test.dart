import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/l10n/app_localizations_en.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/theme/app_theme.dart';
import 'package:flutterweather/theme/contrast.dart';
import 'package:flutterweather/views/settings/settings_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// English text for every language, so these tests don't depend on which translations exist.
class _EnglishForAll extends LocalizationsDelegate<AppLocalizations> {
  const _EnglishForAll();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizationsEn();

  @override
  bool shouldReload(_EnglishForAll old) => false;
}

/// What the panel reported, in order, so a test can say which callbacks it expects.
class _Calls {
  final List<String> names = [];

  /// The unit saved in the store at the moment onUnitChanged ran.
  final List<String?> savedWhenUnitChanged = [];
}

class _Panel {
  final LocaleManager locale;
  final UnitManager unit;
  final ThemeManager theme;
  final _Calls calls;

  _Panel(this.locale, this.unit, this.theme, this.calls);
}

Future<_Panel> _pump(WidgetTester tester,
    {Locale? chosen, TemperatureUnit? unit, int accent = 0, bool dark = false}) async {
  final locale = LocaleManager();
  await locale.load();
  if (chosen != null) await locale.setLocale(chosen);
  final units = UnitManager(device: () => const Locale('en', 'GB'));
  await units.load();
  if (unit != null) await units.setUnit(unit);
  final theme = ThemeManager();
  if (dark) await theme.setTheme(AppTheme.Dark);
  final calls = _Calls();
  final store = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>.value(value: theme),
        ChangeNotifierProvider<LocaleManager>.value(value: locale),
        ChangeNotifierProvider<UnitManager>.value(value: units),
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
            body: Stack(
              children: [
                SettingsOverlay(
                  accent: accent,
                  onClose: () => calls.names.add('close'),
                  onLanguage: () => calls.names.add('language'),
                  onRate: () => calls.names.add('rate'),
                  onUnitChanged: () {
                    calls.names.add('unitChanged');
                    calls.savedWhenUnitChanged.add(store.getString('temperature_unit'));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Panel(locale, units, theme, calls);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the title, the four rows and both units', (tester) async {
    await _pump(tester);

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Rate on Google Play'), findsOneWidget);
    expect(find.text('°C'), findsOneWidget);
    expect(find.text('°F'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsOneWidget);
  });

  testWidgets('the rows run top to bottom as Theme, Language, Temperature, Rate on Google Play', (tester) async {
    await _pump(tester);

    final tops = [
      for (final label in ['Theme', 'Language', 'Temperature', 'Rate on Google Play'])
        tester.getTopLeft(find.text(label)).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
    expect(tops.toSet().length, 4);
  });

  testWidgets('the Theme row shows a sun and a moon, read aloud as Light and Dark', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);

    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    expect(find.byIcon(Icons.brightness_3), findsOneWidget);
    expect(find.bySemanticsLabel('Light'), findsOneWidget);
    expect(find.bySemanticsLabel('Dark'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('tapping the moon makes the theme dark and leaves the panel open', (tester) async {
    final panel = await _pump(tester);
    expect(panel.theme.theme, AppTheme.White);

    await tester.tap(find.byIcon(Icons.brightness_3));
    await tester.pumpAndSettle();

    expect(panel.theme.theme, AppTheme.Dark);
    expect(find.byType(SettingsOverlay), findsOneWidget);
    expect(panel.calls.names, isEmpty);
  });

  testWidgets('tapping the sun makes the theme light again', (tester) async {
    final panel = await _pump(tester);
    await tester.tap(find.byIcon(Icons.brightness_3));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.wb_sunny));
    await tester.pumpAndSettle();

    expect(panel.theme.theme, AppTheme.White);
    expect(panel.calls.names, isEmpty);
  });

  testWidgets('the Language row shows System default when no language is saved', (tester) async {
    await _pump(tester);

    expect(find.text('System default'), findsOneWidget);
  });

  testWidgets('the Language row shows the native name of the chosen language', (tester) async {
    await _pump(tester, chosen: const Locale('hi'));

    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('System default'), findsNothing);
  });

  testWidgets('tapping °F switches to Fahrenheit, keeps the panel open and reports the change once, after the save',
      (tester) async {
    final panel = await _pump(tester, unit: TemperatureUnit.celsius);

    await tester.tap(find.text('°F'));
    await tester.pumpAndSettle();

    expect(panel.unit.unit, TemperatureUnit.fahrenheit);
    expect(find.byType(SettingsOverlay), findsOneWidget);
    expect(panel.calls.names, ['unitChanged']);
    expect(panel.calls.savedWhenUnitChanged, ['fahrenheit']);
  });

  testWidgets('tapping the unit already chosen reports nothing', (tester) async {
    final panel = await _pump(tester, unit: TemperatureUnit.celsius);

    await tester.tap(find.text('°C'));
    await tester.pumpAndSettle();

    expect(panel.unit.unit, TemperatureUnit.celsius);
    expect(panel.calls.names, isEmpty);
  });

  testWidgets('tapping the Language row calls onLanguage and nothing else', (tester) async {
    final panel = await _pump(tester);

    await tester.tap(find.text('Language'));

    expect(panel.calls.names, ['language']);
  });

  testWidgets('tapping Rate on Google Play calls onRate and nothing else', (tester) async {
    final panel = await _pump(tester);

    await tester.tap(find.text('Rate on Google Play'));

    expect(panel.calls.names, ['rate']);
  });

  testWidgets('the only close button is in the header, above the Theme row, and calls onClose', (tester) async {
    final panel = await _pump(tester);

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(tester.getTopLeft(find.byIcon(Icons.close)).dy, lessThan(tester.getTopLeft(find.text('Theme')).dy));

    await tester.tap(find.byIcon(Icons.close));

    expect(panel.calls.names, ['close']);
  });

  testWidgets('in Arabic it reads right to left', (tester) async {
    await _pump(tester, chosen: const Locale('ar'));

    expect(tester.takeException(), isNull);
    expect(Directionality.of(tester.element(find.byType(SettingsOverlay))), TextDirection.rtl);
  });

  testWidgets('on a short screen the rows scroll instead of overflowing', (tester) async {
    tester.view.physicalSize = const Size(360, 260);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
  testWidgets('in Arabic the unit labels still read °C and °F, left to right', (tester) async {
    await _pump(tester, chosen: const Locale('ar'));

    for (final String label in ['°C', '°F']) {
      final Text text = tester.widget<Text>(find.text(label));
      expect(text.textDirection, TextDirection.ltr, reason: label);
    }
  });

  testWidgets('in Arabic the open-in-new icon is not mirrored', (tester) async {
    await _pump(tester, chosen: const Locale('ar'));

    expect(Directionality.of(tester.element(find.byIcon(Icons.open_in_new))), TextDirection.ltr);
  });

  testWidgets('the language chip reads clearly on either card, with dark and pale accents', (tester) async {
    // 7 is Aubergine and 3 is 50 Shades of Grey, close to the dark card; 4 is Pale Wood, pale under white text.
    for (final (int accent, bool dark) in [(7, true), (3, true), (4, false), (4, true)]) {
      final _Panel panel = await _pump(tester, accent: accent, dark: dark);
      final Text name = tester.widget<Text>(find.text('System default'));
      final Container chip = tester.widget<Container>(
        find.ancestor(of: find.text('System default'), matching: find.byType(Container)).first,
      );
      final Color fill = (chip.decoration as BoxDecoration).color!;
      final String reason = 'accent $accent, ${dark ? 'dark' : 'light'}';
      expect(contrastRatio(name.style!.color!, fill), greaterThanOrEqualTo(textContrast), reason: reason);
      expect(contrastRatio(fill, panel.theme.bgColor), greaterThanOrEqualTo(shapeContrast), reason: reason);
    }
  });

  testWidgets('on the dark card a selected segment stands out from the card', (tester) async {
    final _Panel panel = await _pump(tester, accent: 3, dark: true);
    final Container box = tester.widget<Container>(
      find.ancestor(of: find.text('°C'), matching: find.byType(Container)).first,
    );
    final Color fill = (box.decoration as BoxDecoration).color!;
    expect(contrastRatio(fill, panel.theme.bgColor), greaterThanOrEqualTo(shapeContrast));
  });
}
