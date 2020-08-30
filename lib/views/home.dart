import 'package:flutter/material.dart';
import 'package:flutterweather/views/location_screen.dart';
import 'package:flutterweather/components/hamburger.dart';

class Home extends StatelessWidget {
  final bool isDrawerOpen;
  final void Function() onNavPress;

  final DragData homeDragData = DragData();

  Home({@required this.isDrawerOpen, @required this.onNavPress});

  @override
  Widget build(BuildContext context) {
    final double x = isDrawerOpen ? 320 : 0;
    final double y = isDrawerOpen ? 150 : 0;
    final double factor = isDrawerOpen ? 0.6 : 1;

    return GestureDetector(
      onHorizontalDragEnd: onDragEnd,
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      child: AnimatedContainer(
        padding: EdgeInsets.all(24),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(x, y, 0)..scale(factor),
        duration: Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: isDrawerOpen
              ? [BoxShadow(color: Colors.black38, blurRadius: 40.0)]
              : [],
          borderRadius: BorderRadius.circular(isDrawerOpen ? 48 : 0),
        ),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: [
                  Hamburger(
                    isDrawerOpen: isDrawerOpen,
                    onPressed: onNavPress,
                  )
                ],
              ),
            ),
            LocationScreen()
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
