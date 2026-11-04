---
type: Technical Debt
title: Technical debt
description: Leftovers worth fixing, from the Kotlin package name and Kelvin conversions repeated in views to unmapped condition codes and unused fonts.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Technical debt

## Items

- **Condition codes that fall through to "partly cloudy".** `Weather.getIcon` matches rain only in its 3xx and
  500 to 504 ranges. So OpenWeatherMap's shower and freezing rain codes (511, 520s), and atmosphere codes other than
  fog (smoke, haze, dust), show the `few` icon ([condition icons](../domain/condition-icons.md)).
  `lib/services/weather.dart`.
- **All screen state in one widget.** `_MainAppState` in `lib/main.dart` holds the report, the accent, the dialogs
  and every animation controller, and passes them down by hand. The accent and the city are read from
  SharedPreferences there, while the theme goes through `ThemeManager`.
- **Untyped callbacks and props** in older widgets (`lib/components/btn.dart`, `lib/components/hamburger.dart`). New code types them; these get types when next touched
  ([decisions/code-style-120-typed](../decisions/code-style-120-typed.md)).
- **Old-style code:** `new MainApp()` in `lib/main.dart`; `AppTheme.White` and `AppTheme.Dark` aren't lowerCamelCase
  (`lib/theme/app_theme.dart`); the `description` in `pubspec.yaml` is still Flutter's template text.
- **Kotlin package `com.example.flutterweather`**, which differs from the application ID
  ([decisions/new-application-id](../decisions/new-application-id.md)).
- **Unused font files.** `assets/fonts/` holds the whole Montserrat family, but `pubspec.yaml` bundles only Regular and
  Italic.
- **Text that is still English.** The wind unit (`m/s`, written inline in `lib/views/weather/weather_view.dart`, the
  forecast chips and `lib/services/weather_widget.dart`), each provider's attribution line (`lib/services/providers/`)
  and the app's label "Beautiful Weather" aren't translated.
- **Forecast cards overflow for a few pixels while they expand.** In tests, the hourly chips and day cards overflow
  by a few pixels mid-animation, because their inner parts grow on a different curve from the outer container
  (`lib/views/forecast/hourly_detail_chip.dart`, `lib/views/forecast/daily_detail_card.dart`). It settles when the
  animation ends; `test/centre_in_list_test.dart` ignores it.
- **Layout errors on the first frames after launch.** Seen in the `flutter run` log on an emulator and a phone: a
  burst of "BoxConstraints has a negative minimum height" and "has both a negative minimum width and a negative
  minimum height" assertions at start-up, while the screen size is still 0. One source is the home card's height,
  `size.height - 112 - bottomInset` in `lib/views/home/home.dart`, which goes negative then; the negative-width ones
  aren't traced yet. The app recovers on the next frame and nothing shows on screen, but every debug run starts with
  these errors. Clamping these sizes at 0 would fix it.
- **Flare is discontinued.** The icons depend on our patched copy ([decisions/vendored-flare-flutter](../decisions/vendored-flare-flutter.md)).
- **The analyzer enables no lint set.** `./analysis_options.yaml` only lists excludes.

## History

- 2026-11-04: the launch-time layout errors weren't recorded; now they are an item, because the developer asked
  for them to be kept during the knowledge review.
- 2026-11-04: added the item about forecast cards overflowing mid-expand, seen while testing the centring. See [forecast](../features/forecast.md).
- 2026-11-03: `lib/views/home/dialog_overlay.dart` was listed with the untyped callbacks; now it is typed, because it was rebuilt on `OverlayCard`. See [overlays share one card](../decisions/overlays-share-one-card.md).
- 2026-11-03: removed the item about Kelvin conversions repeated in views, and "temperatures stay in °C" from the untranslated text item; `formatTemperature` in `lib/services/unit_manager.dart` is now the one place Kelvin becomes shown text, because the temperature unit became a setting. See [temperature unit](../decisions/temperature-unit-by-region.md).
- 2026-11-03: added the untranslated text item, because the app is now translated and these stayed English. See [supported languages](../decisions/supported-languages.md).

## Sources

* `lib/services/weather.dart`
* `lib/views/weather/weather_view.dart`
* `lib/views/forecast/hourly_detail_chip.dart`
* `lib/views/forecast/daily_detail_card.dart`
* `lib/services/providers/weather_provider.dart`
* `lib/services/weather_widget.dart`
* `lib/services/unit_manager.dart`
* `test/centre_in_list_test.dart`
* `lib/services/providers/openweathermap.dart`
* `lib/main.dart`
* `lib/components/btn.dart`
* `lib/components/hamburger.dart`
* `lib/theme/app_theme.dart`
* `pubspec.yaml`
* `./analysis_options.yaml`
* `lib/views/home/home.dart`
