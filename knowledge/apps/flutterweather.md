---
type: Application
title: The Flutter app (flutterweather)
description: The single Flutter app: entry point, screens, platform projects, and its Android build (Android is the only supported platform).
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# The Flutter app (flutterweather)

## Role

The whole product. The Dart package is named in `pubspec.yaml`. Users see it as "Beautiful Weather", the label in
`android/app/src/main/AndroidManifest.xml` and the `title` in `lib/main.dart`.

## Stack

- Flutter and Dart. The SDK range and every dependency are in `pubspec.yaml`, and resolved versions are in
  `pubspec.lock`.
- State: `setState` in `_MainAppState`, plus `provider` for the theme, the language and the temperature unit
  ([architecture](../project/architecture.md)).
- Main plugins: `geolocator` (position), `http` (provider calls), `shared_preferences` (on-device storage), `url_launcher` (the Play Store page),
  `home_widget` and `workmanager` (Android widget), `flutter_localizations` and `intl` (translations and dates), `google_mobile_ads` (banner and consent), `flutter_spinkit`
  (loading pulse), and `flare_flutter` from `packages/flare_flutter` (animated icons).
- Android: a Gradle Kotlin build in `android/app/build.gradle.kts`, which sets the application ID, compile and target
  SDK, and the signing config. The Kotlin code is in `android/app/src/main/kotlin/com/example/flutterweather/`.
- iOS: an Xcode project in `ios/`, with its `Info.plist` at `ios/Runner/Info.plist`. It is kept but not maintained: Android
  is the only supported platform ([decisions/android-only](../decisions/android-only.md)).

## Entry points

- `lib/main.dart`: `main()` runs `MainApp`. `_MainAppState` holds the screen state and the actions (refresh, city
  search, theme, accent, menu, forecast).
- `widgetRefreshDispatcher` in `lib/services/weather_widget.dart`: the background WorkManager entry point, marked
  `@pragma('vm:entry-point')`.
- `android/app/src/main/kotlin/com/example/flutterweather/MainActivity.kt`: the Android activity, which also answers
  the widget's pin request on the `in.spanion.weather/widget` channel.
- `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`: the widget's
  `AppWidgetProvider`, registered as a `receiver` in `android/app/src/main/AndroidManifest.xml`.

## Screens and routes

There is one route. All parts are layered in a `Stack` in `lib/main.dart`:

- `Home` (`lib/views/home/home.dart`): the main card. It shows `LocationScreen`
  (`lib/views/weather/weather_screen.dart`), which shows a loading pulse, `ErrorView`
  (`lib/views/weather/weather_error.dart`) or `LocationView` (`lib/views/weather/weather_view.dart`). Swiping it
  sideways opens and closes the menu. See [current weather](../features/current-weather.md).
- `Menu` (`lib/views/menu/menu.dart`): the gradient drawer behind the card, with the accent picker and, where needed,
  the ad privacy button. See [themes and accents](../features/themes-and-accents.md).
- The top buttons: refresh, theme, add-widget, settings (a gear), location and close. `MenuButtons`
  (`lib/views/menu/menu_buttons.dart`) lays them out as `Btn`s, positioned in `lib/main.dart`, and they are shown
  while the menu is open.
- `SettingsOverlay` (`lib/views/settings/settings_overlay.dart`): the settings panel the gear opens. See
  [settings](../features/settings.md).
- `LanguageOverlay` (`lib/views/home/language_overlay.dart`): the language list. See
  [language picker](../features/language-picker.md).
- `DialogOverlay` (`lib/views/home/dialog_overlay.dart`): the city search. See
  [city search](../features/city-search.md).
- `Forecast` (`lib/views/forecast/forecast.dart`): the panel that slides up. See
  [forecast](../features/forecast.md).
- `AdBanner` (`lib/components/ad_banner.dart`), anchored at the bottom. See
  [Google AdMob](../integrations/google-admob.md).

## Depends on

- The weather services: [OpenWeatherMap](../integrations/openweathermap.md),
  [WeatherAPI.com](../integrations/weatherapi.md), [Tomorrow.io](../integrations/tomorrow-io.md) and
  [MET Norway](../integrations/met-norway.md).
- [Google AdMob](../integrations/google-admob.md).
- Build-time keys: [environment](../operations/environment.md).

## History

- 2026-11-03: the top buttons included translate; now a settings gear opens `SettingsOverlay`, which holds the language, the temperature unit (`UnitManager`, provided in `lib/main.dart`) and Rate on Google Play, and `url_launcher` is a dependency, because every setting lives in one panel. See [settings panel](../decisions/settings-panel.md).
- 2026-11-03: the top buttons were five hand-placed `Btn`s; now `MenuButtons` with a translate button, and the app is translated, because the developer chose ten languages. See [supported languages](../decisions/supported-languages.md).

## Sources

* `pubspec.yaml`
* `lib/main.dart`
* `lib/views/home/home.dart`
* `lib/views/menu/menu.dart`
* `lib/views/home/dialog_overlay.dart`
* `lib/views/home/language_overlay.dart`
* `lib/views/settings/settings_overlay.dart`
* `lib/views/menu/menu_buttons.dart`
* `lib/views/forecast/forecast.dart`
* `lib/views/weather/weather_screen.dart`
* `lib/views/weather/weather_view.dart`
* `lib/views/weather/weather_error.dart`
* `lib/components/ad_banner.dart`
* `lib/services/weather_widget.dart`
* `android/app/build.gradle.kts`
* `android/app/src/main/AndroidManifest.xml`
* `android/app/src/main/kotlin/com/example/flutterweather/MainActivity.kt`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
* `ios/Runner/Info.plist`
