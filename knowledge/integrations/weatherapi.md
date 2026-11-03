---
type: Integration
title: WeatherAPI.com
description: Second provider by default; current weather and a 3-day hourly forecast in one call, city search and geocoding. Needs WEATHERAPI_KEY.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# WeatherAPI.com

## What it is used for

- Weather: `WeatherApiProvider` in `lib/services/providers/weather_api.dart` calls the forecast endpoint once, with
  air quality and alerts turned off (`_fetch`). Hourly entries start from an hour ago. Days come straight from the
  response.
- City search: by name directly.
- Geocoding: it implements `Geocoder` through the search endpoint, for both `search` and `reverse`.
- Conversions: °C to Kelvin, km/h to m/s, and WeatherAPI condition codes to OpenWeatherMap ones (`_conditionCode`).
  The UTC offset comes from the difference between the response's local time and epoch, rounded to 15 minutes
  (`_utcOffset`). Sunrise and sunset come from the "06:45 AM" style text (`_localTimeToEpoch`). They are null when
  the text isn't a time, as near the poles.

## Configuration

- Key: `WEATHERAPI_KEY`, read in `lib/config/api_keys.dart`. When it is blank the provider is skipped
  ([environment](../operations/environment.md)).

## Failure modes

- A non-200 status or a timeout throws `ProviderException`, and the service moves on
  ([provider failover](../domain/provider-failover.md)).

## Sources

* `lib/services/providers/weather_api.dart`
* `lib/config/api_keys.dart`
