# Overlay Consistency Implementation Plan

**Status:** complete

> **For agentic workers:** REQUIRED SUB-SKILL: the project's workflow policy names the executor (`run.executor`): ga:implement-with-subagents by default, or ga:implement. Follow the policy and this plan's Checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the theme toggle into the settings panel and give the city dialog, the language picker and the
settings panel one shared card with the title at the top start and the close button at the top end.

**Architecture:** Two shared widgets in `lib/components/`: `OverlayCard` (backdrop, card, header with title and
close, scrolling content) and `SegmentedChoice<T>` (the accent-filled two-part toggle). The three overlays are
rebuilt on `OverlayCard`; the settings panel's theme and temperature rows use `SegmentedChoice`. The menu row loses
its theme button.

**Tech Stack:** Flutter / Dart, `provider`, `shared_preferences`, `flutter_localizations` + `intl` (`gen_l10n`,
`lib/l10n/app_<code>.arb`). Android only.

**Spec:** [docs/specs/2026-11-03-overlay-consistency.md](../specs/2026-11-03-overlay-consistency.md)

## Global Constraints

- Android only ([decisions/android-only](../../knowledge/decisions/android-only.md)): no iOS work or checks.
- New and changed Dart: `dart format` at page width 120, callbacks typed as function types, `package:flutterweather/...`
  imports, `///` comments that say why ([knowledge/project/conventions.md](../../knowledge/project/conventions.md)).
- Tests live in `test/<subject>_test.dart` with their fakes in the same file; no network.
- Generated `lib/l10n/app_localizations*.dart` files are not committed; run `flutter pub get` after changing an `.arb`
  file, before running tests.
- Start and end, never left and right, for the header: Arabic and Urdu mirror it.
- Card values, from spec §1: background `Colors.black87`; card colour `ThemeManager.bgColor`; radius 12;
  `BoxShadow(color: Colors.black38, blurRadius: 40.0)`; width `size.width - 64`; at most `size.height - 100` tall;
  padding 24 top, 12 bottom, 12 start and end; title upper-cased, bold, size 16, `ThemeManager.textColor`.

## Checkpoints

None (`run.checkpoints: none`). The run goes from Task 1 to the end without stopping.

---

### Task 1: Foundation: OverlayCard, SegmentedChoice and the strings

**Files:**
- Create: `lib/components/overlay_card.dart`
- Create: `lib/components/segmented_choice.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_zh.arb`, `lib/l10n/app_hi.arb`, `lib/l10n/app_es.arb`,
  `lib/l10n/app_ar.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_bn.arb`, `lib/l10n/app_pt.arb`, `lib/l10n/app_ru.arb`,
  `lib/l10n/app_ur.arb`
- Test: `test/overlay_card_test.dart`, `test/segmented_choice_test.dart`

**Interfaces:**
- Consumes: existing `ThemeManager` (`bgColor`, `textColor`) from `lib/services/theme_manager.dart`.
- Produces: `OverlayCard`, `SegmentedChoice<T>`, `SegmentedOption<T>`, and the `AppLocalizations` getters `theme`,
  `lightTheme`, `darkTheme`, `city`.

```dart
// lib/components/overlay_card.dart
/// Reads ThemeManager from Provider. Returns a Positioned.fill, so it goes straight into a Stack.
class OverlayCard extends StatelessWidget {
  const OverlayCard({super.key, required String title, required void Function() onClose, required Widget child});
}

// lib/components/segmented_choice.dart
class SegmentedOption<T> {
  final T value;
  final Widget child;       // a Text or an Icon
  final String? semanticLabel;
  const SegmentedOption({required this.value, required this.child, this.semanticLabel});
}

/// The selected option is filled with [accent] and drawn white; the others are transparent in [textColor].
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required List<SegmentedOption<T>> options,
    required T selected,
    required Color accent,
    required Color textColor,
    required void Function(T value) onChanged, // not called for the already-selected option
  });
}
```

**Spec:**
- §1: "`lib/components/overlay_card.dart` (`OverlayCard`), a new shared widget, used by the city dialog, the language picker and the settings panel:"
- §1: "A header row: the title, upper-cased, bold, 16, in `ThemeManager.textColor`, at the top start; an `Icons.close` `IconButton` at the top end, its tooltip `MaterialLocalizations.closeButtonTooltip`. Start and end mirror in Arabic and Urdu."
- §1: "Below the header, the overlay's own content, which scrolls when it doesn't fit."
- §2: "The two toggles share one widget, so they can't drift apart: `SegmentedChoice<T>` in `lib/components/segmented_choice.dart`."
- §6: "New keys in all ten `.arb` files, with `@key` descriptions in `app_en.arb`, drafted in the other nine and left unreviewed:"

**Knowledge:**
- `design-system/components`: `OverlayCard` and `SegmentedChoice` in `lib/components/` are the shared overlay card
  and two-part toggle.

**Acceptance:**
- `app_en.arb` holds `theme` = "Theme", `lightTheme` = "Light", `darkTheme` = "Dark", `city` = "City", and
  `test/arb_files_test.dart` passes with the four keys in all ten files.
- `OverlayCard(title: 'Settings', ...)` shows "SETTINGS".
- In a left-to-right locale, the close button's centre is right of the title's centre and above the child's top;
  in `Locale('ar')` its centre is left of the title's centre.
- Tapping the close button calls `onClose` once; its tooltip is `MaterialLocalizations.closeButtonTooltip`.
- A child taller than the screen scrolls inside the card and the header stays on screen (no overflow error).
- `SegmentedChoice` with options `°C`, `°F` and `selected` °C: the °C segment's decoration colour is the accent, the
  °F one's is transparent; tapping °F calls `onChanged` with °F once; tapping °C calls nothing.
- An option with `semanticLabel: 'Dark'` is found by `find.bySemanticsLabel('Dark')`.

- [x] **Step 1: Add the four keys to all ten `.arb` files and run `flutter pub get`**, so `AppLocalizations` has the new getters
- [x] **Step 2: Create both widgets with the signatures above and an empty build**, so the tests fail on behaviour
- [x] **Step 3: Write the failing tests** for each Acceptance case, in `test/overlay_card_test.dart` and `test/segmented_choice_test.dart`
- [x] **Step 4: Run them to verify they fail**

Run: `flutter test test/overlay_card_test.dart test/segmented_choice_test.dart`
Expected: FAIL on the assertions.

- [x] **Step 5: Write the minimal implementation** to the Interfaces, until they pass
- [x] **Step 6: Run them to verify they pass**

Run: `flutter test test/overlay_card_test.dart test/segmented_choice_test.dart test/arb_files_test.dart`
Expected: PASS

- [x] **Step 7: Commit**

```bash
git add lib/components/overlay_card.dart lib/components/segmented_choice.dart lib/l10n/app_en.arb lib/l10n/app_zh.arb lib/l10n/app_hi.arb lib/l10n/app_es.arb lib/l10n/app_ar.arb lib/l10n/app_fr.arb lib/l10n/app_bn.arb lib/l10n/app_pt.arb lib/l10n/app_ru.arb lib/l10n/app_ur.arb test/overlay_card_test.dart test/segmented_choice_test.dart
git commit -m "Add the shared overlay card, the two-part toggle and the theme and city strings."
```

---

### Task 2: Theme in settings, and the menu row without it

**Files:**
- Modify: `lib/views/settings/settings_overlay.dart`
- Modify: `lib/views/menu/menu_buttons.dart`
- Modify: `lib/main.dart`
- Test: `test/settings_overlay_test.dart`, `test/menu_buttons_test.dart`

**Interfaces:**
- Consumes from Task 1: `OverlayCard`, `SegmentedChoice`, `SegmentedOption`, and the getters `theme`, `lightTheme`, `darkTheme`.
- Consumes: existing `ThemeManager.setTheme`, `ThemeManager.theme`, `AppTheme`, `UnitManager`, `LocaleManager`.
- Produces: `MenuButtons` without `onTheme` and `themeIcon`; `SettingsOverlay`'s constructor unchanged.

```dart
// lib/views/menu/menu_buttons.dart: the two parameters are removed
const MenuButtons({
  super.key,
  required void Function() onRefresh,
  void Function()? onPinWidget,
  required void Function() onSettings,
  required void Function() onLocation,
  required void Function() onClose,
});
```

**Spec:**
- §2: "its bottom close button is gone."
- §2: "A **Theme** row, first in the list: a two-part toggle, ☀ (`Icons.wb_sunny`) for light and ☾ (`Icons.brightness_3`) for dark, styled exactly like the °C / °F toggle"
- §2: "Rows, top to bottom: Theme, Language, Temperature, Rate on Google Play."
- §3: "`MenuButtons` loses the theme button, `onTheme` and `themeIcon`."
- §3: "`lib/main.dart` drops `toggleTheme` and the sun/moon icon it passed."
- §3: "The accent carousel and the PRIVACY button stay in the menu."

**Tags:** `screen`

**Knowledge:**
- `features/settings`: rows are Theme, Language, Temperature, Rate on Google Play; the panel is built on `OverlayCard`.
- `features/themes-and-accents`: the light/dark choice is the settings panel's Theme row; the accents stay in the menu.
- `design-system/components`: `MenuButtons` is refresh, widget, gear, location, close.

**Acceptance:**
- The settings panel's rows appear top to bottom as Theme, Language, Temperature, Rate on Google Play.
- The Theme row shows `Icons.wb_sunny` and `Icons.brightness_3`; with `ThemeManager.theme` `AppTheme.White`, tapping
  ☾ makes it `AppTheme.Dark`, the panel is still on screen, and `onClose` was not called.
- The two segments are read aloud as "Light" and "Dark".
- The Temperature row still switches °C to °F and calls `onUnitChanged` after the save (existing cases pass).
- The panel's only `Icons.close` is in the header, above the Theme row, and tapping it calls `onClose`.
- `MenuButtons` with `onPinWidget` shows, in order, `Icons.refresh`, `Icons.widgets`, `Icons.settings`,
  `Icons.location_on`, `Icons.close`; without it, the same four without `Icons.widgets`; it shows no
  `Icons.wb_sunny` or `Icons.brightness_3`; the size cases in `test/menu_buttons_test.dart` still pass for five and
  four buttons.
- `flutter analyze lib/main.dart` reports no issues, and `lib/main.dart` no longer contains `toggleTheme`.

- [x] **Step 1: Remove `onTheme` and `themeIcon` from `MenuButtons` and its caller in `main.dart`**, so the tests compile
- [x] **Step 2: Write the failing tests** for each Acceptance case, in `test/settings_overlay_test.dart` and `test/menu_buttons_test.dart`
- [x] **Step 3: Run them to verify they fail**

Run: `flutter test test/settings_overlay_test.dart test/menu_buttons_test.dart`
Expected: FAIL on the assertions.

- [x] **Step 4: Write the minimal implementation**: the panel on `OverlayCard`, the Theme row first, both toggles as `SegmentedChoice`, and `toggleTheme` gone from `main.dart`
- [x] **Step 5: Run them to verify they pass**

Run: `flutter test test/settings_overlay_test.dart test/menu_buttons_test.dart`
Expected: PASS

- [x] **Step 6: Commit**

```bash
git add lib/views/settings/settings_overlay.dart lib/views/menu/menu_buttons.dart lib/main.dart test/settings_overlay_test.dart test/menu_buttons_test.dart
git commit -m "Move the theme toggle into settings and build the panel on the shared overlay card."
```

---

### Task 3: The language picker and the city dialog on the shared card

**Files:**
- Modify: `lib/views/home/language_overlay.dart`
- Modify: `lib/views/home/dialog_overlay.dart`
- Test: `test/language_overlay_test.dart`, `test/dialog_overlay_test.dart`

**Interfaces:**
- Consumes from Task 1: `OverlayCard` and the getter `city`.
- Consumes: existing `LocaleManager`, `supportedLanguages`, `ThemeManager`, `GradientValues`; `main.dart`'s existing
  `DialogOverlay(accent:, onCancel: () => toggleDialog(false), onSubmit: (city) => onSubmit(city))` call, which
  compiles unchanged against the typed callbacks.
- Produces: `DialogOverlay` with typed callbacks.

```dart
// lib/views/home/dialog_overlay.dart
class DialogOverlay extends StatefulWidget {
  const DialogOverlay({super.key, required int accent, required void Function(String city) onSubmit,
      required void Function() onCancel});
}
```

**Spec:**
- §4: "Rows and the accent check mark are unchanged."
- §5: "its bottom close and Done buttons are gone."
- §5: "label and city icon; a ✓ (`Icons.done`) in the accent colour sits at the end of the field and submits. The keyboard's action key is Done (`TextInputAction.done`) and submits too."
- §5: "What submitting does is unchanged: the typed text goes to `onSubmit`, as before."

**Tags:** `screen`

**Knowledge:**
- `features/language-picker`: the picker is built on `OverlayCard`, closed from the header.
- `features/city-search`: the dialog has a CITY title, a ✓ inside the field and the keyboard's Done key to submit,
  and a header close.

**Acceptance:**
- The language picker shows the title "LANGUAGE"; its only `Icons.close` is in the header, above "System default";
  tapping it closes without changing the language (existing case); the other existing cases still pass.
- The city dialog shows the title "CITY" and the "City name" field.
- Typing "Paris" and tapping the ✓ in the field calls `onSubmit` with "Paris" once.
- Typing "Paris" and sending `TextInputAction.done` calls `onSubmit` with "Paris" once.
- Tapping the header close calls `onCancel` once and not `onSubmit`.
- The city dialog has exactly one `Icons.done` and one `Icons.close`.

- [x] **Step 1: Type `DialogOverlay`'s callbacks as above**, so the tests compile
- [x] **Step 2: Write the failing tests** for each Acceptance case, in `test/language_overlay_test.dart` and `test/dialog_overlay_test.dart`
- [x] **Step 3: Run them to verify they fail**

Run: `flutter test test/language_overlay_test.dart test/dialog_overlay_test.dart`
Expected: FAIL on the assertions.

- [x] **Step 4: Write the minimal implementation**: both overlays on `OverlayCard`, the ✓ as the field's suffix, the keyboard's done action wired to submit
- [x] **Step 5: Run them to verify they pass**

Run: `flutter test test/language_overlay_test.dart test/dialog_overlay_test.dart`
Expected: PASS

- [x] **Step 6: Commit**

```bash
git add lib/views/home/language_overlay.dart lib/views/home/dialog_overlay.dart test/language_overlay_test.dart test/dialog_overlay_test.dart
git commit -m "Build the language picker and the city dialog on the shared overlay card."
```
