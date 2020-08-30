import 'package:flutter/material.dart';

class Hamburger extends StatelessWidget {
  final bool isDrawerOpen;
  final double _hamSize = 48;
  final double _barHeight = 4;
  final Color _hamColor = Colors.black87;
  final onPressed;

  Hamburger({@required this.onPressed, @required this.isDrawerOpen});

  @override
  Widget build(BuildContext context) {
    final double translateX = isDrawerOpen ? 9 : -9;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.all(4),
        color: Colors.white,
        child: SizedBox(
          width: _hamSize,
          height: _hamSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  children: [
                    AnimatedContainer(
                      width: _hamSize / 2,
                      height: _barHeight,
                      color: _hamColor,
                      margin: EdgeInsets.all(3),
                      curve: Curves.easeInExpo,
                      duration: Duration(milliseconds: 400),
                      transform: Matrix4.translationValues(translateX, 0, 0),
                    ),
                    Container(
                      width: _hamSize,
                      height: _barHeight,
                      color: _hamColor,
                      margin: EdgeInsets.all(3),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
