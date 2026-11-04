---
type: Decision
title: Release builds are obfuscated to save download size
description: The Play release is built with --obfuscate and --split-debug-info, which shrank the arm64 native library, at the cost of needing build/symbols to read Dart stack traces.
generated: { by: claude-code/claude-sonnet-5-5, at: 2026-11-04T12:00:00Z }
status: draft
---

# Release builds are obfuscated to save download size

## Context

The Play download for an arm64 phone was about 12.50 MB. The developer asked to shrink it while keeping AdMob. Most of
the size can't shrink (the Flutter engine, AdMob's dex), so the spec took the cuts that cost a user nothing
([spec](../../docs/specs/2026-11-04-smaller-download.md)).

## Decision

- The release command is `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=keys.json`
  ([run locally](../operations/run-locally.md)).
- Measured: `libapp.so` for arm64 went from 2.55 to 2.03 MB compressed. With the unused fonts and the WebP frames
  ([decisions/widget-webp-frames](widget-webp-frames.md)), the arm64 download went from 12.50 to 11.62 MB.
- The unused `cupertino_icons` dependency and the Montserrat Italic font were removed in the same work (about 0.22 MB).

## Consequences

- The app has no crash reporter, so the only place a Dart stack trace is read is by hand: it needs the `build/symbols`
  of that build (`flutter symbolize`). Keep a copy per release.
- Glance and Compose stay: `home_widget` registers them when the plugin starts, so R8 keeps them.

## Sources

* `docs/specs/2026-11-04-smaller-download.md`
* `README.md`
* `pubspec.yaml`
