---
type: Business Rule
title: Weather provider failover
description: WeatherService tries the providers in turn, the last one that worked first, parks failing ones for a cooldown, skips unconfigured ones, and geocodes cities for providers that need coordinates.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Weather provider failover

## Rule

The app gets its weather from whichever provider answers first, so one broken or rate-limited service doesn't break
the app. The commit that added this (`01da471`) says the forecast had been broken in production because
OpenWeatherMap retired its One Call 2.5 API.

1. **Which providers.** `WeatherService.withDefaultProviders` lists them in their default order. A provider whose
   `isConfigured` is false (its API key is empty) is dropped when the service is created. Only MET Norway needs no
   key ([environment](../operations/environment.md)).
2. **Order.** The provider that last succeeded goes first (`_preferred`). A provider that failed less than
   `WeatherService.cooldown` ago is moved to the end. It is still tried if all the others fail.
3. **Failure.** Any exception counts as a failure: a non-200 status, a timeout in `getJson`, or a response that
   doesn't parse. The failure time is recorded and the next provider is tried. When all fail, a `ProviderException`
   lists each provider's error.
4. **City searches.** A provider with `supportsCitySearch` gets the city name directly. For the others, the service
   finds coordinates with the first `Geocoder` that answers (`_firstGeocoder`), only once per search, and passes
   them on. No geocoder finding the city counts as that provider failing.
5. **Place names.** A coordinates result with no place name is named by reverse geocoding, or "My location" if that
   fails. A city result with no name is named after the search text.
6. **Timezone.** For coordinates, the device's UTC offset is passed, because the user is there (a comment says so).
   For a geocoded city, the offset is estimated from the longitude. Providers whose responses include a timezone
   use their own.

The state (`_preferred`, `_failedAt`) lives only in memory, per `WeatherService` instance. The app keeps one for its
lifetime (`_weatherService` in `lib/main.dart`). The background widget refresh builds a new one each run, so it
always starts from the default order.

## Where it is enforced

- `lib/services/weather_service.dart`: `WeatherService`, `_ordered`, `_run`, `_firstGeocoder`, `fetchByCoords`,
  `fetchByCity`.
- `lib/services/providers/weather_provider.dart`: `WeatherProvider.isConfigured`, `supportsCitySearch`, `Geocoder`,
  `getJson` (status check and timeout).
- Tested in `test/weather_service_test.dart` ([testing](../quality/testing.md)).

## Sources

* `lib/services/weather_service.dart`
* `lib/services/providers/weather_provider.dart`
* `lib/main.dart`
* `lib/services/weather_widget.dart`
* `test/weather_service_test.dart`
