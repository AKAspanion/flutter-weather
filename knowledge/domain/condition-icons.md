---
type: Business Rule
title: Condition codes, icons and night
description: Every provider maps its conditions to OpenWeatherMap codes; Weather.getIcon turns a code into one of a fixed set of icon names, with a night variant by local hour.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Condition codes, icons and night

## Rule

- **One code system.** Every provider converts its own conditions to OpenWeatherMap condition codes (each provider's
  `_conditionCode`). A doc comment in `lib/services/providers/met_norway.dart` says this is because the icons are
  keyed on those codes.
- **Code to icon.** `Weather.getIcon` in `lib/services/weather.dart` maps a code to one icon name: thunder, rain, snow,
  clear, sunny, foggy, broken or few. Clear, sunny and few have a `-night` variant. Codes not matched by a range
  there fall through to `few`. That includes some rain codes (511 and the 520s) and every 7xx atmosphere code except
  fog (741). See [debt](../risks/debt.md).
- **Night.** It is night when the local hour at the place is after 18 or at most 6. With no override, `getIcon` uses
  the current time at the place's `timezone`. Forecast chips pass `overrideNight`
  computed from the reading's own time instead (`getNight` in `lib/views/forecast/hourly_detail_chip.dart`). Daily cards always use the day icon (`overrideNight: ""` in
  `lib/views/forecast/daily_detail_card.dart`).
- **Description.** The words shown for a condition come from the code too, not from the provider's English text:
  `describeCondition(l10n, code)` in `lib/l10n/conditions.dart` returns the translated phrase for the code, else its
  group's phrase (by hundreds), else "Unknown" ([decision](../decisions/descriptions-by-condition-code.md)).
- **Where the names are used.** In the app, the icon name picks a Flare animation in
  `assets/animations/cloudy.flr`. On the widget, it picks an animated layout through `iconLayoutFor` in `WeatherWidgetProvider.kt`
  ([home-screen widget](../features/home-screen-widget.md)). `tool/render_widget_icons_test.dart` holds the list of
  names it renders. A new icon name needs its Flare animation, then its frames, `widget_anim_<name>` list and
  `widget_icon_<name>` layout rendered with `ICON_LOOPS=1` ([run locally](../operations/run-locally.md)), and an
  `iconLayoutFor` entry; `test/widget_icon_resources_test.dart` checks the list, the layout and the entry.

## Where it is enforced

- `lib/services/weather.dart` (`getIcon`)
- `_conditionCode` in `lib/services/providers/weather_api.dart`, `lib/services/providers/tomorrow_io.dart` and
  `lib/services/providers/met_norway.dart`. OpenWeatherMap's codes are used as they come.
- `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt` (`iconLayoutFor`)

## History

- 2026-11-03: the widget picked a static PNG through `iconFor`, and its hour columns passed `overrideNight`; now it picks
  an animated layout through `iconLayoutFor` and has no hour columns, because the widget became one animated Now card.
  See [decisions/widget-animated-icons](../decisions/widget-animated-icons.md).

## History

- 2026-11-03: the description shown was each provider's English text; now a translated phrase per condition code, because the app is translated. See [descriptions by condition code](../decisions/descriptions-by-condition-code.md).

## Sources

* `lib/services/weather.dart`
* `lib/l10n/conditions.dart`
* `lib/services/providers/weather_api.dart`
* `lib/services/providers/tomorrow_io.dart`
* `lib/services/providers/met_norway.dart`
* `lib/views/forecast/hourly_detail_chip.dart`
* `lib/views/forecast/daily_detail_card.dart`
* `lib/services/weather_widget.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
* `tool/render_widget_icons_test.dart`
* `assets/animations/cloudy.flr`
* `test/widget_icon_resources_test.dart`
