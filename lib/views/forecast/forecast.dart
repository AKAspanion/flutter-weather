import 'package:flutter/material.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/views/forecast/hourly.dart';
import 'package:provider/provider.dart';

class Forecast extends StatelessWidget {
  final int accent;
  final Location location;
  final bool isWindowOpen;
  final void Function() onClosePress;

  Forecast({
    @required this.isWindowOpen,
    @required this.onClosePress,
    this.accent = 0,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double y = !isWindowOpen ? size.height + 80 : 0;
    Color bgColor = Provider.of<ThemeManager>(context).bgColor;

    // dynamic currentGradient = GradientValues().gradients[accent].gradient

    return AnimatedContainer(
      curve: Curves.easeInOutCirc,
      duration: Duration(milliseconds: 800),
      width: size.width,
      height: size.height,
      transform: Matrix4.translationValues(0, y, 0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isWindowOpen ? 0 : 24),
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 40.0)],
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                iconSize: 36,
                onPressed: onClosePress,
                icon: Icon(
                  Icons.close,
                  size: 36,
                ),
              ),
              SizedBox(width: 24),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 48),
            child: Text(
              "NEXT HOURS",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 4, bottom: 24),
            child: Text(
              "Forecast for the next few hours".toUpperCase(),
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          HourlyView(
            accent: accent,
            hourly: location.getHourly(),
          ),
          Container(
            padding: EdgeInsets.only(top: 48),
            child: Text(
              "NEXT DAYS",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 4, bottom: 24),
            child: Text(
              "Forecast for the next 7 days".toUpperCase(),
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 16,
            ),
            height: 250,
            child: ListView(
              children: [
                Text(location.getHourly().toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
