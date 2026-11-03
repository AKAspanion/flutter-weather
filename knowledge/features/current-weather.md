---
type: Feature
title: See the current weather
description: At launch the app shows the last report at once, then fetches fresh weather for the device location or the saved city; refresh does the same.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# See the current weather

## What it does

The main card shows the place name, date, an animated icon, the temperature in °C, the description, and chips for
sunrise, wind and humidity. Under them is the provider's attribution.

1. **Launch.** `_loadCachedReport` shows the last saved report straight away, if there is one and nothing newer has
   arrived yet. Then `getLocation` fetches fresh weather. While it runs, the spinner shows only if there is no cached
   report (`loading && location.getWeather() == null` in `lib/main.dart`).
2. **Which place.** If `city_preference` is set, the app fetches that city ([city search](city-search.md)).
   Otherwise `Location.currentPosition` asks for permission when it is denied. It uses the last known fix if that is
   recent enough (`_maxLastKnownAge`), or waits a limited time for a new one. A comment says the recent fix makes
   start-up instant.
3. **Fetch.** `WeatherQuery.fetch` goes through [provider failover](../domain/provider-failover.md).
4. **Show.** `_showReport` swaps in the new report and replays the card's entrance animation. The report is also
   saved and sent to the [widget](home-screen-widget.md).
5. **Failure.** If every provider fails or there is no position: with a report already on screen, a snackbar says
   the update failed and the last result stays. With none, `ErrorView` shows an error message.

The refresh button (top left, shown while the menu is open) clears `city_preference` and fetches again. So refresh
always returns to the device location.

## Screens and routes

- `lib/views/home/home.dart` (`Home`): the card, the menu button (`Hamburger`) and the forecast button. The forecast
  button is disabled while loading or while the menu is open.
- `lib/views/weather/weather_screen.dart` (`LocationScreen`): chooses between the spinner, `ErrorView` and
  `LocationView`.
- `lib/views/weather/weather_view.dart` (`LocationView`) and `lib/views/weather/weather_detail_chip.dart`.
- The state and actions are in `lib/main.dart` (`getLocation`, `onRefresh`, `_loadCachedReport`, `_showReport`).

## Rules

- Temperatures are stored in Kelvin and shown in °C, rounded down ([data model](../data/model.md)).
- The icon depends on the condition code and whether it is night at the place
  ([condition icons](../domain/condition-icons.md)).
- The provider's attribution is always shown with its data. The doc comment on `WeatherReport.attribution` says the
  providers' terms ask for this.

## Sources

* `lib/main.dart`
* `lib/services/location.dart`
* `lib/services/weather_cache.dart`
* `lib/views/home/home.dart`
* `lib/views/weather/weather_screen.dart`
* `lib/views/weather/weather_view.dart`
* `lib/views/weather/weather_detail_chip.dart`
* `lib/views/weather/weather_error.dart`
* `lib/services/providers/weather_provider.dart`
