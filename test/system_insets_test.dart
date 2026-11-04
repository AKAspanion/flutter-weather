import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/components/system_insets.dart';

/// Reads the helpers from a context under a [MediaQuery] with the given padding.
Future<({double buttonRowTop, double adBottom, double contentBottom})> _read(
  WidgetTester tester, {
  required EdgeInsets padding,
  required double adHeight,
}) async {
  late double buttonRowTop, adBottom, contentBottom;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(padding: padding),
      child: Builder(
        builder: (context) {
          buttonRowTop = SystemInsets.buttonRowTop(context);
          adBottom = SystemInsets.adBottom(context);
          contentBottom = SystemInsets.contentBottom(context, adHeight);
          return const SizedBox();
        },
      ),
    ),
  );
  return (buttonRowTop: buttonRowTop, adBottom: adBottom, contentBottom: contentBottom);
}

void main() {
  testWidgets('adds the system padding to the button row, the ad and the content', (tester) async {
    final r = await _read(tester, padding: const EdgeInsets.only(top: 30, bottom: 20), adHeight: 50);
    expect(r.buttonRowTop, 54);
    expect(r.adBottom, 20);
    expect(r.contentBottom, 70);
  });

  testWidgets('with no padding the offsets are as before', (tester) async {
    final r = await _read(tester, padding: EdgeInsets.zero, adHeight: 50);
    expect(r.buttonRowTop, 24);
    expect(r.adBottom, 0);
    expect(r.contentBottom, 50);
  });

  testWidgets('with no ad loaded the content still clears the bottom padding', (tester) async {
    final r = await _read(tester, padding: const EdgeInsets.only(bottom: 20), adHeight: 0);
    expect(r.contentBottom, 20);
  });
}
