import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The generated resources behind the widget's animated icon, written by
/// tool/render_widget_icons_test.dart with ICON_LOOPS=1.
const String res = 'android/app/src/main/res';

const List<String> names = [
  'clear',
  'clear_night',
  'sunny',
  'sunny_night',
  'few',
  'few_night',
  'broken',
  'rain',
  'snow',
  'thunder',
  'foggy',
];

/// The WebP frames together measure 758914 bytes; the cap is that plus about 10%, rounded up to a whole KB.
const int maxFrameBytes = 835584;

void main() {
  test('each icon has an endlessly looping animation list of at least two frames, all present as WebP', () {
    for (final name in names) {
      final file = File('$res/drawable/widget_anim_$name.xml');
      expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
      final xml = file.readAsStringSync();

      expect(xml, contains('<animation-list'), reason: name);
      expect(xml, contains('android:oneshot="false"'), reason: name);

      final frames =
          RegExp(r'android:drawable="@drawable/([a-z0-9_]+)"').allMatches(xml).map((m) => m.group(1)!).toList();
      expect(frames.length, greaterThanOrEqualTo(2), reason: '$name needs at least 2 frames');
      for (final frame in frames) {
        expect(File('$res/drawable-nodpi/$frame.webp').existsSync(), isTrue, reason: '$frame.webp is missing');
        expect(File('$res/drawable-nodpi/$frame.png').existsSync(), isFalse, reason: '$frame.png sits beside its WebP');
      }
    }
  });

  test('each icon has a layout with one indeterminate ProgressBar, id card_icon, playing its animation list', () {
    for (final name in names) {
      final file = File('$res/layout/widget_icon_$name.xml');
      expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
      final xml = file.readAsStringSync();

      expect(RegExp('<ProgressBar').allMatches(xml).length, 1, reason: name);
      expect(xml, contains('android:id="@+id/card_icon"'), reason: name);
      expect(xml, contains('android:indeterminateOnly="true"'), reason: name);
      expect(xml, contains('android:indeterminateDrawable="@drawable/widget_anim_$name"'), reason: name);
    }
  });

  test('no frame is left as a PNG, and the stills stay PNG', () {
    final dir = Directory('$res/drawable-nodpi');
    final leftovers = dir
        .listSync()
        .whereType<File>()
        .where((f) => RegExp(r'^widget_icon_.*_[0-9][0-9]\.png$').hasMatch(f.uri.pathSegments.last));
    expect(leftovers, isEmpty);
    for (final name in names) {
      expect(File('${dir.path}/widget_icon_$name.png').existsSync(), isTrue, reason: 'widget_icon_$name.png');
    }
    for (final detail in ['sun', 'wind', 'drop']) {
      expect(File('${dir.path}/widget_detail_$detail.png').existsSync(), isTrue, reason: 'widget_detail_$detail.png');
    }
  });

  test('all WebP frames together are at most maxFrameBytes', () {
    final frame = RegExp(r'^widget_icon_.*_[0-9][0-9]\.webp$');
    final frames = Directory('$res/drawable-nodpi')
        .listSync()
        .whereType<File>()
        .where((f) => frame.hasMatch(f.uri.pathSegments.last))
        .toList();
    expect(frames, isNotEmpty);

    final total = frames.fold<int>(0, (sum, f) => sum + f.lengthSync());
    expect(total, lessThanOrEqualTo(maxFrameBytes));
  });

  test('the provider picks the layout of each icon', () {
    final kotlin =
        File('android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt').readAsStringSync();
    for (final name in names) {
      expect(kotlin, contains('R.layout.widget_icon_$name'), reason: name);
    }
  });
}
