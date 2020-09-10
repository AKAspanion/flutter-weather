import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutterweather/services/calendar.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/gradients.dart';

class HourlyDetail extends StatefulWidget {
  final int accent;
  final Weather detail;

  HourlyDetail({
    this.accent,
    this.detail,
  });

  @override
  _HourlyDetailState createState() => _HourlyDetailState();
}

class _HourlyDetailState extends State<HourlyDetail> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final Weather weather = widget.detail;
    final int accentIndex = widget.accent;
    final double width = expanded ? 200 : 80;
    final double innerWidth = expanded ? 50 : 0;
    return InkWell(
      onTap: toggleExpand,
      child: AnimatedContainer(
        curve: Curves.easeInOutCirc,
        padding: EdgeInsets.symmetric(vertical: 16),
        duration: Duration(milliseconds: 500),
        margin: EdgeInsets.only(right: 24, top: 12, bottom: 12),
        width: width,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black12, blurRadius: 6.0)
          ],
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(2, 0.0),
            colors: GradientValues().gradients[accentIndex].gradient,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                getTime(weather),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedContainer(
                  width: innerWidth,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      SizedBox(height: 13),
                      Container(
                        width: 42,
                        height: 42,
                        child: FlareActor(
                          "assets/animations/icons.flr",
                          alignment: Alignment.center,
                          animation: "drop",
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 20,
                        ),
                        child: AnimatedDefaultTextStyle(
                          child: Text(
                            "${weather.humidity}%",
                          ),
                          duration: Duration(milliseconds: 500),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: expanded ? 10 : 0,
                            fontFamily: "Montserrat",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        padding: EdgeInsets.only(top: 8),
                        child: FlareActor(
                          "assets/animations/cloudy.flr",
                          alignment: Alignment.center,
                          animation:
                              'cloudy-${weather.getIcon(overrideNight: getNight(weather))}',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '${(weather.temperature - 273.15).floor()}°C',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  width: innerWidth,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      SizedBox(height: 13),
                      Container(
                        width: 42,
                        height: 42,
                        child: FlareActor(
                          "assets/animations/icons.flr",
                          alignment: Alignment.center,
                          animation: "wind",
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 20,
                        ),
                        child: AnimatedDefaultTextStyle(
                          child: Text(
                            "${weather.windSpeed}m/s",
                          ),
                          duration: Duration(milliseconds: 500),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: expanded ? 10 : 0,
                            fontFamily: "Montserrat",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void toggleExpand() {
    setState(() {
      expanded = !expanded;
    });
  }

  String getTime(Weather weather) {
    DateTime now =
        DateTime.fromMillisecondsSinceEpoch(weather.date * 1000, isUtc: true);
    DateTime zoneTime = now.add(Duration(seconds: weather.timezone ?? 0));

    final suffix = zoneTime.hour >= 12 ? "PM" : "AM";
    final hours = ((zoneTime.hour + 11) % 12 + 1);

    String date = "";

    if (expanded) {
      date += ", ${CalendarHelper.weekdays[zoneTime.weekday - 1]}";
      date += "  ${zoneTime.day} ${CalendarHelper.months[zoneTime.month - 1]} ";
    }

    return "$hours $suffix$date".toUpperCase();
  }

  String getNight(Weather weather) {
    DateTime now =
        DateTime.fromMillisecondsSinceEpoch(weather.date * 1000, isUtc: true);
    DateTime zoneTime = now.add(Duration(seconds: weather.timezone ?? 0));

    String night = zoneTime.hour > 18 || zoneTime.hour <= 6 ? "-night" : "";

    return night;
  }
}
