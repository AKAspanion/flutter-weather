import 'package:flutter/material.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/views/forecast/hourly_detail_chip.dart';

class HourlyView extends StatelessWidget {
  final int accent;
  final List<Weather> hourly;

  HourlyView({
    required this.accent,
    required this.hourly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 196,
      padding: EdgeInsets.symmetric(vertical: 16),
      // Built lazily: only the chips on screen exist (and animate).
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.only(start: 24),
        itemCount: hourly.length,
        itemBuilder: (_, i) => HourlyDetail(
          accent: accent,
          detail: hourly[i],
        ),
      ),
    );
  }
}
