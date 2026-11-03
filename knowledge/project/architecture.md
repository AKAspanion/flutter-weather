---
type: Architecture
title: How the app is put together
description: One Flutter app in three layers (views, services, weather providers), a background refresh isolate, and a Kotlin widget fed through home_widget.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# How the app is put together

## Services

The app is a single Flutter app, with all Dart code in `lib/`:

- **Views** (`lib/views/`) are widgets for each part of the screen: `home/`, `menu/`, `forecast/` and `weather/`.
  Small shared widgets are in `lib/components/`. See [components](../design-system/components.md).
- **Services** (`lib/services/`) hold everything that isn't drawing. `WeatherService` picks a weather provider
  ([provider failover](../domain/provider-failover.md)). `WeatherCache` stores the last report. `Location` asks
  for the device position and wraps the report the views show. `WeatherWidget` feeds the Android widget. `Ads`
  handles AdMob consent and start-up. `ThemeManager` holds the theme and `LocaleManager` the chosen language and `UnitManager` the temperature unit.
- **Providers** (`lib/services/providers/`) each call one weather service and turn its answer into a
  `WeatherReport` ([data model](../data/model.md)). They all extend `WeatherProvider` in
  `lib/services/providers/weather_provider.dart`, and some also implement `Geocoder`.

**State.** Almost all screen state lives in `_MainAppState` in `lib/main.dart`, held in fields and changed with
`setState`: the current `Location`, the accent, and whether the menu, forecast and city dialog are open. It is passed
down to the views as constructor arguments and callbacks. The theme, the language and the temperature unit are shared through the `provider` package:
`ThemeManager`, `LocaleManager` and `UnitManager` are `ChangeNotifier`s that `MainApp` provides, and widgets read them with
`Provider.of`. `MaterialApp` takes its `locale` from `LocaleManager`. Strings come from the generated
`AppLocalizations`, built from `lib/l10n/*.arb`; code with no `BuildContext` looks them up by locale with
`lookupAppLocalizations` ([language picker](../features/language-picker.md)).

**Screen structure.** There is one route. `MainApp` builds a single `Scaffold` whose body is a `Stack`: the
`Menu`, the top buttons (`MenuButtons`), the `Home` card, the `DialogOverlay`, the `SettingsOverlay`, the `LanguageOverlay`, the `Forecast` panel and the `AdBanner`. Opening the
menu or the forecast moves and scales these layers with `AnimationController`s; nothing is pushed on a navigator.

## Jobs and queues

- **Widget refresh.** `WeatherWidget.scheduleRefresh` in `lib/services/weather_widget.dart` registers a periodic
  WorkManager task. WorkManager runs `widgetRefreshDispatcher` in a background isolate. That isolate builds its own
  `WeatherService.withDefaultProviders()`, fetches the last saved `WeatherQuery`, saves the report and updates the
  widget, in the language saved by the app (`WeatherWidget.localizations`). The task's frequency and start delay are set in `scheduleRefresh`. See
  [home-screen widget](../features/home-screen-widget.md).
- **Ads start-up** waits until after the first frame (`addPostFrameCallback` in `lib/main.dart`). A comment there
  says this keeps the heavy ads SDK from slowing launch.

## Data flow

1. On launch, `_MainAppState.initState` shows the cached report from `WeatherCache.loadReport`, then calls
   `getLocation`.
2. `getLocation` reads `city_preference`. If it is set, it builds `WeatherQuery.city`. Otherwise it asks
   `Location.currentPosition` for coordinates and builds `WeatherQuery.coords`.
3. `WeatherQuery.fetch` calls `WeatherService`, which tries the providers in turn and returns a `WeatherReport`.
4. The report is saved (`WeatherCache.save`), shown (`_showReport` wraps it in a `Location`), and pushed to the
   widget (`WeatherWidget.update`).
5. `WeatherWidget.update` writes JSON strings with `HomeWidget.saveWidgetData`. The Kotlin `WeatherWidgetProvider`
   reads them from its `SharedPreferences` and draws the cards.

The background refresh runs steps 3 to 5 from the saved query, without asking for location.

## History

- 2026-11-03: the language was shared through `provider`; now the temperature unit is too (`UnitManager`), and a `SettingsOverlay` joins the `Stack`, because the app can show °F. See [settings](../features/settings.md).
- 2026-11-03: only the theme was shared through `provider`; now the language is too, and strings come from generated `AppLocalizations`, because the app is translated. See [gen_l10n decision](../decisions/app-localization-gen-l10n.md).

## Sources

* `lib/main.dart`
* `lib/services/weather_service.dart`
* `lib/services/weather_cache.dart`
* `lib/services/location.dart`
* `lib/services/weather_widget.dart`
* `lib/services/ads.dart`
* `lib/services/theme_manager.dart`
* `lib/services/unit_manager.dart`
* `lib/views/settings/settings_overlay.dart`
* `lib/services/locale_manager.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/services/providers/weather_provider.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
