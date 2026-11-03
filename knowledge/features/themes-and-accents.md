---
type: Feature
title: Choose a theme and an accent
description: A light and a dark theme, toggled from the menu, and accent gradients picked from a carousel; both are remembered.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Choose a theme and an accent

## What it does

- **Theme.** The sun/moon button (in the menu's button row, shown while the menu is open) switches between `AppTheme.White` and `AppTheme.Dark`
  through `ThemeManager.setTheme`. The choice is saved as `theme_preference` and loaded when `ThemeManager` is
  created.
- **Accent.** The menu's carousel lists every gradient in `GradientValues`. Tapping one calls `setAccent` in
  `lib/main.dart`, which saves it as `accent_preference`. The accent colours the menu background, the spinner, the
  dialog's field and the expanded forecast cards.

## Screens and routes

- `lib/views/menu/menu.dart` (`Menu`): the drawer and the accent carousel.
- `lib/views/menu/menu_buttons.dart` and `lib/main.dart`: the theme button, `toggleTheme`, `setAccent` and `getAccent`.
- Opening the menu: the hamburger on the card (`lib/components/hamburger.dart`), or swiping the card towards the end of the line
  (`onDragEnd` in `lib/views/home/home.dart`: right in left-to-right languages, left in Arabic and Urdu).

## Rules

- The gradients and the theme colours are in [design tokens](../design-system/tokens.md).
- With the menu open, the card shrinks so it stays clear of the menu footer and the banner ad
  (`Menu.footerHeight`, `fitScale` in `lib/views/home/home.dart`). `footerHeight` includes a 24 dp gap (`_cardGap`) so
  the shrunken card never touches the accent picker.
- Both choices load asynchronously after start-up. Until they do, the app uses the defaults: `ThemeManager` returns
  `AppTheme.White` until `_loadTheme` finishes, and `selectedAccent` in `lib/main.dart` starts at the first gradient
  until `getAccent` finishes. A user who picked the dark theme or another accent can see the defaults briefly at
  launch.

## History

- 2026-11-03: the card could touch the accent picker, and the menu mirrored only left to right; now a 24 dp gap sits above the picker and the layout mirrors for Arabic and Urdu, because the developer saw the card touch the picker and the app gained right-to-left languages. See [supported languages](../decisions/supported-languages.md).

## Sources

* `lib/services/theme_manager.dart`
* `lib/theme/app_theme.dart`
* `lib/theme/gradients.dart`
* `lib/views/menu/menu.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/views/home/home.dart`
* `lib/components/hamburger.dart`
* `lib/main.dart`
