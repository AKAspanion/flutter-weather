import 'package:flutter/material.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/ads.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

class Menu extends StatelessWidget {
  final int accent;
  final bool isDrawerOpen;
  final void Function() onNavPress;
  final void Function(int)? onAccentSelect;

  /// Space kept free at the bottom for the banner ad.
  final double bottomInset;

  static const double _actionsHeight = 48;

  /// Height of the accent picker (plus the privacy row, when shown) and its padding, which the home card has to stay
  /// clear of while the drawer is open.
  static double get pickerHeight => 24 + 88 + 16 + (Ads.privacyOptionsRequired.value ? _actionsHeight : 0);

  const Menu({
    Key? key,
    required this.isDrawerOpen,
    required this.onNavPress,
    this.onAccentSelect,
    this.accent = 0,
    this.bottomInset = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = GradientValues().gradients[accent].gradient;
    ThemeManager theme = Provider.of<ThemeManager>(context);
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional(0.8, 0.0),
          colors: colors,
        ),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24 + bottomInset),
      child: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Only for users who must be able to revisit their ad consent (e.g. in the EEA).
          ValueListenableBuilder<bool>(
            valueListenable: Ads.privacyOptionsRequired,
            builder: (_, required, __) => !required
                ? SizedBox(height: 16)
                : SizedBox(
                    height: _actionsHeight,
                    child: Center(child: _action(AppLocalizations.of(context)!.privacy.toUpperCase(), Ads.showPrivacyOptions)),
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.bgColor,
              boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 40.0)],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 88,
              child: PageView.builder(
                itemCount: GradientValues().gradients.length,
                controller: PageController(viewportFraction: 0.30),
                itemBuilder: (_, i) {
                  return InkWell(
                    onTap: () => onAccentTap(i),
                    child: AnimatedContainer(
                      height: 48,
                      width: 48,
                      duration: Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(
                          getX(i, size.width), getY(i), 0)
                        ..scaleByDouble(getScale(i), getScale(i), getScale(i), 1),
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white54, width: 3),
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: Colors.black12, blurRadius: 6.0)
                        ],
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.centerStart,
                          end: AlignmentDirectional(0.8, 0.0),
                          colors: GradientValues().gradients[i].gradient,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(String label, void Function() onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: Colors.white, letterSpacing: 2),
      ),
    );
  }

  onAccentTap(i) {
    if (onAccentSelect != null) {
      onAccentSelect!(i);
    }
  }

  getScale(i) {
    final current = accent;
    return current == i ? 1.2 : 1.0;
  }

  getY(i) {
    final current = accent;
    return current == i ? -9.0 : 0.0;
  }

  getX(i, width) {
    final double boxSize = (width - 48) * 0.30;
    final double padding = (boxSize * 1.2 - boxSize) / 2;
    final current = accent;
    return current == i ? -padding : 0.0;
  }
}
