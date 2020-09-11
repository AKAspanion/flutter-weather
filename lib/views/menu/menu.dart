import 'package:flutter/material.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

class Menu extends StatelessWidget {
  final int accent;
  final bool isDrawerOpen;
  final void Function() onNavPress;
  final void Function(int) onAccentSelect;

  const Menu({
    Key key,
    @required this.isDrawerOpen,
    @required this.onNavPress,
    this.onAccentSelect,
    this.accent = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = GradientValues().gradients[accent].gradient;
    ThemeManager theme = Provider.of<ThemeManager>(context);
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment(0.8, 0.0),
          colors: colors,
        ),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                        ..scale(getScale(i)),
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white54, width: 3),
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: Colors.black12, blurRadius: 6.0)
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment(0.8, 0.0),
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

  onAccentTap(i) {
    if (onAccentSelect != null) {
      onAccentSelect(i);
    }
  }

  getScale(i) {
    final current = accent ?? 0;
    return current == i ? 1.2 : 1.0;
  }

  getY(i) {
    final current = accent ?? 0;
    return current == i ? -9.0 : 0.0;
  }

  getX(i, width) {
    final double boxSize = (width - 48) * 0.30;
    final double padding = (boxSize * 1.2 - boxSize) / 2;
    final current = accent ?? 0;
    return current == i ? -padding : 0.0;
  }
}
