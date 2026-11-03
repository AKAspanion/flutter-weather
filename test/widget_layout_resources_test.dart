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

  test('the compact layout scales its icon and temperature by their own scales, not by scaleFor', () {
    final kotlin = File(provider).readAsStringSync();
    // Side by side: a 3x2 (about 235 x 217 dp) reaches the cap.
    expect(kotlin, contains('const val COMPACT_DESIGN_WIDTH = 130f'));
    expect(kotlin, contains('const val COMPACT_DESIGN_HEIGHT = 135f'));
    // Stacked, on a card taller than it is wide (a 2x2).
    expect(kotlin, contains('const val TALL_DESIGN_WIDTH = 100f'));
    expect(kotlin, contains('const val TALL_DESIGN_HEIGHT = 150f'));
    expect(kotlin, contains('views.text(temperature, 30f, compactScale)'));
    expect(kotlin, contains('views.image(iconSlot, 40f, compactScale)'));
    expect(kotlin, isNot(contains('30f, scale)')));
    expect(kotlin, isNot(contains('40f, scale)')));
  });

  test('the compact layout has a side-by-side and a stacked arrangement, each with the ids the provider sets', () {
    final xml = File('$layouts/weather_widget_small.xml').readAsStringSync();
    for (final id in [
      'card_row',
      'card_icon_slot',
      'card_temperature',
      'card_stack',
      'card_icon_slot_tall',
      'card_temperature_tall'
    ]) {
      expect(xml, contains('android:id="@+id/$id"'), reason: '$id is missing');
    }
  });

  test('the mini layout has only the temperature and the icon, and nothing ellipsizes', () {
    final xml = File('$layouts/weather_widget_mini.xml').readAsStringSync();
    for (final id in ['widget_root', 'widget_content', 'card_icon_slot', 'card_temperature', 'widget_empty']) {
      expect(xml, contains('android:id="@+id/$id"'), reason: '$id is missing');
    }
    for (final id in ['card_city', 'card_description', 'card_details']) {
      expect(xml, isNot(contains('android:id="@+id/$id"')), reason: '$id should not be in the mini layout');
    }
    expect(xml, isNot(contains('android:ellipsize')));
  });

  test('the launcher may shrink the widget to one row and one cell, with 4x2 still the default', () {
    final xml = File('android/app/src/main/res/xml/weather_widget_info.xml').readAsStringSync();
    expect(xml, contains('android:minResizeWidth="40dp"'));
    expect(xml, contains('android:minResizeHeight="40dp"'));
    expect(xml, contains('android:targetCellWidth="4"'));
    expect(xml, contains('android:targetCellHeight="2"'));
  });

  test('the provider picks the mini layout by STRIP_HEIGHT and MINI_WIDTH', () {
    final kotlin = File(provider).readAsStringSync();
    expect(kotlin, contains('const val STRIP_HEIGHT = 150f'));
    expect(kotlin, contains('const val MINI_WIDTH = 110f'));
    expect(kotlin, contains('R.layout.weather_widget_mini'));
  });
}
