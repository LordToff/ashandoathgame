# Recovering Ash & Oath

## One canonical source repository

- Repository: https://github.com/LordToff/ashandoathgame.git
- Development source: `main` (the default branch for this dedicated repository).
- Tested browser releases: `gh-pages`.
- Current gameplay release: **v0.25**, source `34fb8c2cee35ad2bea8f8a935d587edc0055134e`.
- Original tested browser commit: `00cf7f43394f9e18dff0a2939a3ed2d33fb1c7a7`.

The dedicated repository retains source history and the previous Pages history. The original game lived on `LordToff/Godot-Game-Template`, branch `ash-and-oath-prototype`. Keep it as historical backup; new development belongs here. Migration adds documentation only; gameplay and the v0.25 pack are unchanged.

A GitHub repository backs up committed source and published files. It cannot guarantee that a cloud runtime never fails. Commit and push completed work; ignored caches, running processes and uncommitted files are not repository backups.

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

Enable GitHub Pages in the dedicated repository's **Settings → Pages → Build and deployment → Deploy from a branch → gh-pages → /(root)**. This setting is separate from pushing the branch. The new browser URL is https://lordtoff.github.io/ashandoathgame/?v=0.25 only after deployment succeeds. Until then, the previous verified live URL remains https://lordtoff.github.io/Godot-Game-Template/?v=0.25.

Check the repository's public Actions page for the Pages run and match its commit. If direct live-site access is blocked by the environment, state that limitation and test the exact release package locally; do not claim to have browsed the public deployment.

## What persists

Events, Gold, supplies, fragments and claim state are local browser/device data, not a cloud account or a campaign checkpoint. The browser's IndexedDB storage is scoped by origin and Godot's project data path, not backed up by Git. Verify any old saved data after opening a new URL; keep the old site available. The Windows download is an older release and is not rebuilt by a browser-only publication.
