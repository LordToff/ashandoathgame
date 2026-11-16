# Artwork and interface sources — v0.46

## Party knights and arena

Original pixel artwork by Dungeon Crawl Stone Soup / RLTiles contributors, pinned to revision `7c9bbd012c6538499643b2da006c16a7c6fee1e0` (17 September 2016), https://github.com/crawl/crawl . The historical original tiles predate contemporary generative-image tools; no image generation is used for this release.

- Vesper: `crawl-ref/source/rltiles/mon/vault_guard.png`.
- Rook: `crawl-ref/source/rltiles/mon/death_knight.png`.
- Wren: `crawl-ref/source/rltiles/mon/vault_warden.png`.
- Floors: `crawl-ref/source/rltiles/dngn/floor/cobble_blood1.png`, `cobble_blood2.png`, `cobble_blood3.png`.
- Masonry: `crawl-ref/source/rltiles/dngn/wall/brick_gray0.png`.

The seven original PNGs are unchanged. Native 32px knights render at 2× integer scale on the board. HUD portraits use a read-only crop. Movement, lunge, recoil and falls transform the original still; no new painted frames or palette variants are made. Runtime terrain lighting, the single logical grid, hazards and selection overlays are separate code rendering. Decorative walls stay outside legal cells.

`prototype/assets/vendor/crawl_party_arena/` contains each unchanged image, per-file original path / pinned URL / SHA-256, SOURCE.md, the original tile-directory public-domain notice and the upstream licence distinguishing tile art (Public Domain / CC0) from GPL program code. All seven PNGs also match exact Git blob hashes in crawl/tiles’ curated CC0 Nov-2015 release; curation policy, artist approvals and exclusions are retained beside the selection manifest. No upstream program code is copied. Knight selections are cosmetic and never grant stats, weapons, classes or abilities. Main menu → More → Art credits names the source family.

## Retained selections

The Hollow retains roctavian’s original 2016 skeletal-warrior tile and notices. Other enemies retain v0.41 selections. All 85 ability identities retain distinct original Game-icons.net symbols, pinned to the 2020 revision documented in Sprite-Sources-v0.45.md, with visible author / CC BY 3.0 attribution. Pirata One headings retain their original OFL notice. Existing 0x72 and Kenney source archives and licences remain in source control as historical and active selections.

Source evidence for the alternative 0x72 DungeonTileset II pack was checked online during research (its artist explicitly says no generative AI was used). The selected knights and arena use the closer-matching 2016 Dungeon Crawl family instead. The rejected cartoony alternatives were not added.
