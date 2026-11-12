# Recovering Ash & Oath

## One canonical source repository

- Repository: https://github.com/LordToff/ashandoathgame.git
- Development source: `main` (the default branch for this dedicated repository).
- Tested browser releases: `gh-pages`.
- Previous gameplay release: **v0.25**, source `34fb8c2cee35ad2bea8f8a935d587edc0055134e`.
- Original tested browser commit: `00cf7f43394f9e18dff0a2939a3ed2d33fb1c7a7`.

The dedicated repository retains source history and the previous Pages history. The original game lived on `LordToff/Godot-Game-Template`, branch `ash-and-oath-prototype`. Keep it as historical backup; new development belongs here. Migration adds documentation only; gameplay and the v0.25 pack are unchanged.

A GitHub repository backs up committed source and published files. It cannot guarantee that a cloud runtime never fails. Commit and push completed work; ignored caches, running processes and uncommitted files are not repository backups.

Current source for v0.37 is on `main`. The dedicated Pages site is enabled at https://lordtoff.github.io/ashandoathgame/. Read SOURCE_COMMIT.txt and VERSION.txt on `gh-pages` for exact current build provenance.

## Recover in a new environment

Use an existing clean checkout when present; do not create a worktree. Otherwise:

```sh
git clone --branch main https://github.com/LordToff/ashandoathgame.git
cd ashandoathgame
git status --short
git log -1 --oneline
```

Recheck installed tools and existing Git authentication. Do not assume an old cloud workspace, proxy, credentials or caches survived. An environment cancellation is a runtime failure, not proof that source was lost or that a new token is needed.

Use **Godot 4.6.3**, with its matching official export templates for web releases. Verify official download checksums and preserve TLS validation. Set writable XDG locations if the environment's defaults are read-only:

```sh
export XDG_DATA_HOME=/tmp/ash-data
export XDG_CONFIG_HOME=/tmp/ash-config
export XDG_CACHE_HOME=/tmp/ash-cache
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
godot --version
godot --headless --recovery-mode --path . --import
godot --headless --path . --script res://prototype/tests/events_v25_test.gd
godot --headless --path . --script res://prototype/tests/events_v25_ui_test.gd
```

Read `prototype/README.md` and `docs/Validation-v0.25.md` for the broader tests and their limits. New code lives mainly in `prototype/prototype.gd`, `expedition.gd` and `event_battle.gd`; existing combat is in `battle.gd` and the boss modules. Do not replace the game with the upstream template.

## Browser export and publication

`tools/export_web.sh` exports to ignored `exports/web/`. Install official 4.6.3 web templates under Godot's active XDG data directory first. Serve the export locally and run `python3 tools/verify_events_browser.py`; this needs Python Playwright, `/usr/bin/chromium` and Tesseract. A browser package loading successfully is separate from a successful public deployment.

Preserve other local work. Prepare a separate clone of `gh-pages` for publication rather than resetting the source checkout. Copy the validated browser files there. Use a versioned main pack (v0.25 uses `index.v0.25.pck`) and update both `GODOT_CONFIG.mainPack` and its `fileSizes` key in index.html. Record the source commit in SOURCE_COMMIT.txt and VERSION.txt; generate SHA-256 BUILD.json for the actual release files. Publish current HTML/PDF rules, notes and validation alongside the build. Keep licenses and historical assets intact.

For future gameplay releases, run `godot --headless --path . --script res://tools/export_current_rules.gd` followed by `python3 tools/make_current_rules.py` after updating the version and reviewed rules prose in that generator. Its optional copy destination `/workspace/outputs` must exist.

Pages is already enabled. If recovering in a new repository, enable GitHub Pages in that repository's **Settings → Pages → Build and deployment → Deploy from a branch → gh-pages → /(root)**. This setting is separate from pushing the branch. The new browser URL is https://lordtoff.github.io/ashandoathgame/?v=0.25 only after deployment succeeds. Until then, the previous verified live URL remains https://lordtoff.github.io/Godot-Game-Template/?v=0.25.

Check the repository's public Actions page for the Pages run and match its commit. If direct live-site access is blocked by the environment, state that limitation and test the exact release package locally; do not claim to have browsed the public deployment.

## What persists

Events, Gold, supplies, fragments and claim state are local browser/device data, not a cloud account or a campaign checkpoint. The browser's IndexedDB storage is scoped by origin and Godot's project data path, not backed up by Git. Verify any old saved data after opening a new URL; keep the old site available. The Windows download is an older release and is not rebuilt by a browser-only publication.

## v0.28 UI and equipment checks

Run `prototype/tests/hub_v28_test.gd`, the current Essence/usability suites and `tools/verify_hub_browser.py`. The two browser verifiers use the separate fixture generated by `tools/make_essence_fixture.py`; fixture code lives under tools and is excluded from shipping exports. New local starting equipment is in essence.gd; equipped Beginning Soul scopes Move 1/one use to its hero. Main menu and Forge rendering are in hub_ui.gd, Camp workspaces in camp_ui.gd.

## v0.29 Wilds checks

New content data is in prototype/wilds.gd, creature tactics in event_battle.gd and bound Soul recipes in essence.gd. Run wilds_v29_test.gd and tools/verify_wilds_browser.py alongside the prior suites. Bind recipes to a chosen hero; never collapse bound ownership into a party unlock. New Souls use the existing per-hero Blank allowance and occupy the existing Soul slot. Creature/source/gallery pagination retains the old IDs and first page.

## v0.30 sprite pipeline

Run python tools/make_retro_sprites.py to reproduce the current 16-pixel tiles from the included human-authored Kenney CC0 source sheet and explicit palette variants. Do not restore the retired detailed generated pictures. Atlas dimensions are documented in ART_NOTES.md. Gameplay rules and saves remain v0.29. Verify actual browser artwork and the hub/Wilds UI suites after editing these assets.

## v0.31 phone controls

The phone presentation is in prototype/mobile_ui.gd. It calls the existing model and controller for every action; do not fork battle, rewards or equipment rules. prototype.gd maps board taps to the existing grid and adapts the virtual viewport on rotation. The browser uses the ash-and-oath-mobile localStorage key for immediate layout persistence; native runs use user://ash-ui-layout.cfg. Both are independent of local reward storage. Run mobile_v31_test.gd and tools/verify_mobile_browser.py (the isolated Essence fixture) plus existing hub/Wilds/Essence verifiers. The fixture is excluded from release exports. Browser emulation is not physical iOS/Android testing.

## v0.32 combat clarity

Enemy priority scoring and stable random tie selection are in prototype/enemy_targeting.gd; battle.gd shares those rules between real resolution and live forecasts. UI inspection must never advance the combat RNG. Actual credited enemy HP damage is recorded per hero and rolled into previous-round threat on the shared roll. Support Mend targets the most wounded legal ally. battle_panels.gd renders intent cards and the nine-result picker. Do not show hidden installed sides for a rolled-result choice; installed-slot abilities remain explicit exceptions. The status SFX queue is separate from impact audio, respects mute/volume, and consumes each event once. Engrave previews installed-side changes without rewriting recorded results. All recipe effects are now visible before payment; prices/ownership remain unchanged. Run clarity_v32_test.gd and verify_clarity_browser.py plus existing equipment, Wilds, Essence and boss suites.

## v0.33 phone flow, boss rewards and Debug

Combat controls in mobile_ui.gd use fixed rows, without a battle-action ScrollContainer. Enemy intent names open focused details. Poison ticks never queue combat_notices or floating HP text; green smoke reads actual status in draw_effects. Earned faces 69–72 and four boss Memories are original requested content; bosses yield 3 matching Essence, ordinary creatures 1. Keep the 48-design free pool and old IDs stable. Memories share one copy of each type, with one slot per hero. Debug defaults off: stationary 650 ms holds on locked Collection cards/Forge recipes grant one owned item; movement cancels. Web Debug preference uses ash-and-oath-debug localStorage, native user://ash-debug.cfg; reward ownership still uses the existing ledger. Run mobile_flow_v33_test.gd and tools/verify_mobile_flow_browser.py plus clarity/Essence/hub/Wilds checks. Test fixtures must never ship.

## v0.34 Trials

Main menu → Trials renders through trials_ui.gd on both layouts. trials.gd owns the independent run/checkpoint and boss-Soul collection (user://ash-trials-v34.json, web ash-and-oath-trials localStorage). trial_encounter.gd adds original Shieldbearer, Mender, Ram, Cutpurse and Sentry groups through the EventBattle special-action hook. trial_rules.gd gates all experimental base-model hooks behind trial.enabled; preserve unchanged normal combat when absent. Five route stops precede the chosen existing boss. No Trial reward may call normal Essence settlement, supplies or party build mutation. Combat reload/abandon fails the Trial; safe nodes resume. Run trials_v34_test.gd and tools/verify_trials_browser.py with the isolated Essence fixture, plus normal combat, Essence, equipment, Wilds, phone and boss regressions. Fixture callbacks stay outside shipping exports. The normal 73-face catalog and 48 free designs are unchanged.

## v0.35 readability and equipment

Trial equipment uses memories/souls/bodies/weapons arrays. trial_rules.gd defines three test Memories and Dagger/Poison Dagger/Heavy Dagger; only Poke changes with the Weapon. Starter dice are independent of Memory. Legacy paths become Memories; legacy mods refund 2 Trial Essence each and are never applied. equipment_version 35 prevents repeat refunds. Keep the existing Trial save path for migration. battle_preview.gd is read-only and renders full reach, sight-blocked cells, targets and actual movement destinations. No preview may consume RNG or alter a die. Ordinary creature rendering uses cell-sized HP/Block, without the boss shadow. Action Reroll/Focus never append combat_notices; their real dice presentation remains. Run clarity_v35_test.gd, the updated trials/usability suites, tools/verify_readability_browser.py and tools/verify_trials_browser.py. Shipping exports exclude fixture hooks.

## v0.36 Trial experiments

The new data is in `trial_content.gd`; `trial_forecast.gd` resolves isolated model copies across Numeric outcomes without changing the live battle or its RNG. `trial_hollow.gd` is a Trial-only Hollow subclass with a round-two Rupture Core interrupt. `trial_encounter.gd` holds ritual/spirit objectives and shared spirit targeting. Object units have their own faction and never take enemy turns or become owned worms.

Spear and Hammer project one first Strike side to Jab / Crack in rolls, previews and dice views. Physical ownership still uses Strike and the 73-face normal catalog. Keep at least one Strike while using these weapons. Invalid actions pay nothing; each successful weapon face spends its die, once per own turn. Other Strikes remain normal so Crack can be set up. Four-slot gear and crafting unlocks remain separate from ordinary Camp.

The existing Trial save/key is retained. Version 36 adds loadout weapons, matching ingredient balances, crafted designs and one wishlist; old safe checkpoints still load. An interrupted fight fails the run but retains the collection. Always check that `enemy_intents()` is read-only (including the event log), or target-confirmation stamps can become stale from a redraw.

Run `prototype/tests/trials_v36_test.gd`, the updated Trials suite and all current normal regressions. Browser checks use `tools/verify_trials_v36_browser.py` and the separate nonshipping Essence fixture. Fresh fixture imports use `--recovery-mode --editor --import --quit` to avoid template editor-plugin startup during imports. Use `ASH_FIXTURE_URL` for its loopback URL. Keep test callbacks out of shipping exports. Update the current rules snapshot, generator, HTML/PDF, patch notes and release validation before publishing.

## v0.37 Trial classes

`prototype/trial_classes.gd` defines exactly two classes and their starter dice/reward faces. `trials.gd` assigns class kits before new runs and scopes each free class Body to its recipient; crafting still unlocks it for the other class. Empty class keys are retained only for pre-class checkpoints and isolated legacy regressions. The user-facing lobby initializes missing class choices. Changing a class is lobby-only, applies only to the chosen hero, resets its starting equipment including Beginning Soul, and costs no currency. Class equipment has no additional hidden combat stat bonus.

Use the same first-Strike projection for starter previews and actual shared/rerolls. Spear/Jab and Hammer/Crack must appear on a real rolled side, with normal Strike sides retained. Class dice are independent of manual Memory changes. `trial_classes.gd` has no dependency on the battle model. Keep normal faces, ownership and Camp isolated.

Run `prototype/tests/classes_v37_test.gd`, current Trials/clarity/Essence/mobile and normal regressions. `tools/verify_classes_browser.py` exercises class setup, readable face previews, per-hero application/reload and real Step → Jab / Attack → Crack using class starter sides in the nonshipping fixture. The class rules/PDF export includes definitions and exact starter die names from game data. Safe old checkpoints preserve actual dice/HP/gear; a new Trial chooses new classes. Do not retrofit an old active run to class dice.


## v0.38 Soulcaster and Trial help

`Soulcaster` is a free starter Soul for either class, with exact PDF costs in `soulcaster.gd`. Four starting Blanks are construction requirements; manifestation changes them temporarily during encounters. Six base HP applies before Memory penalties. `No Memory` is a free option with no bonus/penalty. Classes and other starter defaults remain. The source document is retained at `docs/design/Soulcaster-Soul-Rules-and-Spells.pdf`.

Spell IDs75–80 never enter the normal73-face catalog or48 free designs. Physical creation metadata blocks same-turn activation even after a reroll; future shared rolls work before the own-turn counter advances. Omen stores the original die, skips its shared roll/RNG consumption and releases it next own turn in the following round. Mutation/Downing removes the hold. Fate queues support initial shared rolls, Focus, Action Reroll, copies and recovery; initial Lethargic Bind is checked once on final results. Enemy dice track resolved/rerolled state independently of activation cursor resets. Mirror reflection completes after collision/Stun/evasive continuations and supports allied Spirit/friendly fire.

`soulcaster_ui.gd` supplies the focused picker, spellbook, Fate/Omen choices and Wraith direction controls. Trial help now selects a topic and one hero. Run Essence buys temporary rewards; matching Forge materials persist. Reward slot selection previews a replacement; Buy is the only payment step. Prospective validation never temporarily modifies the physical-copy pool. Save path remains `ash-trials-v34.json`, equipment_version38. Old active/safe runs are not retrofitted. Run `soulcaster_v38_test.gd` and the existing suites plus `tools/verify_soulcaster_browser.py` in the nonshipping fixture.


## v0.38.1 fullscreen Settings

`prototype.gd` shares fullscreen availability, live browser state, caption, toggle and button creation with desktop/mobile/Trial Options. Use the actual browser fullscreen element for state (not a saved preference); the Options label polls at 200 ms so browser-owned exits update it too. Godot's Web DisplayServer requests fullscreen from the clicked control; do not replace this with a CSS-only canvas enlargement or auto-request on load. Unsupported browser APIs disable the button. Window resizing uses the existing layout refresh and preserves battle state. `tools/verify_fullscreen_browser.py` tests actual mouse/touch entry/exit, viewport coverage, browser-owned exit and Trial/RNG preservation in the separate nonshipping fixture. v0.38 gameplay rules/PDF remain current.
