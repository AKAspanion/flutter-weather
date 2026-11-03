// Renders the app's Flare weather icons to PNGs for the Android home-screen
// widget, which can't play animations.
//
//   flutter test tool/render_widget_icons_test.dart
//
// Set ICON_FRAMES=1 to instead dump several moments per animation for picking
// the capture time.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const List<String> details = ['sun', 'wind', 'drop'];

const List<String> icons = [
  'clear',
  'clear-night',
  'sunny',
  'sunny-night',
  'few',
  'few-night',
  'broken',
  'rain',
  'snow',
  'thunder',
  'foggy',
];

const String outDir = 'android/app/src/main/res/drawable-nodpi';

// The loops are subtle; their first frame is the cleanest (no fading rain drops).
const Duration captureAt = Duration.zero;

// Thunder only shows its lightning bolt partway through the loop.
const Map<String, Duration> captureOverrides = {'thunder': Duration(milliseconds: 2000)};

Future<void> render(WidgetTester tester, String icon, Duration at, String path,
    {String file = 'assets/animations/cloudy.flr', String prefix = 'cloudy-'}) async {
  final key = GlobalKey();
  Widget build({required bool paused}) => Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: 128,
              height: 128,
              child: FlareActor(
                file,
                alignment: Alignment.center,
                animation: '$prefix$icon',
                isPaused: paused,
              ),
            ),
          ),
        ),
      );

  await tester.pumpWidget(build(paused: false));
  // Flare loads the file asynchronously, then advances on frame callbacks.
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
  await tester.pump();
  for (var t = Duration.zero; t < at; t += const Duration(milliseconds: 16)) {
    await tester.pump(const Duration(milliseconds: 16));
  }

  // Freeze on this frame; a running animation keeps the boundary dirty.
  await tester.pumpWidget(build(paused: true));
  await tester.pump();

  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  final bool frames = Platform.environment['ICON_FRAMES'] == '1';

  testWidgets('render widget icons', (tester) async {
    if (frames) {
      for (final icon in (Platform.environment['ICON_NAMES'] ?? 'sunny,rain').split(',')) {
        for (final ms in [0, 250, 500, 750, 1000, 1500, 2000, 3000]) {
          await render(tester, icon, Duration(milliseconds: ms), 'build/icon_frames/$icon-$ms.png');
        }
      }
      await tester.pumpWidget(SizedBox());
      await tester.pump(const Duration(seconds: 10));
      return;
    }
    for (final icon in icons) {
      await render(tester, icon, captureOverrides[icon] ?? captureAt, '$outDir/widget_icon_${icon.replaceAll('-', '_')}.png');
    }
    // The small white icons from the app's sunrise / wind / humidity chips.
    for (final detail in details) {
      await render(tester, detail, captureAt, '$outDir/widget_detail_$detail.png',
          file: 'assets/animations/icons.flr', prefix: '');
    }
    await tester.pumpWidget(SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });

}
