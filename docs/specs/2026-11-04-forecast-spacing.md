# Even, tighter spacing in the forecast panel

Date: 2026-11-04. Branch: `feat/forecast-spacing`.

## Why

On a phone, the forecast panel's vertical gaps were uneven and loose. The developer marked two pairs on a screenshot:
the gaps above each section title (O) should be equal and smaller, and the gaps between each subtitle and its list (X)
should be equal and small.

## The gaps (dp)

| Gap | What makes it up today | Today | New |
|---|---|---|---|
| O₁: the close button's row → "NEXT HOURS" | list top padding 16 + title top 40 | 56 | 32 |
| O₂: hourly chips → "NEXT DAYS" | strip bottom padding 16 + chip bottom margin 12 + title top 48 | 76 | 32 |
| X₁: hours subtitle → chips | subtitle bottom 16 + strip top padding 16 + chip top margin 12 | 44 | 16 |
| X₂: days subtitle → first day card | subtitle bottom 8 + card top margin 12 | 20 | 16 |

## What changes

All in `lib/views/forecast/`:

- `HourlyView` (`hourly.dart`) loses its 16 vertical padding, and its height goes from 196 to 164, so the chips keep
  the same room. The chips' own 12 top and bottom margins stay: they leave room for the chips' shadows.
- In `forecast.dart`, the section title gaps and subtitle gaps become named constants, so the pairs can't drift apart:
  - "NEXT HOURS" top 16 (O₁ = the list's 16 top padding + 16);
  - "NEXT DAYS" top 20 (O₂ = the chip's 12 bottom margin + 20);
  - both subtitles bottom 4 (X₁ = 4 + the chip's 12 top margin; X₂ = 4 + the day card's 12 top margin).
- Nothing else moves: the close button, the subtitles' 4 top gap, the cards, the attribution.

## Testing

Test first: a widget test pumps `Forecast` with a fake report and measures, on screen:

- O₁ (bottom of the close button's row to the top of "NEXT HOURS") and O₂ (bottom of the first chip's card to the top
  of "NEXT DAYS") are both 32, within 1 dp;
- X₁ (bottom of the hours subtitle to the top of the first chip's card) and X₂ (bottom of the days subtitle to the top
  of the first day card) are both 16, within 1 dp.

`test/hourly_detail_chip_test.dart`'s no-overflow cases keep passing with the 164 strip. At the end: `flutter analyze`,
then a look on the emulator and the phone.

## Out of scope

- The gap between the close button and the top of the screen (the camera cutout area).
- The gaps between cards, which matched in `docs/specs/2026-11-04-forecast-center-on-tap.md`.
