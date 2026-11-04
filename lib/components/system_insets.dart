import 'package:flutter/widgets.dart';

/// The offsets that keep the app's fixed chrome clear of the camera cutout and the gesture bar.
class SystemInsets {
  /// Gap between the screen's top inset and the menu's button row.
  static const double buttonRowGap = 24;

  /// `buttonRowGap` plus the top system padding.
  static double buttonRowTop(BuildContext context) => buttonRowGap + MediaQuery.paddingOf(context).top;

  /// The bottom system padding: where the ad banner's bottom edge sits.
  static double adBottom(BuildContext context) => MediaQuery.paddingOf(context).bottom;

  /// `adHeight` plus the bottom system padding: the room `Menu`, `Home` and `Forecast` leave at the bottom.
  static double contentBottom(BuildContext context, double adHeight) => adHeight + MediaQuery.paddingOf(context).bottom;
}
