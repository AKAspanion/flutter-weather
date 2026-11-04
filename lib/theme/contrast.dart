import 'package:flutter/material.dart';

/// Contrast WCAG asks of text against its background.
const double textContrast = 4.5;

/// Contrast WCAG asks of icons, borders and other shapes that carry meaning.
const double shapeContrast = 3;

/// The near-black drawn on a pale accent: opaque, so the ratio computed is the ratio seen.
const Color _onPale = Color(0xFF212121);

/// The WCAG contrast ratio of two opaque colours, from 1 (the same) to 21 (black on white).
double contrastRatio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double lighter = la > lb ? la : lb;
  final double darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// [color], lightened on a dark [background] or darkened on a light one, just enough to reach [minRatio] against
/// it. The accents are picked for the light card, so on the dark card some of them (Aubergine, 50 Shades of Grey)
/// would be unreadable as they are.
Color readableOn(Color color, Color background, {double minRatio = textContrast}) {
  if (contrastRatio(color, background) >= minRatio) return color;
  final Color target = background.computeLuminance() < 0.5 ? Colors.white : Colors.black;
  // Small steps, so the result keeps as much of the accent's hue as the ratio allows.
  for (int step = 1; step <= 20; step++) {
    final Color mixed = Color.lerp(color, target, step / 20)!;
    if (contrastRatio(mixed, background) >= minRatio) return mixed;
  }
  return target;
}

/// White or near-black, whichever reads better on [fill].
Color onFill(Color fill) => contrastRatio(Colors.white, fill) >= contrastRatio(_onPale, fill) ? Colors.white : _onPale;
