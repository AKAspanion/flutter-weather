---
type: Decision
status: draft
title: The app is declared a trader app, with terms.md as its Terms of Service
description: Play Console's app-level trader status is Yes because the app earns from AdMob ads; terms.md is the Terms of Service, keeping EEA and UK consumer rights and saying forecasts are not for safety decisions.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-04T15:00:29Z }
---

# The app is declared a trader app, with terms.md as its Terms of Service

## Context

Play Console asked whether the developer account's trader status applies to this app, and offered an optional Terms
of Service URL. Answering No would tell users in the EEA and UK that consumer protection laws do not apply to the app.
The app shows ads through [Google AdMob](../integrations/google-admob.md), so it earns money from them.

## Decision

On 2026-11-04 the developer chose to declare that the trader status applies, because ad revenue is business activity.

`terms.md`, beside `privacy.md`, is the app's Terms of Service. It:

- says the app is free, ad-supported, with no accounts or in-app purchases;
- says forecasts come from third-party services and are not for decisions where safety, health or property is at
  risk;
- keeps every consumer right the user's local law gives, including in the EEA and UK, to match the trader
  declaration;
- names the developer only by contact email, as `privacy.md` does, and names no governing law.

## Consequences

- The Terms of Service URL in Play Console is left blank until `terms.md` is served as a public HTTPS web page (not a
  raw file or PDF), as Play requires.
- Adding accounts, purchases or another data use means updating `terms.md` and `privacy.md` together.
- Dropping ads would be the time to revisit the trader declaration.

## Sources

* `terms.md`
* `privacy.md`
* `lib/services/ads.dart`
