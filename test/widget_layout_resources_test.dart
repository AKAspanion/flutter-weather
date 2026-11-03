import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String layouts = 'android/app/src/main/res/layout';
const String provider = 'android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt';

void main() {
  test('the compact layout never ellipsizes, so long text wraps instead', () {
    final xml = File('$layouts/weather_widget_small.xml').readAsStringSync();
    expect(xml, isNot(contains('android:ellipsize')));
  });

  test('the compact layout has a card_details row with sunrise, wind and humidity, and no card_updated', () {
    final xml = File('$layouts/weather_widget_small.xml').readAsStringSync();

    final start = xml.indexOf('android:id="@+id/card_details"');
    expect(start, isNot(-1), reason: 'card_details is missing');
    // The row is a flat LinearLayout, so its first closing tag ends it.
    final row = xml.substring(start, xml.indexOf('</LinearLayout>', start));
    for (final id in ['card_sunrise', 'card_wind', 'card_humidity']) {
      expect(row, contains('android:id="@+id/$id"'), reason: '$id is not in card_details');
    }

    expect(xml, isNot(contains('card_updated')));
  });

  test('the provider chooses the layout by WIDE_WIDTH and the details row by DETAILS_WIDTH, with no SMALL_WIDTH', () {
    final kotlin = File(provider).readAsStringSync();
    expect(kotlin, contains('const val WIDE_WIDTH = 300f'));
    expect(kotlin, contains('const val DETAILS_WIDTH = 220f'));
    expect(kotlin, isNot(contains('SMALL_WIDTH')));
  });
}
