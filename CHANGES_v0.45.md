# Ash & Oath v0.45 — Gothic HUD and ability symbols

16 November 2026. Browser presentation release; normal and Trial rules are unchanged.

- Replaces the earlier ash-and-brass / parchment direction with near-black surfaces, ivory symbols, restrained crimson actions, etched corners and Pirata One headings. Body text retains the readable existing font.
- A compact three-face skill rack replaces the desktop stacked rows. A larger active hero portrait, HP bar and Block readout sit above it. Phone actions and End turn remain fixed. Full names fit narrow face tiles; selected, held, forced and spent states remain distinct.
- Every one of the 85 face identities has a distinct symbol: 73 normal / earned / generated entries, six Soulcaster spells and six projected weapon attacks. Ability choices, Test chamber, equipment and dice selectors share the same registry. Attack / Defense / Movement / Skill names retain their category colors; spent faces are gray.
- Intents separate the action name from its target and open the existing full explanation. Decorative artwork ignores input. Battle history remains button-opened.
- The Hollow uses roctavian’s original 2016 skeletal-warrior pixel tile instead of the rejected red demon. Its existing attack, phase and death effects remain. Its footprint, stats and behavior are unchanged. Other creatures retain v0.41 selections.
- Stone floors use three unchanged 0x72 dungeon tiles underneath the single combat grid.
- Main menu → More → Art credits identifies the Game-icons.net artists and CC BY 3.0 licence, with source links. Original SVGs, font licence, tile notices and exact selection hashes are in source control.

## Reference and sources

The user selected a restrained gothic direction like Darkest Dungeon. Its official HUD screenshots informed contrast, portrait hierarchy and the compact skill rack: https://www.darkestdungeon.com/darkest-dungeon/ . No Red Hook game assets or fan-clone assets are shipped. The UI implementation is custom; this is not an installed Darkest Dungeon template.

Icons are existing artist-authored Game-icons.net designs from pinned revision c547b7e4941d83bba737cd97a0a168e6719a7807 (2020). No new image-generation service was used. The rejected Kenney Adventure parchment assets were removed from this release.

## Preserved behavior

Direct ability → map target, one-tap self Defense, Soulcaster costs/timing, equipment construction, physical copies, saves, rewards and normal / Trial isolation are retained. Test chamber remains on the main menu. Rendering never rolls combat RNG. Windows artifacts are unchanged.
