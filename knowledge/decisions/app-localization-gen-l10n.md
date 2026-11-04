---
type: Decision
title: Translate the app with Flutter gen_l10n and drafted .arb files
description: In-app text lives in .arb files compiled by gen_l10n; Claude drafts the translations and they stay marked unreviewed until a native speaker checks them.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-03T07:29:23Z }
verified: human:panditankit1995@gmail.com
---

# Translate the app with Flutter gen_l10n and drafted .arb files

## Context

Play Console reported "Your app text is not automatically translated". Play's automatic translation reads only
Android string resources, and the app's only ones are the five widget strings in
`android/app/src/main/res/values/strings.xml`. Every other string was hard-coded English in Dart.

Two ways were weighed:

- Flutter's own `gen_l10n`: `.arb` files compiled into a typed `AppLocalizations` class. Standard, checked at compile
  time, works in debug builds. Play doesn't translate `.arb` files, so someone has to supply each language.
- Keeping every string in Android `strings.xml` and reading it from Flutter over a platform channel, so Play's
  translation covers the whole app. Possible because the app is [Android only](android-only.md), but not standard
  Flutter, with no compile-time keys, English-only debug builds, and reliance on Play behaviour that can't be tested
  locally.

## Decision

The developer chose `gen_l10n` on 2026-11-03. English (`app_en.arb`) is the source. Claude drafts the other languages
([supported languages](supported-languages.md)); each drafted file stays marked unreviewed until a native speaker
checks it: the nine files carry `"@@x-reviewed": false` as their second entry, and a native speaker's review is to
flip it. `test/arb_files_test.dart` checks the marker, the keys and the placeholders of every file.

## Consequences

- The drafted Russian `nextDaysSubtitle` has no `=1` form: gen_l10n folds `=1` into `one`, so one day reads
  "Прогноз на 1 день".
- The generated `AppLocalizations` files (`app_localizations` plus the language, in `lib/l10n/`) are git-ignored (`./.gitignore`) and come from `flutter pub get` or
  `flutter gen-l10n`; `l10n.yaml` and `generate: true` in `pubspec.yaml` set it up.
- A new language is one more `.arb` file plus its entry in the language picker.
- Play's notice keeps saying the app text isn't automatically translated, except for the widget's own `strings.xml`,
  which gets a translation per language.
- The background widget refresh has no `BuildContext`, so it looks strings up by locale with the generated
  `lookupAppLocalizations`.

## History

- 2026-11-03: now records the `@@x-reviewed` marker, Russian's missing `=1` form and the git-ignored generated files, because they were settled while building. See [language picker](../features/language-picker.md).

## Sources

* `docs/specs/2026-11-03-app-localization.md`
* `android/app/src/main/res/values/strings.xml`
* `l10n.yaml`
* `lib/l10n/app_fr.arb`
* `test/arb_files_test.dart`
