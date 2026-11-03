---
type: Feature
title: Android home-screen widget
description: One flat card that snaps between Now and the next 24 hours on a vertical swipe, fed by the app and refreshed in the background for the last place viewed.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T01:20:00+05:30 }
verified: human:panditankit1995@gmail.com
---

# Android home-screen widget

## What it does

A resizable home-screen widget, on Android only. It is one card with two pages. A vertical swipe inside the card
snaps to the other page once it passes StackView's swipe threshold; a smaller nudge springs back. Two dots at the
right edge show which page is visible.

- **Now:** the city, the icon, the temperature, the description with today's high and low beside them, a row with
  sunrise, wind and humidity (using the app's own detail icons), and when it was updated.
- **Next 24 hours:** hour columns, each with a short hour label (`DateFormat.j`: "3 PM", or "15" in a 24-hour language), an icon and the temperature. The app sends
  up to `_hourColumns` entries at least `_hourStep` apart (both in `WeatherWidget`). A squarish card (width to height
  under `SQUARE_RATIO` in the Kotlin provider, e.g. 4x3) shows every other entry, 4 columns six hours apart, still
  covering 24 hours; wider cards (4x2, 3x2) show all 8.

On Android 12 and later, text and icons on both pages scale with the card (`scaleFor`, from 1x up to 1.6x), so a
large card is filled. Before Android 12 only the text scales.

Left/right swipes can't reach a home-screen widget (launchers use them to change pages), so the hours sit side by
side rather than in a horizontal pager. The drag effect while swiping (a grey line and the other page fading in)
is StackView's own and can't be changed from a widget.

Tapping a page opens the app. Before any data arrives, the widget shows an empty view that also opens the app.

**Updating.** Every successful fetch in the app calls `WeatherWidget.update`. `scheduleRefresh` registers a periodic
WorkManager task that needs a network. It refetches the last `WeatherQuery` in the background and updates the widget.
Its frequency and its first delay are set there. A comment says the delay is so it doesn't start a second engine
during launch. The widget itself never asks for updates (`updatePeriodMillis` is 0 in
`android/app/src/main/res/xml/weather_widget_info.xml`). The provider also re-renders on resize
(`onAppWidgetOptionsChanged`).

**Adding it.** If the launcher supports pinning (`WeatherWidget.canPin`), a widgets button appears in the menu's top
button row while the menu is open. It calls `WeatherWidget.pin`.

**Temperature unit.** The temperatures follow the saved `temperature_unit`, or the phone's region when none is saved:
`WeatherWidget.temperatureUnit` reads it without a `BuildContext`, so the background refresh follows it too. The widget
shows `°` only, with no `C` or `F`, for lack of room. The app re-pushes the cached report when the unit changes
(`onUnitChanged` in `lib/main.dart`), so the widget switches at once ([settings](settings.md),
[decision](../decisions/temperature-unit-by-region.md)). A missing temperature shows `--`.

**Language.** The text the app pushes (city, description, high and low, the card titles, the update line, the hour
labels) is in the app's chosen language: `WeatherWidget.payload` builds it from `WeatherWidget.localizations()`, which
reads `language_preference` without a `BuildContext`, so the background refresh follows the choice too
([language picker](language-picker.md)). Titles and update line travel in the `labels` data key. The widget's own
`strings.xml` values follow the phone's language (a `values-<code>` folder per language) and show only until the first
update, or when a label is missing.

## Screens and routes

- Flutter side: `lib/services/weather_widget.dart` (`WeatherWidget`, `widgetRefreshDispatcher`).
- Kotlin side: `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`.
- Layouts: `weather_widget.xml` (the card and its StackView), `weather_widget_item.xml` (Now),
  `weather_widget_hours.xml` and `weather_widget_hour.xml` (hours), and `weather_widget_preview.xml`, all in
  `android/app/src/main/res/layout/`. Widget info: `android/app/src/main/res/xml/weather_widget_info.xml`.
- Backgrounds: `widget_background.xml` (the card), `widget_page_background.xml` (pages; square in `drawable-v31/`)
  and `widget_dot.xml` in `android/app/src/main/res/drawable/`.
- Icons: PNGs `widget_icon_*.png` (weather) and `widget_detail_*.png` (sunrise, wind, humidity) in
  `android/app/src/main/res/drawable-nodpi/`, rendered from the Flare animations by
  `tool/render_widget_icons_test.dart` ([run locally](../operations/run-locally.md)).

## Rules

- The background refresh uses the last place viewed in the app and never the device location. See
  [decisions/widget-uses-last-place](../decisions/widget-uses-last-place.md).
- The pages live in a StackView, the only widget view that snaps on a swipe. StackView normally draws a fanned deck:
  it caps each page (inside a frame padded by `FRAME_PADDING`) at 90% of its size and shifts the pages behind into
  the rest. On Android 12+ `flattenStack` and `sizedTo` size each page to the card and enlarge the StackView past the
  card's edges so the front page covers the card exactly; the card (`clipToOutline`) hides the page behind. `SLACK`
  keeps StackView on its predictable "spread" branch. Before Android 12 the stacked look shows.
- Collection item ids encode the card size. With fixed ids the launcher kept the old pages after a resize, sized for
  the previous card and outside the visible area.
- `_androidName` names the provider by its full Kotlin class, because the Kotlin package differs from the
  application ID (a comment says so).
- `iconFor` in the Kotlin provider maps icon names to drawables one by one, instead of looking them up by name. A
  comment says this is so resource shrinking keeps them. Adding an icon name: see
  [condition icons](../domain/condition-icons.md).
- `WeatherWidget` does nothing on platforms other than Android (`_supported`).
- When the background fetch fails, the task returns false so WorkManager retries with backoff.

## History

- 2026-11-03: temperatures were always °C; now they follow the saved unit and are re-pushed when it changes, because the app can show °F. See [temperature unit](../decisions/temperature-unit-by-region.md).
- 2026-11-03: the pushed text was English, with `3P` hour labels and the `updated` time; now translated in the app's language with a `labels` key and `3 PM` labels, and the pin button moved into the menu's button row, because the app is translated. See [supported languages](../decisions/supported-languages.md).

## Sources

* `lib/services/weather_widget.dart`
* `lib/services/unit_manager.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
* `android/app/src/main/res/xml/weather_widget_info.xml`
* `android/app/src/main/res/layout/weather_widget.xml`
* `android/app/src/main/res/layout/weather_widget_item.xml`
* `android/app/src/main/res/layout/weather_widget_hours.xml`
* `android/app/src/main/res/layout/weather_widget_hour.xml`
* `android/app/src/main/res/layout/weather_widget_preview.xml`
* `android/app/src/main/res/drawable/widget_background.xml`
* `android/app/src/main/res/drawable/widget_page_background.xml`
* `android/app/src/main/res/drawable-v31/widget_page_background.xml`
* `android/app/src/main/res/drawable/widget_dot.xml`
* `android/app/src/main/AndroidManifest.xml`
* `tool/render_widget_icons_test.dart`
* `lib/main.dart`
* `lib/l10n/app_en.arb`
* `android/app/src/main/res/values/strings.xml`
* `test/weather_widget_test.dart`
