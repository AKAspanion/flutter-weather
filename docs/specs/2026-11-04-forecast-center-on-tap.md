# Centre a forecast card when it is tapped open

Date: 2026-11-04. Branch: `feat/forecast-center-on-tap`.

## Why

Tried on a phone: in the forecast panel, tapping a chip near the left or right edge of "Next hours", or a card near
the top or bottom of "Next days", expands it in place, so the detail it opens can end up half off screen. The
developer wants a tapped card to expand and move to the centre of its list.

## What is there

- "Next hours" is `HourlyView` (`lib/views/forecast/hourly.dart`), a horizontal `ListView.builder` of
  `HourlyDetail` chips (`lib/views/forecast/hourly_detail_chip.dart`). A tap toggles `expanded`, and an
  `AnimatedContainer` grows the chip from 80 to 200 wide over 500 ms.
- "Next days" is a `DailyDetail` card per day (`lib/views/forecast/daily_detail_card.dart`) inside the panel's
  vertical `ListView.builder` (`_buildList` in `lib/views/forecast/forecast.dart`). A tap toggles `expanded`, and the
  card's detail row grows from 0 to 104 tall over 500 ms.
- [features/forecast](../../knowledge/features/forecast.md): both lists are built lazily, and each card expands on its
  own; neither changes here.

## What changes

1. **Expanding centres the card in its own list.** When a tap expands a chip or a card, once its expand animation
   ends (the `AnimatedContainer`'s `onEnd`), the list it sits in scrolls so the card's centre lines up with the
   list's centre: horizontally for an hourly chip, vertically for a day card.
2. **Only that list moves.** The chip calls `ensureVisible` on its own list's `ScrollPosition`
   (`Scrollable.of(context).position`), not `Scrollable.ensureVisible`, which would also scroll the panel vertically
   to centre the whole hourly strip.
3. **The scroll:** `alignment: 0.5`, `duration: 400 ms`, `curve: Curves.easeOutCubic`.
4. **At the ends:** a list can't scroll past its first or last item, so the first and last cards go as near the
   centre as the list allows; nothing is padded to let them reach it.
5. **Collapsing doesn't scroll.** Tapping an expanded card closes it where it is.
6. **Right to left:** in Arabic and Urdu the hourly list runs right to left, and centring works the same.
7. A card that is scrolled away or unmounted before its animation ends does nothing (it checks `mounted`).

Expanding, then gliding to the centre, was chosen over doing both at once: centring needs the card's final size,
which is only known once it has finished growing.

Unchanged: one card expanding doesn't close another, and how a card looks open or closed.

## Testing

Test first, in widget tests:

- `HourlyDetail` in a horizontal list narrower than its chips: tapping a chip near the right edge expands it, and
  after settling its centre is within 1 px of the list's centre.
- The same with the first chip: the list stays at offset 0 (it can't centre the first chip), and nothing throws.
- Tapping an expanded chip again closes it and the scroll offset doesn't change.
- `DailyDetail` cards in a vertical list taller than the screen: tapping a card near the bottom expands it and after
  settling its centre is within 1 px of the list's centre.
- A chip inside a vertical outer list: expanding it scrolls the horizontal list only; the outer list's offset doesn't
  change.
- In `Locale('ar')` the hourly centring case passes too.
- At the end: `flutter analyze` and a debug build, then the same taps on the phone.

## Out of scope

- Closing other cards when one opens.
- Centring when the forecast panel opens, or on scroll.
