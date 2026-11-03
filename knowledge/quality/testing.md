---
type: Test Strategy
title: Tests
description: Unit and widget tests in test/ for provider failover, translations, dates, the language picker, the menu buttons and the widget payload, and a test-harness tool that renders the widget icons.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Tests

## What is tested

`test/weather_service_test.dart`, unit tests with `flutter_test`:

- [Provider failover](../domain/provider-failover.md): falling over to the next provider, trying the last working
  provider first, parking failed ones, trying parked ones as a last resort, throwing when all fail, geocoding for
  providers without city search, naming coordinate results, and skipping providers without a key. It uses
  `FakeProvider` and `FakeGeocoderProvider`, defined in the test file.
- `dailyFromSeries` grouping readings by local day.
- `WeatherReport` surviving a round trip through the cache's JSON format.

Translation tests, one file per subject:

- `test/arb_files_test.dart`: each of the nine drafted `.arb` files has its locale, the `@@x-reviewed: false` marker,
  the English keys and placeholders, a translated value (not the English one), and a matching widget `strings.xml`.
- `test/conditions_test.dart`: `describeCondition`: every code, then the group fallback, then "Unknown".
- `test/dates_test.dart`: the weekday, date line and time formats in other languages.
- `test/locale_manager_test.dart`: saving, restoring and resolving the language, including a store that fails.
- `test/language_overlay_test.dart`, `test/menu_buttons_test.dart` and `test/hourly_detail_chip_test.dart`: the
  language list, the menu's button row (including narrow screens) and the hourly chip's height with fallback fonts.
- `test/weather_widget_test.dart`: the text `WeatherWidget.payload` pushes to the home-screen widget, per language.

`test/weather_service_test.dart` also checks that an unnamed place keeps an empty name.

The providers' parsing of real responses and ads are not covered by the tests. The right-to-left look and the
Kotlin widget code are checked on an emulator, not by a test.

`tool/render_widget_icons_test.dart` is not a test. It is a tool that uses the test harness to render the Flare icons
to PNGs, and it writes files into `android/`. It sits outside `test/`, so the test command doesn't run it
([run locally](../operations/run-locally.md)).

## How to run it

The policy's `checks.commands.test` (`ga.mjs workflow show`), run by hand.

## History

- 2026-11-03: the tests covered the service layer only; now also the translations, dates, language picker, menu buttons and widget payload, because the app was translated. See [gen_l10n decision](../decisions/app-localization-gen-l10n.md).

## Sources

* `test/weather_service_test.dart`
* `test/arb_files_test.dart`
* `test/conditions_test.dart`
* `test/dates_test.dart`
* `test/locale_manager_test.dart`
* `test/language_overlay_test.dart`
* `test/menu_buttons_test.dart`
* `test/hourly_detail_chip_test.dart`
* `test/weather_widget_test.dart`
* `tool/render_widget_icons_test.dart`
* `pubspec.yaml`
