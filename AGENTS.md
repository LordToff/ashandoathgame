# Ash & Oath development

Canonical repository: https://github.com/LordToff/ashandoathgame.git, source branch `main`. Start by reading README.md, docs/RECOVERY.md and current source. The older Godot-Game-Template repository is a historical location, not the default development target.

Use the existing checkout. Cloud tasks are already isolated; do not create Git worktrees unless the user requests one. Inspect git status and preserve user changes.

Use Godot 4.6.3 for the current browser workflow. Most game code is under prototype/. Preserve action faces, face ownership/caps, weak early Blanks and optional Soul progression, four boss selectors, Warden guard/evade mechanics, and friendly Summon/Command Nu’gh. Do not restore obsolete pinned descriptions or cocoon Bu’gh to satisfy historical tests.

Before publishing, run relevant model/UI tests, inspect actual exported Chromium UI, and update current rules, PDF, in-game patch notes and release notes for gameplay changes. See docs/Validation-v0.25.md for verified checks and known historical test limitations. Do not count headless rendered-fixture timeouts as passes.

Browser releases use gh-pages with a versioned main pack, SOURCE_COMMIT.txt, VERSION.txt and SHA-256 BUILD.json. Verify deployment through GitHub Actions. Keep Windows artifacts unchanged unless explicitly updated and validated. Check existing Git authentication before asking for tokens; never copy credentials into recovery notes.

Essence/Camp rewards are defined in prototype/essence.gd and docs/Essence-Implementation-v0.27.md. Earned faces 60–68 use shared physical copy counts with no owned maximum; the free initial bonus pool stays at 48 designs. Retain normal Blank/body caps and bound Soul ownership. Do not invent effects or prices for the PDF’s unfinished service/Hunt/unique-boss candidates. Run essence_v27_test.gd and the saved Essence browser verifier for changes here.

v0.28 opens at Main menu. hub_ui.gd renders that menu and the starter-dice editor; camp_ui.gd has crafting, refit, Equipment and direct-creature tabs. Equipment and bound Beginning Soul ownership persist in essence.gd. Beginning Soul grants one rolled Blank as Move 1 per own turn; earned Souls retain Move 2 per equipped hero. Dagger Poke requires actual enemy HP damage in the current own turn, is once per own turn and spends no die. Test hub_v28_test.gd and tools/verify_hub_browser.py alongside the Essence verifier. Direct groups bank Essence only and never replace a required pre-boss event. No fixture callbacks belong in the shipping project.
