# v0.32 — readable fights and deliberate choices

Enemy intents now show each living enemy’s rolled abilities, named targets, priorities, range and effect in a dedicated scrollable panel. The phone battle header opens it directly; landscape and desktop also have a permanent intent button. Ability descriptions are concise and use category colors.

Enemy abilities use different priorities: lowest/highest HP, most Block, buffs, debuffs, distance or actual enemy HP damage dealt in the previous round. Preferred targets outside legal reach fall back to the closest legal target. Equal priorities use a stable random choice seeded by the round; inspecting the UI does not change combat randomness. Targets update when battlefield state changes. Movement rechecks attack range afterward; Reactions can force a retarget. Self, area, healing and summon targets are explicit. Support creatures heal the legal ally with the most missing HP.

Borrow Shape, Conjure, repeat/setup choices and Shared Burden’s ally die use a full face-up picker: nine rolled hero results, inspect first, then confirm. Unrolled installed sides are absent. Abilities that explicitly alter an installed slot still show those slots. Spent and held Borrow Shape sources remain eligible under its existing rules.

Attack faces are red, Defense blue, Movement yellow, Blanks light gray and Skills purple. Spent results turn dark gray; held Reactions and Channels remain distinct.

Poison HP loss now has green damage feedback and its own SFX. Actual healing and newly applied Stun have distinct effects and sounds. SFX respect mute and volume. Visuals pause behind damage notices and resume after acknowledgement, making Poison damage visible after closing its popup.

Engrave’s installed copy was easy to miss, especially when the recorded Blank result stayed Blank. A growth notice now displays all six updated installed sides. Failed triggers explain Block/zero HP loss, lack of Blank sides or the growth/copy limit. Growth still needs actual HP damage, fills a Blank on the same die, defaults to one growth per own turn and three copies per die, and lasts only for the encounter. Newly installed sides affect future rolls, not results already rolled. Killing-hit growth is retained.

Essence recipes can be read before payment. Forge shows cost, banked amount and deficit; refitting shows owned, equipped and free physical copies. Crafting still costs the same Essence and does not equip a copy automatically. Bound Soul recipients, Memory ownership, old banks and inventory are preserved. Undefined Hunt/services from the supplied design PDF are not introduced.

Updated current rules and PDF describe these changes. Windows downloads are unchanged. Browser checks use touch emulation, not physical iOS/Android hardware; encounter difficulty remains provisional.
