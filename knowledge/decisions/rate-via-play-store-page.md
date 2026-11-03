---
type: Decision
title: Rate on Google Play opens the store page, not the in-app review dialog
description: The settings row opens the app's Play Store page through url_launcher, because Google's in-app review dialog is quota-limited and can silently not appear when a button asks for it.
status: draft
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T08:37:08Z }
---

# Rate on Google Play opens the store page, not the in-app review dialog

## Context

The [settings panel](settings-panel.md) has a "Rate on Google Play" row. Android offers two ways: open the Play Store
listing, or Google's in-app review dialog (`in_app_review`). Google limits how often the dialog shows and gives no
signal when it doesn't, so a button that calls it can do nothing, and Google advises against putting it behind a
button.

## Decision

The developer chose on 2026-11-03 to open the store listing with the `url_launcher` package: first
`market://details?id=in.spanion.weather` (the Play Store app), then `https://play.google.com/store/apps/details?id=in.spanion.weather`
if that doesn't open. If neither opens, the app says so in a snackbar. The ID is the one the app is published under
([new application ID](new-application-id.md)).

## Consequences

- `url_launcher` is a new dependency.
- The user leaves the app to rate it.

## Sources

* `docs/specs/2026-11-03-settings-menu.md`
* `android/app/build.gradle.kts`
