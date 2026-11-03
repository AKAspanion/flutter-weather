import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/views/forecast/hourly.dart';
import 'package:flutterweather/views/forecast/hourly_detail_chip.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 12.0 degrees at 6:50 AM UTC on 3 November 2026.
final Weather _weather = Weather(
  condition: 801,
  temperature: 285.15,
  humidity: 80,
  windSpeed: '1.8',
  date: 1793688600,
  timezone: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  // The chips sit in the forecast's fixed-height strip, so that is where they are pumped.
  Future<void> pumpChips(WidgetTester tester, String language) {
    return tester.pumpWidget(
      MaterialApp(
        locale: Locale(language),
        theme: ThemeData(fontFamily: 'Montserrat'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: HourlyView(accent: 0, hourly: [_weather]),
          ),
        ),
      ),
    );
  }

  /// Every row of text keeps Montserrat's line height, so a fallback font's taller line can't grow the chip.
  void expectMontserratLineHeights(WidgetTester tester, String reason) {
    final Iterable<RenderParagraph> rows = tester
        .renderObjectList<RenderParagraph>(
            find.descendant(of: find.byType(HourlyDetail), matching: find.byType(RichText)))
        .where((RenderParagraph row) => row.text.style!.fontSize! > 0);
    expect(rows, isNotEmpty, reason: reason);
    for (final RenderParagraph row in rows) {
      // A line is rounded up to a whole pixel.
      expect(row.size.height, closeTo(row.text.style!.fontSize! * 1.219, 1),
          reason: '$reason: ${row.text.toPlainText()}');
    }
  }

  for (final String language in ['en', 'ar']) {
    testWidgets('an hourly chip does not overflow in $language, collapsed or expanded', (tester) async {
      await pumpChips(tester, language);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'collapsed');
      expectMontserratLineHeights(tester, 'collapsed');

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull, reason: 'expanded');
      expectMontserratLineHeights(tester, 'expanded');
    });
  }
}
