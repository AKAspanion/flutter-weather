---
type: Decision
title: The privacy policy describes only what the app collects
description: The app collects no usage analytics, so privacy.md is to describe only location, the weather services and AdMob.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:30:34Z }
status: draft
---

# The privacy policy describes only what the app collects

## Context

`privacy.md` says the app collects usage and device information for analytics. There is no analytics or
crash-reporting SDK among the dependencies in `pubspec.yaml`. The app sends data only to the weather services and
AdMob ([data protection](../security/data-protection.md)). See
[questions/privacy-policy-analytics](../questions/privacy-policy-analytics.md).

## Decision

The developer decided on 2026-11-03 that the app collects no analytics. `privacy.md` is to be reworded to describe
only location, the weather services and AdMob, and to drop the usage, device-information and analytics sections.

## Consequences

- Rewording `privacy.md` is a change still to make. Until it is made, the policy claims more than the app does.
- Play's Data safety answers should match the reworded policy.
- Adding analytics or crash reporting later means updating the policy first, as a new decision replacing this one.

## Sources

* `privacy.md`
* `pubspec.yaml`
