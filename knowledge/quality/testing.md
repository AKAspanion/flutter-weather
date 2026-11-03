---
type: Test Strategy
title: Tests
description: Unit tests for provider failover, the theme, the widget service and the widget resources in test/, and a test-harness tool that renders the widget icons.
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

The widget and the theme have their own tests:

- `test/weather_widget_test.dart`: `WeatherWidget` against mocked `home_widget` and pin channels. `update` saves the
  city, now and updated but not hours, `setAccent` saves the index and updates the widget, `pin` goes through the
  `in.spanion.weather/widget` channel and not `home_widget`, and each carries on when the channel fails and does
  nothing off Android.
- `test/theme_manager_test.dart`: `resolveTheme` and `ThemeManager`, following the system, keeping an override set
  against the current brightness, and dropping one set against the other
  ([decisions/theme-follows-system](../decisions/theme-follows-system.md)).
- `test/widget_icon_resources_test.dart`: every icon has an endless animation list of at least two frames whose PNGs
  exist, a layout with one indeterminate `ProgressBar`, an `iconLayoutFor` entry in the provider, and the frames
  together stay under 1.5 MB.
- `test/widget_layout_resources_test.dart`: reads the Kotlin and XML as text to hold the layout rules: no ellipsis in
  the compact layout, its details row, `WIDE_WIDTH`, `DETAILS_WIDTH`, `STRIP_HEIGHT` and `MINI_WIDTH`, the stacked
  arrangement's ids, the mini layout, and the launcher's 40dp minimum resize.

The tests cover the service layer, the theme, and what the widget's resources promise. They don't render the widget
or run the provider: how a launcher lays it out and whether it animates the `ProgressBar` is checked on a device. The
views, the providers' parsing of real responses and ads are not covered.

`tool/render_widget_icons_test.dart` is not a test. It is a tool that uses the test harness to render the Flare icons
to PNGs, and it writes files into `android/`. It sits outside `test/`, so the test command doesn't run it
([run locally](../operations/run-locally.md)).

## How to run it

The policy's `checks.commands.test` (`ga.mjs workflow show`), run by hand.

## Sources

* `test/weather_service_test.dart`
* `test/weather_widget_test.dart`
* `test/theme_manager_test.dart`
* `test/widget_icon_resources_test.dart`
* `test/widget_layout_resources_test.dart`
* `tool/render_widget_icons_test.dart`
* `pubspec.yaml`
