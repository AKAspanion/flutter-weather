# flutter-weather

Beautiful Weather, an app built using flutter that shows the current weather.<br/>

Very simple app with the following features.
- Beautiful live animated weather icons.
- Beautiful accent gradient colors.
- Dark and Light theme support.
- View your current location/any city weather details.
- View the weather details for the next 48 hours/next days.
- Home-screen widget (Android) that refreshes about once an hour.
- Weather from several providers (OpenWeatherMap, WeatherAPI.com, Tomorrow.io, MET Norway), switching automatically when one fails.

![Beautiful Flutter](/assets/animations/demo.gif "Beautiful Flutter")


## Motivation

Built this app to learn and get familiar with flutter and dart.

## Building a release

API keys and AdMob IDs are passed in at build time and kept out of git. Copy
`keys.example.json` to `keys.json` and fill in what you have; blank values fall
back to defaults (the bundled OpenWeatherMap key and Google's test ads), and
providers without a key are skipped.

```bash
flutter build appbundle --release --dart-define-from-file=keys.json
```

| Key | Where to get it |
| --- | --- |
| `OPENWEATHERMAP_KEY` | openweathermap.org (free plan) |
| `WEATHERAPI_KEY` | weatherapi.com (free plan) |
| `TOMORROW_IO_KEY` | tomorrow.io (free plan) |
| `ADMOB_APP_ID`, `ADMOB_BANNER_ID` | AdMob console; without them only test ads are shown |

MET Norway needs no key. Release signing reads `android/key.properties`.

## Android App

<a href='https://play.google.com/store/apps/details?id=spanion.flutterweather.xyz&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' width="240" src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'/></a>

## Built With

- [Flutter](https://flutter.dev/) - Framework used to build app
- [Dart](https://dart.dev/) - Language used to build app
- [Rive](https://rive.app/) - Used to build icon animations
