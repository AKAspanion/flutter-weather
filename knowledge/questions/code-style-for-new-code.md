---
type: Open Question
title: Which code style do new files follow?
description: Older views are formatted at 80 columns with untyped callbacks; newer services run past 100 columns with typed callbacks. Which way does new code go?
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Which code style do new files follow?

## Question

The code is split two ways, and there is no formatter config to settle it:

- **Line width.** The services and providers added in `01da471` have lines past 100 columns
  (`lib/services/providers/weather_provider.dart`). The older views fit `dart format`'s default
  (`lib/views/home/dialog_overlay.dart`).
- **Callback types.** Older widgets leave callbacks untyped (`final onPress;` in `lib/components/btn.dart`). Newer
  ones type them (`final void Function() onClosePress;` in `lib/views/forecast/forecast.dart`).

Should new code use `dart format` with a set page width (say 120, in `./analysis_options.yaml`) and typed callbacks?

## Why it matters

Every plan and review checks diffs against [conventions](../project/conventions.md). Without an answer, a reviewer
can't say which style is right, and running a formatter on one file reformats code nobody changed.

## Status

Answered: `dart format` at page width 120, set in `./analysis_options.yaml`, and typed callbacks. See [New Dart code is formatted at 120 columns with typed callbacks](../decisions/code-style-120-typed.md).

## Sources

* `lib/services/providers/weather_provider.dart`
* `lib/views/home/dialog_overlay.dart`
* `lib/components/btn.dart`
* `lib/views/forecast/forecast.dart`
* `./analysis_options.yaml`
