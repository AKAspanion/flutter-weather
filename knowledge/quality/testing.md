---
type: Test Strategy
title: Tests
description: Unit tests for provider failover and report aggregation in test/, and a test-harness tool that renders the widget icons.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
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

The tests cover the service layer. The views, the providers' parsing of real responses, the widget and ads are
not covered by them.

`tool/render_widget_icons_test.dart` is not a test. It is a tool that uses the test harness to render the Flare icons
to PNGs, and it writes files into `android/`. It sits outside `test/`, so the test command doesn't run it
([run locally](../operations/run-locally.md)).

## How to run it

The policy's `checks.commands.test` (`ga.mjs workflow show`), run by hand.

## Sources

* `test/weather_service_test.dart`
* `tool/render_widget_icons_test.dart`
* `pubspec.yaml`
