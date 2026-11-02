---
type: Decision
title: New Dart code is formatted at 120 columns with typed callbacks
description: dart format with a page width of 120, set in analysis_options.yaml, and callbacks typed as function types, as the newer services do.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:30:34Z }
status: draft
---

# New Dart code is formatted at 120 columns with typed callbacks

## Context

The code was split two ways. The newer services and providers run past 100 columns and type their callbacks. The
older views fit 80 columns and leave callbacks untyped (`final onPress;` in `lib/components/btn.dart`). See
[questions/code-style-for-new-code](../questions/code-style-for-new-code.md).

## Decision

The developer decided on 2026-11-03:

- New and changed Dart code is formatted with `dart format` at a page width of 120. The width is to be set in
  `./analysis_options.yaml` (`formatter: page_width: 120`), so the formatter reads it.
- Callbacks are typed as function types, such as `final void Function() onClosePress;` in
  `lib/views/forecast/forecast.dart`, never left untyped.

## Consequences

- Setting the width in `./analysis_options.yaml` is a change still to make. After that, `dart format` gives the
  same result for everyone.
- Formatting the whole of `lib/` at once reflows the older views. Do it as its own commit, or only on the files a
  change touches, so diffs stay readable.
- The untyped callbacks listed in [debt](../risks/debt.md) get types when their files are next touched.
- [Conventions](../project/conventions.md) states the rule.

## Sources

* `./analysis_options.yaml`
* `lib/components/btn.dart`
* `lib/views/forecast/forecast.dart`
* `lib/services/providers/weather_provider.dart`
