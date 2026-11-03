---
type: Runbook
title: Run, build and release
description: Running the app with its keys, building the Play bundle, regenerating widget icons and launcher icons, and the store listing images.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Run, build and release

## Prerequisites

- Flutter with a Dart SDK in the range set in `pubspec.yaml`. The Flutter revision the project was last migrated with
  is in `./.metadata`. Commit `01da471` describes the Flutter, Gradle, Kotlin and NDK upgrade.
- An Android SDK for the compile and target SDK in `android/app/build.gradle.kts`, and Xcode for `ios/`.
- Optionally, a `keys.json` copied from `keys.example.json` ([environment](environment.md)). Without it, the app
  runs on the code's OpenWeatherMap key, MET Norway and test ads. Removing that key is decided
  ([decisions/rotate-openweathermap-key](../decisions/rotate-openweathermap-key.md)).

## Steps

- **Run:** `flutter run --dart-define-from-file=keys.json`, or plain `flutter run` without keys.
- **Check:** the commands are the policy's `checks.commands.lint` and `checks.commands.test`
  ([conventions](../project/conventions.md), [testing](../quality/testing.md)).
- **Release for Play:** `flutter build appbundle --release --dart-define-from-file=keys.json`, as `README.md` says,
  with `android/key.properties` in place. The version and build number are `version` in `pubspec.yaml`. The
  application ID is in `android/app/build.gradle.kts` ([decisions/new-application-id](../decisions/new-application-id.md)).
- **Widget icons:** after changing a weather animation, run `flutter test tool/render_widget_icons_test.dart`. It
  writes the PNGs into `android/app/src/main/res/drawable-nodpi/`. Its header comment explains `ICON_FRAMES=1`,
  which dumps several frames per animation to help pick the capture time.
- **Launcher icons:** `flutter_launcher_icons` is set up under `flutter_icons` in `pubspec.yaml`, from
  `assets/icon/icon.png`.
- **Store listing:** the Play Store images are in `store/` (`store/feature_graphic.png` and `store/phone/`). The
  privacy policy is `privacy.md`.

## Sources

* `README.md`
* `pubspec.yaml`
* `./.metadata`
* `keys.example.json`
* `android/app/build.gradle.kts`
* `tool/render_widget_icons_test.dart`
* `store/feature_graphic.png`
* `privacy.md`
* `assets/icon/icon.png`
