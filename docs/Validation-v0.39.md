# Validation — Ash & Oath v0.39

13 November 2026 · Godot 4.6.3 · software-rendered Chromium.

**Passed: 2,807 checks across 21 native model/UI suites**, plus direct combat browser checks at **390×844, 360×640, 844×390 and 1440×900**. No script errors or browser console/page errors in passing checks. Existing native UI exit-time resource warnings remain separate from failures.

`direct_v39_test.gd` adds actual controller/map inputs for Strike, Guard, movement, invalid targets/RNG preservation and targeted Grave Stitch, plus real idle/run frame bounds and animation indices. Existing Soulcaster, classes, Trial/normal combat, Essence, Wilds, mobile, boss and summon regressions pass; individual results are in Validation-v0.39.json. Soulcaster's UI assertion now checks a direct spell button instead of the removed creation footer.

`tools/verify_direct_browser.py` uses real mouse/touch events in a separate nonshipping export to check ability → enemy damage, one-tap Guard, ability → movement destination, normal and Trial controls, targeted Stitch, copied Guard resolving after Borrow Shape, compact board-visible Soulcaster, two taps total to Gather/create, HP/charge/delay behavior, direct Harvester/Exchange and actual Jab/Crack setup. No generic Confirm button/staged choice appears during these actions.

`tools/verify_direct_art_browser.py` checks desktop and phone: six spell cards have no overlap and stay in view, Mirror creation is a single spell-button tap, a selected Numeric Attack consumes no RNG until its map target, the ordinary floor has no old boss pad, and all four new boss sprites render. The visual review caught and fixed a desktop card overlap before release. Screenshots of compact controls, ordinary creatures and four bosses were inspected.

The 0x72 original artist page explicitly marks the asset pack as CC0 and made without generative AI. The unmodified archive, source/licence evidence and hashes are retained. Re-running `tools/make_enemy_sprites.py` reproduces the same selections and atlas hashes. Original idle/run frames are packed without resampling or image generation. Art changes preserve stats, action dice, targeting and footprints.

Current rules, HTML and PDF are regenerated from the reviewed prose and Godot rules snapshot. Web export excludes fixture callbacks/tests/docs/downloads. Versioned pack, SHA-256 manifest, source commit and successful GitHub Pages deployment are verified separately on publication.

Historical v0.36/v0.38 browser sequences which require generic Confirm or the removed Soulcaster creation footer are superseded by the user's direct-input correction and the current checks. Model forecast/RNG tests remain valid. No physical phone hardware or Windows artifacts were tested/rebuilt.
