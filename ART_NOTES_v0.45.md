# Current artwork and interface — v0.45

The active Hollow selection is roctavian’s skeletal warrior from Dungeon Crawl, pinned to commit 7c9bbd012c6538499643b2da006c16a7c6fee1e0 (17 September 2016). The original 32×32 PNG is unchanged. Its tile-directory public-domain notice and the upstream licence distinguishing tile artwork from GPL program code are retained in prototype/assets/vendor/crawl_roctavian/. No upstream program code is copied.

All 85 face identities use distinct Game-icons.net symbols from revision c547b7e4941d83bba737cd97a0a168e6719a7807 (31 October 2020). Icons made by Lorc, Delapouite, DarkZaitzev, Felbrigg, Sbed, Skoll and Willdabeast. Licence: CC BY 3.0, https://creativecommons.org/licenses/by/3.0/ . Original SVGs are unchanged; runtime display removes black backgrounds, scales and tints them. Exact artist/source URLs, hashes and face assignments are in prototype/assets/vendor/game_icons/SELECTIONS.json. Main menu → More → Art credits supplies visible attribution and source/licence links.

Pirata One by Rodrigo Fuenzalida and Nicolas Massi supplies gothic headings under the SIL Open Font License. Original TTF and OFL are in prototype/assets/vendor/pirata_one/. Body and ability text retain the existing readable font.

The three floor tiles are unchanged CC0 0x72 DungeonTileset II v1.7 originals; exact archive paths and hashes are in prototype/assets/vendor/dungeon_tileset_ii/UI-FLOOR-SELECTIONS.json. The original archive, licence and artist’s no-generative-AI statement remain vendored. https://0x72.itch.io/dungeontileset-ii

Nu’gh, worms and familiar creatures retain v0.41 repository selections. Wilds retain Kenney Tiny Dungeon CC0 selections. Other bosses / Trial roles retain 0x72 art. Their historical source notices, archives and reproduction scripts remain intact. New Hollow art does not change occupied cells, targeting or stats. Native pixel art uses nearest-neighbour enlargement.

The dark HUD, etched frames, portraits, health bars and compact skill rack are custom Godot UI code. Official Darkest Dungeon screenshots were consulted for visual hierarchy only; no Red Hook artwork or fan-clone assets were copied. No image-generation service was used for this update.

---

# Interface and effects — v0.42

The new HUD frames, health bars, category marks and ash particles are drawn in code (`battle_hud.gd` / `death_feedback.gd`). Falls reuse each unit’s existing sprite with a brief fade and collapse. The two new feedback sounds are synthesized in code. No new sprite imagery or image-generation service is used; v0.41 sprite selections, original archives and licences remain unchanged.

---

# Current artwork — v0.41

At the user's request, Nu’gh, phase II, hostile and friendly worms, mites, cocoon and the familiar Bone / Support / Movement creatures return to the earlier repository pixel sheets. Wilds return to the existing Kenney Tiny Dungeon CC0 selections. Camp portraits and combat use matching selections through `enemy_art.gd`.

This is an asset reversion; no new image generation was used. The existing 0x72 DungeonTileset II CC0 art remains for the other bosses and Trial roles. All original archives, licences, source evidence and reproduction scripts are retained. Sprite changes do not alter footprints, stats, targeting or rewards.

---

# Current artwork — v0.39

Enemy sprites now use **0x72’s DungeonTileset II v1.7**, original animated pixel art under **CC0**. The artist’s original page explicitly states **“No generative AI was used in the creation of these assets.”**

Source: https://0x72.itch.io/dungeontileset-ii

The original archive, licence/source evidence and SHA-256 are retained under `prototype/assets/vendor/dungeon_tileset_ii/`. `SELECTIONS.json` records every original frame and generated-atlas hash. Run `python tools/make_enemy_sprites.py` to reproduce the extracted atlases. Frames are cropped only to remove transparent padding and packed without resampling, new paint, palette changes or invented in-between frames. The skeleton Sentry additionally uses the artist’s bow. Rendering uses nearest-neighbour integer enlargement.

Distinct sprites cover the six ordinary creature families, five Trial roles, four bosses and worms/mites/cocoons. Real idle and run frames respond to movement. Boss phase, resonance/core and guard indicators remain. Creature sprite sizes fit their one-cell legal footprints; art does not alter targeting, stats, action dice or rewards. Camp portraits use matching stills.

Soul and Memory icons retain the human-authored Kenney CC0 sprites described below. Hero art, arena art and music remain from earlier versions. Historical builds keep their original art.

---

# Current artwork — v0.30

The Soul, Memory and Wilds creature sprites now use **Kenney's Tiny Dungeon 1.0**, a human-authored 16×16 pixel-art pack under **Creative Commons Zero (CC0)**. The included original licence credits Kenney and dates the pack to 5 July 2022.

Original pack: https://kenney.nl/assets/tiny-dungeon
Vendored original sheet, licence, pinned mirror and SHA-256: prototype/assets/vendor/kenney_tiny_dungeon/.

The reproducible adapter is tools/make_retro_sprites.py. It selects existing tiles and applies explicit palette substitutions; it does not generate imagery, paint new silhouettes, downsample previous images or add gradients/filters. Enemy silhouettes use the pack's slime/spirit, winged creature and armoured creature. Soul variants use its spirit, mask, winged creature and shield; Memory uses its medallion. Tile coordinates and every palette substitution are recorded in the script.

Current atlases:

- souls_memory_sheet.png: 64×16, four 16×16 cells for Beginning, Hollow, Ash Road and Memory of Loss.
- wilds_sheet.png: 48×32, three 16×16 enemies above three 16×16 Souls.
- Alpha is 0 or 255 and every individual sprite has at most 16 visible colours.
- Nearest-neighbour sampling and integer enlargement keep the pixel grid crisp in Camp, Equipment and combat.

Regenerate with `python tools/make_retro_sprites.py`. The original Kenney sheet is preserved unchanged; the adapter produces only selected/colour-varied copies. Credit to Kenney is included voluntarily although CC0 does not require attribution.

The detailed image-generated artwork used by v0.28/v0.29 has been replaced in the current shipping asset paths. Historical browser builds retain their older art. Existing hero/boss art, other pixel creatures, fonts and audio remain unchanged. Gameplay and saves are unchanged.


## v0.36 Trial objects

Ritual stones, the Lost Spirit and the Rupture Core are drawn directly by `draw_trial_object()` in `prototype/prototype.gd`, with rectangles, a small flat palette and restrained motion. Their drawing fits one tile and uses no cast shadow. No new image-generation service, painted image or external art asset was used for these objects. Existing creature, Soul and Memory sprite sheets remain the Kenney Tiny Dungeon selections and palette variants described above.
