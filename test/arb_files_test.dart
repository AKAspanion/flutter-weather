import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/l10n/conditions.dart';

const List<String> _locales = ['zh', 'hi', 'es', 'ar', 'fr', 'bn', 'pt', 'ru', 'ur'];

/// Words that are the same in English and in that language (a cognate), so they can't differ from the English value.
const Set<String> _cognates = {'es:condition781', 'pt:condition781'};

const Map<String, List<String>> _placeholders = {
  'nextDaysSubtitle': ['count'],
  'widgetUpdated': ['time'],
  'widgetHighLow': ['high', 'low'],
};

const List<String> _widgetStrings = [
  'widget_description',
  'widget_empty',
  'widget_updated',
  'widget_now',
  'widget_next_24_hours',
];

Map<String, dynamic> _readArb(String code) {
  final File file = File('lib/l10n/app_$code.arb');
  expect(file.existsSync(), isTrue, reason: '${file.path} should exist');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Iterable<String> _messageKeys(Map<String, dynamic> arb) => arb.keys.where((String k) => !k.startsWith('@'));

List<String> _stringNames(String path) {
  final File file = File(path);
  expect(file.existsSync(), isTrue, reason: '$path should exist');
  return RegExp(r'<string name="([a-z0-9_]+)"').allMatches(file.readAsStringSync()).map((m) => m.group(1)!).toList();
}

void main() {
  final Map<String, dynamic> english =
      jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
  final Set<String> englishKeys = _messageKeys(english).toSet();

  for (final String code in _locales) {
    group('app_$code.arb', () {
      test('is marked with its locale and as unreviewed', () {
        final Map<String, dynamic> arb = _readArb(code);
        expect(arb['@@locale'], code);
        expect(arb['@@x-reviewed'], false);
      });

      test('translates exactly the keys of app_en.arb', () {
        expect(_messageKeys(_readArb(code)).toSet(), englishKeys);
      });

      test('keeps the placeholders of every message that has them', () {
        final Map<String, dynamic> arb = _readArb(code);
        _placeholders.forEach((String key, List<String> names) {
          final String value = arb[key] as String;
          for (final String name in names) {
            expect(value, contains('{$name}'), reason: '$key in $code should keep {$name}');
          }
        });
        expect(arb['nextDaysSubtitle'] as String, contains('{count, plural,'));
        expect(arb['nextDaysSubtitle'] as String, contains('other{'));
      });

      test('has non-empty values that differ from English', () {
        final Map<String, dynamic> arb = _readArb(code);
        for (final String key in englishKeys) {
          final String value = arb[key] as String;
          expect(value.trim(), isNotEmpty, reason: '$key in $code');
          if (_cognates.contains('$code:$key')) continue;
          expect(value, isNot(english[key]), reason: '$key in $code is still English');
        }
      });
    });

    test('values-$code/strings.xml has the five widget strings and keeps %1\$s', () {
      final String path = 'android/app/src/main/res/values-$code/strings.xml';
      expect(_stringNames(path), _widgetStrings);
      expect(_stringNames('android/app/src/main/res/values/strings.xml'), _widgetStrings);
      final String xml = File(path).readAsStringSync();
      final RegExpMatch updated = RegExp(r'<string name="widget_updated">([^<]*)</string>').firstMatch(xml)!;
      expect(updated.group(1), contains(r'%1$s'));
    });
  }

  test('describes a condition in Spanish, by code and by its group', () {
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    final Map<String, dynamic> arb = _readArb('es');
    expect(describeCondition(es, 500), arb['condition500']);
    expect(describeCondition(es, 599), arb['conditionRain']);
  });
}
