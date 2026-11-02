---
type: Decision
title: Keep a patched copy of flare_flutter instead of moving to Rive
description: The app's animations are Flare .flr files, which Rive can't load, so the discontinued flare_flutter is kept in packages/ and patched to compile.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Keep a patched copy of flare_flutter instead of moving to Rive

## Context

The weather icons are Flare animations (`assets/animations/cloudy.flr`, `assets/animations/icons.flr`). Google Play
required the app to target a newer Android, which meant moving to current Flutter and Dart 3. The published
flare_flutter is discontinued. Commit `01da471` says Rive can't load the app's `.flr` animations.

## Decision

Keep flare_flutter 3.0.2 in `packages/flare_flutter/`, patched to compile, and depend on it by path. The comment
next to it in `pubspec.yaml` says the same.

## Consequences

- We maintain the patches. `./analysis_options.yaml` excludes `packages/**` so the copy stays close to upstream.
- New animated icons still have to be made as Flare files, or the icons redone in Rive
  ([packages/flare_flutter](../packages/flare_flutter.md), [debt](../risks/debt.md)).

## Sources

* `pubspec.yaml`
* `packages/flare_flutter/pubspec.yaml`
* `./analysis_options.yaml`
* `assets/animations/cloudy.flr`
* `assets/animations/icons.flr`
