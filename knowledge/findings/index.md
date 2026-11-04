# Findings

<!-- GA-GENERATED:index -->

- [An OpenWeatherMap API key is committed in the code](committed-openweathermap-key.md) - lib/config/api_keys.dart falls back to a hard-coded OpenWeatherMap key, in git history since 2020, though the README says keys are kept out of git.
- [Play flags a deprecated display-cutout mode that comes from the ads SDK](deprecated-cutout-mode-in-ads-sdk.md) - Play's warning about LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES on release 1.0.0 comes from play-services-ads, not the app's code, and clears when that SDK drops the flag.

<!-- GA-GENERATED:END -->
