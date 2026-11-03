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

- **`Btn`** (`lib/components/btn.dart`): a square, rounded, shadowed button in the theme's background colour, 56 dp
  unless given a `size`. Used by `MenuButtons`.
- **`FlareIcon`** (`lib/components/flare_icon.dart`): plays one looping animation from a `.flr` file, inside a
  `RepaintBoundary`. Its doc comment says the boundary keeps the per-frame repaints from repainting the rest of the
  screen. Use it for every animated icon. The animation names are `cloudy-<icon>`
  ([condition icons](../domain/condition-icons.md)) in `assets/animations/cloudy.flr`, plus detail icons such as
  `sun`, `wind` and `drop` in `assets/animations/icons.flr`.
- **`Hamburger`** (`lib/components/hamburger.dart`): the animated menu button on the home card.
- **`AdBanner`** (`lib/components/ad_banner.dart`): the adaptive banner ([Google AdMob](../integrations/google-admob.md)).

In `lib/views/`:

- **`MenuButtons`** (`lib/views/menu/menu_buttons.dart`): the menu's top row of `Btn`s: refresh and close in the far
  corners, with theme, widget (only when the launcher can pin), translate and location spread between them. The buttons
  shrink together on a screen too narrow for full size.
- **`LanguageOverlay`** (`lib/views/home/language_overlay.dart`): the full-screen language list, laid out like
  `DialogOverlay` ([language picker](../features/language-picker.md)).

Reused inside views:

- **`WeatherDetailChip`** (`lib/views/weather/weather_detail_chip.dart`): an icon, a label and a value, three in a
  row on the main card.
- **`HourlyDetail`** (`lib/views/forecast/hourly_detail_chip.dart`) and **`DailyDetail`**
  (`lib/views/forecast/daily_detail_card.dart`): forecast entries that expand when tapped
  ([forecast](../features/forecast.md)).

Animated icons are also rendered to frames for the Android widget, by `tool/render_widget_icons_test.dart`, which
plays them as an animation ([home-screen widget](../features/home-screen-widget.md)).

## History

- 2026-11-03: `Btn` was used for five hand-placed buttons in `lib/main.dart`; now it takes a `size` and `MenuButtons` lays the row out, because the translate button made six. See [supported languages](../decisions/supported-languages.md).

## Sources

* `lib/components/btn.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/views/home/language_overlay.dart`
* `lib/views/home/dialog_overlay.dart`
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
