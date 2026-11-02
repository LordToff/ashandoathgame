# v0.26 validation

Godot 4.6.3 was used. Deployment is verified separately after the source and tested browser package are pushed.

All **27 scripts passed**, reporting **7,989 checks**: the 24 core regression scripts from v0.25, its event model and event UI scripts, and the new `usability_v26_test.gd` (69 checks). See `Validation-v0.26.json` for the per-script counts. Historical Poison assertions now require stacking/decay; the old opening-window assertion explicitly selects Opening only. No assertion was removed to hide a failure.

The focused fixture covers stacking and decay on heroes/bosses/summons, lethal Poison, tick snapshots, Borrow Shape copying spent dice from all heroes, copied Reactions, unchanged source dice, loop/penalty exclusions, anytime and opening-only rerolls, held Reaction rerolls, spent-die rejection, Focus result metadata, Reaction mitigation against hits of 1/2/3, retention beyond 2,000 log entries, mandatory events, one-event-per-boss consumption, notices, full log visibility, Focus target-click handling and first-face-selection restart.

Chromium/WebGL tested the normal exported game: choose faces → boss review → required event → event resolution → boss → Options → Main menu. A separate local-only deterministic fixture, using the actual production scene and code, verified Poison acknowledgement, Borrow Shape's face-up hero choice grid, Focus target clicks and same-face result, an Action Reroll after acting, the Extensive log tab and actual Reaction use. No browser console or page errors occurred. Screenshots and the result report are in `/workspace/outputs/v26-browser/`.

Reproduce browser checks by creating a separate fixture with `python3 tools/make_usability_fixture.py --output /tmp/ash-usability-new` (the destination must not exist). Import and export that generated Godot project with its web preset. Serve the normal export on 127.0.0.1:8876 and the fixture export on 127.0.0.1:8877, then run `python3 tools/verify_usability_browser.py`. Bind both servers explicitly to loopback. Requires Python Playwright, Chromium and Tesseract. The fixture does not add debug hooks to the game or publish anything.

Native scene tests retain inherited shutdown resource-leak warnings without script errors. This is not a human balance study or a claim to have rerun every historical rendered fixture. The previous refresh-only Poison / rotating Borrow Shape behavior is intentionally changed according to user feedback. Windows downloads remain unchanged.
