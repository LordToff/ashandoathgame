# Validation — Ash & Oath v0.45

16 November 2026 · Godot 4.6.3 · software-rendered Chromium.

**Passed: 3,909 checks across 27 native model / UI suites.** Full results are in Validation-v0.45.json. Temporary per-suite save directories isolate inventory and settings. The existing 26 suites pass; direct, menus and chamber suites were rechecked after the final UI changes. Historical exit-time ObjectDB / resource warnings remain; passing runs contain no script errors or failed assertions.

The new 587-check gothic suite verifies all 98 original icon hashes, all 85 distinct face assignments and bounded imported / picker image sizes, the pinned unchanged Hollow tile, compact skill geometry, input-transparent decoration, selected / held / spent / forced states, phone / landscape / desktop bounds and intact Test chamber access. It measures all 85 full ability names in the 360px phone rack. Rendering does not mutate RNG, events, boss HP or occupied cells.

Actual mouse / touch direct-combat journeys pass at 360×640, 390×844, 844×390 and 1440×900, with no browser console / page errors: attacks → map target, one-tap Guard, movement, Borrow Shape, compact Soulcaster creation / Gather / costs / delayed use, Harvester, Wraith, Jab and Crack. Main-menu, Camp, craft → install, explicit equipment Apply, Help/search/return and Trial Memory reward regressions pass phone and desktop. Test chamber entry, search, real Numeric attack, forced result, tool reopening, reset, earned face choice and inventory isolation pass narrow phone and desktop.

Final gothic preview checks at 360×640 and 1440×900 use actual input for Strike / Guard, spent state, six spell symbols and real Mirror creation, Main menu → More → Art credits, author / licence visibility, and a filtered Borrow Shape icon picker. Screenshots of main menu, combat, spells, credits and picker were inspected. Original artist SVGs are unmodified; transparent/tinted display is performed at runtime. Header fonts and readable body text are separate.

The exact committed shipping export is checked separately before publication on desktop and phone: no fixture callback, the versioned pack, visible Test chamber, its ability picker, actual practice map and reopening tools. BUILD.json records source, sizes and SHA-256; GitHub Pages deployment and live file hashes are checked after publishing. Tests, tools and docs are excluded from the game pack. Current HTML / Markdown / PDF rules are regenerated and PDF text is read back; gameplay rules retain their behavior. No physical phone, listening session or Windows rebuild was tested.
