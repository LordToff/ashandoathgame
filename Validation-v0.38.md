# Validation — Ash & Oath v0.38

12 November 2026 · Godot 4.6.3 · Chromium with software rendering.

**Passed:** 2,764 checks in 20 model/UI suites, four exported fixture layouts and two shipping-export browser layouts. No GDScript failures or Chromium console/page errors in passing checks.

## Soulcaster rules and regressions

`prototype/tests/soulcaster_v38_test.gd`: 144 checks covering free starter Soul availability for both classes/all heroes; adapted legal dice; four-Blank construction; Memory HP arithmetic; zero starting charges; Gather and all six creation costs; charge/spell caps; physical-side replacement and creation-turn lock (including rerolled Reaction/Fatebreaker); HP-cost Downing; Wraith swap/Rooted/optional steps; Harvester activation cost/kill cap/object exclusion; Grave Stitch revival/Spirit/return to Blank; Mirror ally protection, reflection, partial HP loss, forced collision/Stun continuation, friendly fire and Spirit; Omen next-turn offer/exclusions/original die/shared roll/Stun/release/mutation; Fate eligibility/resolved results/once-per-die, initial multi-roll queue, Focus, recovery, Bind finalization, all four bosses and the Hollow interrupt; read-only forecast/reward validation; focused UI and refreshed nonblocking reroll hints.

The other 19 suites cover existing classes, Trial objectives/crafting/weapon faces, old checkpoint behavior, normal 73-face/48-design isolation, targeting, Poison, copy/Engrave/reroll interactions, Essence/Camp equipment, Wilds, phone controls, normal model balance, summons/worms and the four bosses. Individual check counts and results are in [Validation-v0.38.json](Validation-v0.38.json).

## Browser interaction and visual review

`tools/verify_soulcaster_browser.py`, using a separate nonshipping fixture: **390×844, 360×640, 844×390 and 1440×900**. Real mouse/touch events select and persist Soulcaster, inspect actual dice/spellbook, create Fatebreaker, Gather, target/confirm Harvester, swap and choose Wraith steps, reroll a secondary enemy die, save an Omen die, inspect illegal reward slots and retain normal class selection. All four pass with zero browser errors. Screenshots were inspected for the casting panel, held-die explanation and board-visible Wraith controls.

The shipping export was also exercised without fixture callbacks at **1440×900 and 390×844**: main-menu version, normal Trial lobby → free Soulcaster selection → actual starter dice → spellbook → new route → combat → enemy intent. The requested pack loads successfully and `window.essenceProof` is absent.

Follow-up reward/help checks use `tools/verify_trial_help_browser.py`: choose a legal side without payment, Buy installs the physical face and spends exactly 2 Run Essence, and topic-based resource/how-to-play help works by mouse/touch. Screenshots and logs are retained in the task workspace.

## Build and documentation

Current rules, HTML and 48-page A4 PDF are generated from reviewed prose and the current Godot snapshot, including all six spell definitions and exact adapted starter dice. The supplied PDF is retained under `docs/design/`. Godot Web export succeeds; test scripts/docs/downloads are excluded from the shipping pack. Pages publication uses a versioned pack, source commit, version file and SHA-256 manifest, verified separately after deployment.

No physical phone hardware or Windows build was tested. Trial balance remains experimental. Native UI tests retain the existing exit-time ObjectDB/resource warnings; these are recorded separately from script failures and actual browser checks. Socket-denied editor listener warnings under the restricted shell did not prevent import/export.
