---
type: Integration
title: OpenWeatherMap
description: First provider by default; current weather plus the 5-day / 3-hour forecast, city search, and geocoding both ways.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# OpenWeatherMap

## What it is used for

- Weather: `OpenWeatherMapProvider` in `lib/services/providers/openweathermap.dart` calls the current-weather and
  5 day / 3 hour forecast endpoints at the same time. The paths are in `_fetch`. A comment says the One Call 2.5 API
  the app used before was retired in 2024. Hourly entries are the first forecast steps, 3 hours apart. Days are built
  with `dailyFromSeries` ([data model](../data/model.md)).
- City search: by name directly (`supportsCitySearch`).
- Geocoding: it implements `Geocoder` with the direct and reverse geocoding endpoints (`search`, `reverse`). The
  service uses it to name coordinates and to find cities for MET Norway
  ([provider failover](../domain/provider-failover.md)).
- Its responses include the place's timezone, which the app uses. Its condition codes are the app's own
  ([condition icons](../domain/condition-icons.md)).

## Configuration

- Key: `OPENWEATHERMAP_KEY`, read in `lib/config/api_keys.dart` ([environment](../operations/environment.md)). When
  it is blank, a key written in that file is used instead, so this provider is always configured. See
  [findings/committed-openweathermap-key](../findings/committed-openweathermap-key.md).
- Attribution text: `attribution` in the provider.

## Failure modes

- A non-200 status or a timeout throws `ProviderException` (`getJson`), and the service moves on.
- Geocoding that finds nothing returns null, and the service tries the next geocoder.

## Sources

* `lib/services/providers/openweathermap.dart`
* `lib/services/providers/weather_provider.dart`
* `lib/config/api_keys.dart`
