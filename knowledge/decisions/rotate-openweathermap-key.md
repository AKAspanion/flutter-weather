---
type: Decision
title: Rotate the OpenWeatherMap key and remove the bundled fallback
description: The committed key is to be rotated, the new one passed only through keys.json, and the fallback removed so OpenWeatherMap is skipped without a key.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:30:34Z }
status: draft
---

# Rotate the OpenWeatherMap key and remove the bundled fallback

## Context

`ApiKeys.openWeatherMap` in `lib/config/api_keys.dart` falls back to a key written in the code, which has been in git
history since 2020 ([finding](../findings/committed-openweathermap-key.md)).

## Decision

The developer decided on 2026-11-03:

1. Rotate the key in the OpenWeatherMap console, so the committed one stops working.
2. Pass the new key only through `keys.json` (`OPENWEATHERMAP_KEY`), like the other providers
   ([environment](../operations/environment.md)).
3. Remove the fallback from `lib/config/api_keys.dart`. Without a key, `OpenWeatherMapProvider.isConfigured` is false
   and the provider is skipped, as WeatherAPI.com and Tomorrow.io already are.

## Consequences

- Builds without `keys.json`, debug runs included, get weather from MET Norway alone, and city search stops working
  because MET Norway needs a geocoder ([MET Norway](../integrations/met-norway.md)). Developers need a `keys.json`
  to work on city search.
- Release builds must pass `OPENWEATHERMAP_KEY`, or the shipped app loses its first provider and its geocoder.
- The README's "blank values fall back to … the bundled OpenWeatherMap key" changes with the code.
- The finding stays open until the code change lands.

## Sources

* `lib/config/api_keys.dart`
* `lib/services/providers/openweathermap.dart`
* `lib/services/providers/met_norway.dart`
* `README.md`
