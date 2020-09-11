import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class WeatherDetailChip extends StatelessWidget {
  final String text;
  final String icon;
  final String value;
  final List<Color> gradient;

  WeatherDetailChip({
    this.text,
    this.icon,
    this.value,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = (size.width - 108) / 3;

    return Container(
      width: width,
      padding: EdgeInsets.only(
        top: 12,
        left: 4,
        right: 4,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black12, blurRadius: 6.0)
        ],
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(2, 0.0),
          colors: gradient,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            child: FlareActor(
              "assets/animations/icons.flr",
              alignment: Alignment.center,
              animation: icon,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 12,
            ),
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
          Container(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}
