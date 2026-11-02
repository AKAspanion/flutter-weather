---
type: Feature
title: See the forecast
description: A panel that slides up with the next 48 hours as expandable chips and the next days as expandable cards.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# See the forecast

## What it does

The chart button on the main card opens `Forecast`, which slides up over everything. It shows:

- **Next hours:** a horizontal list of `HourlyDetail` chips from `WeatherReport.hourly`. Each shows the time, an
  icon and the temperature. Tapping a chip expands it to show wind and humidity.
- **Next days:** a `DailyDetail` card per entry in `WeatherReport.daily`. Each shows the day, an icon and the minimum
  and maximum. Tapping a card expands it in the accent gradient with sunrise, wind and humidity.
- The provider's attribution at the end.

How many hours and days there are, and how far apart they are, depends on the provider that answered (see each
integration). For example, OpenWeatherMap steps by 3 hours.

## Screens and routes

- `lib/views/forecast/forecast.dart` (`Forecast`)
- `lib/views/forecast/hourly.dart` (`HourlyView`) and `lib/views/forecast/hourly_detail_chip.dart` (`HourlyDetail`)
- `lib/views/forecast/daily_detail_card.dart` (`DailyDetail`)
- `toggleForecast` in `lib/main.dart`

## Rules

- The panel's content is built only while it is open (`isForecastMounted` in `lib/main.dart`, `showContent` in
  `Forecast`). It is unmounted after the panel slides away. Comments say this stops its animated icons from running
  off screen.
- Both lists are built lazily with `ListView.builder`. Comments say this is so off-screen icons cost nothing.
- Hourly chips use the same night rule as the widget ([condition icons](../domain/condition-icons.md)).

## Sources

* `lib/views/forecast/forecast.dart`
* `lib/views/forecast/hourly.dart`
* `lib/views/forecast/hourly_detail_chip.dart`
* `lib/views/forecast/daily_detail_card.dart`
* `lib/main.dart`
