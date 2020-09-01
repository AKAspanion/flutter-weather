import 'package:flutter/material.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:provider/provider.dart';

class Btn extends StatelessWidget {
  final Widget child;
  final onPress;

  Btn({
    @required this.child,
    @required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Provider.of<ThemeManager>(context);

    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.bgColor,
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 40.0)],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
