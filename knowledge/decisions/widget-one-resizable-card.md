---
type: Decision
title: One resizable widget that goes down to 2x2, showing only Now
description: The widget is a single picker entry that resizes from 4x2 down to 2x2, switching to a compact layout when narrow; the 24-hour page is dropped.
status: draft
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T07:29:19Z }
---

# One resizable widget that goes down to 2x2, showing only Now

## Context

Internal testing asked for a 2x2 card and for the widget to show only its first page, the current weather, without
the next 24 hours ([home-screen widget](../features/home-screen-widget.md)). A 2x2 card could be a second entry in
the widget picker with its own preview, or the same widget resized.

## Decision

- One widget provider, one entry in the picker. It still opens at 4x2, and resizes down to 2x2. Below full width it
  switches to a compact layout: the icon with the temperature, then the description and high/low as a subtitle, with
  no ellipsis; the sunrise / wind / humidity row stays at 3 cells and goes at 2.
- The widget shows only Now. The 24-hour page, the vertical swipe between pages, and the StackView that carried them
  go, so the card is one plain layout.

Chosen by the developer on 2026-11-03 as the simpler option: one thing to keep up, and the in-app button keeps adding
the 4x2 without asking which.

## Consequences

- A user who wants a 2x2 card adds the widget and shrinks it; there is no separate 2x2 entry.
- The app no longer sends the hourly entries to the widget.
- Without the StackView, the overhang and item-id workarounds it needed are gone.

## History

- 2026-11-03: the compact layout was for 2x2 only, with the full layout from 3 cells; now the full layout is for full
  width only and everything narrower is compact with no ellipsis, because on a Galaxy the 3-cell card ellipsized its
  text. See [the spec](../../docs/specs/2026-11-03-widget-testing-feedback.md).

## Sources

* `docs/specs/2026-11-03-widget-testing-feedback.md`
* `android/app/src/main/res/xml/weather_widget_info.xml`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
* `lib/services/weather_widget.dart`
