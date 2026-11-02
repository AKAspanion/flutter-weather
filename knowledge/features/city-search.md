---
type: Feature
title: Look up a city
description: The location button opens a dialog where the user types a city; the app remembers it until refresh switches back to the device location.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Look up a city

## What it does

The location button (top right, shown while the menu is open) opens `DialogOverlay`. When the user confirms a city
name, `onSubmit` saves it as `city_preference` and calls `getLocation`, which fetches `WeatherQuery.city`. The city
stays chosen across launches. Pressing refresh clears it and goes back to the device location
([current weather](current-weather.md)).

How a city is resolved depends on the provider: some search by name, and the others need the city geocoded to
coordinates first. See [provider failover](../domain/provider-failover.md).

## Screens and routes

- `lib/views/home/dialog_overlay.dart` (`DialogOverlay`): a text field with cancel and done buttons, over a dimmed
  background.
- `lib/main.dart`: `toggleDialog`, `onSubmit`, `setCity` and `getCity`.

## Rules

- The text is submitted as typed. The dialog doesn't trim it or check it for empty. An empty submit saves an empty
  `city_preference`, so the app fetches the device location, and the dialog stays open.
- The dialog closes once `getLocation` reads a non-empty saved city, before the fetch finishes.
- When no provider or geocoder finds the city, the fetch fails like any other failure
  ([current weather](current-weather.md)).

## Sources

* `lib/views/home/dialog_overlay.dart`
* `lib/main.dart`
* `lib/services/weather_service.dart`
