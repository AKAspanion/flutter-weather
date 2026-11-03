---
type: Feature
title: Choose a theme and an accent
description: The theme follows the system light or dark, the menu button overrides it until the system changes, and accent gradients picked from a carousel also colour the widget.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Choose a theme and an accent

## What it does

- **Theme.** By default the theme matches the system brightness (`resolveTheme` in `lib/services/theme_manager.dart`),
  at launch and live when the system changes it (`ThemeManager` observes `didChangePlatformBrightness`). The sun/moon
  button (shown while the menu is open) switches between `AppTheme.White` and `AppTheme.Dark` through
  `ThemeManager.setTheme`. That choice is an override, saved as `theme_preference` together with the brightness it was
  made against (`theme_preference_system`). It holds, across launches too, until the system brightness changes; then it
  is cleared and the app follows the system again. A `theme_preference` saved before this had no brightness, so it
  counts as set against the brightness showing at that launch and nobody's choice flips on upgrade
  ([decisions/theme-follows-system](../decisions/theme-follows-system.md)).
- **Accent.** The menu's carousel lists every gradient in `GradientValues`. Tapping one calls `setAccent` in
  `lib/main.dart`, which saves it as `accent_preference`. The accent colours the menu background, the spinner, the
  dialog's field and the expanded forecast cards, and the home-screen widget: `WeatherWidget.setAccent` pushes the
  index on every change and at launch ([widget](home-screen-widget.md)).

## Screens and routes

- `lib/views/menu/menu.dart` (`Menu`): the drawer and the accent carousel.
- `lib/main.dart`: the theme button, `toggleTheme`, `setAccent` and `getAccent`.
- Opening the menu: the hamburger on the card (`lib/components/hamburger.dart`), or swiping the card sideways
  (`onDragEnd` in `lib/views/home/home.dart`).

## Rules

- The gradients and the theme colours are in [design tokens](../design-system/tokens.md).
- With the menu open, the card shrinks so it stays clear of the menu footer and the banner ad
  (`Menu.footerHeight`, `fitScale` in `lib/views/home/home.dart`).
- `ThemeManager` reads the system brightness when it is created, so the first frame already matches the system. A
  saved override loads asynchronously and applies once `_loadTheme` finishes, so a user whose override differs from
  the system can see the system theme briefly at launch. `selectedAccent` in `lib/main.dart` likewise starts at the
  first gradient until `getAccent` finishes.
- There is no "follow the system" control: the next system change restores it.

## History

- 2026-11-03: was a light/dark toggle saved as `theme_preference` and loaded at start-up, with the light theme until
  it loaded; now the theme follows the system and the toggle is an override until the system next changes, because
  internal testing asked for the app to follow dark mode. See
  [decisions/theme-follows-system](../decisions/theme-follows-system.md).
- 2026-11-03: the accent coloured only the app; now it also colours the widget, because the widget was grey and
  internal testing asked for it in the app's accent. See
  [decisions/widget-one-resizable-card](../decisions/widget-one-resizable-card.md).

## Sources

* `lib/services/theme_manager.dart`
* `lib/theme/app_theme.dart`
* `lib/theme/gradients.dart`
* `lib/services/weather_widget.dart`
* `lib/views/menu/menu.dart`
* `lib/views/home/home.dart`
* `lib/components/hamburger.dart`
* `lib/main.dart`
