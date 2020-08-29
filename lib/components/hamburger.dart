import 'package:flutter/material.dart';

class Hamburger extends StatelessWidget {
  final double _hamSize = 48;
  final double _barHeight = 4;
  final Color _hamColor = Colors.grey[700];
  final onPressed;

  Hamburger({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
                    Container(
                      width: _hamSize / 2,
                      height: _barHeight,
                      color: _hamColor,
                      margin: EdgeInsets.all(3),
                      transform: Matrix4.translationValues(-9, 0, 0),
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
