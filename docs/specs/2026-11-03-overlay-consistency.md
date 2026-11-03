# Theme in settings, and one design for every overlay

Date: 2026-11-03. Branch: `feat/settings-menu` (lands in the open settings-menu pull request).

## Why

Feedback on the settings menu, tried on a phone: the dark theme toggle should live in settings with the other
choices; every close action should sit at the top right, as the forecast panel's already does, not at the bottom;
and the overlays should share one design language. Today the city dialog, the language picker and the settings
panel each have their own width, their own close position and their own way of marking a choice.

## Decisions this rests on

- [decisions/settings-panel](../../knowledge/decisions/settings-panel.md): every setting is a row in the settings
  panel; edited here so the theme moves in too.
- [decisions/overlays-share-one-card](../../knowledge/decisions/overlays-share-one-card.md): the overlays share one
  card, with the title at the top start and the close at the top end.
- [docs/specs/2026-11-03-settings-menu.md](2026-11-03-settings-menu.md): the panel, rows and toggle this changes.

## What changes

### 1. One overlay card

`lib/components/overlay_card.dart` (`OverlayCard`), a new shared widget, used by the city dialog, the language picker
and the settings panel:

- A full-screen `Colors.black87` background, and a card centred on it: `ThemeManager.bgColor`, radius 12, the
  `BoxShadow(color: Colors.black38, blurRadius: 40.0)` the overlays already use, width `size.width - 64`, at most
  `size.height - 100` tall.
- A header row: the title, upper-cased, bold, 16, in `ThemeManager.textColor`, at the top start; an `Icons.close`
  `IconButton` at the top end, its tooltip `MaterialLocalizations.closeButtonTooltip`. Start and end mirror in
  Arabic and Urdu.
- Below the header, the overlay's own content, which scrolls when it doesn't fit.
- Padding: 24 above the header, 12 at the bottom, 12 at the start and end (so `ListTile` rows line up with the
  title).

### 2. Settings panel

- Built on `OverlayCard` with the title "SETTINGS"; its bottom close button is gone.
- A **Theme** row, first in the list: a two-part toggle, ☀ (`Icons.wb_sunny`) for light and ☾
  (`Icons.brightness_3`) for dark, styled exactly like the °C / °F toggle: the current one filled with the accent
  colour and drawn white, the other transparent in the text colour. Tapping one calls
  `ThemeManager.setTheme(AppTheme.White)` or `setTheme(AppTheme.Dark)`; the panel stays open and recolours at once.
  The two segments are read aloud as "Light" and "Dark".
- Rows, top to bottom: Theme, Language, Temperature, Rate on Google Play.
- The two toggles share one widget, so they can't drift apart: `SegmentedChoice<T>` in
  `lib/components/segmented_choice.dart`.

### 3. Menu row

- `MenuButtons` loses the theme button, `onTheme` and `themeIcon`. The row is refresh, widget (when the phone can pin
  widgets), gear, location, close: five buttons, or four. They keep their 56 dp size and stay spread between the far
  corners.
- `lib/main.dart` drops `toggleTheme` and the sun/moon icon it passed.
- The accent carousel and the PRIVACY button stay in the menu.

### 4. Language picker

- Built on `OverlayCard` with the title "LANGUAGE"; its bottom close button is gone. Rows and the accent check mark
  are unchanged.

### 5. City dialog

- Built on `OverlayCard` with the title "CITY"; its bottom close and Done buttons are gone.
- The text field keeps its "City name" label and city icon; a ✓ (`Icons.done`) in the accent colour sits at the end
  of the field and submits. The keyboard's action key is Done (`TextInputAction.done`) and submits too.
- What submitting does is unchanged: the typed text goes to `onSubmit`, as before.
- `onSubmit` and `onCancel` become typed callbacks (`void Function(String)`, `void Function()`), as
  [decisions/code-style-120-typed](../../knowledge/decisions/code-style-120-typed.md) asks of changed code.

### 6. Strings

New keys in all ten `.arb` files, with `@key` descriptions in `app_en.arb`, drafted in the other nine and left
unreviewed:

- `theme`: "Theme"
- `lightTheme`: "Light"
- `darkTheme`: "Dark"
- `city`: "City"

## Testing

Test first where it's behaviour:

- `OverlayCard`: shows its title upper-cased; the close button is at the top end (its centre right of the title's
  and above the content) and calls `onClose`; in Arabic it is at the top left.
- `SegmentedChoice`: marks the selected value; tapping another calls back with it; tapping the selected one doesn't.
- Settings panel: a Theme row shows ☀ and ☾; tapping ☾ sets `ThemeManager.theme` to `AppTheme.Dark` and the panel
  stays; rows come in the order Theme, Language, Temperature, Rate on Google Play; there is no close button below
  the rows.
- Menu buttons: no theme button; with the widget button, five buttons in the order refresh, widget, gear, location,
  close; without it, four.
- Language picker: its close is in the header.
- City dialog: the ✓ in the field submits the typed text; the keyboard's done action submits it; the header close
  calls `onCancel`.
- `test/arb_files_test.dart` checks the new keys in every file.
- At the end: `flutter analyze` and a debug build, then the same walk-through on the phone.

## Out of scope

- Restyling the menu buttons, the forecast panel or the home card (the forecast's close is already at the top
  right).
- Moving the accent carousel or the PRIVACY button.
- Changing what the city search does with the text.
