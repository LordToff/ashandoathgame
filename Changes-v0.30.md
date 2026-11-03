# Ash & Oath v0.30 — Retro sprite replacement

Replaced the detailed generated Soul/Memory and Wilds creature art with licensed human-authored **Kenney Tiny Dungeon** sprites (CC0), using its original 16×16 pixel silhouettes and explicit palette variants. Kenney’s original sheet, licence and source provenance are included. No image generation service or synthesized artwork is used for the replacements.

All three Wilds enemies, six Soul icons and Memory of Loss now use native 16×16 tiles, small palettes and opaque/transparent pixel edges. Exact atlas regions, nearest-neighbour sampling and integer enlargement preserve their retro pixel grid in Camp, Equipment and combat. The existing smaller ordinary creatures also draw at integer enlargement.

The reproducible adapter is tools/make_retro_sprites.py. Tile coordinates and colour substitutions are recorded there; source/credit details are in ART_NOTES.md and prototype/assets/vendor/kenney_tiny_dungeon/SOURCE.md. The previous detailed pictures are no longer used by this build.

This is an art/presentation update. Enemy stats/dice, Souls, recipes, Essence prices, ownership, equipment, saves, combat rules and Windows downloads are unchanged. The v0.29 gameplay rulebook remains current.
