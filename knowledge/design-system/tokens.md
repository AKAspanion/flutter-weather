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
- **Accent on a card:** the accents were picked for the light card, and several are unreadable on the dark one
  (Aubergine, 50 Shades of Grey) or pale on white (Pale Wood). So an accent drawn on a card goes through
  `readableOn` in `lib/theme/contrast.dart`, which lightens it on the dark card or darkens it on the light one just
  enough for WCAG contrast: `textContrast = 4.5` for text, `shapeContrast = 3` for icons, borders and fills (the
  picker's check, the city field, the toggles and the settings panel's language chip). A label on an accent fill uses
  `onFill`, white or near-black, whichever reads better. Found testing on a phone with the Aubergine accent in the
  dark theme.
- Views also use Material colours inline (`Colors.white`, `Colors.black38`, `Colors.red[400]` and others).

## Spacing and radius

These values are repeated inline, not named:

- Cards and buttons: rounded corners (12 for buttons, the overlay card and day cards; 24 for the home card while the menu is
  open), and a soft `BoxShadow` in `Colors.black38`. See `Btn` in `lib/components/btn.dart` (56 square unless given a `size`), `OverlayCard` in `lib/components/overlay_card.dart` and `Home` in
  `lib/views/home/home.dart`.
- Screen padding of 24 around the main card. The menu's button row sits `SystemInsets.buttonRowGap` (24) below the
  top system padding, so it stays clear of the camera cutout, and has 16 at its sides (`SystemInsets.buttonRowTop` in
  `lib/components/system_insets.dart`, `lib/views/home/home.dart`, `lib/views/menu/menu_buttons.dart`).

## Typography

- Montserrat, registered under `flutter.fonts` in `pubspec.yaml` and set as `fontFamily` in `appThemeData`. Only the
  font files listed in `pubspec.yaml` are bundled. The others in `assets/fonts/` are unused
  ([debt](../risks/debt.md)).
- Montserrat has no Devanagari, Bengali, Arabic or Han glyphs: text in those languages falls back to Android's system
  fonts, which are taller, so text rows that must not overflow force Montserrat's line height
  ([forecast](../features/forecast.md), [supported languages](../decisions/supported-languages.md)).
- Headings are upper case and bold. Sizes are set inline per widget.

## History

- 2026-11-04: the button row was 24 from the top of the screen; now 24 below the top system padding, because
  the app draws edge to edge (#12) and the row has to clear the camera cutout.
- 2026-11-04: overlays drew the raw accent as text and icons on either card; now they pass it through `readableOn`
  and `onFill`, because on the dark card some accents were unreadable. See
  [overlays share one card](../decisions/overlays-share-one-card.md).
- 2026-11-03: dialogs repeated their own radius and shadow; now the overlay card holds them once, because the three overlays share `OverlayCard`. See [overlays share one card](../decisions/overlays-share-one-card.md).

## Sources

* `lib/theme/gradients.dart`
* `lib/theme/app_theme.dart`
* `lib/theme/contrast.dart`
* `lib/services/theme_manager.dart`
* `lib/components/btn.dart`
* `lib/components/overlay_card.dart`
* `lib/components/system_insets.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/views/home/home.dart`
* `lib/main.dart`
* `pubspec.yaml`
