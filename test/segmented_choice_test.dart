import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/components/segmented_choice.dart';

const Color _accent = Color(0xFF123456);

enum _Unit { c, f }

/// The fill of the segment that holds [label].
Color? _fill(WidgetTester tester, String label) {
  final Container box = tester.widget<Container>(
    find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
  );
  return (box.decoration as BoxDecoration).color;
}

Future<List<_Unit>> _pump(WidgetTester tester,
    {_Unit selected = _Unit.c, List<SegmentedOption<_Unit>>? options}) async {
  final List<_Unit> changes = [];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SegmentedChoice<_Unit>(
            options: options ??
                const [
                  SegmentedOption(value: _Unit.c, child: Text('°C')),
                  SegmentedOption(value: _Unit.f, child: Text('°F')),
                ],
            selected: selected,
            accent: _accent,
            textColor: Colors.black,
            onChanged: changes.add,
          ),
        ),
      ),
    ),
  );
  return changes;
}

void main() {
  testWidgets('fills the selected segment with the accent and leaves the others transparent', (tester) async {
    await _pump(tester);
    expect(_fill(tester, '°C'), _accent);
    expect(_fill(tester, '°F'), Colors.transparent);
  });

  testWidgets('draws the selected text white and the others in the text colour', (tester) async {
    await _pump(tester);
    expect(DefaultTextStyle.of(tester.element(find.text('°C'))).style.color, Colors.white);
    expect(DefaultTextStyle.of(tester.element(find.text('°F'))).style.color, Colors.black);
  });

  testWidgets('calls onChanged once when another segment is tapped', (tester) async {
    final List<_Unit> changes = await _pump(tester);
    await tester.tap(find.text('°F'));
    expect(changes, [_Unit.f]);
  });

  testWidgets('calls nothing when the selected segment is tapped', (tester) async {
    final List<_Unit> changes = await _pump(tester);
    await tester.tap(find.text('°C'));
    expect(changes, isEmpty);
  });

  testWidgets('exposes an option\'s semantic label', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(tester, options: const [
      SegmentedOption(value: _Unit.c, child: Icon(Icons.light_mode), semanticLabel: 'Light'),
      SegmentedOption(value: _Unit.f, child: Icon(Icons.dark_mode), semanticLabel: 'Dark'),
    ]);
    expect(find.bySemanticsLabel('Dark'), findsOneWidget);
    handle.dispose();
  });
}
