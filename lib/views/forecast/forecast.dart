import 'package:flutter/material.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/location.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/views/forecast/daily_detail_card.dart';
import 'package:flutterweather/views/forecast/hourly.dart';
import 'package:provider/provider.dart';

/// Space above each section title, chosen so the gap from what's above (the close button's row, then the hourly
/// chips) is 32 in both places: the list's own 16 top padding plus [_hoursTitleTop], and a chip's 12 bottom margin plus
/// [_daysTitleTop].
const double _hoursTitleTop = 16;
const double _daysTitleTop = 20;

/// Space below each subtitle: with the 12 margin above every chip and day card, the gap to the first card is 16 in both
/// sections.
const double _subtitleBottom = 4;

class Forecast extends StatelessWidget {
  final int accent;
  final Location location;
  final bool isWindowOpen;
  final void Function() onClosePress;

  /// False once the panel has slid off screen, so its animated icons
  /// stop rendering in the background.
  final bool showContent;

  /// Space kept free at the bottom for the banner ad.
  final double bottomInset;

  final Animation<double> yTranslate;
  final Animation<double> controller;

  Forecast({
    Key? key,
    required this.isWindowOpen,
    required this.onClosePress,
    this.accent = 0,
    required this.controller,
    required this.location,
    this.showContent = true,
    this.bottomInset = 0,
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
      child: !showContent
          ? null
          : Column(
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
                  height: size.height - 76 - bottomInset,
                  child: _buildList(AppLocalizations.of(context)!),
                ),
              ],
            ),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    final List<Weather> daily = location.getDaily();
    final List<Widget> header = [
      _translateBuilder(
        _title(l10n.nextHours.toUpperCase(), top: _hoursTitleTop),
        amount: 0.4,
      ),
      _translateBuilder(
        _subtitle(l10n.nextHoursSubtitle, bottom: _subtitleBottom),
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
        _title(l10n.nextDays.toUpperCase(), top: _daysTitleTop),
        amount: 0.8,
      ),
      _translateBuilder(
        _subtitle(l10n.nextDaysSubtitle(daily.length), bottom: _subtitleBottom),
        amount: 0.8,
      ),
    ];

    // Built lazily so off-screen day cards (and their animations) cost nothing.
    return ListView.builder(
      itemCount: header.length + daily.length + 1,
      itemBuilder: (context, i) {
        if (i < header.length) return header[i];
        if (i == header.length + daily.length) return _attribution();
        return _translateBuilder(
          DailyDetail(
            accent: accent,
            detail: daily[i - header.length],
          ),
        );
      },
    );
  }

  Widget _title(String text, {required double top}) {
    return Container(
      padding: EdgeInsets.only(top: top),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _subtitle(String text, {required double bottom}) {
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: bottom),
      child: Center(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _attribution() {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Center(
        child: Text(
          location.attribution,
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  _translateBuilder(Widget ch, {amount = 1}) {
    return AnimatedBuilder(
      animation: controller,
      child: ch,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(0, yTranslate.value * amount),
          child: child,
        );
      },
    );
  }
}
