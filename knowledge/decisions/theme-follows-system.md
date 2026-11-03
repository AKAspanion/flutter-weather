---
type: Decision
title: The theme follows the system, and the button overrides it until the system next changes
description: The app takes light or dark from the system and switches live; the theme button sets an override that holds until the system brightness changes.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T07:29:19Z }
verified: human:panditankit1995@gmail.com
---

# The theme follows the system, and the button overrides it until the system next changes

## Context

Internal testing asked for the app to follow the system's dark-mode setting and apply it on its own. The app had only
a light/dark toggle, saved as `theme_preference` ([themes and accents](../features/themes-and-accents.md)).

## Decision

- By default the theme matches the system brightness, at launch and whenever the system changes it.
- The theme button still switches light and dark. That choice is an override, saved with the system brightness at
  the moment it was made. It holds, across launches too, until the system brightness changes; then it is cleared and
  the app follows the system again.
- A `theme_preference` saved by an older version counts as an override made against the current system brightness, so
  nobody's choice flips on upgrade.

Chosen by the developer on 2026-11-03 over a three-way System / Light / Dark button and over removing the button: it
needs no new UI.

## Consequences

- There is no explicit "follow the system" control; the next system change restores it.
- A user who sets dark in the evening while the system is light keeps dark until the system itself changes.

## Sources

* `docs/specs/2026-11-03-widget-testing-feedback.md`
* `lib/services/theme_manager.dart`
* `lib/main.dart`
