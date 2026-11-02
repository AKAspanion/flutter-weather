# Decisions

<!-- GA-GENERATED:index -->

- [Publish under the new application ID in.spanion.weather](new-application-id.md) - The app is published as a new Play listing because the original signing key was lost.
- [Keep a patched copy of flare_flutter instead of moving to Rive](vendored-flare-flutter.md) - The app's animations are Flare .flr files, which Rive can't load, so the discontinued flare_flutter is kept in packages/ and patched to compile.
- [The widget refreshes the last place viewed, without background location](widget-uses-last-place.md) - The background widget refresh reuses the last query saved by the app instead of asking for the device's location in the background.

<!-- GA-GENERATED:END -->
