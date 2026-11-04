import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutterweather/components/btn.dart';
import 'package:flutterweather/l10n/app_localizations.dart';

/// The menu's top row of buttons: refresh in the far start corner, close in the far end corner, and the rest spread
/// evenly between them. The buttons shrink together on a screen too narrow for five at full size. The light/dark
/// choice is in the settings panel, not here.
class MenuButtons extends StatelessWidget {
  static const double _maxSize = 56;
  static const double _margin = 16;
  static const double _minGap = 8;
  static const double _iconSize = 32;

  final void Function() onRefresh;

  /// Null on a phone that can't pin widgets, which leaves the widget button out.
  final void Function()? onPinWidget;
  final void Function() onSettings;
  final void Function() onLocation;
  final void Function() onClose;

  const MenuButtons({
    super.key,
    required this.onRefresh,
    this.onPinWidget,
    required this.onSettings,
    required this.onLocation,
    required this.onClose,
  });

  /// The size of each button in a row of [count] buttons on a screen [width] wide.
  static double buttonSize(double width, {required int count}) =>
      math.min(_maxSize, (width - 2 * _margin - _minGap * (count - 1)) / count);

  @override
  Widget build(BuildContext context) {
    final settingsLabel = AppLocalizations.of(context)?.settings;
    return LayoutBuilder(
      builder: (_, constraints) {
        final count = onPinWidget == null ? 4 : 5;
        final size = buttonSize(constraints.maxWidth, count: count);

        Widget button(Widget icon, void Function() onPress) => Btn(size: size, onPress: onPress, child: icon);
        Widget icon(IconData data) => Icon(data, size: _iconSize);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: _margin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              button(icon(Icons.refresh), onRefresh),
              if (onPinWidget != null) button(icon(Icons.widgets), onPinWidget!),
              Semantics(label: settingsLabel, button: true, child: button(icon(Icons.settings), onSettings)),
              button(icon(Icons.location_on), onLocation),
              button(icon(Icons.close), onClose),
            ],
          ),
        );
      },
    );
  }
}
