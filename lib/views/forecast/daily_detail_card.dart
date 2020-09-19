import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutterweather/services/calendar.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/gradients.dart';

class DailyDetail extends StatefulWidget {
  final int accent;
  final Weather detail;

  DailyDetail({
    this.accent,
    this.detail,
  });

  @override
  _DailyDetailState createState() => _DailyDetailState();
}

class _DailyDetailState extends State<DailyDetail> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final Weather weather = widget.detail;
    final int accentIndex = widget.accent;
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: toggleExpand,
      child: AnimatedContainer(
        width: size.width,
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.symmetric(vertical: 8),
        curve: Curves.easeInOutCirc,
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(2, 0.0),
            colors: expanded
                ? GradientValues().gradients[accentIndex].gradient
                : [Colors.white, Colors.white],
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 24.0)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        child: FlareActor(
                          "assets/animations/cloudy.flr",
                          alignment: Alignment.center,
                          animation:
                              'cloudy-${weather.getIcon(overrideNight: "")}',
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              getWeekday(weather),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              "${weather.description}".toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 12, top: 2),
                            child: Text(
                              "MIN",
                              style: TextStyle(
                                fontSize: 11,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 12, top: 2),
                            child: Text(
                              '${(weather.tempMin - 273.15).floor()}°C',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 12, top: 2),
                            child: Text(
                              "MAX",
                              style: TextStyle(
                                fontSize: 11,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 12, top: 2),
                            child: Text(
                              '${(weather.tempMax - 273.15).floor()}°C',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            AnimatedContainer(
              height: expanded ? 104 : 0,
              curve: Curves.easeInOutCirc,
              duration: Duration(milliseconds: 500),
              child: Column(
                children: [
                  Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      getExpandRowItem("sun", "sunrise", getSunrise(weather)),
                      getExpandRowItem(
                          "wind", "wind", "${weather.windSpeed}m/s"),
                      getExpandRowItem(
                          "drop", "humidity", "${weather.humidity}%"),
                    ],
                  ),
                ],
              ),
            )
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

  Widget getExpandRowItem(String icon, String type, String text) {
    return Container(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            child: FlareActor(
              "assets/animations/icons.flr",
              alignment: Alignment.center,
              animation: icon,
            ),
          ),
          Text(
            type.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String getWeekday(Weather weather) {
    DateTime now =
        DateTime.fromMillisecondsSinceEpoch(weather.date * 1000, isUtc: true);
    DateTime zoneTime = now.add(Duration(seconds: weather.timezone ?? 0));

    return "${CalendarHelper.weekdays[zoneTime.weekday - 1]}".toUpperCase();
  }

  String getSunrise(Weather weather) {
    DateTime now = DateTime.fromMillisecondsSinceEpoch(weather.sunrise * 1000,
        isUtc: true);
    DateTime zoneTime = now.add(Duration(seconds: weather.timezone ?? 0));
    final int hour = zoneTime.hour > 12 ? zoneTime.hour - 12 : zoneTime.hour;

    return '$hour:${zoneTime.minute}'.toUpperCase();
  }
}
