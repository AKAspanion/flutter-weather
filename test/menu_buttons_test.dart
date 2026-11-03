import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/components/btn.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/views/home/home.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/views/menu/menu_buttons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The icons of the buttons, in the order they are expected on screen.
const List<IconData> _withWidget = [
  Icons.refresh,
  Icons.brightness_3,
  Icons.widgets,
  Icons.translate,
  Icons.location_on,
  Icons.close,
];

/// Names the callback that was called, so a test can say which one it expects.
class _Calls {
  final List<String> names = [];
  void Function() call(String name) => () => names.add(name);
}

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  bool canPin = true,
  TextDirection direction = TextDirection.ltr,
  _Calls? calls,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  final c = calls ?? _Calls();
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeManager>(
      create: (_) => ThemeManager(),
      child: MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  child: MenuButtons(
                    onRefresh: c.call('refresh'),
                    onTheme: c.call('theme'),
                    themeIcon: Icon(Icons.brightness_3),
                    onPinWidget: canPin ? c.call('widget') : null,
                    onLanguage: c.call('language'),
                    onLocation: c.call('location'),
                    onClose: c.call('close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The button that holds [icon].
Finder _button(IconData icon) => find.ancestor(of: find.byIcon(icon), matching: find.byType(Btn));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('on a 412 dp screen six 56 dp buttons run from refresh to close, 16 dp from the edges', (tester) async {
    await _pump(tester, width: 412);

    expect(find.byType(Btn), findsNWidgets(6));
    final lefts = [for (final icon in _withWidget) tester.getTopLeft(_button(icon)).dx];
    expect(lefts, orderedEquals([...lefts]..sort()));
    for (final icon in _withWidget) {
      expect(tester.getSize(_button(icon)), Size(56, 56));
    }
    expect(tester.getTopLeft(_button(Icons.refresh)).dx, 16);
    expect(tester.getTopRight(_button(Icons.close)).dx, 412 - 16);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a 360 dp screen six equal buttons smaller than 56 dp fit', (tester) async {
    await _pump(tester, width: 360);

    expect(find.byType(Btn), findsNWidgets(6));
    final expected = (360 - 32 - 8 * 5) / 6;
    expect(expected, lessThan(56));
    for (final icon in _withWidget) {
      expect(tester.getSize(_button(icon)), Size(expected, expected));
    }
    expect(tester.getTopLeft(_button(Icons.refresh)).dx, 16);
    expect(tester.getTopRight(_button(Icons.close)).dx, 360 - 16);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without onPinWidget five buttons show, with refresh and close in the far corners', (tester) async {
    await _pump(tester, width: 412, canPin: false);

    expect(find.byType(Btn), findsNWidgets(5));
    expect(find.byIcon(Icons.widgets), findsNothing);
    expect(tester.getTopLeft(_button(Icons.refresh)).dx, 16);
    expect(tester.getTopRight(_button(Icons.close)).dx, 412 - 16);
  });

  testWidgets('right to left, refresh is at the right edge and close at the left', (tester) async {
    await _pump(tester, width: 412, direction: TextDirection.rtl);

    expect(tester.getTopRight(_button(Icons.refresh)).dx, 412 - 16);
    expect(tester.getTopLeft(_button(Icons.close)).dx, 16);
    expect(tester.getTopLeft(_button(Icons.refresh)).dx, greaterThan(tester.getTopLeft(_button(Icons.close)).dx));
  });

  testWidgets('tapping translate calls onLanguage once and nothing else', (tester) async {
    final calls = _Calls();
    await _pump(tester, width: 412, calls: calls);

    await tester.tap(_button(Icons.translate));

    expect(calls.names, ['language']);
  });

  testWidgets('Home has no translate button', (tester) async {
    tester.view.physicalSize = Size(412, 800);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeManager>(
        create: (_) => ThemeManager(),
        child: MaterialApp(
          home: Home(
            isDrawerOpen: false,
            onMorePress: () {},
            onNavPress: () {},
            controller: AlwaysStoppedAnimation(0.0),
            location: Location(),
            loading: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.translate), findsNothing);
  });
}
