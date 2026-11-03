---
type: Feature
title: Choose the app's language
description: A translate button in the menu's top row opens a list of System default and ten languages in their own scripts; the choice applies at once, is remembered, and the widget follows it.
status: draft
generated: { by: claude-code/claude-sonnet-5-5, at: 2026-11-03T09:30:00Z }
---

# Choose the app's language

## What it does

The translate button in the menu's top button row opens `LanguageOverlay`, a full-screen list over a dimmed background,
laid out like the city dialog ([city search](city-search.md)). It lists "System default" first, then the ten
[supported languages](../decisions/supported-languages.md), each in its own script. The current choice has a check
mark in the accent colour. Tapping a row applies the language at once and closes the overlay; a close button closes it
without a change.

- **Remembered.** `LocaleManager.setLocale` saves the code as `language_preference`, or removes it for System default
  ([on-device storage](../data/on-device-storage.md)). `LocaleManager.load` restores it at start-up.
- **System default** follows the phone's language when it is one of the ten, otherwise English
  (`LocaleManager.resolve`).
- **Everything follows it:** the card, the forecast, the city dialog, the menu's privacy button and the snackbar
  ([current weather](current-weather.md), [forecast](forecast.md)), dates and times through `intl`, and the text the
  [home-screen widget](home-screen-widget.md) shows.
- **Right to left.** Arabic and Urdu mirror the layout.

## Screens and routes

- `lib/views/home/language_overlay.dart` (`LanguageOverlay`).
- `lib/views/menu/menu_buttons.dart` (`MenuButtons`): the translate button sits between the widget and location
  buttons, with refresh and close in the far corners. Home's own top row holds only the menu and forecast buttons.
- `lib/services/locale_manager.dart` (`LocaleManager`, `Language`, `supportedLanguages`): provided in `lib/main.dart`,
  which hands the chosen locale to `MaterialApp`.
- `isLanguageOpen` and `toggleLanguage` in `lib/main.dart`. The overlay comes after the menu in the `Stack`, so it
  shows above it.
- The words are in `lib/l10n/app_<code>.arb`; `l10n.yaml` sets `lib/l10n/app_en.arb` as the template, and the generated
  `AppLocalizations` files are git-ignored ([gen_l10n decision](../decisions/app-localization-gen-l10n.md)).

## Rules

- `LocaleManager.setLocale` never throws: the language changes as soon as it notifies, and a failed save is logged
  and means the choice holds only until the app closes.
- An unknown or unreadable saved code is read as System default.
- A new language is one more `.arb` file, one `Language` entry in `supportedLanguages`, and a `values-<code>` widget
  `strings.xml`.
- The overlay reads its strings from `AppLocalizations.of(context)!`, so it must sit below `MaterialApp`; the app's
  own `State` is above it, so strings there go through a `Builder`.

## Sources

* `lib/views/home/language_overlay.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/services/locale_manager.dart`
* `lib/main.dart`
* `lib/l10n/app_en.arb`
* `l10n.yaml`
* `test/language_overlay_test.dart`
* `test/locale_manager_test.dart`
* `test/menu_buttons_test.dart`
* `docs/specs/2026-11-03-app-localization.md`
