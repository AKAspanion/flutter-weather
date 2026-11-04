// Renders the app's Flare weather icons to PNGs for the Android home-screen
// widget, which can't play Flare animations.
//
//   flutter test tool/render_widget_icons_test.dart
//
// writes one still per icon (widget_icon_<name>.png, the widget preview) and the
// small sunrise / wind / humidity icons.
//
//   ICON_LOOPS=1 flutter test tool/render_widget_icons_test.dart
//
// instead renders each icon's whole loop as frames (widget_icon_<name>_<nn>.webp in
// drawable-nodpi, encoded with cwebp: `brew install webp`) and writes, per icon, an animation-list (res/drawable/widget_anim_<name>.xml)
// and the layout the widget adds to its icon slot (res/layout/widget_icon_<name>.xml). A new icon
// also needs a `when` entry in WeatherWidgetProvider.iconLayoutFor.
//
//   ICON_FRAMES=1 [ICON_NAMES=sunny,rain] flutter test tool/render_widget_icons_test.dart
//
// instead dumps several moments per animation into build/icon_frames, for picking the still's
// capture time.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
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

const String resDir = 'android/app/src/main/res';

/// Size in pixels of one loop frame. The icon is 64dp at most (a little over 190px on a dense
/// phone), and the ProgressBar scales the frame to it.
const int frameSize = 112;

/// Encodes a frame PNG as lossy WebP with exact alpha and deletes the PNG, because Android rejects two
/// resources with the same name. Lossy WebP is what keeps the frames near 0.6 MB.
Future<void> encodeWebp(File png) async {
  final webp = png.path.replaceFirst(RegExp(r'\.png$'), '.webp');
  final ProcessResult result;
  try {
    result = await Process.run('cwebp', ['-q', '85', '-exact', '-alpha_q', '100', '-m', '6', png.path, '-o', webp]);
  } on ProcessException catch (e) {
    fail('cwebp could not be started (${e.message}); install it with: brew install webp');
  }
  if (result.exitCode != 0) fail('cwebp failed on ${png.path}: ${result.stderr}');
  png.deleteSync();
}

/// How long the widget shows each frame: 125ms is 8 frames per second. Together with
/// [frameSize] this keeps all the frames near 0.6 MB (the cap `test/widget_icon_resources_test.dart`
/// checks). Raise the rate or the size only with that total in mind.
const int frameMs = 125;

/// Plays the named Flare animation at a time the test sets, so the loop is sampled exactly.
class _LoopController extends FlareController {
  _LoopController(this.animationName);

  final String animationName;
  late final ActorAnimation animation;
  double time = 0;

  @override
  void initialize(FlutterActorArtboard artboard) {
    animation = artboard.getAnimation(animationName)!;
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    animation.apply(time, artboard, 1);
    return true;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
}

/// Writes one icon's loop: its frames, the animation list and the layout. Returns the frames' total bytes.
Future<int> renderLoop(WidgetTester tester, String icon) async {
  final name = icon.replaceAll('-', '_');
  final controller = _LoopController('cloudy-$icon');
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox(
            width: frameSize.toDouble(),
            height: frameSize.toDouble(),
            child: FlareActor('assets/animations/cloudy.flr', alignment: Alignment.center, controller: controller),
          ),
        ),
      ),
    ),
  );
  // Flare loads the file asynchronously, then advances on frame callbacks.
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
  await tester.pump();

  // The loop is as long as the Flare animation, so the last frame leads back into the first.
  final seconds = controller.animation.duration;
  final count = (seconds * 1000 / frameMs).round();
  expect(count, inInclusiveRange(2, 100), reason: '$icon: $count frames');
  print('$icon: ${seconds}s, looping=${controller.animation.isLooping}, $count frames');

  for (final old in Directory(outDir).listSync().whereType<File>()) {
    if (RegExp('^widget_icon_${name}_[0-9][0-9]\\.(png|webp)\$').hasMatch(old.uri.pathSegments.last)) old.deleteSync();
  }

  // A frame equal to one already written reuses its file, and a run of equal frames is one item
  // with a longer duration, so a still icon (clear) costs one PNG and the widget redraws nothing.
  final written = <String, String>{};
  final items = <String>[];
  final counts = <int>[];
  for (var i = 0; i < count; i++) {
    controller.time = i * frameMs / 1000;
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    final png = (await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 1);
      return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    }))!;
    var frame = written[String.fromCharCodes(png)];
    if (frame == null) {
      frame = 'widget_icon_${name}_${i.toString().padLeft(2, '0')}';
      final file = File('$outDir/$frame.png')..writeAsBytesSync(png);
      await tester.runAsync(() => encodeWebp(file));
      written[String.fromCharCodes(png)] = frame;
    }
    if (items.isNotEmpty && items.last == frame) {
      counts.last++;
    } else {
      items.add(frame);
      counts.add(1);
    }
  }
  if (items.length == 1) {
    // An animation-list needs two items; a still icon splits its one in half.
    items.add(items.first);
    counts.last = count - count ~/ 2;
    counts.insert(0, count ~/ 2);
  }
  final bytes = [for (final frame in written.values) File('$outDir/$frame.webp').lengthSync()].fold(0, (a, b) => a + b);
  print('$icon: ${written.length} distinct frames, $bytes bytes');

  File('$resDir/drawable/widget_anim_$name.xml')
    ..createSync(recursive: true)
    ..writeAsStringSync([
      '<?xml version="1.0" encoding="utf-8"?>',
      '<!-- Generated by tool/render_widget_icons_test.dart (ICON_LOOPS=1). Do not edit. -->',
      '<animation-list xmlns:android="http://schemas.android.com/apk/res/android" android:oneshot="false">',
      for (var i = 0; i < items.length; i++)
        '    <item android:drawable="@drawable/${items[i]}" android:duration="${counts[i] * frameMs}" />',
      '</animation-list>',
      '',
    ].join('\n'));

  // The ProgressBar fills its slot (card_icon_slot), which carries the icon's size.
  File('$resDir/layout/widget_icon_$name.xml')
    ..createSync(recursive: true)
    ..writeAsStringSync([
      '<?xml version="1.0" encoding="utf-8"?>',
      '<!-- Generated by tool/render_widget_icons_test.dart (ICON_LOOPS=1). Do not edit. -->',
      '<ProgressBar xmlns:android="http://schemas.android.com/apk/res/android"',
      '    android:id="@+id/card_icon"',
      '    android:layout_width="match_parent"',
      '    android:layout_height="match_parent"',
      '    android:indeterminate="true"',
      '    android:indeterminateDrawable="@drawable/widget_anim_$name"',
      '    android:indeterminateOnly="true" />',
      '',
    ].join('\n'));
  return bytes;
}

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
  final bool loops = Platform.environment['ICON_LOOPS'] == '1';

  testWidgets('render widget icon loops', (tester) async {
    var total = 0;
    for (final icon in icons) {
      total += await renderLoop(tester, icon);
    }
    print('frames: $total bytes in total');
    await tester.pumpWidget(SizedBox());
    await tester.pump(const Duration(seconds: 10));
  }, skip: !loops);

  testWidgets('render widget icons', (tester) async {
    if (loops) return;
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
      await render(
          tester, icon, captureOverrides[icon] ?? captureAt, '$outDir/widget_icon_${icon.replaceAll('-', '_')}.png');
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
