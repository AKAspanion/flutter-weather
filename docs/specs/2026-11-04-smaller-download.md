# Smaller Play download, keeping ads

**Date:** 2026-11-04
**Branch:** `feat/release-1.0.1` (ships in the 1.0.1 release, as build `+5`)

## Why

The Play download for an arm64 phone is about 12.5 MB, measured as the compressed size of what that phone receives
from `app-release.aab` (`lib/arm64-v8a`, `dex`, `res`, `assets`, `resources.pb`). The developer asked to bring it down
while keeping AdMob. Most of the size can't shrink: the Flutter engine is 5.22 MB, and AdMob is over half of the
2.67 MB of dex. This change takes the cuts that cost nothing a user would notice.

## What changes

1. **Unused fonts are removed.** Nothing uses `cupertino_icons` (no `CupertinoIcons` in `lib/` or `packages/`) or
   Montserrat Italic (no `FontStyle.italic`), and each ships about 113 KB compressed. The `cupertino_icons`
   dependency comes out of `pubspec.yaml`. The italic entry comes out of the Montserrat family, and
   `assets/fonts/Montserrat-Italic.ttf` is deleted.
2. **Widget frames become lossy WebP.** `tool/render_widget_icons_test.dart` still renders each loop frame at
   `frameSize = 112` and `frameMs = 125`. Under `ICON_LOOPS=1`, it then encodes each frame with
   `cwebp -q 85 -exact -alpha_q 100 -m 6` to `widget_icon_<name>_<nn>.webp` and deletes the PNG, because Android
   rejects two resources with the same name. The `animation-list` and layout files don't change: they name drawables
   without an extension. If `cwebp` isn't installed, the tool fails with a message saying `brew install webp`. The
   static stills (the widget preview and the sunrise, wind and humidity icons) stay PNG. The app's `minSdk` (the
   Flutter default) is above API 18, the first version that supports WebP with alpha.
3. **Release builds are obfuscated.** The release command in `README.md` and the runbook becomes
   `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=keys.json`.
   `build/symbols` is needed to read a Dart stack trace from that build, so the runbook says to keep a copy per
   release. The app has no crash reporter.
4. **Version** becomes `1.0.1+5`, because `+4` is already in open testing.

## Out of scope

- Glance and Compose (about 0.25 MB). `home_widget` 0.10 calls `HomeWidgetPreviews.registerAll` when the plugin
  attaches, so R8 keeps them. Removing them would mean forking the plugin.
- Removing AdMob, and Flutter's engine and framework code.

## Testing

- `test/widget_icon_resources_test.dart` counts the `.webp` frames instead of the `.png` ones. Its cap drops from
  1.5 MB to the measured total plus about 10%. It also checks that no frame PNG is left beside a WebP. The test
  changes first and fails, then the frames are re-rendered.
- The bundle is rebuilt, and its arm64 payload is measured the same way as above, against 12.50 MB. The expected
  result is about 11.6 MB.
- On a device or emulator, the widget's icon still animates, and the app's text still renders in Montserrat.
- `flutter analyze` passes.

## Knowledge

- `decisions/widget-animated-icons` was verified by the developer, so it is superseded by a decision recording WebP
  frames and the new cap. The frame size and rate stay the same.
- A decision records why release builds are obfuscated.
- `operations/run-locally` gets the new release command, the symbols note and the `cwebp` prerequisite.
