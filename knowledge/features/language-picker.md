---
type: Feature
title: Choose the app's language
description: A Language row in the settings panel opens a list of System default and ten languages in their own scripts; the choice applies at once, is remembered, and the widget follows it.
generated: { by: claude-code/claude-sonnet-5-5, at: 2026-11-03T09:30:00Z }
verified: human:panditankit1995@gmail.com
---

# Choose the app's language

## What it does

The Language row of the [settings panel](settings.md) opens `LanguageOverlay`, a full-screen list on the shared `OverlayCard`
([decision](../decisions/overlays-share-one-card.md)) over a dimmed background, above the panel, titled "Language". It lists "System default" first, then the ten
[supported languages](../decisions/supported-languages.md), each in its own script. The current choice has a check
mark in the accent colour. Tapping a row applies the language at once and closes the overlay; the close button in the header, at the top end, closes it
without a change; there is no close at the bottom. Either way the user is back in the settings panel.

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
- `lib/views/settings/settings_overlay.dart` (`SettingsOverlay`): the Language row that opens it.
- `lib/views/menu/menu_buttons.dart` (`MenuButtons`): the translate button is gone; its place holds the settings gear.
  Home's own top row holds only the menu and forecast buttons.
- `lib/services/locale_manager.dart` (`LocaleManager`, `Language`, `supportedLanguages`): provided in `lib/main.dart`,
  which hands the chosen locale to `MaterialApp`.
- `isLanguageOpen` and `toggleLanguage` in `lib/main.dart`. The overlay comes after the menu and the settings panel in the
  `Stack`, so it shows above both.
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

## History

- 2026-11-03: the list had its own card and a close button at the bottom; now it is built on `OverlayCard` with the close in the header, because every overlay got one look. See [overlays share one card](../decisions/overlays-share-one-card.md).
- 2026-11-03: opened from a translate button in the menu's button row; now opened from the settings panel's Language row, because every setting lives in one panel. See [settings panel](../decisions/settings-panel.md).

## Sources

* `lib/components/overlay_card.dart`
* `lib/views/home/language_overlay.dart`
* `lib/views/settings/settings_overlay.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/services/locale_manager.dart`
* `lib/main.dart`
* `lib/l10n/app_en.arb`
* `l10n.yaml`
* `test/language_overlay_test.dart`
* `test/locale_manager_test.dart`
* `test/menu_buttons_test.dart`
* `docs/specs/2026-11-03-app-localization.md`
