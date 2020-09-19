import 'package:flutter/material.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/theme_manager.dart';
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

  final DragData homeDragData = DragData();

  Home({
    @required this.isDrawerOpen,
    @required this.onMorePress,
    @required this.onNavPress,
    this.accent = 0,
    this.controller,
    this.location,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double factor = isDrawerOpen ? 0.65 : 1;
    Color bgColor = Provider.of<ThemeManager>(context).bgColor;

    final double y = isDrawerOpen ? 120 : 0;
    final double x = isDrawerOpen ? (size.width - size.width * 0.65) / 2 : 0;

    return GestureDetector(
      onHorizontalDragEnd: onDragEnd,
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      child: AnimatedContainer(
        padding: EdgeInsets.all(24),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(x, y, 0)..scale(factor),
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
              height: size.height - 112,
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

  void onDragEnd(DragEndDetails details) {
    double diff = homeDragData.start - homeDragData.end;
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
