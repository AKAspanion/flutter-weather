import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterweather/theme/gradients.dart';

class Menu extends StatelessWidget {
  final bool isDrawerOpen;
  final void Function() onNavPress;

  const Menu({Key key, @required this.isDrawerOpen, @required this.onNavPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = GradientValues().gradients[Random().nextInt(5)].gradient;
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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isDrawerOpen.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
