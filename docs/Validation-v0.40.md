# Validation — Ash & Oath v0.40

13 November 2026 · Godot 4.6.3 · software-rendered Chromium.

**Passed: 2,846 checks across 22 native model/UI suites.** Individual results are recorded in Validation-v0.40.json. No script errors occurred. Native UI suites retain their historical exit-time resource warnings, which are separate from test failures. Native save data was isolated in temporary per-suite XDG_DATA_HOME directories.

The new equipment suite checks Body/Weapon separation, Attack minimums/maximums, Soul Blanks/HP, one/two/three physical Strike projections, Poke’s prerequisite and die spending, unique Weapon passives on projected and other Attacks, Beginning Soul’s once-per-encounter Last Ember, empty starting Memories, legal classes with every retained Soul, post-victory Memory rewards, converted-save copy ownership, idempotence, atomic equipment/refit validation and distinct Iron / Ironbound Memories.

Equipment browser checks passed at **390×844, 360×640, 844×390 and 1440×900**, using real mouse/touch input. They exercise normal equipment selectors, printed Weapon limits/replacement counts/passives, rolled Poke, Oathblade’s passive on another Attack, Trial HP/empty Memories and buying a Memory after the first encounter. No console or page errors occurred. Screenshots were inspected.

Direct-combat browser regressions passed at the same four sizes: select Attack then map target, one-tap Guard, movement then destination, normal/Trial controls, targeted Grave Stitch, copied Guard, compact Soulcaster, Gather/Manifest costs and delays, Harvester, Wraith Exchange, Jab and Crack. The updated fixtures use retained ordinary Strike sides and printed Stride rather than the removed free Poke, Body movement bonuses or starting Memory damage.

The **actual shipping export**, with no test callbacks, passed desktop and phone main-menu/Camp equipment checks and desktop Trial setup. OCR verifies the visible Weapon bounds, Body categories, empty Memory and 6-HP class starter. No browser console/page errors occurred. Export excludes tests, tools, docs and download artifacts.

Current rules are regenerated as HTML, Markdown and PDF from reviewed rules prose plus the shared item definitions. Source branch and public release use separate checkouts; the versioned pack, source commit, file sizes and SHA-256 manifest identify the browser release. No physical phone or Windows build was tested.
