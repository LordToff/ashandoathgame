# Ash & Oath v0.46 — Turn rerolls, original knights and a stone arena

16 November 2026. Browser release for normal play and Trials.

## Optional turn refill

Settings → **1 reroll each turn** is OFF by default. When ON, each living hero starts their own turn with at least 1 Action Reroll charge, up to the existing bank cap. Unused refills do not stack; earned extra charges are preserved. Full immediate recovery turns qualify. Shared round rolls, Focus, ordinary rerolls, Shared Burden interrupts and UI rebuilds do not grant extra refills. Switching ON takes effect at the next own turn, without granting a charge immediately. Any time / Opening only remains a separate timing choice.

The option saves on this device alongside dice animation and Blank → Move 1. Normal and Trial Settings expose the same preference. Existing profiles and saves default to the previous no-refill behavior.

## Fixes and controls

- Clear stale reroll selection and targeting when a turn changes. A new hero’s ability tap cannot silently become a reroll. Valid freshly staged action choices are preserved.
- Reroll selection now has an explicit **Cancel reroll** action. Cancelling spends nothing. Mobile shows the remaining bank, and ineligible dice dim while choosing.
- Mobile names the current target / movement task; legal destinations have clear dots and target outlines. Active hero cards use their hero color.
- Saved Hoarded Omen dice retain the ability name and held marker, without looking spent.
- The boss health bar stays inside the boss footprint. A Block badge remains available; full HP / Block numbers stay in the HUD. This removes the old text strip covering adjacent heroes.
- Mobile menu surfaces match the near-black gothic theme.

## Original non-AI artwork

Three detailed 32×32 knights replace the old party sprites in combat, portraits, preparation and death feedback: silver Vault Guard for Vesper, dark Death Knight for Rook and red-and-gold Vault Warden for Wren. Three cobblestone floors and masonry replace the earlier flat arena surface. The original PNGs come from Dungeon Crawl Stone Soup / RLTiles contributors, pinned to a September 2016 revision, under the public-domain / CC0 tile terms. They are copied unchanged, with exact source URLs, original licence notices and hashes in `prototype/assets/vendor/crawl_party_arena/`.

This uses original still artwork with existing movement, lunge, recoil and fall motion. It does not invent animation frames or use image generation. The playable 9×9 grid, occupied cells, ranges, hero stats, gear, classes, combat effects, enemy selections and rewards retain their behavior. Masonry is decoration outside legal cells. The Hollow keeps its existing original skeletal-warrior art. Windows artifacts are unchanged.

[Art sources](Sprite-Sources-v0.46.md) · [Validation](Validation-v0.46.md)
