---
type: Design Tokens
title: Colours, shapes and type
description: Accent gradients, the two theme colours, the Montserrat font, and the radius and shadow values the screens repeat.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Colours, shapes and type

There is no token file or theme extension. The values below live in a few Dart files, and views repeat some of them
inline.

## Colours

- **Accent gradients:** `GradientValues` in `lib/theme/gradients.dart`, a named list of two-colour gradients. The
  user's choice is an index into it ([themes and accents](../features/themes-and-accents.md)). Views read it as
  `GradientValues().gradients[accent].gradient` and often use the first colour alone. The widget keeps a drawable
  per index (`widget_background_<index>.xml`), so the order must not change and a new gradient goes at the end with a
  drawable ([home-screen widget](../features/home-screen-widget.md)).
- **Theme:** `appThemeData` in `lib/theme/app_theme.dart` sets the brightness and primary colour for `AppTheme.White`
  and `AppTheme.Dark`. The surface and text colours the views actually use come from `ThemeManager.bgColor` and
  `ThemeManager.textColor` in `lib/services/theme_manager.dart`. Which of the two shows follows the system, unless the
  user overrode it ([themes and accents](../features/themes-and-accents.md)).
- Views also use Material colours inline (`Colors.white`, `Colors.black38`, `Colors.red[400]` and others).

## Spacing and radius

These values are repeated inline, not named:

- Cards and buttons: rounded corners (12 for buttons, dialogs and day cards; 24 for the home card while the menu is
  open), and a soft `BoxShadow` in `Colors.black38`. See `Btn` in `lib/components/btn.dart` (56 square unless given a `size`) and `Home` in
  `lib/views/home/home.dart`.
- Screen padding of 24 around the main card, and 24 from the top for the menu's button row, which has 16 at its sides
  (`lib/main.dart`, `lib/views/home/home.dart`, `lib/views/menu/menu_buttons.dart`).

## Typography

- Montserrat, registered under `flutter.fonts` in `pubspec.yaml` and set as `fontFamily` in `appThemeData`. Only the
  font files listed in `pubspec.yaml` are bundled. The others in `assets/fonts/` are unused
  ([debt](../risks/debt.md)).
- Montserrat has no Devanagari, Bengali, Arabic or Han glyphs: text in those languages falls back to Android's system
  fonts, which are taller, so text rows that must not overflow force Montserrat's line height
  ([forecast](../features/forecast.md), [supported languages](../decisions/supported-languages.md)).
- Headings are upper case and bold. Sizes are set inline per widget.

## Sources

* `lib/theme/gradients.dart`
* `lib/theme/app_theme.dart`
* `lib/services/theme_manager.dart`
* `lib/components/btn.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/views/home/home.dart`
* `lib/main.dart`
* `pubspec.yaml`
