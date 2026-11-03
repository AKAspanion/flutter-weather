# Findings

<!-- GA-GENERATED:index -->

- [Fixed: An OpenWeatherMap API key was committed in the code](committed-openweathermap-key.md) - lib/config/api_keys.dart fell back to a hard-coded OpenWeatherMap key, still in git history since 2020; the fallback was removed, but deleting the old key in the OpenWeatherMap console was left to the developer.

<!-- GA-GENERATED:END -->
