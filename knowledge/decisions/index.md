# Decisions

<!-- GA-GENERATED:index -->

- [Android is the only supported platform](android-only.md) - The app ships on Android only; changes are built and checked for Android, and ios/ is kept but not maintained.
- [Translate the app with Flutter gen_l10n and drafted .arb files](app-localization-gen-l10n.md) - In-app text lives in .arb files compiled by gen_l10n; Claude drafts the translations and they stay marked unreviewed until a native speaker checks them.
- [New Dart code is formatted at 120 columns with typed callbacks](code-style-120-typed.md) - dart format with a page width of 120, set in analysis_options.yaml, and callbacks typed as function types, as the newer services do.
- [Weather descriptions are shown from the condition code, translated](descriptions-by-condition-code.md) - The description on screen and on the widget is a translated phrase per OpenWeatherMap condition code, not the provider's English text.
- [Publish under the new application ID in.spanion.weather](new-application-id.md) - The app is published as a new Play listing because the original signing key was lost.
- [The privacy policy describes only what the app collects](privacy-policy-no-analytics.md) - The app collects no usage analytics, so privacy.md is to describe only location, the weather services and AdMob.
- [Rotate the OpenWeatherMap key and remove the bundled fallback](rotate-openweathermap-key.md) - The committed key is to be rotated, the new one passed only through keys.json, and the fallback removed so OpenWeatherMap is skipped without a key.
- [The app speaks the ten most spoken languages, chosen in the app](supported-languages.md) - English, Chinese, Hindi, Spanish, Arabic, French, Bengali, Portuguese, Russian and Urdu, plus System default, picked from a language button on the home screen.
- [Keep a patched copy of flare_flutter instead of moving to Rive](vendored-flare-flutter.md) - The app's animations are Flare .flr files, which Rive can't load, so the discontinued flare_flutter is kept in packages/ and patched to compile.
- [The widget refreshes the last place viewed, without background location](widget-uses-last-place.md) - The background widget refresh reuses the last query saved by the app instead of asking for the device's location in the background.

<!-- GA-GENERATED:END -->
