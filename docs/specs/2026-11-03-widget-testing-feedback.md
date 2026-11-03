# Widget and theme fixes from internal testing

Date: 2026-11-03. Branch: `feat/widget-testing-feedback`.

## Why

Internal testing of the release build reported seven issues with the home-screen widget and the theme:

1. The pin dialog's preview of the widget is a thin pill showing only "LISBON … NOW" (Samsung One UI).
2. The widget should also come as a 2x2 card.
3. The widget should show only its first page, Now, not the next 24 hours.
4. The app should follow the system dark-mode setting and apply it on its own.
5. The widget should follow the accent picked in the app.
6. The widget's weather icon doesn't animate as it does in the app.
7. Tapping "Add" in the pin dialog should go to the home screen, not stay in the app.

Decided with the developer (all drafts, recorded in the knowledge base):

- [decisions/widget-one-resizable-card](../../knowledge/decisions/widget-one-resizable-card.md): one resizable widget
  down to 2x2, Now only.
- [decisions/theme-follows-system](../../knowledge/decisions/theme-follows-system.md): follow the system; the button
  overrides until the system brightness next changes.
- [decisions/widget-animated-icons](../../knowledge/decisions/widget-animated-icons.md): frame animations in a
  `ProgressBar`, about 1.5 MB.

Still holds: [decisions/widget-uses-last-place](../../knowledge/decisions/widget-uses-last-place.md) (the background
refresh uses the last place viewed) and [decisions/android-only](../../knowledge/decisions/android-only.md).

## What changes

### 1. The widget becomes one plain card (items 2 and 3)

- `weather_widget.xml` becomes the Now card itself: a root with the accent background, clipped to its outline, holding
  the current layout of `weather_widget_item.xml` without the two page dots, plus the `widget_empty` view.
- New `weather_widget_small.xml` for narrow cards: city on top, the icon with the temperature, the description, and
  the high/low line. No sunrise/wind/humidity row and no "updated" line.
- Removed: the `StackView`, `weather_widget_item.xml`, `weather_widget_hours.xml`, `weather_widget_hour.xml`,
  `widget_dot.xml`, both `widget_page_background.xml` files, and in `WeatherWidgetProvider.kt` `flattenStack`,
  `sizedTo`, `hoursCard`, `hoursFor`, the collection adapter, `openAppTemplate`, `FRAME_PADDING`, `SLACK` and
  `SQUARE_RATIO`.
- `render` builds one `RemoteViews` per reported size on Android 12+ (as today, `RemoteViews(Map<SizeF, RemoteViews>)`)
  and one from `portraitSize` before 12. A card narrower than a width constant in the provider (a 2-cell card is about
  110–160 dp wide, 3 cells about 200 dp) uses the small layout; the constant's value is set and commented there.
- Amended after testing on a Galaxy (One UI), 2026-11-03: One UI reports a 3x2 card as `235.52x217.6` dp and draws it
  scaled by `hsResizeRatio` (`0.8333`), so 3 cells got the wide layout and ellipsized. Now:
  - The wide layout (`weather_widget.xml`) is used only when the reported width is at least `WIDE_WIDTH = 300` dp
    (full width, 4 cells). Everything narrower uses the compact layout (`weather_widget_small.xml`).
  - The compact layout: the city / NOW header; line 1 the icon and the temperature; line 2 a subtitle, the description
    then the high/low. No text in it ellipsizes: the city and the subtitle wrap onto another line instead.
  - The compact layout shows the sunrise / wind / humidity row while the reported width is at least
    `DETAILS_WIDTH = 220` dp (3 cells), and hides it below (2x2). "Updated" appears only in the wide layout.
  - `SMALL_WIDTH` goes, replaced by those two constants.
- Amended again after the Galaxy check, 2026-11-03 (One UI reports 2x2 as `150.19x217.6`, 3x2 as `235.52x217.6` and
  4x2 as `320.85x217.6` dp):
  - Compact layout, wide cards (width at least height): the icon + temperature row and the subtitle form one block,
    centred vertically between the header and the details row, with no band between them. The icon and temperature
    grow up to the `1.6`x cap, so a 3x2 reaches about `48sp` / `64dp`.
  - Compact layout, tall cards (height greater than width, e.g. 2x2): the icon sits centred above the temperature, and
    both scale with the height, so a 2x2 temperature reaches about `43sp`.
  - New mini layout (`weather_widget_mini.xml`) for a card shorter than `STRIP_HEIGHT = 150` dp (one row: 1x2, 1x3,
    1x4 in the launcher's words) or narrower than `MINI_WIDTH = 110` dp (one column, 1x1): only the temperature,
    centred and scaled to fill the card, with the animated icon before it when the card is at least `MINI_WIDTH`
    wide. No city, description or details; nothing ellipsizes. The card's accent background and tap-to-open stay.
  - `weather_widget_info.xml`: `minResizeWidth` and `minResizeHeight` become `40dp`, so the launcher allows one row
    and one cell. The default 4x2, the picker and the pin dialog stay as they are.
- `weather_widget_info.xml`: `minResizeWidth` and `minResizeHeight` become `110dp`. `minWidth`, `minHeight` and
  `targetCellWidth`/`targetCellHeight` (4x2) stay, so the picker and the pin dialog still add a 4x2.
- The whole card, and the empty view, open the app with `HomeWidgetLaunchIntent.getActivity`.
- `strings.xml`: `widget_description` no longer mentions the next 24 hours or swiping, and `widget_next_24_hours`
  goes.
- `scaleFor` stays for both layouts.
- `lib/services/weather_widget.dart` stops sending `hours`: `_nextDay`, `_hourLabel`, `_isNight`, `_localTime`,
  `_hourColumns` and `_hourStep` go. The `city`, `now` and `updated` keys stay as they are.

### 2. The preview (item 1)

- `weather_widget_preview.xml` gets a fixed-size root, `250dp` by `110dp` (the widget's minimum size), and no row whose
  height depends on a weight, so a host that measures it at wrap-content can't collapse it. It shows the same sample
  values as now, on the default accent, without the page dots.

### 3. The widget uses the app's accent (item 5)

- One background drawable per gradient in `GradientValues`, `widget_background_<n>.xml` for each index, same angle,
  colours and corner radius as `widget_background.xml`, which is renamed `widget_background_0.xml` (the preview uses it).
- `WeatherWidget.setAccent(int index)` saves `accent` with `HomeWidget.saveWidgetData<int>` and calls `updateWidget`.
  `setAccent` and `getAccent` in `lib/main.dart` both call it, so a user who picked an accent before this version gets
  it on the widget at the next launch.
- The provider reads `accent` and sets the root's background with `backgroundFor(index)`, mapped one by one as
  `iconFor` is, so resource shrinking keeps the drawables. An unknown or missing index uses index 0.
- A comment on `GradientValues._gradients` says the widget maps the same indexes, so the order must not change and
  new gradients are added at the end with a drawable.
- The preview stays on the default accent; previews are static.

### 4. Animated icons (item 6)

- `tool/render_widget_icons_test.dart` gains a frames mode for the 11 weather icons: it renders each icon's loop as
  PNG frames into `drawable-nodpi` (`widget_icon_<name>_<nn>.png`), and writes `res/drawable/widget_anim_<name>.xml`
  (an `animation-list`, `oneshot="false"`) and `res/layout/widget_icon_<name>.xml` (a `ProgressBar`, id `card_icon`,
  `indeterminate="true"`, its `indeterminateDrawable` the list, `indeterminateOnly="true"`). Frame size and rate are
  picked so all frames together are about 1.5 MB or less; the chosen values sit in the tool as constants with a
  comment. The loop length per icon is measured from the Flare animation, not assumed.
- The static `widget_icon_<name>.png` files stay; the preview uses one of them.
- In both widget layouts the icon becomes a `FrameLayout` slot (`card_icon_slot`). The provider calls
  `removeAllViews` and `addView` with `iconLayoutFor(name)`, which replaces `iconFor` and is mapped one by one. The
  icon is sized with `setViewLayoutWidth`/`Height` on `card_icon` on Android 12+, as today.
- The detail icons (sunrise, wind, humidity) stay static.
- `run-locally.md` documents the new command.

### 5. "Add" goes to the home screen (item 7)

- `MainActivity` registers a `MethodChannel` (`in.spanion.weather/widget`) with one method, `pin`. It calls
  `AppWidgetManager.requestPinAppWidget(ComponentName(this, WeatherWidgetProvider::class.java), null, callback)`.
- `callback` is a `PendingIntent.getActivity` for `Intent.ACTION_MAIN` with `Intent.CATEGORY_HOME` and
  `FLAG_ACTIVITY_NEW_TASK`, `FLAG_IMMUTABLE`. On Android 14+ it is created with
  `ActivityOptions.setPendingIntentCreatorBackgroundActivityStartMode(MODE_BACKGROUND_ACTIVITY_START_ALLOWED)`, since
  the launcher sends it.
- The method returns false when pinning isn't supported. `WeatherWidget.pin` calls the channel instead of
  `HomeWidget.requestPinWidget`; `canPin` stays on `home_widget`. A failed call is caught and printed, as the other
  `WeatherWidget` methods do.

### 6. The theme follows the system (item 4)

- A pure function decides the theme: `resolveTheme(Brightness system, AppTheme? override, Brightness? overrideSystem)`
  returns `override` when it is set and `overrideSystem == system`, else the theme matching `system`.
- `ThemeManager` reads `WidgetsBinding.instance.platformDispatcher.platformBrightness` in its constructor, so the
  first frame already matches the system when there's no override. It listens as a `WidgetsBindingObserver`
  (`didChangePlatformBrightness`), added in the constructor and removed in `dispose`; replacing
  `onPlatformBrightnessChanged` would take it from the framework, which uses it to update `MediaQuery`. On a change it
  clears the override (memory and prefs) and notifies.
- Prefs: `theme_preference` keeps the override's index; new `theme_preference_system` holds the system brightness
  index it was set against. `setTheme` (the button) writes both. On load, a `theme_preference` without
  `theme_preference_system` is treated as set against the current system brightness, and the key is written then.
- `toggleTheme` in `lib/main.dart` is unchanged: it sets the opposite of the theme shown.
- `themeData`, `theme`, `bgColor` and `textColor` keep their signatures.

### 7. Knowledge

No task edits the knowledge base; each task's report lists what it changed, and the after-finish job writes it:

- `features/home-screen-widget.md`: one card, 2x2 compact layout, accent, animated icon, pin goes home; `## History`.
- `features/themes-and-accents.md`: follows the system with an override; the accent reaches the widget; the launch
  defaults rule changes; `## History`.
- `data/on-device-storage.md`: `theme_preference_system`, and the widget's `accent` key replacing `hours`.
- `operations/run-locally.md`: rendering the frames.
- `domain/condition-icons.md`: adding an icon name now needs its frames and layout.
- `risks/debt.md`, `project/architecture.md` where they mention the StackView or the hours page.

## Error handling

- Missing or malformed widget data shows the empty view, as now. A missing `accent` uses index 0.
- The pin channel failing (no launcher support, exception) leaves the app as it is and prints the error; the button is
  only shown when `canPin` is true.
- If the home intent can't start (background-start blocked by the device), the user stays in the app with the widget
  added: the same as today, nothing worse.

## Testing

- Test first, in `test/`:
  - `resolveTheme`: no override follows the system both ways; an override set against the current system wins; an
    override set against the other brightness is ignored.
  - `ThemeManager` loading: a legacy `theme_preference` alone is kept as an override and gets
    `theme_preference_system` written (with `SharedPreferences.setMockInitialValues`).
- The Kotlin, XML and pin parts have no test harness in this repo. They are checked on the developer's Samsung device
  at the end: the pin dialog preview, adding a 4x2 and shrinking to 2x2, the icon animating, an accent change reaching
  the widget, and "Add" landing on the home screen.
- `flutter analyze` and smoke at the end. The test suite runs when the developer asks.

## Out of scope

- A second picker entry for 2x2, a "follow system" control, and animating the detail icons (see the decisions).
- A `previewImage` PNG for launchers before Android 12: they show the app icon, as now.
- The widget following light/dark: the card is always the accent gradient with white text.
- Lowering battery cost by stopping the animation after a while: RemoteViews can't stop it without re-rendering.
