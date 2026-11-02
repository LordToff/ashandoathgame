# Essence harvesting and Camp Forge

Based on the supplied [Essence Harvesting & Prototype Enemies v1](design/Essence-Harvesting-and-Prototype-Enemies-v1.pdf). Its fixed reward effects and prices are implemented. Its candidate services, unique-boss opportunities and Hunt scheduling are deliberately not invented.

## Harvest and discovery

Each eligible **individual enemy death** puts exactly one token of that enemy's own Essence type on its defeated card. Multiple copies and repeat encounters each yield tokens. Friendly summons yield none. Cards are available through Menu → Enemy cards → harvesting, and from the outcome screen; no token is placed on a grid cell.

Victory banks all this encounter's tokens in the shared collection; defeat or interruption banks none. Banked Essence is never deducted by damage, enemies, curses or events. Only voluntary crafting spends it. Settlements are idempotent across redraw/reload. Conditional checks use actual state at death, before death cleanup: an earlier qualifying state does not count. The engine supports regular, zero-Block, Poisoned and Rooted conditions; only regular harvesting is assigned to the three new creatures. Boss requirements/eligibility/reward lists are hidden until first individual defeat, which permanently reveals them even if the party later loses. Normal creature conditions and current eligibility are public.

Existing bosses and legacy ordinary enemies currently have a **provisional regular-harvest mapping**, because their bespoke conditions and Essence recipes were not supplied. Their Essence can be banked safely; no fictional boss-crafting prices or unique-boss opportunities are assigned. The tutorial Hollow still directly grants its Soul to every hero on victory. Other boss-specific Soul rewards are not invented.

## Fixed recipes

The exact design name/effect remains hidden in the Forge until first crafting; before then, the category/trait and cost are public. The rulebook deliberately remains a full designer reference.

| Essence | Reward | Category | Cost |
| --- | --- | --- | --- |
| Bone Creature | Bone Growth | Skill / Bone | 1 |
| Bone Creature | Bone Strike | Attack / Bone | 2 |
| Bone Creature | Bone Guard | Defense / Bone | 3 |
| Support Creature | Shared Remedy | Skill / Healing | 1 |
| Support Creature | Sorrow's Offering | Skill | 2 |
| Support Creature | Shared Burden | Skill / Copy | 3 |
| Support Creature | Memory of Loss | Memory | 4 |
| Movement Creature | Retreat | Movement | 1 |
| Movement Creature | Momentum Strike | Attack | 2 |
| Movement Creature | Evasive Counter | Defense / Reaction | 3 |

First face crafting unlocks the design, reveals the effect and grants copy one. Every further copy costs the same Essence amount, including immediately in the same Camp visit. There is no owned-copy cap or mutually exclusive recipe choice. Faces stay owned when unequipped. There is no dismantling/refund. Memory of Loss is a one-time permanent unlock, with one shared physical Memory that may be transferred during refitting. Weapons/Bodies/other permanent rewards have no supplied recipes or effects here and are not manufactured as extra content.

Camp → choose a crafted face → choose hero → choose die square. The normal two-Blanks-per-die and body/category limits remain, as do the original two selected bonus designs. The party cannot equip more physical copies than it owns across all three heroes. A replaced crafted face remains in the collection. Saved build presets validate crafted ownership and total party allocation on load. Repositioning owned faces in the existing forge remains supported.

Souls are tracked per recipient and cannot be traded. A hero can own multiple Souls and cycle their equipped Soul at Camp. Both currently available Souls retain the existing Blank → Move 2 effect, limited to one rolled Blank per own turn; equipping one never enables it for another hero. The existing Fragment event now binds its unlock to the chosen hero. Previously unlocked legacy Fragment Souls are preserved for all previously entitled heroes when migrating the old save. The optional manual Blank-movement test rule remains in rules/options and is distinct from earned equipment.

## Reward effects and playtest clarifications

- Bone Growth: gain 1 Block and optionally Move 1. Bone Strike/Guard count that hero's Bone results rolled for the current turn, including results already spent. The three new faces and the existing generated Bone have the Bone trait. Actual rerolls that produce Bone add another result; copy/rotate effects do not add a fictitious roll. Bone Strike/Guard count themselves when actually rolled. Bone Guard uses the normal immediate Defense modifiers.
- Shared Remedy: first heal self 1. Only actual restored HP opens the ally-heal choice, within range 2 (3 with Memory). A full-health self-heal grants no ally heal. The ally can be Downed if normal healing permits revival.
- Sorrow's Offering: decline spends the face without HP cost or benefit. Otherwise pay 1 unavoidable HP, possibly Downing/killing the owner, then grant a standing ally within 2 either 2 Block or +1 next-Attack damage. Multiple paid offerings add their next-Attack bonuses; the next Attack consumes them once, before normal modifiers, Weakness, mitigation and absolute-zero rules.
- Shared Burden: select another die's actual rolled result from this round's history, including already resolved results. A standing ally within 2 spends one ready die (or a held, unspent Reaction) to resolve the copy **immediately in a single-action interrupt**, even if they already took their normal slot. No full turn, activation-start effects, Poison tick, Block expiry, initiative change or shared roll is granted. Usual copied text, targeting and costs apply; Focus may consume its normal target die as well. Reactions are held normally. Shared Burden itself cannot be copied, and indirect copy loops are blocked. Finish/decline the result, then click Return to the original hero. Installed faces are unchanged by the copy process; explicit mutations in copied text follow their own normal rules. The interrupt has a fresh movement scope and restores the recipient's prior normal-turn counter afterwards. It uses the recipient's current rolled Bone history. This timing is a prototype clarification, not a finalized master-rule claim.
- Memory of Loss: the implemented Healing keyword covers the existing healing faces and Shared Remedy. Eligible ranged heals gain +1 range; Self and Adjacent heals do not. Only the first actual self-heal per combat gains +1 HP, capped at maximum. An ally healing the Memory owner does not spend that bonus. Supplies are not Healing abilities.
- Retreat: up to 2 legal orthogonal spaces, then 1 Block only if farther from **every living enemy** than at the start.
- Momentum Strike: after 2 moved spaces this own turn, deal 1 adjacent-enemy damage; after 3+, use Numeric +1. Movement counts the actual legal path of voluntary actions during the hero's turn; outside-turn forced movement does not carry into it. Leaps/swaps use their displacement if no walking path describes them. Normal attack modifiers and absolute Numeric zero remain.
- Evasive Counter: +1 Block before the Attack. If the complete Attack and its riders remove no HP, offer Move 1 afterwards. Block absorption qualifies. Rooted still prevents moving. Multiple successful copies each offer a step. Forced-push/collision HP damage denies the step. This also works on non-boss monsters; pending movement resolves before the next creature acts.

## Provisional encounters, not reward-face AI

The PDF intentionally leaves enemy stats/dice and composition unfinished. The prototype uses:

- Event 4: two Bone Creatures, 3 HP each, Scuttle 2 / Bite 1 / Guard 1 dice. Victory also keeps the existing 3 Gold + 1 Salve reward.
- Event 5: one Support Creature, 2 HP, and two Movement Creatures, 3 HP each. Support can Mend itself/a living ally within 2 for 1; Movement Scuttle moves 3. Bite is 1 normal damage in reach 1; Guard grants 1 Block. Victory keeps the existing 5 Gold + 1 Fragment + 1 Reroll Seal, plus the individual Essence tokens.
- Each creature rolls its own three public six-sided dice. The group resolves each numbered die in card order, with Reactions and Evasive movement pausing it. The enemy-card window prints every die's six sides and the current results. No boss phases or enemy summons are added.

These are visible provisional AI choices, not claims that Bone Growth or Shared Burden were prescribed as enemy actions. Original geometric pixel sprites are generated by `tools/make_essence_art.py`. Names remain working labels; difficulty and duplicate/Bone scaling require playtesting.

Cleansing, Reforging, Restoration, Transmutation and Empowerment are shown only as unavailable candidates. No illustrative service price is charged and no effect/milestone is invented. Hunt frequency/persistence and unique-boss Essence opportunities remain undefined. The implementation does not add a separate spendable Bone currency, settlement or campaign.

The Essence ledger, unlocks, copies, memories and bound Souls save locally alongside existing rewards. Clearing browser storage removes that local data; Git does not back up player saves. Active combat is still not checkpointed. Previously banked Essence/owned rewards survive restarting a run, defeat and refitting. Windows downloads are unchanged.
