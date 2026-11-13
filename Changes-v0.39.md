# Ash & Oath v0.39 — direct combat and animated enemy sprites

13 November 2026.

- **Attack → map target. Movement → destination.** Ordinary Trial actions resolve on that map tap, with no extra generic Confirm step. Targeted heals and swaps follow the same flow. **Guard and other self effects resolve on the ability tap.** Required choices, Reactions and friendly-fire warnings keep their specific controls.
- **Soulcaster: Blank → Gather or spell.** Its compact panel keeps the board visible and shows charge bank, spell slots, HP and creation costs. A spell button creates it immediately; Help is optional and Close spends nothing. The supplied spell rules, costs, caps, creation-turn lock and delayed activation are preserved. Rolled Harvester, Stitch, Exchange and Omen use direct map targets.
- **New original pixel art by 0x72:** six ordinary creature families, five distinct Trial roles, four bosses and summons use original idle/run frames from DungeonTileset II, under CC0. The artist explicitly marks the pack as containing no generative AI. The skeleton Sentry additionally uses the artist's bow. Boss phase/core/guard indicators remain.
- **Clearer occupied tiles:** ordinary creature floors no longer show the old two-cell boss-pad drawing. Sprite appearance does not alter legal footprints, stats, dice, targeting or rewards.
- Current rules/PDF, patch notes, source/licence evidence, original archive and exact frame selections are included. Fullscreen Settings remains available.

Artist and original pack: https://0x72.itch.io/dungeontileset-ii

Source evidence, archive SHA-256 and CC0 link: `prototype/assets/vendor/dungeon_tileset_ii/SOURCE.md`. Reproduce the atlases with `python tools/make_enemy_sprites.py`; no image synthesis, resampling, palette changes or invented in-between frames are used.

Windows artifacts were not rebuilt. Physical phone hardware was not tested; browser checks use touch emulation.
