---
type: Feature
title: Settings panel
description: A gear in the menu's button row opens a panel with Language, a °C | °F temperature toggle and Rate on Google Play; every future setting is a row there.
status: draft
generated: { by: after-finish/claude-sonnet-5-5, at: 2026-11-03T14:40:00+05:30 }
---

# Settings panel

## What it does

The gear (`Icons.settings`) in the menu's top button row, where the translate button used to be, opens `SettingsOverlay`:
a dimmed full-screen layer with a centred card, laid out like the language list ([language picker](language-picker.md)).
Its title is the translated "Settings" and it has one row per setting:

- **Language.** Shows the current language in its own script, or "System default", and opens the language picker
  above the panel. Closing or choosing in the picker returns to the panel.
- **Temperature.** A °C | °F toggle; the current unit is filled with the accent colour. Tapping the other unit applies
  it at once, so the card, the forecast and the home-screen widget all change ([current weather](current-weather.md),
  [forecast](forecast.md), [widget](home-screen-widget.md)). The panel stays open so the change can be seen.
- **Rate on Google Play.** Opens the app's store page; if neither address opens, a snackbar says so
  ([decision](../decisions/rate-via-play-store-page.md)).

A close button closes the panel. The panel is `size.width - 64` wide, not the language list's `- 100`, because the
label and the toggle need the room.

## Screens and routes

- `lib/views/settings/settings_overlay.dart` (`SettingsOverlay`).
- `lib/views/menu/menu_buttons.dart` (`MenuButtons`): the gear, with the semantics label "Settings".
- `lib/main.dart`: `isSettingsOpen` and `toggleSettings`, `onRate` and `onUnitChanged`. `SettingsOverlay` comes after
  `DialogOverlay` and before `LanguageOverlay` in the `Stack`, so the picker shows above it.
- `lib/services/unit_manager.dart` (`UnitManager`, `formatTemperature`) and `lib/services/play_store.dart`
  (`PlayStore.openListing`). `UnitManager` is provided in `lib/main.dart` beside the theme and the language.
- The words are in `lib/l10n/app_<code>.arb`: `settings`, `temperature`, `rateOnGooglePlay`, `couldNotOpenPlayStore`.

## Rules

- **A new setting is a new row** in `SettingsOverlay`, not another menu button
  ([decision](../decisions/settings-panel.md)).
- The temperature unit is saved as `temperature_unit` (`celsius` or `fahrenheit`); with nothing saved the phone's
  region decides ([decision](../decisions/temperature-unit-by-region.md), [storage](../data/on-device-storage.md)).
- `onUnitChanged` runs only after `UnitManager.setUnit` has finished saving, because the widget's background code reads
  the saved value; it pushes the cached report to the widget, and does nothing when there is none.
- Tapping the unit that is already chosen does nothing.
- `°C` and `°F` are not translated.

## Sources

* `lib/views/settings/settings_overlay.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/services/unit_manager.dart`
* `lib/services/play_store.dart`
* `lib/main.dart`
* `lib/l10n/app_en.arb`
* `test/settings_overlay_test.dart`
* `test/unit_manager_test.dart`
* `test/play_store_test.dart`
* `test/menu_buttons_test.dart`
* `docs/specs/2026-11-03-settings-menu.md`
