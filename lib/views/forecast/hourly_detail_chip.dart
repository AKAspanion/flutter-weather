import 'package:flutter/material.dart';
import 'package:flutterweather/components/flare_icon.dart';
import 'package:flutterweather/l10n/dates.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/gradients.dart';

/// Montserrat's line height as a multiple of its font size: the font's ascent (968) plus descent (251) per 1000 units.
const double _montserratLineHeight = 1.219;

/// Gives a row of text the line height of Montserrat at [fontSize], whatever font draws it. The time label's
/// narrow no-break space (U+202F) and Arabic, Bengali, Hindi, Chinese and Urdu text aren't in Montserrat, so the
/// system draws them in a fallback font with a taller line, which would push the chip's text past its fixed height.
StrutStyle _montserratStrut(double fontSize) {
  return StrutStyle(
    fontFamily: 'Montserrat',
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
    height: _montserratLineHeight,
    forceStrutHeight: true,
  );
}

class HourlyDetail extends StatefulWidget {
  final int accent;
  final Weather detail;

  HourlyDetail({
    required this.accent,
    required this.detail,
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
        margin: EdgeInsetsDirectional.only(end: 24, top: 12, bottom: 12),
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
                getTime(weather, Localizations.localeOf(context).toString()),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                strutStyle: _montserratStrut(12),
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
                        child: expanded
                            ? FlareIcon(
                                "assets/animations/icons.flr",
                                animation: "drop",
                              )
                            : null,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 20,
                        ),
                        child: _DetailText("${weather.humidity}%", expanded: expanded),
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
                        child: FlareIcon(
                          "assets/animations/cloudy.flr",
                          animation:
                              'cloudy-${weather.getIcon(overrideNight: getNight(weather))}',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '${(weather.temperature! - 273.15).floor()}°C',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          strutStyle: _montserratStrut(16),
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
                        child: expanded
                            ? FlareIcon(
                                "assets/animations/icons.flr",
                                animation: "wind",
                              )
                            : null,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 20,
                        ),
                        child: _DetailText("${weather.windSpeed}m/s", expanded: expanded),
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

  String getTime(Weather weather, String locale) {
    DateTime now = DateTime.fromMillisecondsSinceEpoch(weather.date! * 1000, isUtc: true);
    DateTime zoneTime = now.add(Duration(seconds: weather.timezone ?? 0));

    return (expanded ? dateLineLabel(zoneTime, locale) : timeLabel(zoneTime, locale)).toUpperCase();
  }

  String getNight(Weather weather) {
    DateTime now =
        DateTime.fromMillisecondsSinceEpoch(weather.date! * 1000, isUtc: true);
    DateTime zoneTime = now.add(Duration(seconds: weather.timezone ?? 0));

    String night = zoneTime.hour > 18 || zoneTime.hour <= 6 ? "-night" : "";

    return night;
  }
}

/// The humidity or wind figure of an expanded chip: its size grows from 0 to 10 as the chip opens.
class _DetailText extends StatelessWidget {
  final String text;
  final bool expanded;

  const _DetailText(this.text, {required this.expanded});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: expanded ? 10 : 0),
      duration: Duration(milliseconds: 500),
      builder: (_, double fontSize, __) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          fontFamily: "Montserrat",
          color: Colors.white,
        ),
        // A StrutStyle needs a size above 0, and text of size 0 has no glyphs to fall back for.
        strutStyle: fontSize > 0 ? _montserratStrut(fontSize) : null,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}
