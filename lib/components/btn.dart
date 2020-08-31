import 'package:flutter/material.dart';

class Btn extends StatelessWidget {
  final Widget child;
  final onPress;

  Btn({
    @required this.child,
    @required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 40.0)],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
