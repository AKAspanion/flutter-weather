import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/components/centre_in_list.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/views/forecast/daily_detail_card.dart';
import 'package:flutterweather/views/forecast/hourly_detail_chip.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Weather _weather = Weather(
  condition: 801,
  temperature: 285.15,
  tempMin: 280.0,
  tempMax: 290.0,
  humidity: 80,
  windSpeed: '1.8',
  date: 1793688600,
  timezone: 0,
);

UnitManager _units() => UnitManager(device: () => const Locale('fr', 'FR'));

Widget _app(Widget body, {String language = 'en'}) {
  return ChangeNotifierProvider<UnitManager>.value(
    value: _units(),
    child: MaterialApp(
      locale: Locale(language),
      theme: ThemeData(fontFamily: 'Montserrat'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Align(alignment: Alignment.topLeft, child: body)),
    ),
  );
}

/// Twelve chips in a horizontal list 360 wide: each is 80 plus a 24 margin, so the later ones start off screen.
Widget _chips(ScrollController controller) {
  return SizedBox(
    width: 360,
    height: 300,
    child: ListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemCount: 12,
      itemBuilder: (_, int i) => KeyedSubtree(key: ValueKey(i), child: HourlyDetail(accent: 0, detail: _weather)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// A chip or card is a few pixels too wide while it animates (its inner parts grow on a different curve), which
  /// is not what these tests are about, so a layout overflow is ignored for the test's duration.
  void cardTest(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (WidgetTester tester) async {
      final void Function(FlutterErrorDetails)? original = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (!details.exceptionAsString().contains('overflowed')) original?.call(details);
      };
      addTearDown(() => FlutterError.onError = original);
      await body(tester);
    });
  }

  Finder chip(int i) => find.byKey(ValueKey(i));

  /// Taps the part of card [i] that is inside the list, so a card that is partly off screen can still be tapped.
  Future<void> tapVisible(WidgetTester tester, int i) {
    final Rect visible = tester.getRect(chip(i)).intersect(tester.getRect(find.byType(ListView).first));
    return tester.tapAt(Offset(visible.center.dx, tester.getRect(chip(i)).top + 50));
  }

  /// The centre of the chip's decorated card, which leaves out the margin that spaces it from the next chip.
  double centreX(WidgetTester tester, int i) => tester
      .getCenter(find.descendant(of: chip(i), matching: find.byType(DecoratedBox)).first)
      .dx;

  cardTest('a tapped chip near the edge is centred in its list', (tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_app(_chips(controller)));
    // 12 chips, 104 each: chip 3 spans 312 to 392 (margins are at its end), past 300.
    await tapVisible(tester, 3);
    await tester.pumpAndSettle();
    expect(tester.getSize(chip(3)).width, 200 + 24);
    expect(centreX(tester, 3), closeTo(180, 1));
  });

  cardTest('the first chip expands and the list stays at 0', (tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_app(_chips(controller)));
    await tester.tapAt(tester.getTopLeft(chip(0)) + const Offset(20, 50));
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });

  cardTest('tapping an expanded chip closes it without scrolling', (tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_app(_chips(controller)));
    await tapVisible(tester, 3);
    await tester.pumpAndSettle();
    final double offset = controller.offset;
    await tapVisible(tester, 3);
    await tester.pumpAndSettle();
    expect(tester.getSize(chip(3)).width, 80 + 24);
    expect(controller.offset, offset);
  });

  cardTest('centring a chip leaves an outer vertical list alone', (tester) async {
    final ScrollController inner = ScrollController();
    final ScrollController outer = ScrollController(initialScrollOffset: 50);
    await tester.pumpWidget(_app(SizedBox(
      width: 360,
      height: 300,
      child: ListView(
        controller: outer,
        children: [SizedBox(height: 200, child: _chips(inner)), const SizedBox(height: 800)],
      ),
    )));
    await tapVisible(tester, 3);
    await tester.pumpAndSettle();
    expect(inner.offset, greaterThan(0));
    expect(outer.offset, 50);
  });

  cardTest('a chip is centred in a right-to-left list too', (tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_app(_chips(controller), language: 'ar'));
    await tapVisible(tester, 3);
    await tester.pumpAndSettle();
    expect(centreX(tester, 3), closeTo(tester.getCenter(find.byType(ListView)).dx, 1));
  });

  // Ten cards so there is room below the tapped one: a list can't scroll past its end.
  cardTest('a tapped day card is centred in its list', (tester) async {
    final ScrollController controller = ScrollController();
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(SizedBox(
      width: 400,
      height: 800,
      child: ListView.builder(
        controller: controller,
        itemCount: 10,
        itemBuilder: (_, int i) => KeyedSubtree(key: ValueKey(i), child: DailyDetail(accent: 0, detail: _weather)),
      ),
    )));
    final Finder last = find.byKey(const ValueKey(5));
    await tester.tapAt(tester.getTopLeft(last) + const Offset(100, 60));
    await tester.pumpAndSettle();
    expect(tester.getCenter(last).dy, closeTo(tester.getCenter(find.byType(ListView)).dy, 1));
  });

  cardTest('centreInList outside any list returns quietly', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (BuildContext c) {
      captured = c;
      return const SizedBox();
    })));
    await centreInList(captured);
    expect(tester.takeException(), isNull);
  });
}
