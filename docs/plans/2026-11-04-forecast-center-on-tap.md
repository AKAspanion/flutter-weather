# Forecast Centre On Tap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: the project's workflow policy names the executor (`run.executor`): ga:implement-with-subagents by default, or ga:implement. Follow the policy and this plan's Checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking.

**Status:** complete

**Goal:** When a forecast chip or day card is tapped open, scroll its own list so the card ends up centred.

**Architecture:** One small helper, `centreInList`, scrolls the nearest enclosing list (and only that one) so a
widget's centre meets the list's centre. `HourlyDetail` and `DailyDetail` call it from their `AnimatedContainer`'s
`onEnd`, when the tap expanded the card.

**Tech Stack:** Flutter / Dart, `provider`, `flutter_test` widget tests. Android only.

**Spec:** [docs/specs/2026-11-04-forecast-center-on-tap.md](../specs/2026-11-04-forecast-center-on-tap.md)

## Global Constraints

- Android only ([decisions/android-only](../../knowledge/decisions/android-only.md)): no iOS work or checks.
- New and changed Dart: `dart format` at page width 120, callbacks typed as function types, `package:flutterweather/...`
  imports, `///` comments that say why ([knowledge/project/conventions.md](../../knowledge/project/conventions.md)).
- Tests live in `test/<subject>_test.dart` with their fakes in the same file; no network.
- Spec §3: the scroll uses `alignment: 0.5`, `duration` 400 ms and `Curves.easeOutCubic`.
- Both lists stay lazy (`ListView.builder`), and how a card looks open or closed doesn't change.

## Checkpoints

None (`run.checkpoints: none`).

---

### Task 1: Centre a card in its list when it is tapped open

**Files:**
- Create: `lib/components/centre_in_list.dart`
- Modify: `lib/views/forecast/hourly_detail_chip.dart`
- Modify: `lib/views/forecast/daily_detail_card.dart`
- Test: `test/centre_in_list_test.dart`

**Interfaces:**
- Consumes: existing `HourlyDetail({accent, detail})` and `DailyDetail({accent, detail})`, which read `UnitManager`
  from `Provider` and `AppLocalizations` from the context.
- Produces: `centreInList`.

```dart
// lib/components/centre_in_list.dart
/// Scrolls the list nearest [context] (and no list around it) so the widget's centre meets the list's centre.
/// Does nothing when [context] isn't inside a list or is no longer mounted.
Future<void> centreInList(BuildContext context);
```

**Spec:**
- §1: "When a tap expands a chip or a card, once its expand animation ends (the `AnimatedContainer`'s `onEnd`), the list it sits in scrolls so the card's centre lines up with the list's centre: horizontally for an hourly chip, vertically for a day card."
- §2: "The chip calls `ensureVisible` on its own list's `ScrollPosition` (`Scrollable.of(context).position`), not `Scrollable.ensureVisible`, which would also scroll the panel vertically to centre the whole hourly strip."
- §4: "a list can't scroll past its first or last item, so the first and last cards go as near the centre as the list allows; nothing is padded to let them reach it."
- §5: "Tapping an expanded card closes it where it is."
- §7: "A card that is scrolled away or unmounted before its animation ends does nothing (it checks `mounted`)."

**Tags:** `screen`

**Knowledge:**
- `features/forecast`: tapping a chip or day card open scrolls its own list so it is centred, after it has expanded;
  closing doesn't scroll.
- `design-system/components`: `centreInList` in `lib/components/centre_in_list.dart`.

**Acceptance:**
- Twelve `HourlyDetail` chips in a horizontal `ListView` 360 wide: tapping the chip whose right edge is past 300
  expands it to 200 wide, and after `pumpAndSettle` its centre x is within 1 px of 180.
- Tapping the first chip expands it and the list's offset stays 0; nothing throws.
- Tapping that expanded chip again closes it to 80 wide and the list's offset is unchanged.
- The horizontal list inside a vertical outer `ListView`, scrolled to offset 50: centring a chip leaves the outer
  offset at 50.
- In `Locale('ar')` (right to left), the edge-chip case also ends with the chip's centre within 1 px of the list's
  centre.
- Eight `DailyDetail` cards in a vertical `ListView` 800 tall: tapping the last card on screen expands it, and after
  `pumpAndSettle` its centre y is within 1 px of the list's centre.
- `centreInList` on a context with no enclosing list returns without throwing.

- [x] **Step 1: Create `centre_in_list.dart` with the signature above and an empty body**, so the tests fail on behaviour
- [x] **Step 2: Write the failing tests** for each Acceptance case, in `test/centre_in_list_test.dart`
- [x] **Step 3: Run them to verify they fail**

Run: `flutter test test/centre_in_list_test.dart`
Expected: FAIL on the assertions.

- [x] **Step 4: Write the minimal implementation**: the helper, and each card's `onEnd` calling it when `expanded` is true
- [x] **Step 5: Run them to verify they pass**

Run: `flutter test test/centre_in_list_test.dart test/hourly_detail_chip_test.dart`
Expected: PASS

- [x] **Step 6: Commit**

```bash
git add lib/components/centre_in_list.dart lib/views/forecast/hourly_detail_chip.dart lib/views/forecast/daily_detail_card.dart test/centre_in_list_test.dart
git commit -m "Centre a forecast chip or day card in its own list once it has expanded."
```
