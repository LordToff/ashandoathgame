# Recovering Ash & Oath

## One canonical source repository

- Repository: https://github.com/LordToff/ashandoathgame.git
- Development source: `main` (the default branch for this dedicated repository).
- Tested browser releases: `gh-pages`.
- Previous gameplay release: **v0.25**, source `34fb8c2cee35ad2bea8f8a935d587edc0055134e`.
- Original tested browser commit: `00cf7f43394f9e18dff0a2939a3ed2d33fb1c7a7`.

The dedicated repository retains source history and the previous Pages history. The original game lived on `LordToff/Godot-Game-Template`, branch `ash-and-oath-prototype`. Keep it as historical backup; new development belongs here. Migration adds documentation only; gameplay and the v0.25 pack are unchanged.

A GitHub repository backs up committed source and published files. It cannot guarantee that a cloud runtime never fails. Commit and push completed work; ignored caches, running processes and uncommitted files are not repository backups.

Current source for v0.32 is on `main`. The dedicated Pages site is enabled at https://lordtoff.github.io/ashandoathgame/. Read SOURCE_COMMIT.txt and VERSION.txt on `gh-pages` for exact current build provenance.

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
