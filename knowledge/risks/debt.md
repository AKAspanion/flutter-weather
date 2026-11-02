---
type: Technical Debt
title: Technical debt
description: Leftovers worth fixing, from the Kotlin package name and Kelvin conversions repeated in views to unmapped condition codes and unused fonts.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Technical debt

## Items

- **Condition codes that fall through to "partly cloudy".** `Weather.getIcon` matches rain only in its 3xx and
  500 to 504 ranges. So OpenWeatherMap's shower and freezing rain codes (511, 520s), and atmosphere codes other than
  fog (smoke, haze, dust), show the `few` icon ([condition icons](../domain/condition-icons.md)).
  `lib/services/weather.dart`.
- **Kelvin conversions repeated in views.** Views subtract `273.15` inline
  (`lib/views/weather/weather_view.dart`, `lib/views/forecast/hourly_detail_chip.dart`,
  `lib/views/forecast/daily_detail_card.dart`), instead of using `kelvinOffset` from
  `lib/services/providers/weather_provider.dart` as `lib/services/weather_widget.dart` does.
- **All screen state in one widget.** `_MainAppState` in `lib/main.dart` holds the report, the accent, the dialogs
  and every animation controller, and passes them down by hand. The accent and the city are read from
  SharedPreferences there, while the theme goes through `ThemeManager`.
- **Untyped callbacks and props** in older widgets (`lib/components/btn.dart`, `lib/components/hamburger.dart`,
  `lib/views/home/dialog_overlay.dart`); see [questions/code-style-for-new-code](../questions/code-style-for-new-code.md).
- **Old-style code:** `new MainApp()` in `lib/main.dart`; `AppTheme.White` and `AppTheme.Dark` aren't lowerCamelCase
  (`lib/theme/app_theme.dart`); the `description` in `pubspec.yaml` is still Flutter's template text.
- **Kotlin package `com.example.flutterweather`**, which differs from the application ID
  ([decisions/new-application-id](../decisions/new-application-id.md)).
- **Unused font files.** `assets/fonts/` holds the whole Montserrat family, but `pubspec.yaml` bundles only Regular and
  Italic.
- **Flare is discontinued.** The icons depend on our patched copy ([decisions/vendored-flare-flutter](../decisions/vendored-flare-flutter.md)).
- **The analyzer enables no lint set.** `./analysis_options.yaml` only lists excludes.

## Sources

* `lib/services/weather.dart`
* `lib/views/weather/weather_view.dart`
* `lib/views/forecast/hourly_detail_chip.dart`
* `lib/views/forecast/daily_detail_card.dart`
* `lib/services/providers/weather_provider.dart`
* `lib/services/weather_widget.dart`
* `lib/main.dart`
* `lib/components/btn.dart`
* `lib/components/hamburger.dart`
* `lib/views/home/dialog_overlay.dart`
* `lib/theme/app_theme.dart`
* `pubspec.yaml`
* `./analysis_options.yaml`
