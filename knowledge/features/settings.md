---
type: Feature
title: Settings panel
description: A gear in the menu's button row opens a panel with a Theme toggle, Language, a °C | °F temperature toggle and Rate on Google Play; every future setting is a row there.
status: draft
generated: { by: after-finish/claude-sonnet-5-5, at: 2026-11-03T14:40:00+05:30 }
---

# Settings panel

## What it does

The gear (`Icons.settings`) in the menu's top button row, where the translate button used to be, opens `SettingsOverlay`:
built on the shared `OverlayCard` ([decision](../decisions/overlays-share-one-card.md)): a dimmed full-screen layer with
a centred card, the translated "Settings" as its title at the start and the close button at the end. It has one row per
setting:

- **Theme.** A ☀ | ☾ toggle (`SegmentedChoice<AppTheme>`, with "Light" and "Dark" as semantic labels); the current theme is
  filled with the accent colour. Tapping the other one calls `ThemeManager.setTheme`, which sets the override
  [decisions/theme-follows-system](../decisions/theme-follows-system.md) describes: it holds until the system brightness
  changes ([themes and accents](themes-and-accents.md)).
- **Language.** Shows the current language in its own script, or "System default", in bold on an accent-filled chip
  drawn exactly like the selected segment of the toggles: the fill made readable on the card, the label white or
  near-black, whichever reads better on it ([design tokens](../design-system/tokens.md)). The chip is at most half the
  card wide, so a long name ends in "…". Tapping the row opens the language picker above the panel. Closing or choosing in the picker returns to the panel.
- **Temperature.** A °C | °F toggle; the current unit is filled with the accent colour. Tapping the other unit applies
  it at once, so the card, the forecast and the home-screen widget all change ([current weather](current-weather.md),
  [forecast](forecast.md), [widget](home-screen-widget.md)). The panel stays open so the change can be seen.
- **Rate on Google Play.** Opens the app's store page; if neither address opens, a snackbar says so
  ([decision](../decisions/rate-via-play-store-page.md)).

The close button in the header closes the panel; there is no close at the bottom.

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

## History

- 2026-11-04: the language chip was the raw accent with white text, which was unreadable on pale accents and could
  overflow the row on a narrow phone; now it uses the toggles' fill and label rules and is capped at half the card,
  because the device round found accent colours unreadable on the dark card.
- 2026-11-03: the Language row showed its value as plain accent-coloured text; now a white bold label on an accent
  chip like the Theme and Temperature toggles, because the developer found the accent text unreadable on the dark card.
- 2026-11-03: the panel had Language, Temperature and Rate, its own card width and a close button at the bottom; now it
  also has the Theme row (moved out of the menu's button row) and is built on `OverlayCard` with the close in the header,
  because the developer wanted every choice in settings and one look for every overlay. See
  [overlays share one card](../decisions/overlays-share-one-card.md).

## Sources

* `lib/components/overlay_card.dart`
* `lib/components/segmented_choice.dart`
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
* `docs/specs/2026-11-03-overlay-consistency.md`
