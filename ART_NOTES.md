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
