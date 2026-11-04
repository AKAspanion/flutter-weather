import 'package:flutterweather/components/centre_in_list.dart';
import 'package:flutterweather/components/flare_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/l10n/conditions.dart';
import 'package:flutterweather/l10n/dates.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

class DailyDetail extends StatefulWidget {
  final int accent;
  final Weather detail;

  DailyDetail({
    required this.accent,
    required this.detail,
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toString();
    final TemperatureUnit unit = context.watch<UnitManager>().unit;

    return InkWell(
      onTap: toggleExpand,
      child: AnimatedContainer(
        width: size.width,
        // 12 above and below, so neighbouring cards are 24 apart, the same gap as the hourly chips.
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                        child: FlareIcon(
                          "assets/animations/cloudy.flr",
                          animation:
                              'cloudy-${weather.getIcon(overrideNight: "")}',
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              getWeekday(weather, locale),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              describeCondition(l10n, weather.condition).toUpperCase(),
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
                            padding: EdgeInsetsDirectional.only(end: 12, top: 2),
                            child: Text(
                              l10n.min.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsetsDirectional.only(end: 12, top: 2),
                            child: Text(
                              formatTemperature(weather.tempMin, unit),
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
                            padding: EdgeInsetsDirectional.only(end: 12, top: 2),
                            child: Text(
                              l10n.max.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: expanded ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsetsDirectional.only(end: 12, top: 2),
                            child: Text(
                              formatTemperature(weather.tempMax, unit),
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
              onEnd: onExpandEnd,
              child: !expanded
                  ? null
                  : Column(
                      children: [
                        Divider(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            getExpandRowItem(
                                "sun", l10n.sunrise, getSunrise(weather, locale)),
                            getExpandRowItem(
                                "wind", l10n.wind, "${weather.windSpeed}m/s"),
                            getExpandRowItem(
                                "drop", l10n.humidity, "${weather.humidity}%"),
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

  /// Centres the card in its list once its details have finished growing. Closing leaves the list where it is.
  void onExpandEnd() {
    if (expanded) centreInList(context);
  }

  Widget getExpandRowItem(String icon, String type, String text) {
    return Container(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            child: FlareIcon(
              "assets/animations/icons.flr",
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

  String getWeekday(Weather weather, String locale) {
    DateTime now = DateTime.fromMillisecondsSinceEpoch(weather.date! * 1000, isUtc: true);
    DateTime zoneTime = now.add(Duration(seconds: weather.timezone ?? 0));

    return weekdayLabel(zoneTime, locale).toUpperCase();
  }

  String getSunrise(Weather weather, String locale) {
    if (weather.sunrise == null) return "--";
    DateTime now = DateTime.fromMillisecondsSinceEpoch(weather.sunrise! * 1000, isUtc: true);
    return timeLabel(now.add(Duration(seconds: weather.timezone ?? 0)), locale);
  }
}
