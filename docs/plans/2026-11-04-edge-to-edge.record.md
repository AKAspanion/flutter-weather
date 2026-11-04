# SDD ledger — plan: docs/plans/2026-11-04-edge-to-edge.md
Plugin: ga 2.15.0 (e989938)
Policy: git.commit=task; run.checkpoints=none; run.unattended=false; run.on-conflict=stop; run.on-plan-defect=rule; run.max-fix-rounds=2; review.when=off; review.minors=defer; knowledge.update=after-finish
Run base: 5c0027bd91917621ce31f0af3a9e231dcb13adcd
Pre-flight: Task 1 and Task 2 share no file or interface: Task 1 is MainActivity.kt and build.gradle.kts, Task 2 is system_insets.dart, main.dart and its test.
Pre-flight: Task 1: Acceptance asks for an emulator check that Steps 1-4 don't run; Task 2: Step 7's emulator check is in its own text. Both agree with their Files.
Ruling: The emulator checks (Task 1's second case, Task 2's Step 7) run once on the merged branch, not in the task worktrees — both tasks build side by side and there is one Pixel_9_Pro emulator; a device is shared like a port — a layout defect shows at the end instead of in Task 2
Task 1: started 2026-11-04 10:08 (worktree from 5c0027b)
Task 2: started 2026-11-04 10:08 (worktree from 5c0027b)
Task 2: merged (204dae2..204dae2)
Task 2: agent implementer a299cbc1fb2b79a73
Task 2: complete (commits 204dae2..204dae2, not reviewed)
Progress: 1/2 tasks — Task 2 Keep the button row and the ad clear of the cutout and the gesture bar — 1/2 tasks — Task 2 Keep the button row and the ad clear — SystemInsets drives the button row's top, the ad's bottom and the content's bottom inset
Task 1: Ruling: The KDoc naming enableEdgeToEdge() stays — Step 2 asks for a comment saying why it isn't used; the acceptance case is about calling it, and nothing does — a literal grep for the name hits one comment line
Task 1: merged (314eb71..314eb71)
Task 1: agent implementer a603b80b3adbe019e
Task 1: complete (commits 314eb71..314eb71, not reviewed)
Progress: 2/2 tasks — Task 1 Edge-to-edge window on every Android version — 2/2 tasks — Task 1 Edge-to-edge window — MainActivity turns off decor fitting with WindowCompat on every Android version
Note: Fix after the run: the open-menu card's fixed top of 120 overlapped the button row once Task 2 moved the row down by the top inset; SystemInsets.openCardTop now adds the same inset (d014100)
Task 3: started 2026-11-04 10:19
Task 3: agent implementer ab0410138e30f1352
Task 3: complete (commits 05f2655..05f2655, not reviewed)
Progress: 3/3 tasks — Task 3 Centre the open-menu card between the button row and the accent picker — 3/3 tasks — the open-menu card is centred between the button row and the accent picker
