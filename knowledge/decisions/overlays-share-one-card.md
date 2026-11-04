---
type: Decision
title: Overlays share one card, closed from the top end
description: The city dialog, the language picker and the settings panel are built on one OverlayCard, with the title at the top start and the close button at the top end, and choices marked the same way.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T09:40:00Z }
verified: human:panditankit1995@gmail.com
---

# Overlays share one card, closed from the top end

## Context

Tried on a phone, the three overlays each had their own width, title and close position: the city dialog and the
language and settings panels closed from the bottom, while the forecast panel closes from the top right.

## Decision

The developer chose on 2026-11-03 one design language for the overlays: a shared `OverlayCard` with one width
(`size.width - 64`), one card style, the title upper-cased at the top start, and the close button at the **top end**
on every overlay, matching the forecast panel. A choice between a few values is a two-part toggle filled with the
accent colour (`SegmentedChoice`, used by the theme and the temperature unit); a choice from a list is marked with an
accent check. The city dialog submits from a ✓ inside its field and the keyboard's done key, so it needs no bottom
row.

Restyling the menu buttons, the forecast panel and the home card was left out: the forecast already closes from the
top right.

## Consequences

- A new overlay starts from `OverlayCard` and gets the header and close for free.
- Start and end mirror in Arabic and Urdu, so the close sits top left there.

## Sources

* `docs/specs/2026-11-03-overlay-consistency.md`
* `lib/components/overlay_card.dart`
* `lib/components/segmented_choice.dart`
* `lib/views/home/dialog_overlay.dart`
* `lib/views/home/language_overlay.dart`
* `lib/views/settings/settings_overlay.dart`
* `lib/views/forecast/forecast.dart`
