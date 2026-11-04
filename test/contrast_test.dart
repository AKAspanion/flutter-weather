import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/theme/contrast.dart';
import 'package:flutterweather/theme/gradients.dart';

/// The dark theme's card colour (`ThemeManager.bgColor`).
const Color _darkCard = Color(0xFF3E4551);

void main() {
  group('contrastRatio', () {
    test('is 21 for black on white and 1 for a colour on itself', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
      expect(contrastRatio(_darkCard, _darkCard), closeTo(1, 0.01));
    });

    test('is the same either way round', () {
      expect(contrastRatio(Colors.red, _darkCard), closeTo(contrastRatio(_darkCard, Colors.red), 0.0001));
    });
  });

  group('readableOn', () {
    for (final gradient in GradientValues().gradients) {
      final Color accent = gradient.gradient[0];

      test('makes ${gradient.name} readable as text on the dark card and on white', () {
        expect(contrastRatio(readableOn(accent, _darkCard), _darkCard), greaterThanOrEqualTo(textContrast));
        expect(contrastRatio(readableOn(accent, Colors.white), Colors.white), greaterThanOrEqualTo(textContrast));
      });

      test('makes ${gradient.name} visible as a shape on the dark card', () {
        expect(
          contrastRatio(readableOn(accent, _darkCard, minRatio: shapeContrast), _darkCard),
          greaterThanOrEqualTo(shapeContrast),
        );
      });
    }

    test('lightens on the dark card and darkens on white', () {
      const Color aubergine = Color(0xFFaa076b);
      expect(readableOn(aubergine, _darkCard).computeLuminance(), greaterThan(aubergine.computeLuminance()));

      const Color paleWood = Color(0xFFd6ae7b);
      expect(readableOn(paleWood, Colors.white).computeLuminance(), lessThan(paleWood.computeLuminance()));
    });

    test('leaves a colour that already reads well unchanged', () {
      const Color cherry = Color(0xFFeb3349);
      expect(contrastRatio(cherry, Colors.black), greaterThanOrEqualTo(textContrast));
      expect(readableOn(cherry, Colors.black), cherry);
    });
  });

  group('onFill', () {
    test('is white on a dark fill and near-black on a pale one', () {
      expect(onFill(const Color(0xFF2c3e50)), Colors.white);
      expect(onFill(const Color(0xFFd6ae7b)), isNot(Colors.white));
      expect(contrastRatio(onFill(const Color(0xFFd6ae7b)), const Color(0xFFd6ae7b)), greaterThan(4.5));
    });
  });
}
