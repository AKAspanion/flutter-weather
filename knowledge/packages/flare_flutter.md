---
type: Package
title: flare_flutter, our patched copy
description: A copy of the discontinued flare_flutter 3.0.2, kept in packages/ and patched to compile, which plays the app's .flr weather animations.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# flare_flutter, our patched copy

## Purpose

Plays the animated weather icons, which are Flare files: `assets/animations/cloudy.flr` and
`assets/animations/icons.flr`, both listed under `flutter.assets` in `pubspec.yaml`. Upstream flare_flutter is
discontinued. A copy is kept in `packages/flare_flutter/` and patched to compile on current Flutter. Why is in
[decisions/vendored-flare-flutter](../decisions/vendored-flare-flutter.md).

`./analysis_options.yaml` excludes `packages/**` from analysis, with a comment saying the copy is kept as close to
upstream as possible.

## Exports

The app uses only `FlareActor`, from the vendored `packages/flare_flutter/lib/flare_actor.dart` (imported as
package:flare_flutter/flare_actor.dart). It is wrapped by `FlareIcon`
in `lib/components/flare_icon.dart` ([components](../design-system/components.md)).
`tool/render_widget_icons_test.dart` also uses `FlareActor`, to render the widget's icon frames and stills.

## Used by

- `pubspec.yaml`, as a path dependency.
- `lib/components/flare_icon.dart`
- `tool/render_widget_icons_test.dart`

## Sources

* `packages/flare_flutter/pubspec.yaml`
* `packages/flare_flutter/CHANGELOG.md`
* `pubspec.yaml`
* `./analysis_options.yaml`
* `lib/components/flare_icon.dart`
* `tool/render_widget_icons_test.dart`
* `assets/animations/cloudy.flr`
* `assets/animations/icons.flr`
* `packages/flare_flutter/lib/flare_actor.dart`
