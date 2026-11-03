# SDD ledger — plan: docs/plans/2026-11-03-widget-testing-feedback.md
Plugin: ga 2.15.0 (e989938)
Policy: git.commit=task; run.checkpoints=none; run.unattended=false; run.on-conflict=stop; run.on-plan-defect=rule; run.max-fix-rounds=2; review.when=off; review.minors=defer; knowledge.update=after-finish
Run base: aba6c596ec80629816252d6049a2d0658b915a82
Pre-flight: Task 1 / Task 2: Task 2 consumes Task 1's two layouts (card_icon ImageView) and iconFor, and replaces them with card_icon_slot and iconLayoutFor; consistent
Pre-flight: Task 1 / Task 3: both change lib/services/weather_widget.dart and test/weather_widget_test.dart; Task 1 leaves pin() as it is, Task 3 changes only pin(); consistent, Task 3 waits for Task 1
Pre-flight: Task 4: shares no file or interface with any other task
Pre-flight: Task 1 self: tests cover the Dart payload; the Kotlin side is checked by the debug build; the preview keeps a static icon and widget_background_0; consistent
Pre-flight: Task 2 self: the resources test reads generated files and the provider as text; staged by quoted glob pathspecs; consistent
Pre-flight: Task 3 self: consistent
Pre-flight: Task 4 self: resolveTheme and the ThemeManager cases agree with the spec's amended observer wording; consistent
Task 1: started 2026-11-03 13:05 (worktree from aba6c59)
Task 4: started 2026-11-03 13:05 (worktree from aba6c59)
Task 4: agent implementer a4d906496aa11a811
Task 4: merged (305b2c5..305b2c5)
Task 4: complete (commits aba6c59..305b2c5, not reviewed)
Progress: 1/4 tasks — Task 4 The theme follows the system — 1/4 tasks — Task 4 The theme follows the system — ThemeManager follows the system brightness, with the button as an override until it changes
Task 1: agent implementer ab251be80c05ab0b4
Ruling: Task 2: card_icon is 64dp in weather_widget.xml and 40dp in weather_widget_small.xml (Task 1 made the small one 40dp so it fits 110dp); size card_icon_slot and the ProgressBar per layout to those values, and scale them per layout in the provider — 64dp plus three text lines can't fit a 110dp card — the 2x2 icon is smaller than the 4x2's; a later resize of either layout
Task 1: merged (236a46b..236a46b)
Task 1: complete (commits aba6c59..236a46b, not reviewed)
Progress: 2/4 tasks — Task 1 The widget as one Now card, resizable to 2x2, in the app's accent — 2/4 tasks — Task 1 Widget as one Now card — one RemoteViews card, 2x2 compact layout under 220dp, accent backgrounds, fixed-size preview
Task 2: started 2026-11-03 13:13 (worktree from 236a46b)
Task 3: started 2026-11-03 13:13 (worktree from 236a46b)
Task 3: agent implementer a5ad75c394e47dbc5
Task 3: merged (0ec31c9..0ec31c9)
Task 3: complete (commits 236a46b..0ec31c9, not reviewed)
Progress: 3/4 tasks — Task 3 "Add" in the pin dialog goes to the home screen — 3/4 tasks — Task 3 Add goes to the home screen — MainActivity pins with a callback that opens the launcher
Task 2: agent implementer ae6c993b8c16a5922
Note: Task 2: clear and clear-night are static in cloudy.flr, so they stay still on the widget as in the app; the animation and the loop seam are unchecked until the device check
Task 2: merged (4a9818d..4a9818d)
Task 2: complete (commits 236a46b..4a9818d, not reviewed)
Progress: 4/4 tasks — Task 2 Animated widget icons — 4/4 tasks — Task 2 Animated widget icons — 8 fps frame loops at 112 px (1.2 MB) played by a ProgressBar in the icon slot
Note: Device test on Galaxy SM_S731B: One UI reports a 3x2 card as 235.52x217.6 dp with hsResizeRatio 0.8333, so it got the wide layout and ellipsized; the developer approved Task 5 (wide only from 300dp, compact two-line layout with no ellipsis below)
Task 5: started 2026-11-03 13:42
Task 5: agent implementer af7b4cdd44f3c82af
Task 5: complete (commits d93911f..ccbea55, not reviewed)
Progress: 5/5 tasks — Task 5 Compact layout below full width, with no ellipsis — 5/5 tasks — Task 5 Compact layout — wide only from 300dp; compact two-line layout with no ellipsis and the details row from 220dp
Note: Task 5: fix round 1 after device check (compact icon and temperature scale from the 2x2 size; commits ccbea55..b7cc9e4)
Ruling: Task 6: the plan's chain is 4 (Task 1, Task 2, Task 5, Task 6) and the fast pace allows 3; kept, since Task 5 and Task 6 are fixes found on the device that change the same provider in turn — they consume each other's code; splitting the file would be artificial — a later reader sees a plan that breaks the pace's chain rule
Task 6: started 2026-11-03 14:03
Task 6: agent implementer a0bf5293719079180
Task 6: complete (commits 143db3e..62c3ac3, not reviewed)
Progress: 6/6 tasks — Task 6 Spacing in the compact layout, and the one-row and one-cell mini layout — 6/6 tasks — Task 6 Spacing and mini layout — centred compact block, stacked 2x2, temperature-only one row and one cell
Run: finished 2026-11-03 14:18
