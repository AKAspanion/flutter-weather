---
type: Component Inventory
title: Shared widgets
description: Btn, FlareIcon, Hamburger and AdBanner in lib/components, plus the detail chips and cards the weather and forecast views reuse.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Shared widgets

## Components

In `lib/components/`:

- **`Btn`** (`lib/components/btn.dart`): a square, rounded, shadowed button in the theme's background colour. Used
  for the top buttons in `lib/main.dart`.
- **`FlareIcon`** (`lib/components/flare_icon.dart`): plays one looping animation from a `.flr` file, inside a
  `RepaintBoundary`. Its doc comment says the boundary keeps the per-frame repaints from repainting the rest of the
  screen. Use it for every animated icon. The animation names are `cloudy-<icon>`
  ([condition icons](../domain/condition-icons.md)) in `assets/animations/cloudy.flr`, plus detail icons such as
  `sun`, `wind` and `drop` in `assets/animations/icons.flr`.
- **`Hamburger`** (`lib/components/hamburger.dart`): the animated menu button on the home card.
- **`AdBanner`** (`lib/components/ad_banner.dart`): the adaptive banner ([Google AdMob](../integrations/google-admob.md)).

Reused inside views:

- **`WeatherDetailChip`** (`lib/views/weather/weather_detail_chip.dart`): an icon, a label and a value, three in a
  row on the main card.
- **`HourlyDetail`** (`lib/views/forecast/hourly_detail_chip.dart`) and **`DailyDetail`**
  (`lib/views/forecast/daily_detail_card.dart`): forecast entries that expand when tapped
  ([forecast](../features/forecast.md)).

Animated icons are also rendered to frames for the Android widget, by `tool/render_widget_icons_test.dart`, which
plays them as an animation ([home-screen widget](../features/home-screen-widget.md)).

## Sources

* `lib/components/btn.dart`
* `lib/components/flare_icon.dart`
* `lib/components/hamburger.dart`
* `lib/components/ad_banner.dart`
* `lib/views/weather/weather_detail_chip.dart`
* `lib/views/forecast/hourly_detail_chip.dart`
* `lib/views/forecast/daily_detail_card.dart`
* `tool/render_widget_icons_test.dart`
* `assets/animations/cloudy.flr`
* `assets/animations/icons.flr`
* `lib/main.dart`
