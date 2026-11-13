# DungeonTileset II — original source and licence

Artist: **0x72**. Original page: https://0x72.itch.io/dungeontileset-ii

Downloaded 13 November 2026 from the artist's own free itch.io download, upload 9911410, `0x72_DungeonTilesetII_v1.7.zip`.

Archive SHA-256: `a5b23341ebc831d7798bfb9666d864a08c079bb7aed18e3cf023a27d517c1512`.

The artist's page explicitly lists **Creative Commons Zero v1.0 Universal** as the asset licence, links CC0, and says credit is not necessary. It also explicitly states **“No generative AI was used in the creation of these assets.”** The original page has development posts from July and October 2019. These are original human-authored pixel frames, not generated or traced artwork.

CC0 legal terms: https://creativecommons.org/publicdomain/zero/1.0/legalcode

The unmodified original archive is retained here. `tools/make_enemy_sprites.py` extracts the named idle/run frames, removes transparent outer padding, anchors them to a 32-pixel cell and packs atlases without resampling, palette changes or synthesized frames. The Sentry combines the artist's skeleton and bow assets. `SELECTIONS.json` records every original frame, crop and output hash. Game rendering uses nearest-neighbour integer enlargement. Bosses retain their normal stats/footprints and have explicit gameplay indicators above the new art.
