---
type: Decision
title: Widget icon frames are lossy WebP
description: The widget's loop frames are encoded as lossy WebP with cwebp and capped at their measured size; the stills stay PNG.
generated: { by: claude-code/claude-sonnet-5-5, at: 2026-11-04T12:00:00Z }
status: draft
---

# Widget icon frames are lossy WebP

## Context

[Widget icons animate as frames](widget-animated-icons.md) in a ProgressBar. The frames were PNGs, the largest
resource set in the app, so the smaller-download work looked at them first
([spec](../../docs/specs/2026-11-04-smaller-download.md)).

## Decision

- `tool/render_widget_icons_test.dart` still renders each loop frame at `frameSize = 112` and `frameMs = 125`, then, under
  `ICON_LOOPS=1`, encodes it with `cwebp -q 85 -exact -alpha_q 100 -m 6` to `widget_icon_<name>_<nn>.webp` and deletes
  the PNG (Android rejects two resources with one name). The tool fails with `brew install webp` when `cwebp` is missing.
- The animation lists and layouts are unchanged, since they name drawables without an extension. The static stills
  (the picker preview, sunrise, wind, humidity) stay PNG.
- 678 frames in all measure 758914 bytes. `test/widget_icon_resources_test.dart` caps them at `maxFrameBytes = 835584`
  (the measured total plus about 10%) and checks no frame PNG is left beside a WebP.
- The developer chose lossy WebP.

## Consequences

- The download saving was only about 0.13 MB (0.87 to 0.73 MB compressed), because the Android build already crunched the PNGs.
- Whether the WebP frames still animate on a launcher was not checked on a device.

## Sources

* `tool/render_widget_icons_test.dart`
* `test/widget_icon_resources_test.dart`
* `docs/specs/2026-11-04-smaller-download.md`
