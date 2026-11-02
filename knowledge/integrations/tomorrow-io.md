---
type: Integration
title: Tomorrow.io
description: Third provider by default; hourly and daily forecast in one call, city search by name. Needs TOMORROW_IO_KEY.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Tomorrow.io

## What it is used for

- Weather: `TomorrowIoProvider` in `lib/services/providers/tomorrow_io.dart` calls the forecast endpoint once, for
  hourly and daily steps in metric units. The current conditions are the first hourly entry, with today's sunrise and
  sunset added.
- City search: by name directly. It is not a `Geocoder`.
- Conversions: Tomorrow.io weather codes become OpenWeatherMap codes (`_conditionCode`) and text (`_describe`).
  Responses have no timezone. For coordinates the device offset is used. For a city search the offset is estimated
  from the longitude (a comment says so). A doc comment says coordinate lookups come back without a place name, so
  the service names them ([provider failover](../domain/provider-failover.md)).

## Configuration

- Key: `TOMORROW_IO_KEY`, read in `lib/config/api_keys.dart`. When it is blank the provider is skipped
  ([environment](../operations/environment.md)).

## Failure modes

- A non-200 status or a timeout throws `ProviderException`. An empty hourly timeline also throws.

## Sources

* `lib/services/providers/tomorrow_io.dart`
* `lib/config/api_keys.dart`
