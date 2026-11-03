import 'package:intl/intl.dart';

/// [zoneTime] is already shifted to the place's offset, so these only format it. [locale] is a locale name such as
/// `fr`, and its date symbols must be loaded: MaterialApp's localization delegates do that for the app's languages.

/// The weekday's full name: "Monday", "lundi".
String weekdayLabel(DateTime zoneTime, String locale) => DateFormat.EEEE(locale).format(zoneTime);

/// Day and month, weekday, then time: "Nov 2, Monday 2:05 PM".
String dateLineLabel(DateTime zoneTime, String locale) =>
    '${DateFormat.MMMd(locale).format(zoneTime)}, ${weekdayLabel(zoneTime, locale)} ${timeLabel(zoneTime, locale)}';

/// The time of day in the locale's own style: "5:50 AM", "05:50".
String timeLabel(DateTime zoneTime, String locale) => DateFormat.jm(locale).format(zoneTime);
