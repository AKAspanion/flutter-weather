import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/l10n/conditions.dart';

const List<int> _codes = [
  200, 201, 202, 210, 211, 212, 221, 230, 231, 232, //
  300, 301, 302, 310, 311, 312, 313, 314, 321,
  500, 501, 502, 503, 504, 511, 520, 521, 522, 531,
  600, 601, 602, 611, 612, 613, 615, 616, 620, 621, 622,
  701, 711, 721, 731, 741, 751, 761, 762, 771, 781,
  800, 801, 802, 803, 804,
];

const Set<int> _sameAsGroup = {211, 301, 601, 701};

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  test('uses the description of a known code', () {
    expect(describeCondition(l10n, 500), 'Light rain');
    expect(describeCondition(l10n, 800), 'Clear sky');
  });

  test('falls back to the group of an unknown code', () {
    expect(describeCondition(l10n, 299), 'Thunderstorm');
    expect(describeCondition(l10n, 399), 'Drizzle');
    expect(describeCondition(l10n, 599), 'Rain');
    expect(describeCondition(l10n, 699), 'Snow');
    expect(describeCondition(l10n, 799), 'Mist');
    expect(describeCondition(l10n, 899), 'Clouds');
  });

  test('says Unknown for codes outside every group and for null', () {
    expect(describeCondition(l10n, 999), 'Unknown');
    expect(describeCondition(l10n, 100), 'Unknown');
    expect(describeCondition(l10n, null), 'Unknown');
  });

  test('has a description for every OpenWeatherMap code, other than a group phrase', () {
    final groups = {
      l10n.conditionThunderstorm,
      l10n.conditionDrizzle,
      l10n.conditionRain,
      l10n.conditionSnow,
      l10n.conditionMist,
      l10n.conditionClouds,
      l10n.conditionUnknown,
    };
    for (final code in _codes) {
      final text = describeCondition(l10n, code);
      expect(text, isNotEmpty, reason: 'code $code');
      // OpenWeatherMap's own text for these four is the group's name, so the lookup can't tell them apart.
      if (!_sameAsGroup.contains(code)) expect(groups, isNot(contains(text)), reason: 'code $code');
    }
  });
}
