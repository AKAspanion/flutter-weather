import 'package:flutterweather/components/flare_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/l10n/conditions.dart';
import 'package:flutterweather/l10n/dates.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:flutterweather/views/weather/weather_detail_chip.dart';
import 'package:provider/provider.dart';

class LocationView extends StatelessWidget {
  final int accent;
  final Weather weather;
  final Animation<double> opacity;
  final Animation<double> yTranslate;
  final Animation<double> controller;
  final String attribution;

  LocationView({
    Key? key,
    required this.weather,
    this.accent = 0,
    required this.controller,
    this.attribution = '',
  })  : opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              1.000,
              curve: Curves.ease,
            ),
          ),
        ),
        yTranslate = Tween<double>(
          begin: 60.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.500,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        super(key: key);

  Widget _buildAnimation(BuildContext context, Widget? child) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toString();
    final TemperatureUnit unit = context.watch<UnitManager>().unit;
    return Column(
      mainAxisSize: MainAxisSize.max,
      verticalDirection: VerticalDirection.down,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Opacity(
          opacity: opacity.value,
          child: Column(
            children: <Widget>[
              Container(
                transform: Matrix4.translationValues(0, yTranslate.value, 0),
                padding: EdgeInsets.only(
                  top: 32,
                  bottom: 4,
                ),
                child: Text(
                  (weather.name?.isNotEmpty == true ? weather.name! : l10n.myLocation).toUpperCase(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(0, yTranslate.value, 0),
                child: Text(
                  getDateTime(weather.timezone, locale),
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Opacity(
          opacity: opacity.value,
          child: Container(
            width: 200,
            height: 200,
            transform: Matrix4.translationValues(0, yTranslate.value * 0.9, 0),
            padding: EdgeInsets.only(
              bottom: 16,
            ),
            child: FlareIcon(
              "assets/animations/cloudy.flr",
              animation: 'cloudy-${weather.getIcon()}',
            ),
          ),
        ),
        Opacity(
          opacity: opacity.value,
          child: Column(
            children: <Widget>[
              Container(
                transform:
                    Matrix4.translationValues(0, yTranslate.value * 0.8, 0),
                padding: EdgeInsets.only(
                  bottom: 16,
                ),
                child: Text(
                  formatTemperature(weather.temperature, unit),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                transform:
                    Matrix4.translationValues(0, yTranslate.value * 0.7, 0),
                child: Text(
                  getGreeting(weather.timezone, l10n),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Container(
                transform:
                    Matrix4.translationValues(0, yTranslate.value * 0.7, 0),
                child: Text(
                  describeCondition(l10n, weather.condition).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Opacity(
          opacity: opacity.value,
          child: Container(
            transform: Matrix4.translationValues(0, yTranslate.value * 0.5, 0),
            padding: EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WeatherDetailChip(
                  icon: "sun",
                  text: l10n.sunrise,
                  value: getSunriseTime(weather.sunrise, weather.timezone, locale),
                  gradient: GradientValues().gradients[accent].gradient,
                ),
                WeatherDetailChip(
                  icon: "wind",
                  text: l10n.wind,
                  value: '${weather.windSpeed}m/s',
                  gradient: GradientValues().gradients[accent].gradient,
                ),
                WeatherDetailChip(
                  icon: "drop",
                  text: l10n.humidity,
                  value: '${weather.humidity}%',
                  gradient: GradientValues().gradients[accent].gradient,
                ),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: opacity.value,
          child: Text(
            attribution,
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }

  String getSunriseTime(int? date, int? zone, String locale) {
    if (date == null) return "--";
    DateTime now = DateTime.fromMillisecondsSinceEpoch(date * 1000, isUtc: true);
    return timeLabel(now.add(Duration(seconds: zone ?? 0)), locale);
  }

  String getDateTime(int? zone, String locale) {
    DateTime now = DateTime.now().toUtc();
    return dateLineLabel(now.add(Duration(seconds: zone ?? 0)), locale).toUpperCase();
  }

  String getGreeting(int? zone, AppLocalizations l10n) {
    DateTime now = DateTime.now().toUtc();
    DateTime zoneTime = now.add(Duration(seconds: zone ?? 0));

    final int hour = zoneTime.hour;

    final String greeting;
    if (hour > 19 || hour <= 5) {
      greeting = l10n.greetingNight;
    } else if (hour > 5 && hour < 12) {
      greeting = l10n.greetingMorning;
    } else if (hour >= 12 && hour < 16) {
      greeting = l10n.greetingAfternoon;
    } else {
      greeting = l10n.greetingEvening;
    }
    return greeting.toUpperCase();
  }
}
