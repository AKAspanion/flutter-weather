# Smaller Download Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: the project's workflow policy names the executor (`run.executor`): ga:implement-with-subagents by default, or ga:implement. Follow the policy and this plan's Checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cut the Play download for an arm64 phone from about 12.5 MB, keeping AdMob, by dropping unused fonts,
encoding the widget's animation frames as lossy WebP, and obfuscating release builds.

**Architecture:** Two independent slices. Task 1 changes the app's manifest, fonts, version and release command.
Task 2 changes the widget-icon render tool so loop frames are encoded with `cwebp`, re-renders the frames, and
updates the resource test that caps their size.

**Tech Stack:** Flutter / Dart, `flutter_test`, Android resources (`drawable-nodpi`, `animation-list`), the `cwebp`
encoder from Homebrew's `webp` package. Android only.

**Spec:** [docs/specs/2026-11-04-smaller-download.md](../specs/2026-11-04-smaller-download.md)

## Global Constraints

- Android only ([decisions/android-only](../../knowledge/decisions/android-only.md)): no iOS work or checks.
- New and changed Dart: `dart format` at page width 120, `package:flutterweather/...` imports, `///` comments that say
  why ([knowledge/project/conventions.md](../../knowledge/project/conventions.md)).
- Tests live in `test/<subject>_test.dart`; no network.
- Spec §2: frames keep `frameSize = 112` and `frameMs = 125`, encoded with `cwebp -q 85 -exact -alpha_q 100 -m 6`.
- No task edits `knowledge/`: the after-finish job writes the concepts each task lists.

## Checkpoints

None (`run.checkpoints: none`). The run stops before Task 2 only if `cwebp` isn't installed: installing it
(`brew install webp`) needs the developer's yes.

---

### Task 1: Drop unused fonts, bump the build, obfuscate the release command

**Files:**
- Modify: `pubspec.yaml` (remove `cupertino_icons` and its comment, remove the `Montserrat-Italic.ttf` entry,
  `version: 1.0.1+5`)
- Modify: `pubspec.lock` (written by `flutter pub get`)
- Delete: `assets/fonts/Montserrat-Italic.ttf`
- Modify: `README.md:28` (the release command)

**Interfaces:**
- Consumes: none
- Produces: none

**Spec:**
- §1: "The `cupertino_icons` dependency comes out of `pubspec.yaml`. The italic entry comes out of the Montserrat
  family, and `assets/fonts/Montserrat-Italic.ttf` is deleted."
- §3: "`flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=keys.json`"
- §4: "**Version** becomes `1.0.1+5`, because `+4` is already in open testing."

**Knowledge:**
- `operations/run-locally`: the release command adds `--obfuscate --split-debug-info=build/symbols`, and a copy of
  `build/symbols` is kept per release to read Dart stack traces; re-rendering the widget icons with `ICON_LOOPS=1`
  needs `cwebp` (`brew install webp`), from Task 2
- `decisions/obfuscate-release-builds` (new): release builds are obfuscated to save download size; the app has no crash
  reporter, and `build/symbols` makes a trace readable

**Acceptance:**
- Given the change, when `grep -rn 'CupertinoIcons\|cupertino_icons' lib packages pubspec.yaml` runs, then it prints
  nothing.
- Given the change, when `grep -rn 'Italic\|FontStyle.italic' lib packages pubspec.yaml` runs, then it prints nothing,
  and `assets/fonts/Montserrat-Regular.ttf` is still listed under the Montserrat family.
- Given the change, when `flutter pub get` runs, then it succeeds and `pubspec.lock` no longer lists `cupertino_icons`.
- Given the change, `pubspec.yaml` says `version: 1.0.1+5`.
- Given the change, `README.md` gives the release command exactly as Spec §3 quotes it.

- [ ] **Step 1: Run the first two greps** and confirm they print the lines this task removes

- [ ] **Step 2: Edit `pubspec.yaml`, delete the italic font file, and edit `README.md`**

- [ ] **Step 3: Run `flutter pub get`**

Expected: succeeds, and `pubspec.lock` loses `cupertino_icons`

- [ ] **Step 4: Run the two greps again**

Expected: no output

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/fonts/Montserrat-Italic.ttf README.md
git commit -m "Drop the unused Cupertino icons and Montserrat Italic fonts, bump to 1.0.1+5, and obfuscate the release build."
```

### Task 2: Encode the widget's animation frames as lossy WebP

**Files:**
- Modify: `test/widget_icon_resources_test.dart` (frame existence check and the size test)
- Modify: `tool/render_widget_icons_test.dart` (encode loop frames with `cwebp`, delete the PNGs)
- Delete: `android/app/src/main/res/drawable-nodpi/widget_icon_<name>_<nn>.png` (the 11 icons' loop frames)
- Create: `android/app/src/main/res/drawable-nodpi/widget_icon_<name>_<nn>.webp` (the same frames)
- Modify: `android/app/src/main/res/drawable-nodpi` (the directory holding both, staged as one path)

**Interfaces:**
- Consumes: none (existing `ICON_LOOPS=1` mode of `tool/render_widget_icons_test.dart`)
- Produces: frame drawables with the same resource names, so `res/drawable/widget_anim_<name>.xml` and
  `res/layout/widget_icon_<name>.xml` come out unchanged
- `maxFrameBytes` in `test/widget_icon_resources_test.dart` stays a top-level `const int`, now the measured WebP
  total plus about 10% (Step 7)

**Spec:**
- §2: "Under `ICON_LOOPS=1`, it then encodes each frame with `cwebp -q 85 -exact -alpha_q 100 -m 6` to
  `widget_icon_<name>_<nn>.webp` and deletes the PNG, because Android rejects two resources with the same name."
- §2: "If `cwebp` isn't installed, the tool fails with a message saying `brew install webp`."
- §2: "The static stills (the widget preview and the sunrise, wind and humidity icons) stay PNG."
- Testing: "Its cap drops from 1.5 MB to the measured total plus about 10%. It also checks that no frame PNG is left
  beside a WebP."

**Knowledge:**
- `decisions/widget-webp-frames` (new, superseding `decisions/widget-animated-icons`): loop frames are lossy WebP at
  quality 85 with exact alpha, still 112 px at 8 fps, rendered by the tool with `cwebp`; the cap is the measured total
  plus about 10%
- `features/home-screen-widget`: the icon's frames are WebP

**Acceptance:**
- Given each frame an animation list names, then `drawable-nodpi/<frame>.webp` exists, and `<frame>.png` doesn't.
- Given the `drawable-nodpi` folder, then no file matches `widget_icon_*_[0-9][0-9].png`.
- Given all `widget_icon_*_[0-9][0-9].webp` files, then their total is at most `maxFrameBytes`, and there is at least
  one.
- Given the stills, then `widget_icon_<name>.png` for each icon and the `sun`, `wind` and `drop` icons are still PNG.
- Given `cwebp` isn't on the `PATH`, when `ICON_LOOPS=1 flutter test tool/render_widget_icons_test.dart` runs, then it
  fails with a message containing `brew install webp`.
- Given a re-render, then `git diff --stat android/app/src/main/res/drawable android/app/src/main/res/layout` shows no
  change.

- [ ] **Step 1: Check `cwebp` is installed** with `which cwebp`. If it isn't, stop and ask the developer to approve
  `brew install webp`.

- [ ] **Step 2: Change the resource test** for the first four Acceptance cases, with `maxFrameBytes` at `629146`
  (0.6 MB, the spec's estimate) until Step 7 measures it

- [ ] **Step 3: Run it to verify it fails**

Run: `flutter test test/widget_icon_resources_test.dart`
Expected: FAIL, because no `.webp` frames exist and the `.png` frames do

- [ ] **Step 4: Change the render tool**: after writing each loop frame's PNG, run `cwebp` with the Spec §2 flags into
  `<frame>.webp`, delete the PNG, and fail with the `brew install webp` message when `cwebp` can't be started

- [ ] **Step 5: Re-render the frames**

Run: `ICON_LOOPS=1 flutter test tool/render_widget_icons_test.dart`
Expected: PASS, 11 icons' frames written as `.webp`, no frame `.png` left

- [ ] **Step 6: Measure the frames** with `du -ck android/app/src/main/res/drawable-nodpi/widget_icon_*_[0-9][0-9].webp`

- [ ] **Step 7: Set `maxFrameBytes`** to the measured total plus about 10%, rounded up to a whole KB, with its comment

- [ ] **Step 8: Run the resource test to verify it passes**

Run: `flutter test test/widget_icon_resources_test.dart`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add test/widget_icon_resources_test.dart tool/render_widget_icons_test.dart android/app/src/main/res/drawable-nodpi
git commit -m "Encode the widget's animation frames as lossy WebP, and cap them at their measured size."
```

The `drawable-nodpi` path is the one directory staged: it is where the 692 frame files are deleted and added, and the
task changes nothing else in it.
