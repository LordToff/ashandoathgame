# Validation — Ash & Oath v0.44

15 November 2026 · Godot 4.6.3 · software-rendered Chromium.

**Passed: 3,322 checks across 26 native model / UI suites.** Full results are in Validation-v0.44.json. Suites use temporary isolated save data and have no script errors in passing runs. Native UI tests retain historical exit-time ObjectDB / resource warnings.

The new 164-check chamber suite walks the real MainLab / MobileLab buttons at 360×640, 390×844, 844×390 and 1440×900. The visible footer opens the shared tools directly. All 73 normal / earned entries construct actual Lab scenarios. Search is read-only, a single filtered result can be selected again, no-match results are safely disabled, forced Numeric values are applied, Try returns to combat, tools remain reachable, Reset restores the test, and combinations apply their actual second result. Leaving clears tool state. Normal prepared dice, bonuses, bank and owned copies remain unchanged. Existing 169-check menu tests verify shared headers, footers, widths, crafting and every Trial reward branch.

The chamber browser journey passed all four sizes with real mouse / touch and no console / page errors: Main menu → chamber, search / choose Strike Numeric, force a Numeric value, hit the real boss on the map, reopen tools, reset, select Bone Growth without paying for an owned copy, filter to no results, return to Main menu, and inspect Camp, Equipment, Help and Trial preparation. Final phone / desktop runs also open and close the shared combination screen; native checks apply its physical second ability at all four sizes. The final desktop hearth and phone menus were visually inspected.

Phone / desktop menu regressions pass normal suggestions → boss → road event, resource Help / search / return, a paid craft → installation, read-only gear preview then Apply, Trial Memory rewards and Back without payment. Direct combat regressions pass Attack → map target, one-tap Guard, movement, Borrow Shape, compact Soulcaster, spell costs / creation delay, Harvester, Wraith, Jab and Crack.

The exact committed shipping export is checked separately with no fixture callback, on desktop and phone: the visible chamber button, actual practice map, reopening its tools, Main menu return, Camp tasks, equipment explanations, Help, suggested normal party and required road-event navigation. Versioned pack, source commit, byte sizes and SHA-256 BUILD.json identify the release. GitHub Pages deployment and live file hashes are verified after publication.

The rulebook is regenerated in HTML / Markdown / PDF, including direct chamber entry and practice tools; its PDF text was read back. Tests / tools / documentation are excluded from the browser pack. This release reuses existing artwork and adds code-drawn menu ornaments / hearth; enemy selections and gameplay rules retain their behavior. No physical phone, listening session or Windows rebuild was tested.
