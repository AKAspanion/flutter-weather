import 'package:flutter/material.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/views/forecast/daily.dart';
import 'package:flutterweather/views/forecast/hourly.dart';
import 'package:provider/provider.dart';

class Forecast extends StatelessWidget {
  final int accent;
  final Location location;
  final bool isWindowOpen;
  final void Function() onClosePress;

  final Animation<double> yTranslate;
  final Animation<double> controller;

  Forecast({
    Key key,
    @required this.isWindowOpen,
    @required this.onClosePress,
    this.accent = 0,
    this.controller,
    this.location,
  })  : yTranslate = Tween<double>(
          begin: 240.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              1.000,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double y = !isWindowOpen ? size.height + 80 : 0;
    Color bgColor = Provider.of<ThemeManager>(context).bgColor;

    // dynamic currentGradient = GradientValues().gradients[accent].gradient

    return AnimatedContainer(
      width: size.width,
      height: size.height,
      curve: Curves.easeOutCubic,
      duration: Duration(milliseconds: 800),
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
            padding: EdgeInsets.only(
              top: 16,
            ),
            height: size.height - 76,
            child: ListView(
              children: [
                _translateBuilder(
                  Container(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        "NEXT HOURS",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  amount: 0.4,
                ),
                _translateBuilder(
                  Container(
                    padding: EdgeInsets.only(top: 4, bottom: 16),
                    child: Center(
                      child: Text(
                        "Forecast for the next 48 hours".toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  amount: 0.4,
                ),
                _translateBuilder(
                  HourlyView(
                    accent: accent,
                    hourly: location.getHourly(),
                  ),
                  amount: 0.6,
                ),
                _translateBuilder(
                  Container(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        "NEXT DAYS",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  amount: 0.8,
                ),
                _translateBuilder(
                  Container(
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child: Center(
                      child: Text(
                        "Forecast for the next 7 days".toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  amount: 0.8,
                ),
                _translateBuilder(
                  DailyView(
                    accent: accent,
                    daily: location.getDaily(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _translateBuilder(Widget ch, {amount = 1}) {
    return AnimatedBuilder(
      animation: controller,
      child: ch,
      builder: (BuildContext context, Widget child) {
        return Transform.translate(
          offset: Offset(0, yTranslate.value * amount),
          child: child,
        );
      },
    );
  }
}
