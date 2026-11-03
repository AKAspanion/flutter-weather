import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/components/overlay_card.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:provider/provider.dart';

Future<void> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  String title = 'Settings',
  void Function()? onClose,
  Widget child = const Text('Body'),
  Size size = const Size(400, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeManager>(
      create: (_) => ThemeManager(),
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: Stack(children: [OverlayCard(title: title, onClose: onClose ?? () {}, child: child)]),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('shows the title upper-cased', (tester) async {
    await _pump(tester);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('puts the close button at the end of the title, above the child', (tester) async {
    await _pump(tester);
    final Offset close = tester.getCenter(find.byIcon(Icons.close));
    expect(close.dx, greaterThan(tester.getCenter(find.text('SETTINGS')).dx));
    expect(close.dy, lessThan(tester.getTopLeft(find.text('Body')).dy));
  });

  testWidgets('mirrors the header in Arabic', (tester) async {
    await _pump(tester, locale: const Locale('ar'));
    expect(tester.getCenter(find.byIcon(Icons.close)).dx, lessThan(tester.getCenter(find.text('SETTINGS')).dx));
  });

  testWidgets('lines the title up with the text of a ListTile row', (tester) async {
    await _pump(tester, child: const ListTile(title: Text('Row')));
    expect(tester.getTopLeft(find.text('SETTINGS')).dx, tester.getTopLeft(find.text('Row')).dx);
  });

  testWidgets('lines the title up with a ListTile row at the right in Arabic', (tester) async {
    await _pump(tester, locale: const Locale('ar'), child: const ListTile(title: Text('Row')));
    expect(tester.getTopRight(find.text('SETTINGS')).dx, tester.getTopRight(find.text('Row')).dx);
  });

  testWidgets('calls onClose once when the close button is tapped, and has the material tooltip', (tester) async {
    int closed = 0;
    await _pump(tester, onClose: () => closed++);
    final String tooltip = MaterialLocalizations.of(tester.element(find.byIcon(Icons.close))).closeButtonTooltip;
    expect(find.byTooltip(tooltip), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    expect(closed, 1);
  });

  testWidgets('scrolls a child taller than the screen and keeps the header on screen', (tester) async {
    await _pump(tester, child: const Column(children: [Text('Tall'), SizedBox(height: 3000)]));
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.close).hitTestable(), findsOneWidget);
    final double before = tester.getTopLeft(find.text('Tall')).dy;
    await tester.drag(find.text('Tall'), const Offset(0, -100));
    await tester.pump();
    expect(tester.getTopLeft(find.text('Tall')).dy, lessThan(before));
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.close).hitTestable(), findsOneWidget);
    expect(find.text('SETTINGS').hitTestable(), findsOneWidget);
  });
}
