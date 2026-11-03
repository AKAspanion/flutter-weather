import 'package:flutter/material.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/views/menu/menu.dart';
import 'package:flutterweather/views/weather/weather_screen.dart';
import 'package:flutterweather/components/hamburger.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final int accent;
  final bool loading;
  final bool isDrawerOpen;
  final Location location;
  final void Function() onNavPress;
  final void Function() onMorePress;
  final Animation<double> controller;

  /// Space kept free at the bottom for the banner ad.
  final double bottomInset;

  final DragData homeDragData = DragData();

  Home({
    required this.isDrawerOpen,
    required this.onMorePress,
    required this.onNavPress,
    this.accent = 0,
    required this.controller,
    required this.location,
    required this.loading,
    this.bottomInset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double top = 120;
    // The card is always full screen height; shrink it enough to clear the
    // menu footer and the banner ad.
    final double fitScale = (size.height - top - Menu.footerHeight - bottomInset) / size.height;
    final double factor = isDrawerOpen ? fitScale.clamp(0.3, 0.65) : 1;
    Color bgColor = Provider.of<ThemeManager>(context).bgColor;
    Color textColor = Provider.of<ThemeManager>(context).textColor;

    final double y = isDrawerOpen ? top : 0;
    final double x = isDrawerOpen ? (size.width - size.width * factor) / 2 : 0;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onHorizontalDragEnd: (details) => onDragEnd(details, rtl),
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      child: AnimatedContainer(
        padding: EdgeInsets.all(24),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(x, y, 0)..scaleByDouble(factor, factor, factor, 1),
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: isDrawerOpen
              ? [BoxShadow(color: Colors.black38, blurRadius: 40.0)]
              : [],
          borderRadius: BorderRadius.circular(isDrawerOpen ? 24 : 0),
        ),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hamburger(
                    isDrawerOpen: isDrawerOpen,
                    onPressed: onNavPress,
                  ),
                  IconButton(
                    iconSize: 36,
                    // Same colour as the hamburger; Material's default is a grey in the dark theme.
                    color: textColor,
                    onPressed: loading || isDrawerOpen ? null : onMorePress,
                    icon: Icon(
                      Icons.show_chart,
                      size: 36,
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: size.height - 112 - bottomInset,
              child: LocationScreen(
                controller: controller,
                location: location,
                loading: loading,
                accent: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The menu opens with a swipe towards the end of the line, so right to left it is a swipe to the left.
  void onDragEnd(DragEndDetails details, bool rtl) {
    double diff = homeDragData.start - homeDragData.end;
    if (rtl) diff = -diff;
    if ((isDrawerOpen && diff > 0) || (!isDrawerOpen && diff < 0)) {
      onNavPress();
    }
  }

  void onDragStart(DragStartDetails details) =>
      homeDragData.start = details.globalPosition.dx;

  void onDragUpdate(DragUpdateDetails details) =>
      homeDragData.end = details.globalPosition.dx;
}

class DragData {
  double _start = 0;
  double _end = 0;

  get start => _start;

  get end => _end;

  set start(start) => _start = start;

  set end(end) => _end = end;

  @override
  String toString() {
    return 'DragData(start: $_start, end: $_end)';
  }
}
