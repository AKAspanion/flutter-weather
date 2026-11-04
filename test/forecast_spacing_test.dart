import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/views/forecast/daily_detail_card.dart';
import 'package:flutterweather/views/forecast/forecast.dart';
import 'package:flutterweather/views/forecast/hourly_detail_chip.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Weather _reading(int hour) => Weather(
      condition: 801,
      temperature: 285.15,
      tempMin: 280.0,
      tempMax: 290.0,
      humidity: 80,
      windSpeed: '1.8',
      date: 1793688600 + hour * 3600,
      timezone: 0,
    );

/// Six hours and three days: enough for both sections to show their first cards.
final WeatherReport _report = WeatherReport(
  current: _reading(0),
  hourly: [for (int h = 0; h < 6; h++) _reading(h * 3)],
  daily: [for (int d = 0; d < 3; d++) _reading(d * 24)],
  source: 'test',
  attribution: '',
);

/// The visible card inside a chip or day card: its first decorated box, without the margin around it.
Rect _card(WidgetTester tester, Finder of) =>
    tester.getRect(find.descendant(of: of, matching: find.byType(DecoratedBox)).first);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => initializeDateFormatting('en'));
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the gaps above the two titles match, and so do the gaps below the two subtitles', (tester) async {
    // Wide enough for the day cards' text in the test font, which is much wider than Montserrat.
    await tester.binding.setSurfaceSize(const Size(600, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // A phone drawn edge to edge reports a top inset (status bar, camera cutout): 30 logical pixels here.
    tester.view.padding = FakeViewPadding(top: 30 * tester.view.devicePixelRatio);
    addTearDown(tester.view.resetPadding);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeManager>(create: (_) => ThemeManager()),
          ChangeNotifierProvider<UnitManager>(create: (_) => UnitManager(device: () => const Locale('fr', 'FR'))),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(fontFamily: 'Montserrat'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Forecast(
              isWindowOpen: true,
              onClosePress: () {},
              controller: const AlwaysStoppedAnimation<double>(1),
              location: Location(_report),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    // The visible cross, not the button around it: the close icon is drawn 36 wide, and its cross spans the middle
    // 14 of Material's 24 grid, so it ends 36 * 5 / 24 = 7.5 above the icon's box.
    final double crossBottom = tester.getRect(find.byIcon(Icons.close)).bottom - 36 * 5 / 24;
    final Rect hoursTitle = tester.getRect(find.text('NEXT HOURS'));
    final Rect hoursSubtitle = tester.getRect(find.text('FORECAST FOR THE NEXT 48 HOURS'));
    final Rect firstChip = _card(tester, find.byType(HourlyDetail).first);
    final Rect daysTitle = tester.getRect(find.text('NEXT DAYS'));
    final Rect daysSubtitle = tester.getRect(find.text('FORECAST FOR THE NEXT 3 DAYS'));
    final Rect firstDay = _card(tester, find.byType(DailyDetail).first);

    final double o1 = hoursTitle.top - crossBottom;
    final double o2 = daysTitle.top - firstChip.bottom;
    final double x1 = firstChip.top - hoursSubtitle.bottom;
    final double x2 = firstDay.top - daysSubtitle.bottom;

    expect(o1, closeTo(32, 1), reason: 'the close cross to NEXT HOURS');
    expect(o2, closeTo(32, 1), reason: 'hourly chips to NEXT DAYS');
    expect(x1, closeTo(16, 1), reason: 'hours subtitle to the chips');
    expect(x2, closeTo(16, 1), reason: 'days subtitle to the first day card');
  });
}
