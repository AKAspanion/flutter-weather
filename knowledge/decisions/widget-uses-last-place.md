---
type: Decision
title: The widget refreshes the last place viewed, without background location
description: The background widget refresh reuses the last query saved by the app instead of asking for the device's location in the background.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# The widget refreshes the last place viewed, without background location

## Context

The home-screen widget refreshes in the background ([home-screen widget](../features/home-screen-widget.md)). Using
the current position there would need background location access.

## Decision

The refresh fetches the `WeatherQuery` the app last saved (`WeatherCache.loadQuery`). The doc comment on
`WeatherWidget.scheduleRefresh` says background location is deliberately not used. `privacy.md` tells users the same.
Commit `01da471` describes it as "for the last viewed place (no background location)".

## Consequences

- The app asks only for location while it is open ([data protection](../security/data-protection.md)).
- When the user moves without opening the app, the widget keeps showing the last place they viewed.
- Until the app has fetched once, there is no saved query, and the background task does nothing.

## Sources

* `lib/services/weather_widget.dart`
* `lib/services/weather_cache.dart`
* `privacy.md`
