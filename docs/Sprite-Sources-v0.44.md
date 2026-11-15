# Sprite selections — v0.44

Sprite selections are unchanged from v0.41. Menus reuse the chamber backdrop and hero sheet, with original drawn brass ornaments and a code-drawn oathfire; no enemy artwork was replaced.

The release retains the earlier repository pixel sprites for Nu’gh (both phases), hostile / friendly worms, mites, cocoon and Bone / Support / Movement creatures. Wilds use the existing Kenney Tiny Dungeon CC0 selections. `prototype/enemy_art.gd` is the active selection map; `Sprite-Selections-v0.44.json` records selected file hashes. Camp portraits share these selections.

This update reuses existing assets and makes no new image-generation calls. The restored custom repository sprites are not newly commissioned external art. Existing reproduction scripts include `tools/make_nugh_art.py`, `tools/make_bugh_art.py` and `tools/make_retro_sprites.py`.

Other bosses and Trial roles retain 0x72 DungeonTileset II v1.7 CC0 sprites. The original source archive, artist’s explicit no-generative-AI statement, licence and exact frame hashes remain under `prototype/assets/vendor/dungeon_tileset_ii/`. Source: https://0x72.itch.io/dungeontileset-ii

Kenney Tiny Dungeon original sheet, licence and hashes remain under `prototype/assets/vendor/kenney_tiny_dungeon/`. Source: https://kenney.nl/assets/tiny-dungeon

All sprites use nearest-neighbour enlargement. Stats, occupied cells and targeting footprints are unchanged. See ART_NOTES.md for historical asset notes.
