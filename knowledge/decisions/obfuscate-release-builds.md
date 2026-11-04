---
type: Decision
title: Release builds are obfuscated to save download size
description: The Play release is built with --obfuscate and --split-debug-info, which shrank the arm64 native library, at the cost of needing build/symbols to read Dart stack traces.
generated: { by: claude-code/claude-sonnet-5-5, at: 2026-11-04T12:00:00Z }
verified: human:panditankit1995@gmail.com
---

# Release builds are obfuscated to save download size

## Context

The Play download for an arm64 phone was about 12.50 MB. The developer asked to shrink it while keeping AdMob. Most of
the size can't shrink (the Flutter engine, AdMob's dex), so the spec took the cuts that cost a user nothing
([spec](../../docs/specs/2026-11-04-smaller-download.md)).

## Decision

- Release builds pass `--obfuscate --split-debug-info=build/symbols` to `flutter build appbundle`. The full command is
  in `README.md` and the [runbook](../operations/run-locally.md).
- Measured: `libapp.so` for arm64 went from 2.55 to 2.03 MB compressed, the largest of the spec's cuts.

## Consequences

- The app has no crash reporter, so the only place a Dart stack trace is read is by hand: it needs the `build/symbols`
  of that build (`flutter symbolize`). Keep a copy per release.

## History

- 2026-11-04: also recorded the font removal, Glance/Compose staying and the full release command; now only the
  obfuscation flags and their cost, because those facts belong to the spec, `pubspec.yaml` and the runbook.

## Sources

* `docs/specs/2026-11-04-smaller-download.md`
* `README.md`
