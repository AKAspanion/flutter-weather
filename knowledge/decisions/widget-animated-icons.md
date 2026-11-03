---
type: Decision
title: Widget icons animate as frame animations in a ProgressBar
description: Home-screen widgets can't play Flare, so each icon's loop is rendered to frames and played by an indeterminate ProgressBar, at a cost of about 1.5 MB and some battery.
status: draft
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T07:29:19Z }
---

# Widget icons animate as frame animations in a ProgressBar

## Context

Internal testing noticed the widget's weather icon doesn't animate the way it does in the app. The app plays Flare
animations ([flare_flutter](../packages/flare_flutter.md)); a home-screen widget is drawn by the launcher from
`RemoteViews` and can't run Flutter or Flare. RemoteViews can't start an animation either, but an indeterminate
`ProgressBar` starts its own indeterminate drawable when it is an `Animatable`, which includes an `animation-list`.

## Decision

- Each weather icon's Flare loop is rendered to PNG frames by `tool/render_widget_icons_test.dart`, with an
  `animation-list` per icon.
- The widget shows the icon as an indeterminate `ProgressBar` whose drawable is that list. RemoteViews can't change a
  ProgressBar's drawable, so each icon has its own tiny layout, added into the card's icon slot.
- Frame size and rate are chosen to keep the frames to about 1.5 MB in all.
- The small detail icons (sunrise, wind, humidity) stay static.

Accepted by the developer on 2026-11-03, with the cost: a larger APK, and the animation running whenever the home
screen shows the widget.

## Consequences

- Changing an icon means re-rendering its frames, as before, and adding a new icon name means a new layout and
  animation list as well as the `iconFor` mapping ([condition icons](../domain/condition-icons.md)).
- Whether a given launcher animates the ProgressBar is checked on a device; there is no automated check.

## Sources

* `docs/specs/2026-11-03-widget-testing-feedback.md`
* `tool/render_widget_icons_test.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
