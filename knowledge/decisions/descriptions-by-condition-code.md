---
type: Decision
title: Weather descriptions are shown from the condition code, translated
description: The description on screen and on the widget is a translated phrase per OpenWeatherMap condition code, not the provider's English text.
status: draft
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T07:29:23Z }
---

# Weather descriptions are shown from the condition code, translated

## Context

Descriptions such as "light rain" came from each provider in English: OpenWeatherMap's own text, and English tables
in our code for Tomorrow.io and MET Norway. They couldn't be translated, and they read differently from one provider
to the next. Every provider already maps its conditions to OpenWeatherMap codes
([condition codes](../domain/condition-icons.md)).

## Decision

The developer chose on 2026-11-03 to show a translated phrase per OpenWeatherMap condition code. Every code
OpenWeatherMap documents has its own phrase; a code without one falls back to its group's phrase (thunderstorm,
drizzle, rain, snow, mist, clouds), and a missing code to "Unknown".

## Consequences

- All providers read the same, in every language. The wording can differ a little from OpenWeatherMap's own text.
- `Weather.description` stays in the model and the cache so older cached reports still load, but isn't shown.

## Sources

* `docs/specs/2026-11-03-app-localization.md`
* `lib/services/weather.dart`
* `lib/services/providers/openweathermap.dart`
* `lib/services/providers/tomorrow_io.dart`
* `lib/services/providers/met_norway.dart`
