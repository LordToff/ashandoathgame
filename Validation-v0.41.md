# Validation — Ash & Oath v0.41

14 November 2026 · Godot 4.6.3 · software-rendered Chromium.

**Passed: 2,902 checks across 23 native model/UI suites.** Individual results are in Validation-v0.41.json. Native saves use isolated temporary per-suite XDG_DATA_HOME directories. No script errors occurred in the passing suites; historical exit-time ObjectDB/resource warnings remain in native UI runs.

The new 56-check playback suite uses a real seeded Nu’gh worm hit: the model resolves damage and Poison once; displayed HP remains unchanged during the roll and wind-up, updates at impact, then Poison appears. It checks result hold duration, no replay RNG/damage, compact board-visible dice, worm attack cues, Poison sound during its visual step, log access, actual Blank Move 1 die spending, no toggle refill, settings across four sizes, and spell-card/header bounds.

Chromium playback checks passed at **390×844, 360×640, 844×390 and 1440×900**. They observe roll → settled result → wind-up/lunge → HP impact → Poison, plus visible zero/miss without damage or Poison. Poison sound starts during its cue. Model RNG is unchanged during replay. Final outcomes remain in the last-roll strip; Summary / Extensive history opens from a button. Screenshots were inspected.

Direct-combat regressions and equipment checks passed at those four sizes with real touch/mouse inputs. They retain ability → map target, one-tap Guard, movement, Borrow Shape, Soulcaster costs/delays, Harvester/Wraith/Jab/Crack, Body/Weapon separation, rolled Poke, Oathblade passives, empty starting Memories and post-victory Memory rewards. Equipment automation waits for touch scrolling to settle before opening a dropdown.

Layout/settings checks passed at all four sizes: six spell cards fit, Settings is reachable in both modes, Soulcaster’s optional Move 1 spends a Blank without spending charges, toggling cannot refill the allowance, the preference survives reload, and Extensive history opens. The final compact Soulcaster heading was rechecked at 360×640. No console/page errors occurred in passing browser checks.

The actual shipping export is checked without fixture callbacks on desktop and phone: main menu, Camp equipment, desktop Trial setup and combat, with a compact shared roll and the Battle log button. Export excludes tests, tools, docs and downloads. Current rules are regenerated as HTML / Markdown / PDF. The public release records exact source commit, versioned pack size and SHA-256 hashes; GitHub Pages deployment and live release metadata are verified after publishing.

No physical phone, listening session or Windows rebuild was tested. Audio assertions verify distinct streams and cue timing; headless Chromium does not establish speaker quality. Equipment rules, rewards and RNG behavior retain their existing semantics except the explicit OFF-by-default Blank movement setting.
