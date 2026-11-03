---
type: Integration
title: MET Norway
description: Last provider by default and the only keyless one; locationforecast plus the sunrise API, by coordinates only.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# MET Norway

## What it is used for

- Weather: `MetNorwayProvider` in `lib/services/providers/met_norway.dart` calls the compact locationforecast. Then,
  separately, it calls the sunrise API for today's sunrise and sunset. If that call fails, sunrise and sunset stay
  empty: a comment calls them a nice-to-have, and says polar day and night responses have no times. Days are built
  with `dailyFromSeries` ([data model](../data/model.md)).
- Coordinates only (`supportsCitySearch` is false). For a city, the service geocodes first with another provider
  ([provider failover](../domain/provider-failover.md)). So with no other provider configured, city search doesn't
  work.
- Conversions: MET symbol codes become OpenWeatherMap codes (`_conditionCode`) and readable text (`_describe`).
  Responses have no place name or timezone; the service supplies both.

## Configuration

- No key. The doc comment says MET Norway is free, allows commercial use with attribution, and needs an identifying
  `User-Agent` and coordinates with at most four decimals. Both are set in the provider (`_headers`, and
  `toStringAsFixed` in `fetchByCoords`).
- Attribution: `attribution` in the provider (CC BY 4.0).

## Failure modes

- A non-200 status or a timeout on the forecast throws `ProviderException`. A forecast with no usable entries also
  throws.

## Sources

* `lib/services/providers/met_norway.dart`
* `lib/services/weather_service.dart`
