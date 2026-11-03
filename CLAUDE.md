<!-- GA-WORKFLOW:START -->
<!-- ga:rules bd61e803c530 -->

## How work flows here

Use these skills without being asked; the developer shouldn't have to name them. Say in one line which one you're using and why, so they can redirect you.

- **A product's first screens, or whenever the look isn't decided:** `ga:design-brief` writes a design brief and a ready-to-paste prompt, for Claude Design or a design team. The finished design comes back through `ga:design`. Start from the landing page and the main flow, not a single feature.
- **House rules:** before writing code, read `knowledge/project/conventions.md` when it exists, and follow it. Where the code you're changing does otherwise, say so rather than picking one.
- **While building:** `ga:debug` when something fails and the cause isn't obvious.
- **Where a plan run stands:** `ga.mjs run status` reads each run's ledger: tasks done out of the plan's total, the task in hand and its fix round, the checkpoints, rulings and provisional rulings so far. Run it when the developer asks how far the work has got, rather than piecing it together.
- **Before saying it's done:** `ga:verify-work`. `ga:review-code` when the developer asks for a review.
- **Commands:** lint `flutter analyze`, test `flutter test`. This repository has no typecheck, format-check or e2e command. Run these as written. An app's `AGENTS.md` may list its own under Commands.
- **Anything the client hands over** (documents, an API collection, a design or a Figma link, their code): `ga:learn` files it, asks the one question it needs and runs the skill that learns it. For what's already in place, use those directly: `ga:learn-docs` for `intake/`, and `ga:learn-codebase` for an existing codebase with little knowledge, or the client's code copied into this project, keeping their structure and updating the knowledge base that's there. Drafts are reviewed by a person: suggest `/ga:review-knowledge`.
- **Estimating a new build for a proposal:** suggest `/ga:estimate`, which the developer starts. It grills out every gap in the client's documents and prototype, freezes the workflows, and writes the GeekyAnts estimate, plus the client's own format when they gave one. Never estimate from a template of your own.
- **Knowledge:** `ga:ask` before searching the code, `ga:remember` for every feature, decision or changed requirement, and `ga:check-knowledge` at the end. The knowledge section below has the rules.
- **Write down what's agreed, as it's agreed.** A design section approved, an answer to a question, a trade-off chosen: record it with `ga:remember` before moving to the next step, a decision in `decisions/` and an answer on its question. A spec or plan may restate it, but they are scaffolding for the build; the knowledge base is what lasts. A later session can't read this conversation, and a teammate never could.
- **Shell:** it's the developer's shell (zsh on a Mac by default), and nothing set in one Bash call reaches the next. Call the CLI by its full path, every time, `node "<plugin>/scripts/ga.mjs" …`: the `ga CLI:` line at session start gives it, and so does a skill; each `ga.mjs` command named here means that path. Never put a command with its arguments in a variable: after `G="node …/ga.mjs"`, zsh runs `$G …` as one word, a program called "node …/ga.mjs". Keep only a path in a variable, quoted, `node "$G" …`, and one path per variable. Quote a word that starts with `=`: zsh reads an unquoted `=====` as a command lookup and fails, so write `echo '====='`. Quote globs meant for a program, use `sed -i ''` on macOS, and never `git stash`.
- **Finishing:** `ga:finish-branch`. When a feature with a prototype under `design/<feature>/` ships, delete the prototype and its `compare/` screenshots, point the concepts that linked them at the real routes and components, and run `ga:check-knowledge`.

### This project's workflow

Set in `.ga/config.json` under `workflow`. `/ga:workflow` asks the developer and sets it; `ga.mjs workflow show` prints it. When the developer states a way of working, record it with `ga:workflow` before acting on it, in the middle of a plan run too: kept only in this conversation, it is lost at compaction, and no subagent, reviewer or later session ever sees it. A step that is only how they work ("I don't write specs") is theirs, with `--me`, not the team's. "Don't stop" or "don't ask me" is `run.unattended true`; "commit once at the end" is `git.commit plan`; "I'll commit myself" is `git.commit manual`; "no checkpoints" is `run.checkpoints none`. Follow it over any skill's own default: where a skill and this list differ, this list wins.

- Load `ga:discover` first for any feature or change to behaviour, however small. Skip it only for a typo, a rename, formatting or a dependency bump.
- When a requirement is unclear or risky, offer to grill it with `ga:grilling`, in the same message as your other questions.
- The design step is off here: design screens as part of the technical design.
- A change bigger than a small fix gets a written spec; `ga:discover` says in one line when none is needed, and why.
- More than a couple of steps: `ga:write-plan` breaks the work into tasks before it's built.
- New behaviour is built test first with `ga:tdd`. Watch each test fail before you write the code that passes it.
- Build in the current checkout, on a feature branch; don't create worktrees (a parallel wave's per-task worktrees are the executor's own).
- A developer may keep their own steps in `.ga/people/<git email>.json` (`ga.mjs workflow set --me`). The session start names them, and for that developer's own work they replace the matching rule above.
- This project builds at the fast pace: a feature aims at about 30 minutes from plan to merge request, and the developer gets the code first. A plan keeps to five tasks or fewer, with a chain of three or fewer: one foundation task, then a slice per app that consumes only the foundation. Implementers run on sonnet; tasks run only the tests they write, and nothing else runs unless the developer asks or the policy names it. `ga.mjs workflow set run.pace thorough` reviews and checks every task instead.
- Carry out plans with `ga:implement-with-subagents`: a fresh implementer for each task.
- Tasks that touch nothing in common run side by side. Whenever a task finishes, `ga.mjs run ready <plan>` says which tasks to start, from each task's Files, Knowledge and Interfaces: a task starts as soon as the tasks it waits for are in. A task touching a shared package, the root manifest, the lockfile or the database schema runs alone; when more tasks are ready than may run at once, the ones with the longest chain still ahead of them start first. A task built beside another is built in its own worktree, and merged back as soon as it's built. While the plan runs, every task is committed on the run's branch, whatever `git.commit` says; `git.commit` decides what the finish leaves.
- At most 5 tasks are built at once.
- Stop only at the stops the developer names for a run, which are always honoured.
- When the approved design, the spec and the knowledge base disagree, stop and ask. Never settle it alone.
- When the plan turns out to be wrong, decide, record the ruling in the ledger, and carry on; stop only if every way forward is a guess.
- Before a plan's first task, start the project's dev servers with `ga.mjs run dev`: it returns at once, and every task built in place or merged back reloads in the running apps. Give the developer their addresses with the dashboard's link. Leave them running at the finish, say so, and say that `ga.mjs run dev --stop` ends them; the end's e2e run reuses them.
- A task is security-sensitive when the plan tags it `security`: `ga:write-plan` tags every task touching auth, sessions, secrets, encryption, permissions, personal data, uploads, outbound URL fetches, allowlists or rate limits.
- Nothing is reviewed unasked here: no task review, re-review, security review or final review, and so no fix rounds. A task is done when its code is in, and a test-first task when its own test passes. When the developer asks ("review it", "review the branch"), review the branch since its base with `ga:review-code`, as a background agent, and post its findings when it's done. `ga.mjs workflow set review.when both` (or `run.pace thorough`) reviews every task and the branch again.
- A task runs no checks: only the tests it writes, each alone, by name, to watch it fail and then pass. Every check runs once, at the end.
- Before the work is done, run smoke (`ga.mjs run smoke --since <the branch's base>`: the apps and the routes the branch adds start and answer, and no app's latest compile failed) and lint (`flutter analyze`). There is no typecheck command here: skip it, and name it as skipped. Run that for what the branch changed: `ga.mjs run checks --since <the branch's base> --only lint` gives each command, narrowed to the packages it changed and those that depend on them. Test run only when the developer asks ("run the tests", "run e2e", "run all checks"): `ga.mjs run checks --since <the branch's base> --only <checks>` gives each command, narrowed to what changed. Then `ga:verify-work`: read the output, don't assume it.
- Commit at the end of each step: each spec, each approved design, each task. In a plan run the implementer commits its task, and the task is complete then. Stage the step's files by name, never `git add -A`, with the knowledge that describes them in the same commit.
- Commit messages are plain sentences.
- Build on a branch named `feat/<topic>`.
- Branch from, and merge back into, `master`. Until ga's own setup is on `master` (`git cat-file -e master:.ga/config.json` fails), branch from the branch that holds it, and say so: a branch cut from `master` then has no `knowledge/` and no `.ga/`.
- Ask before pushing.
- Ask before opening a merge request.
- Keep the branch's commits as they are when it's finished; don't squash.
- No task edits the knowledge base: each task's report lists the concepts it changed. Once the merge request is open, `ga:finish-branch` starts one background agent that writes them, runs the knowledge gates and the run's record in its own worktree of the branch, and pushes them there (its after-finish.md). Nothing waits for it, and the developer can start the next thing.
- The after-finish job runs `knowledge stale` over the branch and rereads and fixes each concept it lists, or records it as still true.
- Suggest `/ga:review-knowledge` for knowledge drafted in the work.
- Specs are written to `docs/specs/<YYYY-MM-DD>-<topic>.md`.
- Plans are written to `docs/plans/<YYYY-MM-DD>-<topic>.md`. A run's working files (ledger, briefs, reports, review diffs) live in `.ga/runs/<plan>/`, which git ignores.
- When a run finishes, keep its ledger beside the plan as `<plan>.record.md`, and delete the rest of `.ga/runs/<plan>/`.
- Start subagents by these agent types, whose model the policy fixes, rather than choosing one yourself: `ga-implementer` (sonnet), `ga-reviewer` (opus), `ga-security-reviewer` (opus), `ga-final-reviewer` (opus), `ga-explorer` (sonnet).

Never configurable, whatever the project sets:

- Ask before anything destructive or irreversible.
- Never read, copy or print a secret.
- Never push to a shared branch unless asked.
- Only a person sets a `human:` review mark.

<!-- GA-WORKFLOW:END -->

<!-- OKF-BASELINE:START -->
<!-- ga:rules cfa4ec6801fa -->

## Knowledge base (OKF v0.2)

- **Where knowledge lives:** `knowledge/`, an [Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) v0.2 bundle. Every `.md` file under it other than `index.md`, `log.md`, and anything under `log.d/`, is one concept: one unit of knowledge, one file, identified by its path with `.md` stripped. Log entries are not concepts.
- **Read `knowledge/` before you search anything.** When you need to understand how something works, consult the bundle _first_ -- before grepping, globbing, or exploring the codebase. It records the _why_ that the code itself cannot. Falling back to a code search is correct only once the bundle has come up short.
- **Nobody has to ask you.** Keeping and using the bundle is part of every task, not a command the developer runs: load the `ga:ask` skill whenever you need a fact about this project, `ga:remember` in the same change that adds or changes a feature, alters a decision, requirement, port, env key, route or model, or makes a choice worth a reason (a cycling button rather than a dropdown, and why), and `ga:check-knowledge` before you call a change done. When the bundle and the code disagree, say so and fix whichever is wrong; don't silently trust either.
- **Where to look first:** `/ga:ask` searches the bundle and reads the current version of each concept. Starting a task, it also assembles the context for the whole work item.
- **How to read it:** follow `knowledge/index.md` -> subdirectory `index.md` -> concept. Check each concept's `type` to know what you're looking at, and weigh it: a concept with no `verified` key is _unverified_, one verified only by non-`human:` actors is _machine-confirmed_, one verified by a `human:<id>` actor is _human-reviewed_. Treat unverified concepts, `status: draft`, and anything past its `stale_after` date with more skepticism than current, human-reviewed knowledge -- and say so when you rely on them.
- **How to write it:** knowledge is written as part of normal development, like a test suite. When you learn something durable -- an architectural decision, an API contract, a non-obvious constraint, a playbook -- add it as a concept rather than leaving it in a commit message. The **one required frontmatter field is a non-empty `type`** (free-form, e.g. `Architecture Decision`, `Convention`, `Runbook`); `title` and `description` are strongly recommended because `description` is what the index and the map below show. Record `generated: { by: <actor>, at: <ISO 8601> }` on anything you author (`<producer>/<version>` for an agent, `human:<id>` for a person). Each subdirectory's `index.md` lists its concepts from their `title` and `description`, written by `knowledge map`: write the concept, run map, and never edit between the index's generated markers.
- **Why and where, not what:** the bundle records what the code can't say (decisions and their reasons, requirements, domain rules, outside constraints, open questions) and _where_ each fact lives. Values the code already states (ports, env keys, versions, routes, schemas, module lists) stay in the code: point at the file that holds them instead of copying the value, which goes stale the first time the file changes. To answer "what is X", follow the pointer and read the file. The one exception is a value that is itself a decision, e.g. `MAX_UPLOAD_MB = 15` because of the provider's limit: record the reason, with the value in backticks so it can be checked. **Don't write what isn't built:** "not built yet", "no routes exist yet", "still to come" are true the day they're written and false after the next feature. Say what's planned in a requirement or feature concept, and let the code, and each concept's `## Sources`, say what exists.
- **Lists the code holds are generated:** an api's routes, a web app's pages and the data models go in a generated section, two marker lines such as `<!-- GA-GENERATED:routes apps/api -->` and `<!-- GA-GENERATED:END -->` (kinds: `routes`, `screens`, `models`; then the directory to read). `knowledge map` rebuilds what's between them from the code, so never edit inside one; write the why around it.
- **A changed concept keeps its history:** when an edit changes what a concept says (an approach, a rule, a behaviour, not wording), add one line to its `## History` section, newest first: `- YYYY-MM-DD: was <before>; now <after>, because <why>. See <decision>.` The full old text stays in git. A Requirement or Decision isn't edited but superseded, which keeps both. verify skips `## History`, since it describes what used to be true.
- **Questions stay, answered or not:** a question in `questions/` keeps its file when it's answered. Its `## Status` changes from `Open` to `Answered: <the answer>. See <decision>`, and the answer itself is recorded as a decision. `knowledge questions` lists the open ones, and the answered ones, separately.
- **An answered question is answered everywhere:** in the same change, fix each concept that still calls it open (a line such as "how titles are generated is open", or a list of open questions): say what was decided, and link the decision. `check` notes each one it finds.
- **A fixed finding reads as fixed:** when its `## Status` becomes `Fixed …`, its title starts "Fixed:" and its title and description put the defect in the past tense ("emails weren't normalised"), so the index and the map stop announcing a bug that's gone.
- **One fact, one concept:** state each fact where it belongs (a rule in its decision, a behaviour in its feature, a shared pattern in the design system) and link to it from everywhere else. A fact restated in several concepts drifts: one copy gets fixed and the others don't.
- **Checkable claims:** write the value inside the backticks, for example `` `MAX_UPLOAD_MB = 15` `` or `` `POST /uploads` ``, so it can be compared with the code.
- **The tracking fields:** `work_item` is the tracker key the concept belongs to (`PAY-1042`, `tmp-<slug>`, or `"group/proj#12"` -- **quoted whenever it contains `#`**, which otherwise starts a YAML comment). `superseded_by` names the one concept that replaces this one; it is written by the supersede command, never by hand. `pinned_from` and `pinned_version` mark a concept copied from the central repository, and are set together. **Never edit a pinned concept.**
- **Changing a Requirement or Decision:** never overwrite one. `/ga:remember` adds the new concept and records that it replaces the old one, both ways, in the log. **Before acting on a Requirement or Decision, check it is current** with `/ga:ask`, which follows the chain to the latest version.
- **A draft is edited; a decision others rely on is superseded:** a Requirement or Decision still `status: draft`, that nobody outside the work in hand relies on yet, is edited in place, with a `## History` line saying what it said before and why it changed. Once a person has confirmed it, or it has shipped, others rely on it: supersede it instead, so both stay.
- **Guardrails:** **never invent data** -- if a `type`, URL, or field value is unknown, ask rather than guessing. **Preserve unknown frontmatter keys** you did not write. **Don't impose a taxonomy** -- add the subdirectory a concept actually needs instead of reorganizing to fit a scheme. **Broken links in a concept are acceptable**: a link to a concept that doesn't exist yet marks not-yet-written knowledge, and check lists each one as a note so a typo still shows. An `index.md` entry must point at a concept that exists. **Stay minimal** -- one concept per unit of knowledge, no empty placeholder directories.
- **Logging requirement:** log every meaningful change **the same day**, one line each, with the `knowledge log` command (`ga:remember` shows it): it writes `knowledge/log.d/<YYYY-MM-DD>-<slug>-<4 hex>.md` with a real timestamp and recompiles `log.md`. Knowledge changes use `Update` / `Creation` / `Deprecation`; codebase changes use `Feature` / `Fix` / `Refactor`; add `--work-item` when there is one. Milestones are logged too, with `--event` and `--ref <file>`: `spec-approved`, `plan-approved` and `run-finished`, so the log links each feature's spec, plan and build. Each entry records who made the change (`by: human:<email>`, from git, or `--by` for someone else) and `agent: claude-code` when Claude wrote it. Never write a `log.d` file by hand, never edit or delete an existing entry (to correct one, add another), and never edit `knowledge/log.md` or `knowledge/log.json`: both are generated and gitignored, `log.json` being the same log as data, to filter by person, kind or date.
- **Keeping it current:** run `/ga:check-knowledge` after adding, renaming or replacing a concept, and before finishing a change to code a concept describes: it also compares each concept's backticked claims with the code, and notes any file a concept's prose names that its `## Sources` leaves out. `knowledge stale` then lists each concept whose Sources files changed on this branch after the concept's own last change: reread those, since prose goes stale where no check can see it, and record one that's still true with `knowledge reread <id> --by <who>` so it drops off the list until its Sources change again. It regenerates the map below and this section, compiles `log.md`, and runs the conformance check. The check fails on: a missing or unparseable frontmatter block; a missing `type`; a malformed `index.md`, or one linking to a file that doesn't exist; a `work_item` that is not a tracker key or has an unquoted `#`; a `superseded_by` naming a concept that does not exist, or more than one; a `supersedes` field; a supersession cycle; `pinned_from` without `pinned_version` or the reverse; and a `log.d` entry with unparseable frontmatter, a `type` other than `Log Entry`, a non-ISO `date`, an unknown `kind`, an empty body or invalid `op` fields. Missing descriptions, stale dates, broken links in concepts, a finding with no `## Status` (or a fixed one whose title doesn't start "Fixed:"), a question with no `## Status` of `Open` or `Answered: …`, a `## History` line without its date or out of order, and possible unrecorded supersessions come back as advisory notes, never errors.
- **Don't copy framework documentation into a concept.** Each app's `AGENTS.md` describes how to work in that app; a copy of it here goes stale the day it is written. Link to it instead, and record what is true about _this_ project.
- **Sources point at the code once it exists:** a feature, API, app, data or package concept lists the files that build it under `## Sources`, not only the spec, plan or intake it came from. Those don't change when the code does, so neither verify nor `knowledge stale` could see the concept fall behind; verify notes one that cites only documents.
- **A review mark covers the text it was given on:** once a concept's body changes after its `verified` mark, the mark no longer counts, and check says so. Never set a mark yourself, and leave a `human:` one as it is: a person confirms the concept again with `/ga:review-knowledge`. A stale `ga-plugin/verify` mark may simply be deleted.

<!-- OKF-BASELINE:END -->

<!-- OKF-KNOWLEDGE-MAP:START -->

## Knowledge map

_Generated from `knowledge/`. Do not edit by hand._

### apps

- [The Flutter app (flutterweather)](knowledge/apps/flutterweather.md) _(Application)_ — The single Flutter app: entry point, screens, platform projects, and its Android build (Android is the only supported platform).

### data

- [Weather data model](knowledge/data/model.md) _(Data Model)_ — Weather, WeatherReport, Place and WeatherQuery, and the normalised units every provider converts to.
- [What the app stores on the device](knowledge/data/on-device-storage.md) _(Data Model)_ — The SharedPreferences keys the app and the widget read and write, and what each holds.

### decisions

- [Android is the only supported platform](knowledge/decisions/android-only.md) _(Decision)_ — The app ships on Android only; changes are built and checked for Android, and ios/ is kept but not maintained.
- [New Dart code is formatted at 120 columns with typed callbacks](knowledge/decisions/code-style-120-typed.md) _(Decision)_ — dart format with a page width of 120, set in analysis_options.yaml, and callbacks typed as function types, as the newer services do.
- [Publish under the new application ID in.spanion.weather](knowledge/decisions/new-application-id.md) _(Decision)_ — The app is published as a new Play listing because the original signing key was lost.
- [The privacy policy describes only what the app collects](knowledge/decisions/privacy-policy-no-analytics.md) _(Decision)_ — The app collects no usage analytics, so privacy.md is to describe only location, the weather services and AdMob.
- [Rotate the OpenWeatherMap key and remove the bundled fallback](knowledge/decisions/rotate-openweathermap-key.md) _(Decision)_ — The committed key is to be rotated, the new one passed only through keys.json, and the fallback removed so OpenWeatherMap is skipped without a key.
- [The theme follows the system, and the button overrides it until the system next changes](knowledge/decisions/theme-follows-system.md) _(Decision)_ — The app takes light or dark from the system and switches live; the theme button sets an override that holds until the system brightness changes.
- [Keep a patched copy of flare_flutter instead of moving to Rive](knowledge/decisions/vendored-flare-flutter.md) _(Decision)_ — The app's animations are Flare .flr files, which Rive can't load, so the discontinued flare_flutter is kept in packages/ and patched to compile.
- [Widget icons animate as frame animations in a ProgressBar](knowledge/decisions/widget-animated-icons.md) _(Decision)_ — Home-screen widgets can't play Flare, so each icon's loop is rendered to frames and played by an indeterminate ProgressBar, at a cost of about 1.2 MB and some battery.
- [One resizable widget that goes down to one cell, showing only Now](knowledge/decisions/widget-one-resizable-card.md) _(Decision)_ — The widget is a single picker entry that resizes from 4x2 down to one row or one cell, switching to a compact or a temperature-only layout when small; the 24-hour page is dropped.
- [The widget refreshes the last place viewed, without background location](knowledge/decisions/widget-uses-last-place.md) _(Decision)_ — The background widget refresh reuses the last query saved by the app instead of asking for the device's location in the background.

### design-system

- [Shared widgets](knowledge/design-system/components.md) _(Component Inventory)_ — Btn, FlareIcon, Hamburger and AdBanner in lib/components, plus the detail chips and cards the weather and forecast views reuse.
- [Colours, shapes and type](knowledge/design-system/tokens.md) _(Design Tokens)_ — Accent gradients, the two theme colours, the Montserrat font, and the radius and shadow values the screens repeat.

### domain

- [Condition codes, icons and night](knowledge/domain/condition-icons.md) _(Business Rule)_ — Every provider maps its conditions to OpenWeatherMap codes; Weather.getIcon turns a code into one of a fixed set of icon names, with a night variant by local hour.
- [Weather provider failover](knowledge/domain/provider-failover.md) _(Business Rule)_ — WeatherService tries the providers in turn, the last one that worked first, parks failing ones for a cooldown, skips unconfigured ones, and geocodes cities for providers that need coordinates.

### features

- [Look up a city](knowledge/features/city-search.md) _(Feature)_ — The location button opens a dialog where the user types a city; the app remembers it until refresh switches back to the device location.
- [See the current weather](knowledge/features/current-weather.md) _(Feature)_ — At launch the app shows the last report at once, then fetches fresh weather for the device location or the saved city; refresh does the same.
- [See the forecast](knowledge/features/forecast.md) _(Feature)_ — A panel that slides up with the next 48 hours as expandable chips and the next days as expandable cards.
- [Android home-screen widget](knowledge/features/home-screen-widget.md) _(Feature)_ — One resizable Now card in the app's accent, with an animated weather icon, fed by the app and refreshed in the background for the last place viewed.
- [Choose a theme and an accent](knowledge/features/themes-and-accents.md) _(Feature)_ — The theme follows the system light or dark, the menu button overrides it until the system changes, and accent gradients picked from a carousel also colour the widget.

### findings

- [An OpenWeatherMap API key is committed in the code](knowledge/findings/committed-openweathermap-key.md) _(Finding)_ — lib/config/api_keys.dart falls back to a hard-coded OpenWeatherMap key, in git history since 2020, though the README says keys are kept out of git.

### integrations

- [Google AdMob and consent](knowledge/integrations/google-admob.md) _(Integration)_ — An anchored adaptive banner on Android, started only after Google UMP consent allows ads, with a privacy button where the user must be able to change their choice.
- [MET Norway](knowledge/integrations/met-norway.md) _(Integration)_ — Last provider by default and the only keyless one; locationforecast plus the sunrise API, by coordinates only.
- [OpenWeatherMap](knowledge/integrations/openweathermap.md) _(Integration)_ — First provider by default; current weather plus the 5-day / 3-hour forecast, city search, and geocoding both ways.
- [Tomorrow.io](knowledge/integrations/tomorrow-io.md) _(Integration)_ — Third provider by default; hourly and daily forecast in one call, city search by name. Needs TOMORROW_IO_KEY.
- [WeatherAPI.com](knowledge/integrations/weatherapi.md) _(Integration)_ — Second provider by default; current weather and a 3-day hourly forecast in one call, city search and geocoding. Needs WEATHERAPI_KEY.

### operations

- [Build-time keys and signing](knowledge/operations/environment.md) _(Runbook)_ — The dart-define keys in keys.example.json, where each is read, what a blank value does, and the Android signing file.
- [Run, build and release](knowledge/operations/run-locally.md) _(Runbook)_ — Running the app with its keys, building the Play bundle, regenerating widget icons and launcher icons, and the store listing images.

### packages

- [flare_flutter, our patched copy](knowledge/packages/flare_flutter.md) _(Package)_ — A copy of the discontinued flare_flutter 3.0.2, kept in packages/ and patched to compile, which plays the app's .flr weather animations.

### project

- [How the app is put together](knowledge/project/architecture.md) _(Architecture)_ — One Flutter app in three layers (views, services, weather providers), a background refresh isolate, and a Kotlin widget fed through home_widget.
- [How code is written here](knowledge/project/conventions.md) _(Conventions)_ — Folder layout, naming, error handling and tests as the code shows them, the analyzer config, and where the git and check settings live.
- [Beautiful Weather, an animated weather app built with Flutter](knowledge/project/overview.md) _(Project Overview)_ — Shows the current weather and a 48-hour and multi-day forecast for your location or a city, with an Android home-screen widget.

### quality

- [Tests](knowledge/quality/testing.md) _(Test Strategy)_ — Unit tests for provider failover, the theme, the widget service and the widget resources in test/, and a test-harness tool that renders the widget icons.

### questions

- [Which code style do new files follow?](knowledge/questions/code-style-for-new-code.md) _(Open Question)_ — Older views are formatted at 80 columns with untyped callbacks; newer services run past 100 columns with typed callbacks. Which way does new code go?
- [Is the iOS app built and shipped?](knowledge/questions/ios-support.md) _(Open Question)_ — An iOS project exists, but ads and the widget are Android-only and iOS carries Google's sample AdMob ID.
- [Does the app collect usage analytics, as the privacy policy says?](knowledge/questions/privacy-policy-analytics.md) _(Open Question)_ — privacy.md says usage and device information are collected for analytics, but the app has no analytics SDK.

### risks

- [Technical debt](knowledge/risks/debt.md) _(Technical Debt)_ — Leftovers worth fixing, from the Kotlin package name and Kelvin conversions repeated in views to unmapped condition codes and unused fonts.

### security

- [Location, keys and what leaves the device](knowledge/security/data-protection.md) _(Security)_ — The app has no accounts; its sensitive data is the user's location, the API keys built into it, and ad consent.

<!-- OKF-KNOWLEDGE-MAP:END -->
