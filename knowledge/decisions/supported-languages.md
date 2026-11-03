---
type: Decision
title: The app speaks the ten most spoken languages, chosen in the app
description: English, Chinese, Hindi, Spanish, Arabic, French, Bengali, Portuguese, Russian and Urdu, plus System default, picked from a translate button in the menu's top row.
status: draft
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T07:29:23Z }
---

# The app speaks the ten most spoken languages, chosen in the app

## Context

With the app translatable ([gen_l10n](app-localization-gen-l10n.md)), it needed a first set of languages and a way
for a user to pick one.

## Decision

The developer chose on 2026-11-03 the ten most spoken languages in the world by total speakers, as ranked by
Ethnologue: English (`en`, the source and fallback), Chinese Simplified (`zh`), Hindi (`hi`), Spanish (`es`), Arabic
(`ar`), French (`fr`), Bengali (`bn`), Portuguese (`pt`), Russian (`ru`) and Urdu (`ur`). Some years Indonesian ranks
tenth instead of Urdu; Urdu was taken.

The language is picked from a translate button in the menu's top button row, between the widget and location
buttons: System default first, then each language in its own script. System default follows the phone's language when it is in the list, otherwise English.

## Consequences

- Arabic and Urdu are right to left, so the layout mirrors for them.
- Montserrat has no Devanagari, Bengali, Arabic or Han glyphs; Android's system fonts show those scripts.
- Android's own per-app language setting isn't wired up: the in-app picker is the way to choose.

## History

- 2026-11-03: the translate button was in the home screen's top row; now in the menu's top button row, with refresh
  and close in the far corners and the other buttons justified between them, because the developer wanted the home
  screen's top row kept as it was.

## Sources

* `docs/specs/2026-11-03-app-localization.md`
* `lib/main.dart`
* `lib/services/locale_manager.dart`
* `lib/views/menu/menu_buttons.dart`
