import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/views/home/dialog_overlay.dart';
import 'package:provider/provider.dart';

/// Pumps the dialog in a Stack, as main.dart does, and returns the cities it submitted and how often it was cancelled.
Future<({List<String> submitted, List<int> cancelled})> _pump(WidgetTester tester) async {
  final submitted = <String>[];
  final cancelled = <int>[];
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeManager>(
      create: (_) => ThemeManager(),
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Stack(
            children: [
              DialogOverlay(
                accent: 0,
                onSubmit: (String city) => submitted.add(city),
                onCancel: () => cancelled.add(1),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (submitted: submitted, cancelled: cancelled);
}

void main() {
  testWidgets('shows the CITY title and the City name field', (tester) async {
    await _pump(tester);

    expect(find.text('CITY'), findsOneWidget);
    expect(find.text('City name'), findsOneWidget);
  });

  testWidgets('tapping the check in the field submits the typed city once', (tester) async {
    final result = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    expect(result.submitted, ['Paris']);
    expect(result.cancelled, isEmpty);
  });

  testWidgets("the keyboard's Done key submits the typed city once", (tester) async {
    final result = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(result.submitted, ['Paris']);
    expect(result.cancelled, isEmpty);
  });

  testWidgets('the header close cancels without submitting', (tester) async {
    final result = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(result.cancelled, hasLength(1));
    expect(result.submitted, isEmpty);
  });

  testWidgets('has exactly one check and one close', (tester) async {
    await _pump(tester);

    expect(find.byIcon(Icons.done), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
