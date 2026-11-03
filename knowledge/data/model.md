---
type: Data Model
title: Weather data model
description: Weather, WeatherReport, Place and WeatherQuery, and the normalised units every provider converts to.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Weather data model

There is no database. The app's data is the weather report it fetches. It keeps the last one on the device
([on-device storage](on-device-storage.md)).

## Entities

- **`Weather`** (`lib/services/weather.dart`): one reading, either the current conditions, one forecast hour or one
  forecast day. Every field is nullable. It has the place name, a time (`date`, epoch seconds), the place's
  `timezone` (UTC offset in seconds), `sunrise` and `sunset`, `humidity`, a `condition` code, `latitude` and
  `longitude`, `windSpeed`, `temperature` (for current and hourly readings), `tempMin` and `tempMax` (for days), and
  `description`. `getIcon` turns the condition into an icon name ([condition icons](../domain/condition-icons.md)).
- **`WeatherReport`** (`lib/services/providers/weather_provider.dart`): what a provider returns. It holds `current`,
  the `hourly` and `daily` lists, `source` (the provider's name) and `attribution` (the text the provider's terms ask
  the app to show).
- **`Place`** (`lib/services/providers/weather_provider.dart`): a name and coordinates, returned by a `Geocoder`.
- **`WeatherQuery`** (`lib/services/weather_cache.dart`): what the user last asked for, either a city or coordinates.
  It is saved so the widget can refresh the same place in the background.
- **`Location`** (`lib/services/location.dart`): wraps the `WeatherReport` the views show, with `getWeather`,
  `getHourly`, `getDaily` and `attribution`.

## Relations

A `WeatherReport` has one current `Weather` and lists of hourly and daily `Weather`. A `Location` wraps at most one
`WeatherReport`. A `WeatherQuery` produces a `WeatherReport` through `WeatherService`.

**Normalised units.** The doc comment on `WeatherReport` says every provider converts its answer to temperatures in
Kelvin, wind in m/s, and OpenWeatherMap condition codes, because that is what the UI expects. Celsius values are
converted with `kelvinOffset`. `formatTemperature` turns Kelvin into °C or °F for display, as the user chose ([settings](../features/settings.md)). `windSpeed` is a string, formatted by
`formatWind`.

**Days from a series.** Providers without a daily forecast (OpenWeatherMap, MET Norway) build days with
`dailyFromSeries`. It groups readings by local day and takes the condition from the reading closest to midday. It
uses the minimum and maximum temperature, the highest wind and the average humidity. Later days reuse today's sunrise
and sunset, shifted by whole days.

**Serialisation.** `Weather` and `WeatherReport` have `toJson` and `fromJson`. The cache uses them, and a test checks
the round trip ([testing](../quality/testing.md)).

## Sources

* `lib/services/weather.dart`
* `lib/services/providers/weather_provider.dart`
* `lib/services/weather_cache.dart`
* `lib/services/location.dart`
* `lib/services/weather_service.dart`
