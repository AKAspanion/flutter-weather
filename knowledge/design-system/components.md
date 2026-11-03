---
type: Component Inventory
title: Shared widgets
description: Btn, OverlayCard, SegmentedChoice, FlareIcon, Hamburger and AdBanner in lib/components, plus the detail chips and cards the weather and forecast views reuse.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Shared widgets

## Components

In `lib/components/`:

- **`Btn`** (`lib/components/btn.dart`): a square, rounded, shadowed button in the theme's background colour, 56 dp
  unless given a `size`. Used by `MenuButtons`.
- **`OverlayCard`** (`lib/components/overlay_card.dart`): the card every full-screen overlay sits in: a dimmed backdrop,
  a card `size.width - 64` wide with its title upper-cased at the start (inset 16 so it lines up with `ListTile` text), a
  close `IconButton` at the end, and the content below, scrolling when it doesn't fit. It returns a `Positioned.fill`, so
  it goes straight into the `Stack` ([decision](../decisions/overlays-share-one-card.md)).
- **`SegmentedChoice<T>`** (`lib/components/segmented_choice.dart`): the two-part toggle filled with the accent colour,
  used by the settings panel's Theme and Temperature rows.
- **`FlareIcon`** (`lib/components/flare_icon.dart`): plays one looping animation from a `.flr` file, inside a
  `RepaintBoundary`. Its doc comment says the boundary keeps the per-frame repaints from repainting the rest of the
  screen. Use it for every animated icon. The animation names are `cloudy-<icon>`
  ([condition icons](../domain/condition-icons.md)) in `assets/animations/cloudy.flr`, plus detail icons such as
  `sun`, `wind` and `drop` in `assets/animations/icons.flr`.
- **`Hamburger`** (`lib/components/hamburger.dart`): the animated menu button on the home card.
- **`AdBanner`** (`lib/components/ad_banner.dart`): the adaptive banner ([Google AdMob](../integrations/google-admob.md)).

In `lib/views/`:

- **`MenuButtons`** (`lib/views/menu/menu_buttons.dart`): the menu's top row of `Btn`s: refresh and close in the far
  corners, with widget (only when the launcher can pin), the settings gear and location spread between them. There is no
  theme button; the theme is a row in settings. The buttons
  shrink together on a screen too narrow for full size.
- **`SettingsOverlay`** (`lib/views/settings/settings_overlay.dart`): the settings panel the gear opens, an `OverlayCard` of rows
  (Theme toggle, Language, Temperature toggle, Rate on Google Play) ([settings](../features/settings.md)).
- **`LanguageOverlay`** (`lib/views/home/language_overlay.dart`): the full-screen language list on `OverlayCard`
  ([language picker](../features/language-picker.md)).
- **`DialogOverlay`** (`lib/views/home/dialog_overlay.dart`): the city dialog on `OverlayCard`
  ([city search](../features/city-search.md)).

Reused inside views:

- **`WeatherDetailChip`** (`lib/views/weather/weather_detail_chip.dart`): an icon, a label and a value, three in a
  row on the main card.
- **`HourlyDetail`** (`lib/views/forecast/hourly_detail_chip.dart`) and **`DailyDetail`**
  (`lib/views/forecast/daily_detail_card.dart`): forecast entries that expand when tapped
  ([forecast](../features/forecast.md)).

Animated icons are also rendered to frames for the Android widget, by `tool/render_widget_icons_test.dart`, which
plays them as an animation ([home-screen widget](../features/home-screen-widget.md)).

## History

- 2026-11-03: the city dialog, the language list and the settings panel each built their own backdrop and card; now they share `OverlayCard`, and the theme and unit toggles share `SegmentedChoice`; the menu row lost its theme button, because every overlay got one look and the theme moved into settings. See [overlays share one card](../decisions/overlays-share-one-card.md).
- 2026-11-03: the menu row's sixth button was translate; now the settings gear, and `SettingsOverlay` is new, because every setting lives in one panel. See [settings panel](../decisions/settings-panel.md).
- 2026-11-03: `Btn` was used for five hand-placed buttons in `lib/main.dart`; now it takes a `size` and `MenuButtons` lays the row out, because the translate button made six. See [supported languages](../decisions/supported-languages.md).

## Sources

* `lib/components/btn.dart`
* `lib/components/overlay_card.dart`
* `lib/components/segmented_choice.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/views/home/language_overlay.dart`
* `lib/views/settings/settings_overlay.dart`
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
