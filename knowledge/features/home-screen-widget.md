---
type: Feature
title: Android home-screen widget
description: One resizable Now card in the app's accent, with an animated weather icon, fed by the app and refreshed in the background for the last place viewed.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T01:20:00+05:30 }
verified: human:panditankit1995@gmail.com
---

# Android home-screen widget

## What it does

A resizable home-screen widget, on Android only. It is one card showing the current weather, coloured with the accent
the user picked in the app. It opens at 4x2 and the launcher lets it shrink to one row or one cell. There is no
second page: the 24-hour view, the vertical swipe, the StackView that carried them and the page dots are gone
([decisions/widget-one-resizable-card](../decisions/widget-one-resizable-card.md)).

The provider chooses one of three layouts from the card's size, in `WeatherWidgetProvider.kt`:

- **Wide** (`weather_widget.xml`), from `WIDE_WIDTH` (300dp), which is full width, 4 cells: the city, the icon, the
  temperature, the description with today's high and low, a row with sunrise, wind and humidity (using the app's own
  detail icons), and when it was updated.
- **Compact** (`weather_widget_small.xml`), for anything narrower and not mini. Nothing in it ellipsizes: the city and
  the description with high and low wrap instead. The sunrise / wind / humidity row stays from `DETAILS_WIDTH`
  (220dp, 3 cells) and goes below it (2x2). A tall compact card (taller than wide, a 2x2) stacks the icon above the
  temperature so the number can grow; the others put them side by side.
- **Mini** (`weather_widget_mini.xml`), below `STRIP_HEIGHT` (150dp) tall (one row) or `MINI_WIDTH` (110dp) wide (one
  cell): only the temperature, centred and sized to the card, with the weather icon from `MINI_WIDTH` wide.

The launcher's smallest size is `minResizeWidth` / `minResizeHeight` of 40dp in
`android/app/src/main/res/xml/weather_widget_info.xml`; `targetCellWidth` / `targetCellHeight` keep 4x2 the default.

On Android 12 and later, text and icons scale with the card (`scaleFor`, and `compactScaleFor` for the compact
layout's icon and temperature, both capped at 1.6x), so a large card is filled. Before Android 12 only the text scales.
On Android 12+ the launcher reports every size the widget can be shown at, and the provider renders one `RemoteViews`
per size so the host picks the layout that fits; before that it renders for the size in the options. The thresholds
are set against the sizes a Galaxy (One UI) reports, which it draws scaled by `hsResizeRatio`: about 150dp for 2
cells, 235dp for 3 and 320dp for 4, not the nominal cell size
([the spec](../../docs/specs/2026-11-03-widget-testing-feedback.md)).

**The icon is animated.** A home-screen widget can't run Flare, so each icon's loop is rendered to frames and played
by an indeterminate `ProgressBar` (an `animation-list`) that the provider adds into `card_icon_slot`. The small
sunrise, wind and humidity icons stay static
([decisions/widget-animated-icons](../decisions/widget-animated-icons.md)).

**Accent.** The card's background is the drawable for the app's accent, `backgroundFor` mapping the index to
`widget_background_0` to `widget_background_8` in the order of `GradientValues`
([themes and accents](themes-and-accents.md)).

Tapping the card opens the app. Before any data arrives, the widget shows an empty view that also opens the app. The
picker's preview (`weather_widget_preview.xml`) is a fixed 250x110dp card with static icons, so a host that measures
it at wrap-content can't collapse it.

**Updating.** Every successful fetch in the app calls `WeatherWidget.update`; picking an accent calls
`WeatherWidget.setAccent`, at launch too. `scheduleRefresh` registers a periodic WorkManager task that needs a
network. It refetches the last `WeatherQuery` in the background and updates the widget. Its frequency and its first
delay are set there. A comment says the delay is so it doesn't start a second engine during launch. The widget itself
never asks for updates (`updatePeriodMillis` is 0 in the widget info). The provider also re-renders on resize
(`onAppWidgetOptionsChanged`).

**Adding it.** If the launcher supports pinning (`WeatherWidget.canPin`), a widgets button appears at the top
centre while the menu is open. It calls `WeatherWidget.pin`, which goes through the `in.spanion.weather/widget`
channel to `MainActivity` rather than through `home_widget`, whose pin request has no callback. `MainActivity` passes
the launcher a callback that opens the home screen, so tapping "Add" lands the user on the widget instead of back in
the app. On Android 14+ the callback's creator has to allow the background launch, which `MainActivity` sets.

## Screens and routes

- Flutter side: `lib/services/weather_widget.dart` (`WeatherWidget`, `widgetRefreshDispatcher`).
- Kotlin side: `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`, and
  `MainActivity.kt` for the pin request.
- Layouts, all in `android/app/src/main/res/layout/`: the three above, `weather_widget_preview.xml`, and one
  generated `widget_icon_<name>.xml` per icon. Widget info: `android/app/src/main/res/xml/weather_widget_info.xml`.
- Backgrounds: `widget_background_<0..8>.xml` in `android/app/src/main/res/drawable/`.
- Icons: the loop frames `widget_icon_<name>_<nn>.png` and the stills `widget_icon_*.png` (preview), and
  `widget_detail_*.png` (sunrise, wind, humidity), in `android/app/src/main/res/drawable-nodpi/`; the
  `widget_anim_<name>.xml` lists in `res/drawable/`. All are rendered from the Flare animations by
  `tool/render_widget_icons_test.dart` ([run locally](../operations/run-locally.md)).

## Rules

- The background refresh uses the last place viewed in the app and never the device location. See
  [decisions/widget-uses-last-place](../decisions/widget-uses-last-place.md).
- The widget's values reach it as `SharedPreferences` written by `home_widget`
  ([what the app stores](../data/on-device-storage.md)).
- The ids the provider fills are those of the arrangement the layout shows: a tall compact card fills
  `card_icon_slot_tall` and `card_temperature_tall`, not `card_icon_slot` and `card_temperature`.
- `WeatherWidget` does nothing on platforms other than Android (`_supported`); a pin or accent failure is logged and
  the app carries on.
- `iconLayoutFor` and `backgroundFor` in the Kotlin provider map names and indexes to resources one by one, instead
  of looking them up by name. A comment says this is so resource shrinking keeps them. Adding an icon name: see
  [condition icons](../domain/condition-icons.md). Adding an accent needs a drawable and an index at the end of
  `GradientValues`, whose comment says the order must not change.
- When the background fetch fails, the task returns false so WorkManager retries with backoff.

## History

- 2026-11-03: was one card with two pages (Now and the next 24 hours) in a StackView, with a grey background and
  static PNG icons, and could not shrink below 4x2; now one Now card in three layouts, in the app's accent with an
  animated icon, down to one cell, because internal testing asked for a 2x2, no 24-hour page and an animated icon. See
  [decisions/widget-one-resizable-card](../decisions/widget-one-resizable-card.md).

## Sources

* `lib/services/weather_widget.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
* `android/app/src/main/kotlin/com/example/flutterweather/MainActivity.kt`
* `android/app/src/main/res/xml/weather_widget_info.xml`
* `android/app/src/main/res/layout/weather_widget.xml`
* `android/app/src/main/res/layout/weather_widget_small.xml`
* `android/app/src/main/res/layout/weather_widget_mini.xml`
* `android/app/src/main/res/layout/weather_widget_preview.xml`
* `android/app/src/main/res/drawable/widget_background_0.xml`
* `android/app/src/main/AndroidManifest.xml`
* `tool/render_widget_icons_test.dart`
* `lib/main.dart`
* `docs/specs/2026-11-03-widget-testing-feedback.md`
