import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/l10n/app_localizations_en.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/unit_manager.dart';
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
  final _Calls calls;

  _Panel(this.locale, this.unit, this.calls);
}

Future<_Panel> _pump(WidgetTester tester, {Locale? chosen, TemperatureUnit? unit}) async {
  final locale = LocaleManager();
  await locale.load();
  if (chosen != null) await locale.setLocale(chosen);
  final units = UnitManager(device: () => const Locale('en', 'GB'));
  await units.load();
  if (unit != null) await units.setUnit(unit);
  final calls = _Calls();
  final store = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
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
                  accent: 0,
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
  return _Panel(locale, units, calls);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the title, the three rows and both units', (tester) async {
    await _pump(tester);

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Rate on Google Play'), findsOneWidget);
    expect(find.text('°C'), findsOneWidget);
    expect(find.text('°F'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsOneWidget);
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

  testWidgets('the close button calls onClose', (tester) async {
    final panel = await _pump(tester);

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
}
