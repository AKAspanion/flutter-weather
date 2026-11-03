---
type: Decision
title: Every setting lives in one settings panel behind a gear
description: The menu's translate button became a gear that opens a settings panel (language, temperature unit, rate on Google Play); new settings are added there as rows, not as more menu buttons.
status: draft
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T08:37:08Z }
---

# Every setting lives in one settings panel behind a gear

## Context

The menu's top button row already holds six buttons (refresh, theme, widget, language, location, close), which shrink
together on a narrow phone. A temperature unit and a "rate the app" link needed a place, and each new setting would
otherwise cost another button.

## Decision

The developer chose on 2026-11-03 to replace the translate button with a gear (`Icons.settings`) in the same place.
It opens a full-screen settings panel laid out like the language and city dialogs, one row per setting: Language
(shows the current language and opens the existing language picker on top), Temperature (a °C | °F toggle) and Rate
on Google Play. **Every future setting goes into this panel as a row**, not into the menu's button row. A panel was
chosen over a bottom sheet or a separate page because it matches the app's other dialogs and needs no navigation.

The theme and accent stay where they are in the menu, and so does the PRIVACY button, which Google's consent rules
need the user to be able to find ([AdMob](../integrations/google-admob.md)).

## Consequences

- The menu's button row keeps five or six buttons, whatever settings are added.
- The language picker is one tap deeper than before.

## Sources

* `docs/specs/2026-11-03-settings-menu.md`
* `lib/views/menu/menu_buttons.dart`
* `lib/views/home/language_overlay.dart`
