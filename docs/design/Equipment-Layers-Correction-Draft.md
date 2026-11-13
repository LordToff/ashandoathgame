# Equipment layers — correction and balance draft

13 November 2026. Applies to **normal play and Trials**. The layer definitions below follow the user's latest correction. Implemented in v0.40 for normal play and Trials. This records the design decisions; the current in-game item descriptions and rulebook are the playable reference.

## Authoritative layer responsibilities

| Layer | Owns | Does not supply by default |
| --- | --- | --- |
| Body | Minimum and maximum Defense, Movement and Skill faces across all three dice. | Attack limits, maximum HP, minimum Blanks, free movement distance bonuses. |
| Soul | Maximum HP, minimum Blanks on **each** Action Die, and its printed strong effect. Every Soul copy is bound to one named hero. | An implicit Blank-to-Move conversion merely because a Soul is equipped. |
| Memory | One passive modifier slot. The first encounter starts with this slot empty. A Memory may let a hero spend a rolled Blank for another effect. | A free starting class passive or default HP penalty. |
| Weapon | Minimum and maximum total Attack faces, An exact printed count of 1–3 basic Strike replacements with weapon-specific Attacks, and any optional passive affecting all Attack faces. | Extra free attacks outside the dice merely because the item is equipped. |

Bodies set only Defense, Movement and Skill minimums and maximums. Weapons alone set Attack minimums and maximums; every Weapon must specify both. Ownership/copy limits, available die sides and the Soul's per-die Blank minimum still apply. A replacement weapon face is still one Attack face; it does not add an extra side or die.

The supplied original Master Rules v4 confirms a six-HP starting Soul, a two-Blank alternative, an empty starting Memory, and Broken Body's separate 3/3/3 non-Attack category caps. Its extra starting Soul passive was explicitly undecided. The latest user correction supersedes its older classification of Blank movement as a Soul effect.

## Body minimums and maximums

Ranges count equipped category faces across the hero's **three Action Dice combined**. Each minimum is 0, so no current Body requires a category. Bodies have no Attack limit. HP and Blank minimum do not change when changing Body.

| Body | Defense min–max | Movement min–max | Skill min–max |
| --- | ---: | ---: | ---: |
| Broken Body | 0–3 | 0–3 | 0–3 |
| Fleet Body | 0–2 | 0–4 | 0–3 |
| Stone Body | 0–4 | 0–2 | 0–3 |

Fleet permits more movement faces; it does not make Step move 2. Stone permits more defenses; it does not increase HP or reduce Stride distance. Existing class starter dice must be rebuilt against these ranges: in particular, Skirmisher's third Guard should become a Blank so Fleet's two-Defense cap is respected.

## Starter Souls

| Soul | Maximum HP | Minimum Blanks per die | Strong effect |
| --- | ---: | ---: | --- |
| Beginning Soul | 6 | 2 | **Last Ember.** Once per encounter, lethal enemy damage leaves you at 1 HP instead. Voluntary HP payments are not cancelled. |
| Soulcaster | 6 | 4 | Keep the supplied Gather / Manifest system and six spells: charges cap 3, four manifested spells, creation costs charges + 1 HP, new spells must roll on a later turn, encounter-only manifestations. |

Last Ember supplies the Beginning Soul's strong effect. Soulcaster's 6 HP / 4 Blanks come from its supplied PDF. Both retain normal Block, healing, Downed and Broken rules except for an explicitly printed effect.

Values for the retained strong-effect Souls:

| Earned Soul | Maximum HP | Minimum Blanks per die | Existing effect to retain |
| --- | ---: | ---: | --- |
| Cinder | 6 | 3 | First enemy-HP-damaging Attack each own turn adds Poison 1; begin the encounter with Poison 1. |
| Brood | 5 | 3 | The first Poison application each own turn spreads Poison 1 to another adjacent enemy. The reduced HP is printed on this Soul. |
| Echo | 6 | 3 | First Skill each own turn readies +1 next-Attack damage; begin with zero Action Rerolls. |
| Warden | 6 | 3 | Preserve up to 2 Block at own-turn start; movement abilities travel 1 less, minimum 1. |

The three-Blank baseline follows the old earned-Soul construction baseline; these are the v0.40 item values. An item whose only effect is a Blank conversion should become a Memory instead of retaining the Soul label. Existing owned rewards must be retained through that conversion, with no deletion of earned copies.

## Weapon bounds

Every Weapon card must clearly state:

1. **Minimum Attack faces** and **maximum Attack faces**, counted across the hero's three dice. Count remaining basic Strikes, weapon replacements and other equipped Attack faces.
2. **Replace X basic Strikes with [weapon Attack]**, where the exact printed total X is 1, 2 or 3. Replacements can be copies of one weapon Attack or several named Attacks. Each replaces one existing basic Strike side and remains an Attack face.
3. **Attack passive**, if any. More unique Weapons may modify **all** of the equipped hero's Attack faces, including remaining basic Strikes, weapon replacements and other equipped Attacks. Display “None” if the Weapon has no such passive.

Oathblade is an earned unique Weapon: 3–6 Attack faces, 3 Strikes → Oath Cut, with Pierce 1 on all Attack faces. Craft it for 4 Warden Essence in normal play, or 4 Ward + 2 Hollow Essence in Trials.

The 1–3 range describes possible Weapon designs; each individual Weapon specifies its own replacement count. A replacement swaps a face rather than adding a side or die, so the total Attack-face count is unchanged. The build needs enough basic Strike sides for the printed replacements.

| Weapon | Minimum Attack faces | Maximum Attack faces | Basic Strike replacements | Weapon Attack effect | Passive for all Attack faces |
| --- | ---: | ---: | --- | --- | --- |
| Dagger | 2 | 5 | 1 Strike → Poke | 1 adjacent-enemy damage after this hero has damaged an enemy this turn. | None |
| Poison Dagger | 2 | 5 | 1 Strike → Poison Poke | Poke applies Poison 1 after HP damage. | None |
| Heavy Dagger | 2 | 6 | 1 Strike → Heavy Poke | 2 adjacent-enemy damage, then costs 1 HP; same prerequisite. | None |
| Spear | 2 | 6 | 1 Strike → Jab | Range 2, Move 2 first, once per own turn. | None |
| Hammer | 2 | 8 | 1 Strike → Crack | Adjacent enemy, another Attack first, remove up to 2 Block, no HP damage, once per own turn. | None |

Poke becomes a **rolled weapon face**. A two-Attack minimum leaves another Attack available to satisfy Poke/Crack prerequisites. The five common Weapons replace one Strike each; Oathblade replaces three. The schema also supports two replacements. Track replacement copies per equipped Weapon.

**Illustrative unique-Weapon passive:** “All your Attack faces gain Pierce 1.” This would affect every Attack face belonging to that hero while the Weapon is equipped. It would not affect non-Attack damage unless stated. This example does not grant Pierce to the five common Weapons above.

## Memory and starting loadouts

- Every first encounter starts with **Memory empty**, including both Trial classes.
- **Memory of the First Step** holds the old basic conversion: spend one rolled Blank as Move 1, once per own turn. The installed side remains Blank; this is neither a free move nor automatic movement when rolled.
- Wind / Hearth / Mire / Glasswing / Iron effects whose only role is Blank movement, healing, blinking or Block belong in Memory entries. Normal First Step Memory costs 1 Movement Creature Essence; converted Wilds Memories cost 3 matching Essence. Trial Memories can be equipped as a reward after the first victory for 2 Run Essence. Wind / Hearth recipes unlock them in the Trial Forge.
- Existing Guard, Momentum, Venom and Shelter passives are earned Memories. Their old default maximum-HP penalties are removed; maximum HP comes from the equipped Soul.
- A new class supplies Body, Soul, Weapon and legal starter dice. It supplies no starting Memory. With Beginning Soul, both classes have 6 HP. Movement distances use printed ability values, not old Body bonuses.
- Soulcaster's starter dice must remain legal with two Attack sides and four Blanks per die. A Stride side instead of its old Step side lets a Spear caster reach Jab's Move-2 requirement without a hidden Fleet Body movement bonus.

## Implementation requirements

1. Share one equipment rules definition between normal mode and Trials; preserve their separate inventories and currency.
2. Calculate HP/Blank requirements from each hero's equipped, owned Soul. Validate Body Defense/Movement/Skill ranges and Weapon-only Attack bounds together before applying an equipment change or dice refit.
3. Track bound Soul copies per hero in both modes. A globally unlocked recipe/design is not a tradable Soul copy.
4. Project each equipped Weapon's provided attacks onto actual selected Strike sides; expose the physical sides in build and dice previews. Support 1–3 replacements and attack-wide modifiers.
5. Start Memories empty and make later equip/acquisition explicit. Move pure Blank conversion effects into Memory records. Keep Soulcaster's explicitly printed Soulcasting effect on Soulcaster.
6. Preserve existing owned items and safe checkpoints through an explicit save migration. Explain required build repairs; do not silently delete earned faces or rewards.
7. Update equipment descriptions, class examples, rewards, current rules/PDF and tests to use the corrected roles consistently. Keep v0.39 direct combat controls, fullscreen and licensed non-AI enemy art.
