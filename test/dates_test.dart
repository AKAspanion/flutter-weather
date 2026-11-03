import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/dates.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('fr');
  });

  test('weekdayLabel names the weekday in the locale', () {
    final monday = DateTime.utc(2026, 11, 2);

    expect(weekdayLabel(monday, 'en'), 'Monday');
    expect(weekdayLabel(monday, 'fr'), 'lundi');
  });

  test('timeLabel uses AM and PM in English and 24 hours in French', () {
    final morning = DateTime.utc(2026, 11, 2, 5, 50);
    final label = timeLabel(morning, 'en');

    expect(label, contains('5:50'));
    expect(label, contains('AM'));
    expect(timeLabel(morning, 'fr'), '05:50');
  });

  test('dateLineLabel gives the day and month, the weekday and the time', () {
    final label = dateLineLabel(DateTime.utc(2026, 11, 2, 14, 5), 'en');

    expect(label, contains('Nov 2'));
    expect(label, contains('Monday'));
    expect(label, contains('2:05'));
    expect(label, contains('PM'));
  });
}
