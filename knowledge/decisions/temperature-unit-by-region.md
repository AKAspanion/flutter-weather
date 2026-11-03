---
type: Decision
title: Temperatures show in °C or °F, defaulting to the phone's region
description: The user picks °C or °F in settings; until they do, the phone's region decides (°F in the handful of countries that use it), and the app and the widget both follow it.
status: draft
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T08:37:08Z }
---

# Temperatures show in °C or °F, defaulting to the phone's region

## Context

Every temperature was shown in °C. Users in the US, the app's largest Fahrenheit market, had no way to switch.

## Decision

The developer chose on 2026-11-03 a °C | °F choice in the [settings panel](settings-panel.md), saved on the device.
With nothing saved, or a value the app can't read, the phone's region decides: °F when the region is one of `US`,
`BS`, `BZ`, `KY`, `LR`, `PW`, `FM`, `MH` (the countries that use Fahrenheit day to day), °C everywhere else. Following
the region was chosen over "always °C" so most US users never need to open settings.

Every temperature follows it: the current weather, the hourly chips, the daily cards, and the home-screen widget,
whose background refresh reads the saved choice the same way it reads the language. Weather is still stored in Kelvin
([data model](../data/model.md)); only display converts.

## Consequences

- Wind stays in m/s whatever the unit; a wind unit would be another row in the same panel.
- Rounding stays as it was (floor), in both units.

## Sources

* `docs/specs/2026-11-03-settings-menu.md`
* `lib/services/providers/weather_provider.dart`
* `lib/services/weather_widget.dart`
