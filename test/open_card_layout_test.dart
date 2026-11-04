import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/views/home/open_card_layout.dart';
import 'package:flutterweather/views/menu/menu_buttons.dart';

/// The gap below the card, down to the top of the accent picker.
double _gapBelow(OpenCardLayout l, {required double h, required double picker, required double inset}) =>
    h - inset - picker - (l.top + h * l.scale);

void main() {
  test('a tall screen caps the scale and splits the spare room evenly', () {
    final l = OpenCardLayout.compute(screenHeight: 952, rowBottom: 132, pickerHeight: 128, bottomInset: 0);
    expect(l.scale, 0.65);
    final above = l.top - 132;
    expect(above, closeTo(36.6, 0.1));
    expect(_gapBelow(l, h: 952, picker: 128, inset: 0), closeTo(above, 0.001));
  });

  test('a screen the card fills keeps the minimum gap on both sides', () {
    final l = OpenCardLayout.compute(screenHeight: 700, rowBottom: 80, pickerHeight: 128, bottomInset: 50);
    expect(l.top, closeTo(104, 0.001));
    expect(l.top - 80, closeTo(OpenCardLayout.minGap, 0.001));
    expect(_gapBelow(l, h: 700, picker: 128, inset: 50), closeTo(OpenCardLayout.minGap, 0.001));
  });

  test('a short screen floors the scale at 0.3 and still centres the card', () {
    final l = OpenCardLayout.compute(screenHeight: 500, rowBottom: 80, pickerHeight: 128, bottomInset: 100);
    expect(l.scale, 0.3);
    expect(_gapBelow(l, h: 500, picker: 128, inset: 100), closeTo(l.top - 80, 0.001));
  });

  test('buttons are 56 wide on a wide screen and shrink on a narrow one', () {
    expect(MenuButtons.buttonSize(400, count: 4), 56);
    expect(MenuButtons.buttonSize(400, count: 5), 56);
    expect(MenuButtons.buttonSize(320, count: 5), closeTo(51.2, 0.001));
  });
}
