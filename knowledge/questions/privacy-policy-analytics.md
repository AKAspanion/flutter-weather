---
type: Open Question
title: Does the app collect usage analytics, as the privacy policy says?
description: privacy.md says usage and device information are collected for analytics, but the app has no analytics SDK.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Does the app collect usage analytics, as the privacy policy says?

## Question

`privacy.md` says the app collects usage information (features used, time in the app, error logs) and device
information, and uses them for analytics. The dependencies in `pubspec.yaml` include no analytics or crash-reporting
SDK, and the code sends data only to the weather services and AdMob. Is the policy written broadly on purpose, or
should it, or the app, change?

## Why it matters

Google Play's Data safety form and the privacy policy have to match what the app does. Adding analytics later also
has to fit what the policy promises.

## Status

Answered: the app collects no analytics; `privacy.md` is to describe only location, the weather services and AdMob. See [The privacy policy describes only what the app collects](../decisions/privacy-policy-no-analytics.md).

## Sources

* `privacy.md`
* `pubspec.yaml`
