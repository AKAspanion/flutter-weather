---
type: Feature
title: See the forecast
description: A panel that slides up with the next 48 hours as expandable chips and the next days as expandable cards.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# See the forecast

## What it does

The chart button on the main card opens `Forecast`, which slides up over everything. It shows:

- **Next hours:** a horizontal list of `HourlyDetail` chips from `WeatherReport.hourly`. Each shows the time, an
  icon and the temperature in the chosen unit. Tapping a chip expands it to show wind and humidity.
- **Next days:** a `DailyDetail` card per entry in `WeatherReport.daily`. Each shows the day, an icon and the minimum
  and maximum in the chosen unit. Tapping a card expands it in the accent gradient with sunrise, wind and humidity.
  Day cards are 24 apart, the same gap as the hourly chips (`DailyDetail` margin 24 at the sides, 12 above and below).
- **Centring:** tapping a chip or card open scrolls its own list, and only that list (the panel around the hourly strip
  stays put), so the visible card is centred. It waits until the card has finished expanding (each card's
  `AnimatedContainer` `onEnd`) and uses `centreInList`; closing a card doesn't scroll. At a list's ends the first and
  last cards go as near the centre as the list allows.
- The provider's attribution at the end.

Temperatures follow the unit chosen in [settings](settings.md) (`formatTemperature`); a missing temperature shows `--`.
All text and dates follow the chosen language ([language picker](language-picker.md)): time of day in the language's own
style ("5:00 AM", "05:00"), the weekday and the date line from `lib/l10n/dates.dart`, and descriptions from the
condition code. In Arabic and Urdu the lists and chips run right to left.

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
- Hourly chip text rows are forced to Montserrat's line height with a strut (`height: 1.219`). Time labels in other
  scripts, or with intl's narrow no-break space before AM/PM, fall back to a taller system font, which overflowed the
  chip by a few pixels; `test/hourly_detail_chip_test.dart` covers it.
- Hourly chips pick day or night icons from their own hour, not the current time ([condition icons](../domain/condition-icons.md)).

- **Even spacing.** The gap above each section title is the same (32), and so is the gap between each subtitle and its
  first card (16). The pieces are named constants at the top of `lib/views/forecast/forecast.dart`
  (`_hoursTitleTop`, `_daysTitleTop`, `_subtitleBottom`), and `test/forecast_spacing_test.dart` measures the four gaps,
  so a change to one side of a pair shows up as a failing test.

## History

- 2026-11-04: the gaps above the two titles were 56 and 76 and below the subtitles 44 and 20; now 32 and 32, 16 and
  16, because the developer marked them as uneven on a phone. See `docs/specs/2026-11-04-forecast-spacing.md`.
- 2026-11-04: day cards were 48 apart in the list (24 margin on every side of each card); now 24, the same gap as the hourly chips, because the two lists should space their cards alike. See [spec](../../docs/specs/2026-11-04-forecast-center-on-tap.md).
- 2026-11-04: a tapped chip or card stayed where it was; now it scrolls its own list to the centre once it has expanded (`centreInList`), because an expanded card could sit half off screen. See [spec](../../docs/specs/2026-11-04-forecast-center-on-tap.md).
- 2026-11-03: temperatures were always °C; now they follow the unit chosen in settings, because the app can show °F. See [temperature unit](../decisions/temperature-unit-by-region.md).
- 2026-11-03: text and dates were English, with a hand-written calendar (`lib/services/calendar.dart`, removed); now `intl` formats in the chosen language and chip text rows use a forced line height, because the app is translated and fallback fonts overflowed the chips. See [supported languages](../decisions/supported-languages.md).

## Sources

* `lib/views/forecast/forecast.dart`
* `lib/views/forecast/hourly.dart`
* `lib/views/forecast/hourly_detail_chip.dart`
* `lib/views/forecast/daily_detail_card.dart`
* `lib/main.dart`
* `lib/components/centre_in_list.dart`
* `lib/l10n/dates.dart`
* `lib/services/unit_manager.dart`
* `test/hourly_detail_chip_test.dart`
* `test/forecast_spacing_test.dart`
* `test/centre_in_list_test.dart`
