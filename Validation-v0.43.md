# Validation — Ash & Oath v0.43

15 November 2026 · Godot 4.6.3 · software-rendered Chromium.

**Passed: 3,158 checks across 25 native model / UI suites.** Each suite uses isolated temporary save data. Full results are in Validation-v0.43.json. Passing runs have no script errors; native UI tests retain historical exit-time ObjectDB / resource warnings.

The new 169-check menu suite validates equipment-scoped normal suggestions, retaining ready heroes, read-only gear previews, unowned-item rejection, one-copy installation / return, and all Trial reward branches. Memory, face and Weapon purchases pay exactly once; taking currency leaves dice alone. Normal Camp remains isolated. Searching Help, closing it and Escape preserve choices, pending combat, currency and RNG. Shared title / Help / footer bounds and Camp widths are checked at 360×640, 390×844, 844×390 and 1440×900. Selectors open on release; shared audio widgets cannot cover the footer.

The menu browser journey passed all four sizes with real mouse / touch input and no console / page errors: normal suggested preparation, boss choice and required road event, context resource Help / search / return, crafting one actual face, installing it with no second payment, gear preview then Apply, and staged Trial Memory rewards without an unrelated dice grid. Back spends nothing. Touch drags starting over a material selector neither open its popup nor change the selection. The successful-craft follow-up is immediately accessible. Screenshots of desktop, portrait and landscape menus were inspected; a zero-height title and sideways selector overflow found during testing were fixed before the passing runs.

Direct combat and equipment browser regressions passed on phone and desktop: Attack → map target, one-tap Guard, movement, Borrow Shape, compact Soulcaster / spell costs / creation delay, Harvester, Wraith, Jab, Crack, Weapon limits / projections / passives, rolled Poke and later Memory rewards. Historical flat-menu assertions now exercise the current preparation and reward journeys.

The actual shipping export, with no fixture callbacks, passed desktop and phone journeys through Main menu, Camp tasks, Body / Soul / Weapon explanations, context Help and return, suggested normal parties, boss choice and the road event. The exact committed release is exported and its versioned pack is inspected again before publishing. Export excludes tests, tools, documents and downloads.

Current rules were regenerated as HTML / Markdown / PDF, including menu navigation, explicit Apply, separate currencies and reward steps; PDF text was read back. Published files carry exact source commit, versioned pack, size and SHA-256 provenance. GitHub Pages deployment and live file hashes are checked after publication.

No physical phone, Windows rebuild or listening session was tested. This update changes presentation / navigation while preserving equipment limits, prices, owned copies, combat inputs, damage and RNG rules. Browser rendering and device behavior outside the tested sizes may differ.
