# Ash & Oath — mechanics contract for a complete remake

Snapshot: implemented v0.46, 16 November 2026. Source commit: be9f5c2675a45d989976334c7f20c7e186d4a5ca.

## Purpose and authority

This kit transfers the game design and implemented behavior so a new chat can remake the whole game. The new implementation can use a different engine, interface, HUD, art, palette, animation and layout. None of the previous visual directions is a requirement. This is a mechanics specification, not instructions for replacing parts of the existing interface.

Preserve the mechanics below unless the user explicitly changes them. The source model and the exported rule data are the precise reference for edge cases and numbers. The current rulebook supplies plain-language explanations. Historical design documents and old patch notes are not additional active rules. Many balance values are provisional prototype decisions, not immutable tabletop canon.

The kit covers BOTH normal play and Trials, all four implemented bosses, all 85 face identities, normal and Trial progression, crafting and optional rules. Trials are a separate experimental mode, not a replacement for the normal game.

## The four equipment layers — current decisions

- Body: only minimum/maximum Defense, Movement and Skill faces, counted across a hero's three dice. Body does not set Attack limits, maximum HP, minimum Blanks or movement distance.
- Soul: maximum HP, minimum Blanks on EACH die, and a strong printed effect. Souls belong to individual heroes; ownership must not become a party-wide unlock.
- Memory: one passive modifier slot. The first encounter starts EMPTY. Many Memories offer another use for a rolled Blank. Memories do not inherently change maximum HP. There are no extra passive/path/edge slots.
- Weapon: minimum/maximum total Attack faces; 1–3 designated basic Strike sides become weapon-specific rolled attacks; some weapons modify ALL Attack faces. Preserve the remaining basic Strikes and physical side/copy ownership. These replacements must roll and spend a die when used.

Beginning Soul is 6 HP, minimum 2 Blanks per die, and Last Ember: once per encounter, lethal enemy damage leaves the hero at 1 HP. It does NOT inherently provide Blank movement. Memory of the First Step spends one rolled Blank as Move 1 once per own turn. The optional global Blank → Move 1 rule is a separate setting.

Dagger's Poke is a ROLLED attack face, not a free extra action. It deals 1 damage to an adjacent enemy only after that hero already caused actual enemy HP damage during this own turn, once per own turn. It spends its die. Blocked hits, ally damage, another hero's damage and attacks on objective objects do not satisfy its requirement.

Spear replaces one Strike with Jab: after moving at least 2 spaces this own turn, deal 1 damage to an enemy within 2, once per own turn, spending that rolled die. Hammer replaces one Strike with Crack: after another Attack this own turn, remove up to 2 adjacent enemy Block, dealing no HP damage, once per own turn, spending that rolled die. Oathblade replaces three Strikes with Oath Cut and grants ALL that hero's Attack faces Pierce 1.

## Core battle structure

Three individually built heroes, currently named Vesper, Rook and Wren, fight on a 9×9 grid. Each has three six-sided Action Dice, HP, Block, statuses, a reroll bank and their own equipment. The main boss occupies a 2×2 footprint; ordinary creatures and Trial objective objects use their model-defined one-cell footprints. Art size is never a hitbox.

Initiative is rolled once and stays in a fixed order. All available Action Dice roll together at shared round start. A hero's individual turn does not automatically roll three fresh dice. The hero resolves available results in any order, subject to mandatory pending choices and forced-result rules. Immediate recovery is an explicit exception with fresh dice.

An Attack/targeted effect chooses an ability and a legal target; movement chooses a legal destination; self Defense/effects resolve on use. Invalid actions spend nothing. Reactions and effect-specific choices remain mandatory where the rules require them. Preserve direct action semantics; ordinary attacks do not need an additional generic confirm operation.

The encounter ends when the required boss/objective is defeated, or the party has no hero alive above zero HP. Trial ritual/spirit objectives have their own victory conditions. Nu'gh's defeat also clears his remaining hostile worms. Multiple hits resolve separately, with range, death, sight, riders and reactions rechecked at their actual points in the sequence.

## Rerolls, Blanks and optional rules

Default: one starting banked Action Reroll per hero, bank cap 1, no automatic refill. A paid reroll costs a charge and can land on the same face. It does not automatically use its new result. Focus instead spends its own rolled ability and forces the eligible rerolled result next, or stores it if it is a Reaction. Spent dice, Channels and printed non-rerollable faces remain restricted.

Action Rerolls default to any time during the active hero's own turn. An optional Opening only setting closes that window after an ordinary action resolves/declines. Timing and refill are separate options.

Optional '1 reroll each turn' is OFF by default. When ON, each normal own turn or full immediate recovery turn refills that hero to at least 1 charge, up to the bank cap. Unused refills do not stack; earned extra charges remain. Shared rolls, Focus, rerolls, Shared Burden interrupts and redraws do not refill it. Switching ON applies from the next own turn and never gives an immediate charge. Keep these safeguards in a remake.

A rolled Blank normally does nothing unless an equipped Memory, Soulcaster or explicit setting provides a use. Optional Blank → Move 1 is OFF by default and spends a rolled Blank once per hero own turn. It does not install a movement face or give a free action. Toggling never refills the allowance. Rooted prevents voluntary movement. Soulcaster retains Gather/Manifest and gains a distinct Move 1 choice if the override is enabled.

## Status and timing invariants

Poison STACKS: Poison 1 plus Poison 1 becomes Poison 2. At that unit's own activation it deals its current value as unavoidable HP loss, then decreases by 1. It bypasses ordinary Block/reduction. Killing a unit or invalidating an action during a sequence must stop later ineligible operations.

Temporary Block normally expires at that unit's next turn start; printed effects such as Stonewake/Warden Soul can retain it. Stunned, Rooted, Weakness, Channels, reactions, temporary buffs, delayed penalties and limited per-turn effects use their printed reset points. They must not silently reset on redraw, reroll, a shared roll or someone else's action.

Zero HP is Downed unless Broken makes it death. Downed protection, healing into a Broken immediate recovery turn, the replaced normal initiative slot, later lethal damage and complete-party defeat must follow the detailed timing rules. A recovery turn is a full own turn; Shared Burden is only one borrowed action.

Borrow Shape chooses from CURRENT face-up hero die results, including eligible spent/held results, with its printed exclusions. It cannot inspect/select hidden unrolled installed sides. Installed-side effects, such as choosing a Blank for Engrave or spell creation, are separate operations. Engrave changes another eligible installed Blank when its trigger qualifies; it does not rewrite an already recorded roll. Physical side identity matters.

## Enemy intent and randomness

Every enemy ability has a target policy: self, area, ally support, marked cells, or ranked heroes. Policies include highest/lowest HP, most Block, furthest/closest, buffs, debuffs and prior-round damage as appropriate. Prefer a legal top-priority target, otherwise the closest legal fallback. Ties use a stable round-derived seed. Intent inspection and forecasts never consume combat RNG or reveal a hidden future result.

Numeric dice, optional balance profiles, Weakness, Pierce, Block, damage reduction, repeated hits, poison riders, healing and friendly-fire restrictions must use the actual formulas. Read the full face/boss entries and reference model for conditional ordering. Never replace the complete rules with a few generic attack/block skills.

## Normal progression and Trials remain distinct

Normal play includes party construction, a required pre-boss Ash Road event flow, boss selection, direct creature encounters and a persistent Camp. Direct creature battles do not substitute for the required pre-boss event. Normal crafting pays matching enemy Essence, validates ownership and physical copies, and binds Souls to individual heroes. Bosses yield 3 matching Essence; ordinary creatures normally yield 1 each when a complete encounter is won. Defeat/abandoning does not bank that fight's provisional kills.

Gold, Salves, Reroll Seals and Soul Fragments are distinct. Salve heals up to 2 HP in normal combat, once per hero own turn. A Seal restores 1 Action Reroll up to cap. Three Soul Fragments can unlock/bind the Ash Road Soul to a chosen hero under the current unlock condition. They are not generic crafting Essence. Exact event choices, checks and rewards are in the progression reference model.

Trials have exactly two starter classes, Skirmisher and Vanguard. Classes supply legal starting gear/dice and reward offers; effects still come from Body, Soul, Memory and Weapon. BOTH start with Memory empty. Soulcaster is a free alternate Trial starter Soul. Class choice is not an extra permanent modifier layer.

A Trial follows five route stops before its chosen existing boss, with combat, elite groups, ritual/spirit objectives, events, cache and Camp choices. HP carries; temporary encounter effects reset as specified. Run Essence buys run rewards; permanent Trial Forge ingredients/unlocks form a separate collection. Neither may spend or grant normal Camp resources. Safe route/reward checkpoints resume; leaving/reloading during combat fails that Trial. The first Memory can be earned after the first fight.

## Soulcaster

Soulcaster sets 6 HP and a minimum of 4 Blanks per die. Gather spends a rolled Blank for +1 Soul Charge, cap 3. Manifest spends a rolled Blank, the spell's charges and 1 HP to create a temporary encounter spell on that physical side; at most 4 spells may exist. A new spell cannot activate during its creation turn, including after a mid-turn reroll. It must roll on a later turn. Spells disappear after the encounter.

Hoarded Omen keeps the ORIGINAL die aside; it does not add a fourth ability alongside three new dice. Fatebreaker gains a capped Action Reroll and rerolls an eligible unresolved enemy die, once per enemy die per shared round. Mirror resolves reflection after the full Attack/rider/reaction sequence. Wraith, Harvester and Grave Stitch retain their range, charge, damage, movement and healing conditions. All six spell entries are included.

## Practice, storage and information

Test chamber is isolated practice: ability choices/forced Numeric values/reset/combination tests never consume real inventory or grant rewards. The current normal/earned chamber catalog has 73 entries; the complete game catalog additionally includes six projected weapon faces and six Soulcaster spell identities.

Choices can be inspected without payment. Crafting, equipping and reward purchases commit only after validation; rejected/invalid actions do not charge or partially mutate state. Keep owned but unequipped copies and per-hero bound Souls intact.

The player must be able to learn each ability, inspect enemy intent and targets, identify HP/Block/statuses and ready/spent/held/forced results, understand costs/rewards, and review a summary or complete causal battle log. This specifies information, not a HUD arrangement, color scheme, icon set or art style.

Presentation is separate from simulation. Animation, sound, accessibility and visual effects can be remade completely; they must not reroll RNG, apply damage/healing/rewards twice or let a presentation skip bypass a required rules choice. The old animation and pause setting defaults ON; disabling it changes presentation only.

This snapshot contains no personal saves or credentials. Existing browser/device save behavior is not a cloud account. A new implementation needs its own considered storage/migration policy.



# Detailed implemented rules

The following chapters retain the current numeric/timing explanations; presentation-only chapters are omitted. Full face definitions follow in the catalog.


## Enemy targeting and face-up choices

### Targeting priorities

Enemy intents lists each living enemy and each currently rolled ability, its current named target, priority, range and effect. Smoking Strike, Gnashing Maw and ordinary Bite prefer lowest HP. Driving Blow and Advance prefer highest HP. Shield Bash, Driving Back and Iron Husk Bash prefer most Block. Ashen Chain and Tuning Fork focus the furthest hero. Distort, Fracture and Hushed Chime prefer heroes with the most active buffs. Venom Bite prefers heroes with the most active debuffs. Cinder Brand and Needle prefer the hero who dealt the most actual enemy HP damage in the previous round, including credited friendly summon/Poison damage. Skirmish, Scuttle and worm pursuit prefer closest. Self, area, allied healing, summons and marked tile effects state their actual target type.

### Range, ties and live forecasts

Prefer a top-ranked hero who is currently legal. If none of the preferred heroes can be targeted, use the closest legal target. Random ties use a seed created by the shared round roll, so opening or redrawing the panel never consumes randomness or changes a tie. Forecasts update when HP, positions, statuses or eligibility change. Movement abilities show their pursuit focus; attacks recheck legal range after moving. Reactions can force a new legal target. No legal target retains each ability’s existing fallback or hold behavior. Area attacks hit everyone specified, not one preferred hero.

### Support healing

Mend restores 1 HP to the living ally with the most missing HP in reach 2. Equal injuries use the same stable round-seeded tie system. No wounded ally means no healing.

### Feedback and Engrave

Actual Poison HP loss, positive healing and new Stun have distinct effects and SFX, controlled by SFX volume and mute. Poison ticks reduce HP and stacks immediately, play a distinct sound and briefly tint the unit; no damage text or acknowledgement window appears. Every living poisoned unit carries persistent green smoke until Poison clears. Healing and Stun retain their own cues. Engrave displays the updated six installed sides after growth and explains a failed trigger. It still requires actual HP damage, fills a Blank on the same die, obeys growth/copy caps and lasts only for this encounter. A recorded Blank does not retroactively become Engrave; the new side can be rolled later.

### Essence planning

Read exact recipe names and effects before spending. The Forge shows banked Essence, price and missing amount. Face copies are physical shared party copies: owned minus equipped equals free. Crafting adds ownership; Refit equips it. Bound Souls belong to their selected hero; Memory of Loss remains one shared item. Prices, bank contents, recipe effects and old owned inventory are unchanged.


## Dice construction and ownership

### Body

Sets only minimum and maximum Defense, Movement and Skill faces across all three dice. Bodies never set Attack limits, HP, minimum Blanks or movement distance.

### Soul

Sets maximum HP, minimum Blanks on each die and its printed strong effect. Each Soul copy belongs to one hero. Beginning Soul has 6 HP / 2 Blanks per die; earned Souls require 3; Soulcaster has 6 HP / 4 Blanks. Body and Memory do not impose HP penalties.

### Memory

One passive modifier slot. The first encounter starts empty. Memories can grant alternate uses for rolled Blanks. Memory of the First Step spends one rolled Blank as Move 1, once per own turn. It is not a free move and leaves the installed side Blank.

### Weapon

Every Weapon states minimum and maximum total Attack faces, an exact count of 1–3 basic Strikes to replace with its corresponding attacks, and an optional passive modifying all of that hero’s Attack faces. Replacements occupy physical sides, still count as Attacks and must roll before use. Other Strike sides remain ordinary. Weapon passives affect other equipped Attack faces too; they do not affect non-Attack damage unless printed.

### Broken Body

Defense 0–3 · Movement 0–3 · Skill 0–3 across all three dice. Attack limits come from your Weapon.

### Fleet Body

Defense 0–2 · Movement 0–4 · Skill 0–3 across all three dice. Movement uses its printed distance. Attack limits come from your Weapon.

### Stone Body

Defense 0–4 · Movement 0–2 · Skill 0–3 across all three dice. Attack limits come from your Weapon.

### Physical dice and copies

Three dice, six sides each. Each die must retain the minimum Blanks printed on its Soul. Count Body categories and Weapon Attacks across all three dice combined. Keep enough basic Strike sides for every printed replacement. Owned starting copies, two bonus designs and crafted shared-copy limits still apply. Encounter mutations may exceed opening construction constraints until that encounter ends.

### Starting copies

Strike ×4; Step ×2; Stride ×1; Guard ×2; Reaction ×1; Focus ×1; First Aid ×1; Shove ×1. Each selected bonus design adds one owned copy. Weapon faces are projections from owned Strike sides, not extra owned face designs.


## Round and turn sequence

### A. Set initiative once

At encounter start, each hero and the boss rolls initiative from 1 to 6. Higher goes first. The boss wins an initiative tie with a hero; hero ties use Vesper, then Rook, then Wren. This order stays fixed, except a temporary Break Rhythm delay that resets next round.

### B. Begin the shared round

Clear the previous round’s stored Reactions and Mark Prey. If a hero is still Stunned, choose a die to set aside before rolling; an actively Channeling die cannot be chosen. Roll each available Action Die once for all heroes and the boss. Held Channel dice do not roll. Reaction results automatically become held Reactions. When-rolled effects such as Clairvoyance trigger now.

### C. Start a hero turn

Optional turn refill applies to a living hero at own turn start. Then Poison triggers if present: lose its value as unavoidable HP damage and reduce Poison by 1. If this Downs the hero, skip their normal turn. Expired temporary defenses clear, and ordinary old Block disappears. Stonewake is the exception that can preserve Block. Resolve an unused Echo of Pain penalty if due. Debt’s deferred penalty becomes active; the hero’s Lethargic Bind expires. Refresh that hero’s Blank-conversion allowance and Engrave growth allowance. If a Channel is active, choose Maintain or End before normal actions.

### D. Reroll when desired

By default a banked Action Reroll is allowed at any point during the active hero’s turn on a ready die or held Reaction. Options → Action Rerolls switches to Opening only for comparison. It costs 1 charge. You keep the new result, even if it is another Blank or the same face. A reroll does not itself close the opening window. In Opening only mode, resolving or declining an ordinary face closes it. Spent dice and Channels cannot be refreshed; pending choices and forced results must finish first. Focus is a separate ability, explained in section 4.

### E. Resolve hero dice

Use ready immediate results in any order. Select a die, then click a legal board target or destination; use Resolve for untargeted effects. A legal resolution spends that die. Invalid targets spend nothing. Finish any pending choice or forced result before taking another ordinary action. You may end the turn with immediate dice unused; stored Reactions can still respond afterward, until the next shared roll.

### F. End a hero turn

Clear the hero’s Stunned state and unused turn-only boosts. If Black Oath is armed, pay its 1 unavoidable HP cost only if Block remains. Downed protection for all heroes ends when this full turn ends. Then the owner’s living friendly Nu’gh activates: resolve its Poison, move up to two orthogonal steps toward enemies and bite the closest enemy within one. This is additional to any Command activation. Process queued recovery turns, then continue the initiative order.

### G. Take the boss turn

At boss turn start, The Hollow expires Chain’s Rooted and Distort and detonates armed Cinder Brand cells; then old boss Block clears. Every boss first resolves its Poison as unavoidable HP loss and reduces it by 1. Nu’gh and Bu’gh clear old boss Block but have no Cinder Brand. Bu’gh restores Bulwark at its turn start, resolves any marked sweep before its three dice, and arms a sweep at turn end if none is already marked. Veyl closes any exposed core at boss turn start, then clears old Block; Resonance persists until changed by a face or spent by an attack. Resolve boss dice I → II → III. A Nu’gh Brood Command must finish all queued worms, including their Reactions, before the next boss die. Click Resolve end of turn after all three. Boss Weakness from Wither Ward expires at boss turn end. LAST ENEMY RESULT below the controls keeps fallback outcomes visible, including movement cells and Block gained.

### H. Start the next round

After the last initiative slot and any recovery turns, return to the round-start sequence. Unspent immediate results are replaced by the new shared roll. With turn refill OFF (the default), charges do not automatically refill. With Settings → 1 reroll each turn ON, each hero refills to at least 1 charge at their own turn start, up to the bank cap; unused charges do not stack. Earned extra charges are preserved.


## Timing: actions, rerolls, Reactions and Channels

### Ordinary actions

Attack, Defense, Skill and Movement results usually resolve during their owner’s turn. They are spent once resolved or declined. A grey card may be spent, held as a Reaction, or held as a Channel: inspect its state label. Clicking a grey card still lets you read it.

### Optional turn refill

Settings → 1 reroll each turn is OFF by default and saves on this device for normal play and Trials. When ON, each normal own turn and full immediate recovery turn refills that hero’s bank to at least 1 charge, up to its normal cap. Unused refills do not stack and earned extra charges are retained. Downed/dead turns, shared rolls, rerolls, Focus, UI rebuilds and Shared Burden interrupts never grant another refill. Switching ON applies at the next own turn and never grants an immediate charge. Timing is a separate option: Any time or Opening only.

### Banked Action Reroll versus Focus

A banked reroll uses a saved charge and defaults to any time during your own turn; Options can restrict it to the opening window. Focus spends its own rolled face to reroll another ready die or held Reaction, and can work after other actions. Its new result must resolve next or be declined. A Reaction result is stored instead. Neither method can reroll spent/channelled dice, a locked Red Tile, Gambler’s Coin, Conjure or Passing Grace. Focus cannot target itself. A displayed saved charge can exist while the opening window is CLOSED.

### When-rolled effects

Clairvoyance adds a charge as soon as rolled, up to the cap; it does not wait for the hero to click Resolve. Echo of Pain arms its unused-result penalty when rolled. Contained Power can respond to other dice rolling while maintained. Repeatedly rerolling a Blank is legal; a new Blank is not evidence of a failed reroll.

### Reaction window

A held Reaction is checked before an enemy Attack applies damage, including a commanded Worm Bite. The interface pauses when its trigger is legal. Use spends it; Hold declines this opportunity while keeping the result for another eligible attack before the next shared roll. The starter Reaction grants 2 Block before the hit and never moves you. Oath of Smoke can explicitly store a Step / Stride as a movement Reaction; its stored Guard does not grant a step. Shield Wall protects an ally, Taunt and Target Override can redirect, Defy Death prevents a lethal hit, and Echo of Pain retaliates. Reactions do not normally respond to self-costs, collision damage or Brand hazards.

### After a Reaction changes position or target

A single-target Attack rechecks range and may retarget to another legal hero. Moving one hero away does not necessarily cancel the boss’s attack. Sweep, Furnace Roar and Veyl’s Toll check whether their selected victims remain in range and hit each once. Taunt and Target Override cannot redirect an entire area attack. Forced movement and a reaction step still obey their own movement restrictions.

### Channel start and maintenance

Only one Channel may be active per hero. Starting one holds its die; it does not become a normal ready result on shared rolls. At the next own turn, Maintain applies its maintained effect and keeps the die held. End releases the Channel and rolls that die immediately, including its when-rolled/Reaction handling. Starting another Channel cannot silently replace the first.

### Channel interruption

Contained Power breaks on actual HP loss, adds 2 normal backlash damage and leaves a Red Tile on its source side. Last Pulse breaks on actual HP loss and turns its source side Blank. Stonewake breaks on any HP loss or 2 cumulative Block lost within the window before the next own turn. Removing Block via a non-damage effect counts too. Block absorbing all damage does not break the first two Channels. Lethal HP loss still applies the relevant source-side mutation.

### Forced choices

Focus, Borrow Shape, copied/repeated effects and mutation picks can require a particular result or selection next. The interface pauses until that choice is complete. A failed or illegal choice does not grant a free alternate action. Choosing an ability’s target and inspecting that ability are separate from spending it.


## Movement, targeting and damage

### Grid distance and adjacency

Normal distance counts orthogonal grid steps, not diagonals. Adjacent means distance 1. Distance to the 2×2 boss uses the nearest square of its footprint. Units block occupied cells. A dead worm frees its cell; a Downed but living hero still occupies theirs.

### Movement types

Step and Ashstep may turn along a clear path. Stride is a straight line and cannot turn. Leap of Echoes may jump over units but must land on an empty legal cell. Shove pushes away without collision damage. Drive Back pushes automatically along its incoming direction; players do not choose the direction. Rooted blocks voluntary moves and swaps, but not forced pushes/pulls.

### Line of sight and targets

Abilities that require sight use a straight grid ray; units can obstruct it, including worms, and blocked diagonal corners prevent shooting through. Do not assume every ability needs sight: follow its text. Several Attacks may target allies; the interface asks for confirmation. Hero healing cannot target bosses or worms. Dead heroes cannot be healed.

### Numeric die: what it means

The default ordinary Numeric die has faces 2, 2, 1, 1, 1, 0. “Roll for damage”, “rolled Block” and “heal a rolled value” mean roll this die when resolving that effect. An Action Die chooses the ability; the Numeric die determines its value. Strike deals a fixed 1 and does not roll Numeric. Strike Numeric rolls it. There is no extra default +1 bonus just for being a Numeric Attack.

### Damage order

Compute the attack’s value and relevant modifiers, then apply Weakness (minimum zero). Normal damage consumes Block first, then the remaining amount is reduced by Damage Reduction, and only the remainder removes HP. Unavoidable damage skips Block and ordinary Damage Reduction. Effects requiring HP damage only trigger if HP actually decreases. Pierce bypasses the stated amount of Block for that hit; the bypassed Block is preserved.

### Repeated Attacks

A repeat is another hit, not just doubled damage. Each hit rechecks target legality, range and any required sight; Numeric repeats roll again. A dead target stops later hits. Conditional riders such as Hooked Slash and Engrave check qualifying HP damage. Short Shot’s final per-hit cap is 2, including Mark Prey. A consumed mark or limited charge does not remain for every repeat.

### Gambler and Numeric modifiers

Gambler replaces the final two ordinary Numeric sides with ×0 and ×2. ×2 rolls an ordinary Numeric value and doubles it. ×0 is an absolute zero: boosts do not rescue it. Numeric Echo stores one ordinary value for the next Numeric roll. Focus Numeric changes the next Numeric Blank to 1. Forgotten Strength and Leap bonuses apply to the next rolled damage this turn, not fixed Strike damage.

### Fire is not one universal effect

Any positive Smoking Strike ignites its target cell, even if Block or Damage Reduction prevents HP loss. A later positive Smoking Strike on that cell consumes the fire for 2 extra normal damage (3 in phase II). Ending a hero turn on persistent fire deals 1 normal damage. Moving through fire does not detonate it; moving off before turn end avoids its burn. Zero damage after Weakness does not ignite or detonate. Cinder Brand is a separate delayed marked area that detonates at the next boss turn. Ember Burst is an immediate chosen Block-burn effect that can hurt allies and worms.


## Status, Downed heroes and recovery

### Block and Damage Reduction

Block is a consumable pool, not extra maximum HP. Old Block normally clears at the owner’s next turn start. Damage Reduction removes damage after Block and clears at the hero’s next turn start. Stonewake can preserve Block while maintained. Brood Guard’s worm shield persists until consumed; repeated shielding does not stack above its stated amount.

### Weakness

Weakness reduces Attack damage, to a minimum of zero. Distort lasts until the next boss turn start; Bulwark’s self-Weakness lasts until the hero’s next turn. When both apply, use the greater reduction, not their sum. Wither Ward gives the boss Weakness after an adjacent boss Attack actually removes HP; it lasts until the boss turn ends.

### Rooted

No voluntary movement while active, including reaction steps and Oathbound Exchange. Forced movement remains legal. Upgraded Ashen Chain applies Rooted 1 until the next boss turn begins. The sprite has a persistent root effect.

### Stunned

On application, choose an unused die to lose if one exists. If no unused die remains, the status stays visible; if still Stunned before the next shared roll, choose a non-Channel die to set aside for that roll. Gaining Stunned while already Stunned causes 1 unavoidable damage instead of granting another die choice. Stunned clears at the hero’s turn end. Orbiting stars show the current status.

### Weak Point, Mark Prey and Blood Bargain

Weak Point is personal: the next qualifying rear Attack repeats once, and the marker lasts through the end of the next round unless spent. Rear means the boss’s southern edge. Mark Prey is a boss mark, ending at the next shared round or after its next damaging hit while at zero Block. Blood Bargain empowers the next two Attacks against the boss and charges its owner 1 unavoidable damage after the second.

### Downed at zero HP

The first time a hero reaches zero HP without already being Broken, they become Downed. Their Block, Reactions, Channel and temporary effects are cleared; their reroll bank becomes zero. They cannot take normal actions. Protection prevents death from further damage for the remainder of the current full turn. After that protection ends, further positive HP damage can kill them. If everyone is Downed/dead together, defeat happens immediately.

### Healing a Downed hero

Positive healing revives them and marks them Broken. At the end of the currently active full turn, the revived hero receives a fresh, immediate recovery turn with rerolled Action Dice. Their later normal slot in that round is replaced rather than added as a second turn. Their Blank-conversion allowance refreshes for recovery, and the optional turn-refill setting also applies. With that option OFF, a starting reroll is not automatically restored.

### Broken and dead

Broken means the next fall to zero HP is lethal. Dead heroes cannot act or revive during the encounter. Physical die mutations remain through Downing/revival, while temporary combat statuses do not. Retry starts a clean encounter using the saved starting build and selected rules.

### The Hollow’s Original dice

Die 1: Advance, Advance, Smoking Strike, Smoking Strike, Brace, Drive Back | Die 2: Advance, Skirmish, Smoking Strike, Sweep, Brace, Distort | Die 3: Advance, Skirmish, Smoking Strike, Sweep, Drive Back, Fracture


## Blank conversions and custom rules

### Memories use a rolled Blank

Memory of the First Step: Move 1. Memory of Wind: Move 2. Hearth / Mire Memory: self-heal 1. Glasswing Memory: blink 2. Ironbound Memory: gain 2 Block. Each is once per own turn and spends the rolled Blank. Invalid attempts spend nothing; rerolls and shared rolls do not refill the allowance. Downed heroes cannot self-revive through a Blank conversion. Rooted blocks voluntary movement.

### Soulcaster

Its printed Soul effect replaces ordinary Blank conversion with Gather / Manifest. It has its own charge and spell limits, detailed in the spell chapter.

### Settings: Blank → Move 1

OFF by default. Enable in normal or Trial Settings to spend one rolled Blank for Move 1, once per hero own turn, independently of equipped Memory. Rooted still prevents voluntary movement. Turning OFF restores the equipped conversion; OFF / ON never refills a used allowance. Soulcaster keeps Gather / Manifest and adds Move 1 as a separate choice. The preference is saved on this device. Legacy laboratory overrides remain available separately.


## The Ash Road: events and earned rewards

### Six slots and one d6

All six numbered slots are visible. Roll one fair d6 to select an event; the result is locked until resolved. Read the exact cost, odds and reward before choosing. A resolved event can never grant its reward twice. New sortie explicitly starts another event; repeat sorties can earn more rewards. There is no daily limit.

### 1. Abandoned Supplies

No cost or risk. Choose exactly 1 Salve OR 1 Reroll Seal.

### 2. Ash Shrine

Leave safely for nothing, or pay 2 Gold immediately and roll d6. On 3–6 earn 1 Soul Fragment; on 1–2 lose the offering and gain nothing. An unaffordable offering is disabled.

### 3. Stranded Traveller

Take directions for 1 Gold at no cost, or spend 1 held Salve to help and earn exactly 3 Gold plus 1 Reroll Seal. No hidden injury roll.

### 4. Scavenger Ambush

Withdraw safely for nothing, or fight two ordinary one-cell Bone Creatures, 3 HP each. Defeat BOTH to receive exactly 3 Gold and 1 Salve, plus one Bone Creature Essence per harvested individual. Defeat or abandoning grants no completion reward.

### 5. Infested Ruins

Leave safely for nothing, or fight one 2-HP Support Creature and two 3-HP Movement Creatures. Defeat ALL THREE for exactly 5 Gold, 1 Soul Fragment and 1 Reroll Seal. Defeat or abandoning grants nothing.

### Ordinary monster turns

No boss, phase, fire or boss Soul. Each creature rolls its own three public Action Dice, shown on Enemy cards with all six sides and current results. Resolve numbered results in card order. Bone uses Scuttle 2 / Bite 1 / Guard 1 dice. Support adds Mend: heal one living ally within 2 by 1. Movement uses Scuttle 3. Held Reactions, hero summons and Poison work normally. Bites do not inflict Poison. Evasive steps finish before the next creature acts. AI, HP and compositions are provisional; defeat all creatures for victory and banking.

### 6. Buried Reliquary

Take exactly 1 Gold safely, or replace that reward with a risky search. Roll d6: 4–6 grants 3 Gold and 1 Soul Fragment; 1–3 loses 1 held Salve and grants nothing. If no Salve is held, failure simply grants nothing.

### What the rewards do

Gold is a shared expedition currency for Shrine offerings; there is no shop. Combat Gambler coin Gold remains encounter-local. A Salve restores up to 2 HP to the active standing hero, capped at maximum HP, at most once per own turn; it cannot revive. A Reroll Seal adds exactly 1 stored Action Reroll if below the bank cap. Supplies consume no Action Die; pending choices must finish first. They are unavailable in Lab and training. Spend them via Supplies during combat; each use is immediately deducted.

### Soul Fragments

Spend 3 Fragments to bind Ash Road Soul to one chosen hero. It has 6 HP, requires 3 Blanks per die and grants Last Ember. The fragment action binds and equips it on that hero; check their dice afterward. Blank movement is supplied by Memories.

### Persistence, fresh fights and limitations

Gold, supplies, fragments, Soul unlock and event claim state save locally on this device/browser. They are not cloud accounts and clearing browser storage removes them. Active combat is not saved: reload during a monster encounter records interruption with no reward, and spent supplies stay spent. Boss encounters and event encounters each start fresh with full HP and starting dice. Event injuries and temporary mutations do not carry over; only earned inventory persists. Rewards are granted once when the outcome screen records a victory. Closing before the outcome is recorded cannot grant a reward. Exported Windows builds are unchanged. Balance and reward quantities are provisional.


## The Hollow

### Advance

Targeting: Highest HP. Move up to 2 toward the focus hero. Already adjacent: gain 1 Block. No legal route: +1 Block. HALF-HP UPGRADE: Movement +1; adjacent Block +1.

### Ashen Chain

Targeting: Furthest hero. Reach 3 · pull up to 1 cells · strip 1 Block. No HP damage. HALF-HP UPGRADE: Also applies Rooted 1 until next boss turn.

### Smoking Strike

Targeting: Lowest HP. 1 damage · reach 1. Leave fire under the target. Existing fire detonates for 2 extra damage; ending a hero turn on fire deals 1. HALF-HP UPGRADE: Fire detonation damage +1.

### Skirmish

Targeting: Closest hero. Move up to 1, then attack for 1 in reach 1. Recheck targets after moving; if nobody is in reach, no attack. HALF-HP UPGRADE: Movement +1.

### Sweep

Targeting: All heroes in reach 1. 1 damage to EVERY hero in reach 1, including Downed heroes. Reactions apply. HALF-HP UPGRADE: Reach +1; damage +1 (each hero once).

### Brace

Targeting: Self. +1 Block to self. Expires at next boss turn. HALF-HP UPGRADE: Block +1; Die I instead becomes Furnace Roar.

### Drive Back

Targeting: Most Block. 1 damage · reach 1, then force the target away. Collision can cause damage and Stun. Reactions apply. HALF-HP UPGRADE: Push distance +1.

### Distort

Targeting: Most active buffs. Reach 2 · Weakness 1 until the next boss turn. No immediate HP damage. HALF-HP UPGRADE: Weakness +1.

### Fracture

Targeting: Most active buffs. Reach 1 · target chooses 1 installed ability side(s) to become Blank this encounter. Recorded results stay unchanged. HALF-HP UPGRADE: Reach +1; destruction count stays the same.

### Cinder Brand

Targeting: Most enemy HP damage last round. Reach 3 · mark tiles around the target. At next boss turn start, units still on marked tiles take 2 damage. Move away to evade. HALF-HP UPGRADE: New warnings become 3×3 squares; detonation damage +1. Already armed cells keep their marked area.

### Grave Tithe

Targeting: All heroes in reach 2. Reach 2 · remove 1 Block from every standing hero. Gain stolen Block up to 2. No HP damage. HALF-HP UPGRADE: Steal +1 Block per hero; gain cap +1.

### Furnace Roar

Targeting: All heroes in reach 2. 1 damage to all standing enemies in reach 2, then push survivors up to 1. Reactions apply. HALF-HP UPGRADE: Unlocks; reach +1 over its base test value.

### Boss dice, phase I

Die 1: Advance, Ashen Chain, Smoking Strike, Smoking Strike, Brace, Drive Back | Die 2: Skirmish, Cinder Brand, Smoking Strike, Sweep, Grave Tithe, Distort | Die 3: Advance, Skirmish, Cinder Brand, Sweep, Drive Back, Fracture

### Fallback and targeting

A result without a valid target can use fallback: if already adjacent to a hero, hold position and gain 0 idle Block in Tuned; otherwise move 1 toward a hero, or gain 1 Block if movement fails. Tuned gives no extra idle Block just for already being adjacent. Advance has its own highest-HP/adjacent-Block rule. Read each action’s target priority; they do not all choose the same hero.


## Nu’gh, Worm Summoner

### The brood and Soul Link

Start with two 1-HP worms, up to four living at once. They occupy one cell and block movement/sight. Brood Command activates them individually: move then bite. After all three Nu’gh dice, every living worm activates once before initiative advances. Brood Command grants extra activations during his dice. Each activation moves toward a standing hero, then rolls a bite if adjacent. BEFORE half HP only, hero kills deal 1 unavoidable Soul Link damage to Nu’gh. His own consumption of a worm does not trigger Soul Link. Corpses free their cells. Summons use free legal cells within 2 of Nu’gh, preferring the front/bottom side; upgraded Burrow summons near his old location. All three heroes, including Downed heroes, the full boss footprint and living worms exclude a summon cell. Crowding or the cap can prevent a summon.

### Why clear worms?

They make commanded attacks and feed Nu’gh’s Maw and Devour. In phase I, killing them reduces pressure and damages Nu’gh. In phase II, killing them is crowd control only: you must damage Nu’gh directly to finish him. Friendly Nu’gh never counts toward enemy brood caps, pressure, Guard, Commands, Devour or Soul Link. Enemies can target and kill friendly worms. Their deaths are not required for victory: killing Nu’gh ends the fight and removes the brood.

### Birth Cry

Targeting: Empty nearby cells. Summon 1 worms on empty cells within 2; cap 4 living, 1 HP each. Never on heroes, the boss or other worms. HALF-HP UPGRADE: Summon +1 worm(s); Soul Link switches OFF permanently.

### Brood Command

Targeting: All living worms. Each worm: move up to 2 toward a standing hero, then bite if adjacent.

Die: 1, 1, 0, 0, 0, 0. HP loss applies Poison 1 (next activation: damage equal to total Poison, then reduce by 1; applications stack). Reactions apply.

No worms: summon 2 instead. New worms can act after Nu’gh. HALF-HP UPGRADE: Worm movement +1; empty-brood summon +1.

### Gnashing Maw

Targeting: Lowest HP. Lowest-HP hero (closest legal fallback) within 1: 1 base + 1 brood pressure damage. No target: RETREAT 1 or gain 1 Block if cornered. HALF-HP UPGRADE: Reach +1; brood pressure cap +1.

### Burrow

Targeting: Self. RETREAT up to 1 cells to maximize distance from the nearest hero. No safer route: +1 Block. HALF-HP UPGRADE: Retreat +1 and leave 1 worm(s).

### Brood Guard

Targeting: Self. Gain 1 Block + one per living worm, bonus capped at 0. HALF-HP UPGRADE: Shield one worm with 1 non-stacking Block.

### Devour Brood

Targeting: Closest living worm. Consume the nearest worm (no Soul Link); heal 1 HP. No worms: summon 2. HALF-HP UPGRADE: Gain 1 Block.

### Boss dice, phase I

Die 1: Birth Cry, Brood Command, Burrow, Brood Command, Gnashing Maw, Brood Guard | Die 2: Brood Command, Brood Command, Birth Cry, Burrow, Gnashing Maw, Devour Brood | Die 3: Brood Command, Birth Cry, Burrow, Brood Command, Devour Brood, Brood Guard

### Command sequencing and fallback

Each Command snapshots the living brood and activates each surviving worm once. A worm moves up to 2 (3 in phase II), then rolls a bite against the closest adjacent standing hero or friendly worm: six sides 1,1,0,0,0,0. A 0 misses without triggering a Reaction. A 1 is normal damage with Reactions and Block. Only HP loss on a surviving hero or friendly worm applies Poison 1. Applications stack. At activation, lose HP equal to total Poison, then reduce Poison by 1. Downing clears it; ordinary Block can prevent application but cannot stop an existing Poison tick. Reactions recheck range from that worm, not Nu’gh. Use Activate next worm, then Finish Brood Command before continuing dice. If no worms live at the start of Command, summon 2 (3 in phase II) and stop; new worms wait for another Command or the automatic brood turn after Nu’gh. The automatic brood snapshots current living worms, activates each once and never summons merely because none remain. Maw with no legal target uses fallback: retreat 1 to a safer position or gain 1 Block if cornered. Results remain visible below the controls.


## Veyl, the Brass Cantor

### A different lesson: manage the shared meter

Veyl is a walking brass bell reliquary with a suspended blue crystal. This fight has no boss summons or terrain hazards. Resonance starts at 0 and caps at 6. Each resolved hero Attack face adds 1. Resolving an own-turn Skill or Defense face removes 1. Movement and Blanks do neither. The meter does not reset each round.

### Count faces, not hits

Each successfully spent face changes the meter once. A repeated Attack still adds only 1, even with several hits. A legal Attack that rolls zero still charges it. Declining a face, an invalid action, a held Reaction and maintaining a Channel do not calm or charge it. Conjure uses the final copied result’s category. The combat log names the face and exact meter change.

### Open core: a risk / reward window

Crescendo raises Resonance and opens Veyl’s core until its next boss turn starts. Hero Attack hits against the open core gain +1 before Block (+2 in phase II). Each repeat gets the bonus; Skill damage such as Last Word is not an Attack hit. Normal damage rules, Weakness, Short Shot’s cap and Gambler’s absolute zero still apply. Seal can add Block while the core is open, but does not close it.

### Toll declaration and Reactions

Toll targets every standing hero in range once. Its damage is 1 + floor(Resonance / 2), so the full meter deals 4. It spends the meter as soon as declared; the incoming hit stays fixed through Reactions. Held Reactions do not lower Resonance. Basic Reaction blocks 2 and does not move. Explicit stored movement can leave the area and avoid that hero’s hit; the Toll does not retarget everyone to one hero.

### Grand Peal at half HP

At 7/14 HP or less, all six actions upgrade permanently. Toll / Chime gain reach, Fork moves farther, Seal grants more Block, and notes gather more Resonance. The open-core damage bonus also rises from +1 to +2. This stronger vulnerability rewards a well-timed burst.

### Gathering Note

Targeting: Self. Gain 2 Resonance, up to 6. No immediate damage. Your own-turn Skills and Defenses calm it before the next boss turn. HALF-HP UPGRADE: Resonance gain +1.

### Crescendo

Targeting: Self. Gain 2 Resonance and OPEN THE CORE until next boss turn. Hero Attacks against Veyl gain +1 per hit before Block. Burst now or calm the next Toll. HALF-HP UPGRADE: Resonance gain +1; exposed-core Attack bonus +1.

### Seal the Bell

Targeting: Self. Gain 2 Block. Old Block expires next boss turn; this does not close an open core. HALF-HP UPGRADE: Block +1.

### Toll of Reckoning

Targeting: All heroes in reach 3. Attack EVERY standing hero within 3 for 1 NOW: 1 base + 1 per 2 Resonance. Spend the entire meter when declared. Reactions apply; the declared hit is fixed. No targets: fallback, keep meter. HALF-HP UPGRADE: Reach +1.

### Hushed Chime

Targeting: Most active buffs. Most-buffed hero (closest legal fallback) within 3: 1 damage NOW (1 base + 1 per 3 Resonance). Spend up to 2 Resonance when declared. No target: fallback, keep meter. HALF-HP UPGRADE: Reach +1.

### Tuning Fork

Targeting: Furthest hero. Advance up to 1, then attack within 1 for 1. Reactions apply. No reachable target: fallback advance / Block. HALF-HP UPGRADE: Movement +1.

### Boss dice

Die 1: Gathering Note, Gathering Note, Tuning Fork, Seal the Bell, Hushed Chime, Crescendo | Die 2: Hushed Chime, Tuning Fork, Toll of Reckoning, Seal the Bell, Gathering Note, Hushed Chime | Die 3: Toll of Reckoning, Hushed Chime, Tuning Fork, Toll of Reckoning, Seal the Bell, Crescendo

### Fallback and counterplay

Toll / Chime with no targets advance 1 or gain 1 Block if unable to move, keeping unspent Resonance. Tuning Fork advances before trying its hit. Read the known die order: a Gathering Note before Toll increases its eventual damage. Use Skills and Defenses to calm the meter during hero turns, and save attack bursts for an open core.


## Bu’gh, the Iron Warden

### Defend, evade, counterattack

Bulwark reduces normal incoming damage by 1. Fully preventing HP damage from a positive-damage Warden attack using Block or Damage Reduction breaks Bulwark and removes all boss Block. A threatened hero escaping the marked sweep also breaks it when the sweep resolves. The opening lasts until the next boss activation. Defy Death alone and zero-damage attacks do not count as perfect guards. Unavoidable damage bypasses Bulwark.

### Read the fixed warning

A Crushing Sweep marks cells around the current boss footprint. Phase I: reach 1, damage 1. Phase II: reach 2, damage 2. Impact happens before the next boss turn’s three dice, with Reactions. Cells and damage stay fixed even if Bu’gh moves or changes phase. Move a threatened hero outside the marked cells, or prepare enough Block. A sweep that never threatened a hero grants no free opening. Each full boss turn ends by arming a sweep if one is not already marked. Warnings do not stack or chase heroes.

### Friendly summons and Poison

Each hero may have one friendly Nu’gh across all copies of Summon Nu’gh. Summon on an adjacent empty tile. It has 1 HP and its own 1,1,0,0,0,0 Numeric die. HP-damaging bites apply Poison 1 to bosses or enemy summons. While it lives all the owner’s copies become Command Nu’gh, granting an immediate extra activation without removing its owner-end activation. Death restores Summon. Worms carry their owner’s colored marker. Poison applications add together. At the victim’s next activation, damage equal to total Poison bypasses Block, then Poison decreases by 1. The tick uses sound and green feedback without a popup; green smoke persists while Poison remains. Downing clears Poison. Enemy attacks and area attacks can kill friendly worms; Cleave’s secondary hit chooses only enemies.

### Provisional balance

The Warden replaces the cocoon-and-mite concept. Its difficulty is still provisional. Automated comparisons exercise attack-only, stationary defense and adaptive movement/defense policies; they are not human win-rate estimates. See Changes-v0.24.md and Trial-results-v0.24.json.

### Iron Advance

Targeting: Highest HP. Advance up to 1 toward the party. Occupied tiles block the full 2×2 footprint. HALF-HP UPGRADE: Move +1.

### Shield Bash

Targeting: Most Block. Most-Block hero (closest legal fallback) within 1: 1 normal damage. Fully preventing HP loss with Block / Damage Reduction breaks Bulwark and removes his Block. Reactions apply. HALF-HP UPGRADE: Damage +1.

### Hammerfall

Targeting: All heroes in reach 1. Attack each opponent within 1 for 2 normal damage. Spread out or guard. One fully defended hero hit breaks Bulwark. Reactions apply. HALF-HP UPGRADE: Area reach +1.

### Raise Guard

Targeting: Self. Gain 1 Block. Does not restore a broken Bulwark before his next turn. HALF-HP UPGRADE: Block +1; cannot restore Bulwark early.

### Crushing Sweep

Targeting: Marked tiles. Marked cells take 1 damage before his next three dice. The warning is fixed: move a threatened hero out to break Bulwark, or fully guard the impact. Reactions apply; movement Reactions can escape. After every boss turn a sweep is armed if none is already marked. Future warning reach 1. HALF-HP UPGRADE: Future warning reach +1; damage +1. Existing warnings do not expand.

### Driving Blow

Targeting: Highest HP. Highest-HP hero (closest legal fallback) within 1: 1 damage. A hero who loses HP is pushed up to 1; occupied cells stop the push. Fully guarding prevents the push and breaks Bulwark. HALF-HP UPGRADE: Damage +1; HP-hit push +1.

### Boss dice

Die 1: Iron Advance, Shield Bash, Iron Advance, Hammerfall, Raise Guard, Crushing Sweep | Die 2: Shield Bash, Driving Blow, Iron Advance, Raise Guard, Crushing Sweep, Raise Guard | Die 3: Driving Blow, Shield Bash, Crushing Sweep, Iron Advance, Crushing Sweep, Raise Guard


## Quick timing reference

### Before the shared roll

Set aside a die for any still-Stunned hero. Then roll available dice together; hold Reactions, keep Channel dice held, trigger when-rolled effects.

### At your turn start

Resolve due costs and expiry, refresh Blank allowance, decide Maintain/End Channel. Ordinary old Block disappears; Stonewake can preserve it.

### Before your first action

Optional banked reroll. With turn refill OFF, charges do not refill automatically. The optional refill to 1 occurs at own turn start, not when toggled. Locked, spent and channelled results cannot be rerolled; held Reactions remain eligible.

### During your turn

Resolve ready dice in any order; finish mandatory choices first. Focus can reroll another eligible ready die after actions but forces its result next.

### Before an enemy Attack hits

Resolve eligible held Reactions, including for Worm Bites. Recheck targets/range from the actual attacker after movement or redirection. Starter Reaction grants 2 Block and no movement. Then apply Block → reduction → HP.

### At the end of a full turn

Clear Downed protection; process any queued recovery turn. Hero turn end also clears Stunned/turn boosts, applies persistent fire if occupied and checks Black Oath. Boss turn end clears its Ward Weakness.

### At the next boss turn start

Rooted and Distort expire, Brand detonates, then old boss Block clears. Veyl’s open core closes; its Resonance persists. Resolve new boss dice in order.

### At the next round

Reset temporary initiative delay, expire old Reactions and Mark Prey, and roll available dice together. This is not a new Blank-conversion allowance unless it is also that hero’s own turn.

### At half boss HP

Upgrade immediately once, using current maximum HP and the threshold. Healing does not return the boss to phase I. Open the phase guide for each upgraded action.


## Essence harvesting and Camp Forge

### Essence

Normal creatures yield 1 matching Essence each; bosses yield 3. Defeat the whole encounter to bank eligible tokens once. Different types cannot pay each other’s recipes. All design names, effects and prices can be read before buying.

### Faces and Memories

Each crafted face is one physical party copy. Memories occupy the passive slot. Memory of the First Step costs 1 Movement Creature Essence; the three converted Wilds Memories cost 3 matching creature Essence each. Other listed prices remain. Converted saved rewards keep all existing copies.

### Unique Weapon

After defeating Bu’gh, craft Oathblade for 4 matching Essence. It allows 3–6 Attack faces, replaces 3 Strikes with Oath Cut, and grants all your Attack faces Pierce 1. Pierce bypasses that many Block without destroying the bypassed portion.


## Equipment and normal encounter preparation

### Body

Sets only minimum and maximum Defense, Movement and Skill faces across all three dice. Bodies never set Attack limits, HP, minimum Blanks or movement distance.

### Soul

Sets maximum HP, minimum Blanks on each die and its printed strong effect. Each Soul copy belongs to one hero. Beginning Soul has 6 HP / 2 Blanks per die; earned Souls require 3; Soulcaster has 6 HP / 4 Blanks. Body and Memory do not impose HP penalties.

### Memory

One passive modifier slot. The first encounter starts empty. Memories can grant alternate uses for rolled Blanks. Memory of the First Step spends one rolled Blank as Move 1, once per own turn. It is not a free move and leaves the installed side Blank.

### Weapon

Every Weapon states minimum and maximum total Attack faces, an exact count of 1–3 basic Strikes to replace with its corresponding attacks, and an optional passive modifying all of that hero’s Attack faces. Replacements occupy physical sides, still count as Attacks and must roll before use. Other Strike sides remain ordinary. Weapon passives affect other equipped Attack faces too; they do not affect non-Attack damage unless printed.

### Preparing normal play

Normal heroes can prepare Broken, Fleet or Stone Body and Dagger, Spear or Hammer. Owned Souls remain bound to their hero. Earn Memories and Oathblade through the Forge. Illegal equipment changes explain the required dice edits and preserve previous equipment. The Forge shows projected Weapon faces while retaining the underlying Strike sides for editing.

### Poke is rolled

Dagger replaces one Strike with Poke: deal 1 adjacent-enemy damage only after earlier actual enemy HP damage in this own turn. Once per own turn; spends its rolled die. Fully blocked hits and friendly fire do not unlock it. There is no additional free Poke action.

### Ash Road Soul

6 HP · minimum 3 Blanks per die. Last Ember: once per encounter, lethal enemy damage leaves you at 1 HP.

### Beginning Soul

6 HP · minimum 2 Blanks on every die. Last Ember: once per encounter, lethal enemy damage leaves you at 1 HP. Does not prevent voluntary HP costs.

### Warden Soul

6 HP · minimum 3 Blanks per die. Keep up to 2 Block at own-turn start. Movement abilities travel 1 less, minimum 1.

### Echo Soul

6 HP · minimum 3 Blanks per die. First Skill each own turn readies +1 next-Attack damage. Begin with 0 Action Rerolls.

### Cinder Soul

6 HP · minimum 3 Blanks per die. Your first HP-damaging Attack each own turn adds Poison 1. Begin each encounter with Poison 1.

### Brood Soul

5 HP · minimum 3 Blanks per die. First Poison you apply each own turn spreads Poison 1 to another adjacent enemy.

### Soulcaster

6 HP · minimum 4 Blanks on every die. Gather Soul Charges or Manifest encounter spells using rolled Blanks. Charge cap 3; spell cap 4. Manifest costs charges + 1 HP. New spells activate only when rolled on a later turn.

### Dagger

Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poke (1 damage after earlier enemy HP damage). All-Attack passive: none.

### Hammer

Attack faces: minimum 2 / maximum 8. Replace 1 basic Strike → Crack (remove 2 adjacent Block after another Attack). All-Attack passive: none.

### Heavy Dagger

Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Heavy Poke (2 damage, then pay 1 HP). All-Attack passive: none.

### Oathblade

Attack faces: minimum 3 / maximum 6. Replace 3 basic Strikes → Oath Cut (1 adjacent damage each). Passive: ALL your Attack faces gain Pierce 1, including other equipped Attacks. Replacements spend rolled dice.

### Spear

Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Jab (range 2; move 2 first). All-Attack passive: none.

### Poison Dagger

Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poison Poke (1 damage; HP loss adds Poison 1). All-Attack passive: none.


## Creatures and Memories of the Wilds

### Glasswing Moth — 3 HP

3 HP. Needle 1 at range 3 with line of sight. Scuttle 2, Guard 1. Public dice: Die I: Needle / Needle / Scuttle / Guard / Needle / Scuttle; Die II: Scuttle / Needle / Guard / Needle / Scuttle / Needle; Die III: Needle / Guard / Scuttle / Needle / Guard / Scuttle. Regular harvest: one matching Essence token per defeated individual.

### Iron Husk — 5 HP

5 HP. Bash 2 at reach 1. Scuttle 1, Iron Guard +2 Block. No passive armor. Public dice: Die I: Scuttle / Scuttle / Bash / Iron Guard / Bash / Iron Guard; Die II: Iron Guard / Bash / Scuttle / Iron Guard / Bash / Scuttle; Die III: Bash / Iron Guard / Scuttle / Bash / Iron Guard / Scuttle. Regular harvest: one matching Essence token per defeated individual.

### Mire Leech — 4 HP

4 HP. Venom Bite 1 at reach 1; actual HP loss adds Poison 1. Scuttle 2, Guard 1. Public dice: Die I: Scuttle / Scuttle / Venom Bite / Venom Bite / Guard / Venom Bite; Die II: Venom Bite / Guard / Scuttle / Venom Bite / Scuttle / Venom Bite; Die III: Guard / Venom Bite / Scuttle / Guard / Venom Bite / Scuttle. Regular harvest: one matching Essence token per defeated individual.

### Glasswing Memory

Spend one rolled Blank to blink up to 2 orthogonal spaces, once per own turn. May cross occupied cells; landing must be empty. Rooted prevents it. No extra action. Craft for 3 matching creature Essence, then equip in the Memory slot.

### Ironbound Memory

Spend one rolled Blank to gain 2 Block, once per own turn. Block expires normally at the next own turn. No movement. Craft for 3 matching creature Essence, then equip in the Memory slot.

### Memory of the Mire

Spend one rolled Blank to heal yourself 1 HP, once per own turn. Requires missing HP. No movement; cannot revive a Downed hero. Craft for 3 matching creature Essence, then equip in the Memory slot.

### Saved rewards

Existing owned conversion Souls become equivalent Memory copies. If their Memory slot was empty, the converted effect stays equipped there; otherwise its ownership is retained for later equipment. Their Soul slot returns to Beginning Soul. No earned copy or banked Essence is deleted.


## Boss rewards and ownership

### Poison

Poison adds normally. At activation it deals its value as unavoidable HP loss, then reduces by 1. Preserve the status and exact damage as observable game state.

### Boss harvesting

Each defeated boss yields 3 matching Essence, banked once on victory. Defeat/abandoning grants no current tokens. Boss victory opens Camp at that boss’s recipes. Faces cost 2 matching Essence per physical copy; each Memory costs 3 once. Recipes can be inspected before discovery, but normal crafting requires defeating the boss and paying. Hollow’s automatic bound Soul reward remains.

### The Hollow

Ember Cut — Attack: deal 2 to an adjacent enemy; actual HP loss grants 1 Block. Memory of Embers: your first actual enemy HP damage each own turn grants 1 Block.

### Nu’gh

Brood Needle — Attack: deal 1 to an enemy within 2 with clear sight; actual HP loss applies Poison 1. Memory of the Brood: your first Poison application each own turn adds 1 Poison, including your friendly Nu’gh. Shared Burden interrupts do not refresh or trigger the own-turn allowance.

### Veyl, the Brass Cantor

Quiet Note — Skill: heal self 1 and clear Weakness. Memory of Silence: the first Skill resolved each own turn grants 1 Block.

### Bu’gh, the Iron Warden

Iron Shelter — Defense: gain 2 Block, or 3 if you already have Block. Memory of Iron: the first Defense resolved each own turn grants 1 extra Block.

### Equipment and ownership

One Memory slot per hero. Most crafted Memories are one shared transferable copy; converted saves retain their original copy counts. Souls remain per-hero bound. Weapon and Body constraints, Soul Blanks and physical-copy rules all apply to equipped dice.


## Trials — equipment and expeditions

### Body

Sets only minimum and maximum Defense, Movement and Skill faces across all three dice. Bodies never set Attack limits, HP, minimum Blanks or movement distance.

### Soul

Sets maximum HP, minimum Blanks on each die and its printed strong effect. Each Soul copy belongs to one hero. Beginning Soul has 6 HP / 2 Blanks per die; earned Souls require 3; Soulcaster has 6 HP / 4 Blanks. Body and Memory do not impose HP penalties.

### Memory

One passive modifier slot. The first encounter starts empty. Memories can grant alternate uses for rolled Blanks. Memory of the First Step spends one rolled Blank as Move 1, once per own turn. It is not a free move and leaves the installed side Blank.

### Weapon

Every Weapon states minimum and maximum total Attack faces, an exact count of 1–3 basic Strikes to replace with its corresponding attacks, and an optional passive modifying all of that hero’s Attack faces. Replacements occupy physical sides, still count as Attacks and must roll before use. Other Strike sides remain ordinary. Weapon passives affect other equipped Attack faces too; they do not affect non-Attack damage unless printed.

### Starting and rewards

A class supplies a Body, Beginning Soul, Weapon and legal dice, with Memory empty. Soulcaster is an alternate starter Soul. After the first victory, spend 2 Run Essence on a Memory, a face or a Weapon, or bank the reward as currency. Memories become usable after that first encounter.

### Route

Complete five stops, then the selected boss. HP carries between encounters; Camp heals 2 up to the maximum on each hero’s Soul. Safe route/reward checkpoints resume. Reloading or leaving during a fight fails that Trial. Boss victories grant a separate bound Soul copy to each hero.

### Save migration

Old safe checkpoints retain inventory, currencies and injuries. Where required, dice are repaired for the new construction rules, with original dice retained in the save and an explanation shown. A new run starts with Memory empty.

### Broken Body

Defense 0–3 · Movement 0–3 · Skill 0–3 across all three dice. Attack limits come from your Weapon.

### Fleet Body

Defense 0–2 · Movement 0–4 · Skill 0–3 across all three dice. Movement uses its printed distance. Attack limits come from your Weapon.

### Stone Body

Defense 0–4 · Movement 0–2 · Skill 0–3 across all three dice. Attack limits come from your Weapon.

### Dagger

Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poke (1 damage after earlier enemy HP damage). All-Attack passive: none.

### Hammer

Attack faces: minimum 2 / maximum 8. Replace 1 basic Strike → Crack (remove 2 adjacent Block after another Attack). All-Attack passive: none.

### Heavy Dagger

Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Heavy Poke (2 damage, then pay 1 HP). All-Attack passive: none.

### Oathblade

Attack faces: minimum 3 / maximum 6. Replace 3 basic Strikes → Oath Cut (1 adjacent damage each). Passive: ALL your Attack faces gain Pierce 1, including other equipped Attacks. Replacements spend rolled dice.

### Spear

Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Jab (range 2; move 2 first). All-Attack passive: none.

### Poison Dagger

Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poison Poke (1 damage; HP loss adds Poison 1). All-Attack passive: none.


## Range and reroll rules

### Range and targets

Faint category-colored tiles show reach, including empty tiles. Bright outlines identify targets or legal movement destinations. Red stripes identify sight-blocked cells. Range uses orthogonal distance, the existing minimum distance to a boss’s footprint, sight rules and equipped range bonuses. Movement uses actual legal reachable cells; Stride stays straight and Leap follows its own rules. A range preview never rolls dice or changes combat. Ready and inspected spent/held faces can be read; an outline does not restore a spent action.

### Creature footprints

Ordinary creatures occupy one grid cell. Their sprites, HP dots and small Block badge stay inside that cell; the large boss shadow and wide boss HP label are not drawn on them. Two-by-two bosses retain their normal footprint.

### Reroll presentation

Action Reroll and Focus animate the real new result and update the ability card without a blocking text prompt or Continue acknowledgement. Charges, forced-result timing and held Reactions are unchanged. A same-face result is legal. Detailed old/new results remain in the full log. Required gameplay choices, such as a Reaction or a Channel decision, still need their normal input.


## Trial experiments — objectives, previews and crafting

### Direct targets and self effects

Tap an Attack or targeted skill, then tap a legal map target. Movement uses ability then destination. Guard and other self effects resolve on the ability tap. This applies in both normal and Trial encounters. Jab and Crack still require their printed setup. There is no generic Confirm action step. Friendly-fire warnings and required choices such as copy targets, installed sides, Reactions and Shove direction remain. Numeric values are rolled by the model at resolution; range and sight overlays remain read-only.

### Unknown Numeric results

Numeric attacks, healing and Block show a possible range, including zero, after existing modifiers, caps and defenses. They do not reveal a hidden next result or roll early. A stored Numeric value is known and can be previewed exactly. Some complex choices depend on a subsequent target, Reaction or selection; their preview says that a choice is required instead of promising an exact result.

### Break the Ritual

Break all three violet ritual stones (2 HP each). Any Attack can damage them; they cannot move or receive Poison. Enemies retreat when all three break. Clearing only the creatures does not complete this objective. Victory: +3 Run Essence and 2 Cinder Essence. This is the second route at stop 1. The Ram and Sentry guard three separate one-cell violet stones. Objects have HP but no turns, movement or Poison. You may attack empty of creatures until every stone breaks; clearing only enemies is not sufficient. Attacking an object does not count as enemy HP damage for Dagger Poke or enemy-damage history.

### Protect the Spirit

Keep the blue spirit (5 HP) alive through three enemy turns, or defeat all its attackers sooner. Enemies prefer the spirit when their ability can reach it; otherwise they target a hero. First Aid can heal it. Shield Wall and Taunt can protect it. Its death ends this Trial. Victory: +3 Run Essence and 2 Ward Essence. This is the first route at stop 3. The Shieldbearer and Mender prefer a reachable spirit; named intents and actual targets agree. They pursue it with Scuttle. If it cannot be attacked, the normal hero fallback applies. A spirit has no turn, owned summon action, Downed protection or revival. First Aid heals it within normal range. Shield Wall can supply Block before its hit; Taunt can redirect a legal attack. Three completed enemy turns advances the rescue counter. All heroes falling still fails the Trial.

### Trial Hollow: cancel Soul Rupture

A visible violet Rupture Core starts at G5 with 2 HP. It cannot move, take Poison or act. At the Hollow’s first action in round 2, Soul Rupture deals 3 normal damage to every standing hero and friendly summon, regardless of distance. Block and Reactions work. Destroy the core before that action to cancel it and consume that boss action without damage. The once-only core expires after an uninterrupted Rupture. A matching Lethargic Bind can suppress the rolled Rupture and also ends that once-only attack. Its warning is available from the objective banner; the actual round-two intent names its targets and effect. Ordinary Hollow fire and the half-health phase continue; a phase Roar is queued after the reserved Rupture action. The other three bosses and normal Hollow encounters are unchanged.

### Where crafting Essence comes from

Trial victories bank matching ingredients: Ward & Whisper and Protect the Spirit give Ward Essence; The Long Charge and Break the Ritual give Cinder Essence; Essence Thieves give Shade Essence; the final Trial Hollow gives Hollow Essence. Regular groups and objectives give 2 matching Essence, elites 3, Hollow 3. These ingredients persist between Trial runs. Defeat or interruption grants no victory ingredients. Payment and rewards are recorded once; redraw, reload and repeated Continue cannot duplicate them.

### Build suggestions

Poison uses Memory of Venom, Poison Dagger and, when unlocked, Brood Soul. Movement uses Fleet Body, Memory of Momentum, Spear and Wind Soul. Protection uses Stone Body, Memory of Guard, Hammer and, when unlocked, Warden Soul. Each build explains its actual turn sequence and tradeoffs. Apply available pieces uses Broken Body, Dagger or Beginning Soul for missing items and lists what is missing. It never changes the selected class, rewrites class dice or bypasses ownership. A class can use its own starting Body without crafting it.

### Fleet Body — Body

Defense 0–2 · Movement 0–4 · Skill 0–3 across all three dice. Movement uses its printed distance. Attack limits come from your Weapon. Craft: 3 Cinder Essence.

### Memory of Hearth — Memory

Spend one rolled Blank to heal yourself 1 HP, once per own turn. Cannot revive yourself. Craft: 3 Ward Essence.

### Heavy Dagger — Weapon

Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Heavy Poke (2 damage, then pay 1 HP). All-Attack passive: none. Craft: 2 Cinder Essence, 1 Hollow Essence.

### Oathblade — Weapon

Attack faces: minimum 3 / maximum 6. Replace 3 basic Strikes → Oath Cut (1 adjacent damage each). Passive: ALL your Attack faces gain Pierce 1, including other equipped Attacks. Replacements spend rolled dice. Craft: 2 Hollow Essence, 4 Ward Essence.

### Memory of Shelter — Memory

Your first own-turn Defense ability grants 1 extra Block. Craft: 2 Ward Essence.

### Stone Body — Body

Defense 0–4 · Movement 0–2 · Skill 0–3 across all three dice. Attack limits come from your Weapon. Craft: 3 Ward Essence.

### Poison Dagger — Weapon

Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poison Poke (1 damage; HP loss adds Poison 1). All-Attack passive: none. Craft: 2 Shade Essence.

### Memory of Wind — Memory

Spend one rolled Blank as Move 2, once per own turn. Craft: 3 Cinder Essence.


## Two Trial classes

### How a class works

A class defines starting equipment, starter dice and the three face reward offers for that role. Actual combat effects come from the four equipment slots: Body, Memory, Soul and Weapon. There is no additional hidden class stat bonus. The lobby calculates real maximum HP after equipment. Adjusting equipment marks the class card adjusted gear; changing Memory does not alter dice. The same class may be chosen for multiple heroes.

### Free starting equipment and crafting

Skirmisher includes Fleet Body and Spear; Vanguard includes Stone Body and Hammer. Both use Beginning Soul and start with Memory empty. A class includes its Body for that hero without unlocking the global crafting recipe. Other equipment effects come only from the printed four slots.

### Weapons really appear on dice

Both class weapons replace the first Strike side on Die 1 with their rolled ability. Skirmisher has Jab; Vanguard has Crack. Exactly one side changes, and other normal Strikes remain for setup and ordinary attacks. The class preview, actual shared roll, reroll, combat buttons, copy choices and dice view use the equipped face name. Jab/Crack must be rolled, spend their Action Die and remain once per own turn. Invalid requirements spend nothing. These weapons grant no extra free Poke.

### Saved games

Class choices and adjusted gear save on this device. Safe route/reward checkpoints retain their class, actual dice, injuries, equipment and resource balances. Leaving or reloading during combat retains the existing interrupted-Trial failure rule. Pre-v0.37 safe checkpoints continue with their old setup, not a retrofitted class build; their next new Trial can choose the new classes. Normal Camp and normal game setup do not acquire classes.

### Skirmisher — Move first, then strike from range 2.

Starting Body: Fleet Body. Starting Memory: No Memory. Starting Weapon: Spear. Starting Soul: Beginning Soul. 6 maximum HP from Beginning Soul. Fleet Body sets category limits; Memory starts empty. Example: roll Stride and Jab on different dice. Move at least 2 spaces with Stride, then Jab deals 1 damage within 2. Each ability spends its rolled die. Step moves its printed 1 space. Fleet Body allows up to 4 Movement faces but only 2 Defense faces. Spear allows 2–6 Attack faces. Beginning Soul requires 2 Blanks per die and supplies Last Ember. Earn a Memory later for a passive. Starter dice: Die 1: Jab, Strike Numeric, Guard, Strike, Blank, Blank; Die 2: Step, Stride, Reaction, Step, Blank, Blank; Die 3: Momentum Strike, First Aid, Focus, Blank, Blank, Blank. Face reward offers: Momentum Strike, Retreat, Leap of Echoes.

### Vanguard — Guard the front line and break enemy Block.

Starting Body: Stone Body. Starting Memory: No Memory. Starting Weapon: Hammer. Starting Soul: Beginning Soul. 6 maximum HP from Beginning Soul. Stone Body sets category limits; Memory starts empty. Use Guard, Iron Shelter or a held Reaction for Block. During your own turn, use another rolled Attack first, then spend a rolled Crack to remove up to 2 Block from an adjacent enemy. Crack deals no HP damage. Stone Body allows up to 4 Defense faces but only 2 Movement faces. Hammer allows 2–8 Attack faces. Stride keeps its printed Move 3. Beginning Soul requires 2 Blanks per die and supplies Last Ember. Starter dice: Die 1: Crack, Guard, Iron Shelter, Strike, Blank, Blank; Die 2: Strike Numeric, Strike, Strike, Stride, Blank, Blank; Die 3: Engrave, First Aid, Shove, Reaction, Blank, Blank. Face reward offers: Iron Shelter, Evasive Counter, Wither Ward.


## Soulcaster — free Trial starter Soul

### Starting build and HP

Soulcaster sets 6 maximum HP and requires four Blanks on every die. Memory does not reduce HP. Body controls category ranges; the Weapon replaces its printed 1–3 Strike sides. Starter dice adapt to those requirements. The caster’s Stride retains Move 3, so it can satisfy Spear’s Move-2 prerequisite.

### Gather and Manifest

Tap a ready rolled Blank to open the compact casting panel while the board stays visible. Tap Gather to spend the result for +1 Soul Charge, maximum 3. Tap a spell to create it directly; Manifest spends the result, the chosen charge cost and 1 unavoidable HP, replacing that exact physical Blank side. The HP payment may Down or kill the caster under the existing Broken rules. Maximum four manifested spells per caster. No once-per-turn limit applies to using different ready Blanks. Close leaves the result unspent; Help opens spell descriptions before you spend. Costs, charge bank, HP and spell-slot count are shown in the compact panel. Soulcasting replaces Blank movement.

### Delayed activation and encounter reset

A new spell cannot activate on its creation turn, including another reroll that turn. Its physical side must roll on a later turn. The old rolled result stays Blank and spent when Manifest is paid. Soul Charges start at 0 each encounter; Downing does not erase earned charges or manifested physical sides. Spells exist for this encounter only; the next encounter restores the saved run build.

### Wraith Exchange interpretation

Choose a different standing allied hero within 4. Rooted on either hero prevents the swap. Then each may optionally Move exactly 1, unaffected by Body distance bonuses. Direction / Stay controls keep the board visible; legal movement and terrain consequences apply. No line of sight requirement.

### Mirror timing

Mirror can protect the holder, another hero or a friendly unit including the living Spirit within 2. Give the target 2 Block before the Attack. Reflection is 1 normal damage to its attacker only if the protected target loses no HP from the entire Attack and its riders, including forced collision damage. It can respond to a legal friendly Attack too. Used Reactions leave the held pool normally.

### Hoarded Omen — original die kept aside

The chosen hero receives the storage opportunity on their next own turn. Save one unresolved ordinary Action result through the prompt or More / Trial menu before that turn ends. The original die is held and skips the following shared roll. Its saved result becomes ready on that hero’s own turn in the following round; the other two dice roll normally, for three total dice. Reactions, Channels, Constants, Negative results, Blanks, when-rolled results and Hoarded Omen cannot be saved. Stun cannot set aside the already held die. Downing or changing its saved physical side ends the hold.

### Fatebreaker eligibility and timing

When rolled, Fatebreaker is spent automatically: gain +1 Action Reroll up to the ordinary cap, then reroll one unresolved eligible enemy die. Each individual enemy die may be rerolled once per shared round. Trial creature dice are included so it works before the boss. Keep the new face, even if unchanged. No eligible die means only the Action Reroll is gained. Initial choices occur after all shared rolls and before the first activation; pending Lethargic Bind checks apply to the final boss results. Focus / Action Reroll / recovery / copied when-rolled results use the same choice. No preview consumes battle RNG.

### Grave Stitch and Harvester details

Grave Stitch can revive a Downed hero with Broken and heal the living Spirit. Existing healing modifiers, such as Memory of Venom, still apply to hero recipients. It returns its own physical spell side to Blank after use, freeing one spell slot. Soul Harvester pays another Soul Charge when used and follows normal Attack modifiers; killing an actual enemy creature or boss grants 2 charges capped at 3. Ritual stones / core objects do not grant the kill refund. Neither spell requires line of sight beyond its printed range.

### Wraith Exchange — Movement

Create: 2 Soul Charges + 1 HP. Swap with a standing ally within 4. Then each hero may Move 1. Rooted prevents the swap; the follow-up steps stay Move 1.

### Soul Harvester — Attack

Create: 1 Soul Charges + 1 HP. Spend 1 Soul Charge to deal 1 normal Attack damage to an enemy within 3. Killing an enemy creature or boss grants 2 Soul Charges, up to 3.

### Mirror of the Damned — Defense

Create: 2 Soul Charges + 1 HP. Reaction: when you or an ally within 2 is attacked, give the target 2 Block. If the entire Attack causes no HP loss, deal 1 normal damage to its attacker.

### Grave Stitch — Skill

Create: 1 Soul Charges + 1 HP. Heal yourself or an ally within 2 for 2 HP, then turn this spell side back into Blank. Can revive a Downed hero or heal the living Spirit.

### Hoarded Omen — Skill

Create: 1 Soul Charges + 1 HP. Choose yourself or a standing ally within 3. On their next turn they may save one ordinary ready ability. Its original die stays aside and the saved result is ready on their turn in the following round. No Reactions, Channels, when-rolled results, penalties, Blanks or Hoarded Omen.

### Fatebreaker — Skill

Create: 2 Soul Charges + 1 HP. When rolled: gain 1 Action Reroll, up to its normal cap, then reroll one eligible unresolved enemy die. Each enemy die can be rerolled once per shared round. If none is eligible, only the Action Reroll is gained.


# Complete ability catalog — 85 face identities

IDs 0–72 are the normal/earned/generated catalog. IDs 73–74 and 81–84 are Weapon projections; 75–80 are temporary Soulcaster spells. IDs are identity references, not extra owned copies.

## 0. Blank

Blank · normal/earned/generated

Reaction when another hero is attacked: become the target if adjacent to the boss. You must be a legal target.

Blanks have no starting effect. An equipped Memory may provide a conversion; Soulcaster enables Gather / Manifest. The separate sandbox can test Move 2 with 1 use(s).

## 1. Strike

Attack · normal/earned/generated

Reaction before a lethal Attack: stay at 1 HP instead, gain Stunned, then blank this face. Prototype sets aside your first available result.

Deal 1 damage to an adjacent unit.

## 2. Step

Movement · normal/earned/generated

Gain Damage Reduction 1 and Weakness 1 until your next turn. Unavoidable damage bypasses reduction.

Move up to 1 orthogonal spaces. Occupied cells block the path.

## 3. Stride

Movement · normal/earned/generated

Reaction during an enemy Attack: deal your actual HP damage taken this round to the boss (cap 3), then blank this face. If unused, take 1 unavoidable damage at next turn start.

Move up to 3 spaces in a straight line. No turning or passing through units.

## 4. Guard

Defense · normal/earned/generated

Channel: at each maintained turn start, heal 1 if no HP damage got through. HP damage breaks this Channel and blanks it.

Gain 1 Block. Unspent Block expires at your next turn.

## 5. Reaction

Defense - Reaction · normal/earned/generated

Gain Numeric +1 Block. Prototype timing: at your turn end, lose 1 HP if Block remains.

When personally attacked, gain 2 Block before the hit. No movement.

## 6. Focus

Skill · normal/earned/generated

Prototype: gain Numeric Block. Until your next turn, an adjacent boss Attack causing HP loss gives the boss Weakness 1 until its turn ends.

Click another ready die or held Reaction to reroll it. Resolve its new result next, or decline it.

Works after other actions. Uses this Focus face, not a reroll charge. Locked faces cannot be rerolled.

## 7. First Aid

Skill · normal/earned/generated

Prototype: gain Numeric Block, then burn up to 2 Block; each deals normal damage to every adjacent unit, including allies. Choose how much to burn.

Heal yourself or an ally within 1 for 1 HP. A Downed ally revives as Broken.

## 8. Shove

Skill · normal/earned/generated

Tabletop variant: leap up to 2 orthogonally over units, never land occupied. If ending adjacent to the boss, your next Numeric damage this turn gets +1.

Push an adjacent unit up to 1 spaces away. No collision damage.

## 9. Gambler's Coin

Skill · normal/earned/generated

Arm Numeric with x0 and x2. Roll again to gain 1 Gold and blank this face for the fight.

First use: arm Numeric ×0 / ×2. Next use: gain 1 Gold and turn this face Blank.

Non-rerollable. Gold has no shop in this encounter.

## 10. Weak Point

Skill · normal/earned/generated

Gain a personal backstab marker through next round. Your next adjacent Attack from below the north-facing boss repeats once, with fresh Numeric rolls for each resolution.

Arm Weak Point through the end of the next 1 round(s). Your next Attack from the boss’s southern edge repeats 1 extra time(s).

The gold marker stays until used or expired.

## 11. Conjure

Skill · normal/earned/generated

Copy another visible immediate hero face. Select its hero and die; resolve the copy now. No setup/copy loops.

Copy another visible immediate hero ability within 99. Choose its hero and die, then resolve the copy.

No setup or copy chains. Non-rerollable.

## 12. Blessing of Recovery

Skill · normal/earned/generated

Choose a hero and a specific Blank slot: install Recovery there. Recovery heals Numeric at range 1. After two placements this face becomes Blank.

Install Recovery on a chosen Blank belonging to a hero. Recovery heals a rolled value at range 1.

After 2 placements, this face becomes Blank.

## 13. Clairvoyance

Skill · normal/earned/generated

Prototype: when rolled, gain 1 Action Reroll (cap 1). The bank begins with 1, so save this for replenishment.

When rolled, gain 1 Action Reroll, up to the bank cap of 1. A full bank gains nothing.

## 14. Forgotten Strength

Skill · normal/earned/generated

Tabletop variant: your next Numeric damage this turn gets +1. No party-wide buff or backlash.

Your next rolled damage this turn gets +1.

## 15. Passing Grace

Skill · normal/earned/generated

Heal another hero within 3 for Numeric, then pass this face to a Blank on that hero. No self-target; the source becomes Blank.

Heal another hero within 3 for a rolled value. Move this face to a Blank on that hero.

Cannot heal yourself. Non-rerollable.

## 16. Borrow Shape

Skill · normal/earned/generated

Copy any hero’s face-up die result, even spent or held, onto this die and resolve it next. Borrow Shape and Red Tile cannot be copied.

Choose any of the nine face-up hero dice, including spent or held results. Copy its result onto this die and resolve it next (or hold its Reaction). The source die is unchanged. Borrow Shape and Red Tile are excluded to prevent loops and copying a locked penalty.

## 17. Numeric Echo

Skill · normal/earned/generated

Roll and store one ordinary Numeric value. It replaces your next Numeric roll. A second stored value is not allowed.

Roll and store one ordinary value. Use it instead of your next Numeric roll. Only one value can be stored.

## 18. Lethargic Bind

Skill · normal/earned/generated

Choose a boss die and face. Until your next turn, that face rolls as Bound (no action); you suffer 1 normal damage each time it triggers.

Bind a chosen boss die and face until your next turn. Each matching roll is skipped, but you take 1 normal damage.

## 19. Restore

Skill · normal/earned/generated

Heal another hero within 3 for Numeric, minimum 1. Cannot target yourself. Gambler x0 stays zero.

Heal another hero within 3 for a rolled value, at least 1. Clear sight required. Gambler ×0 stays zero.

## 20. Focus Numeric

Skill · normal/earned/generated

Your next Numeric roll this turn treats Blank as 1, then this benefit ends.

Your next Numeric roll this turn treats Blank as 1.

## 21. Mark Prey

Skill · normal/earned/generated

Mark the boss until round end. The next damaging Attack when it has zero Block adds 1 damage, then removes the mark.

Mark the boss until round end. Its next damaging Attack hit while at zero Block gains 1 damage, then removes the mark.

## 22. Last Word

Skill · normal/earned/generated

After all your other non-Blank dice resolve, deal 1 unavoidable damage to the boss. Prototype range: visible anywhere.

After your other non-Blank dice are spent, deal 1 unavoidable damage to the boss.

## 23. Second Chance

Skill · normal/earned/generated

Skip another unresolved non-Blank die, then repeat one already spent immediate face. Copy/repeat faces cannot chain into themselves.

Skip another unresolved non-Blank die. Repeat a different, already-spent immediate ability. No repeat or copy chains.

## 24. Spiral Instability

Skill · normal/earned/generated

Roll this die until an Attack appears, then resolve it twice at random legal adjacent units, including allies. No Attack on this die: no effect.

Choose an Attack from this die and resolve it 2 times at random legal targets, including allies. No Attack on this die means no effect.

## 25. Contained Power

Skill - Channel · normal/earned/generated

Channel: after maintaining at turn start, each future Blank grants 1 Block and each non-Blank adds Numeric +1 for that turn, capped +2. HP damage breaks it, deals 2 more and leaves a Red Tile. Prototype limit: one active Channel per hero; a second cannot replace it.

Maintain: future Blank rolls grant 1 Block; other rolls add +1 to Numeric, capped at +2.

HP loss breaks it, causes 2 normal backlash damage and leaves a Red Tile.

## 26. Corruption Conversion

Skill · normal/earned/generated

Prototype on resolution: choose an unresolved Blank die, then choose an installed ability on it and resolve that face. This face becomes a locked Red Tile for the fight.

Choose an unresolved Blank die, then an ability installed on it. Resolve that result. This Conversion face becomes a locked Red Tile.

## 27. Blood Bargain

Skill · normal/earned/generated

Empower the next two Attacks against the boss by +1 damage. After the second, take 1 unavoidable damage.

The next 2 Attacks against the boss gain +1 damage. After the last, you take 1 unavoidable damage.

## 28. Target Override

Skill - Reaction · normal/earned/generated

Reaction when personally targeted: force a different legal adjacent hero to be targeted. With no alternative the original target remains.

When personally targeted, redirect to a different legal adjacent hero. With no alternative, the original target remains.

## 29. Debt

Skill · normal/earned/generated

Your next Attack or Defense this turn gets +2 value. At your next turn, the first such face gets −2 value (minimum 0).

Next Attack or Defense this turn: +2. At your next turn, your first such face suffers −2, minimum zero.

## 30. Ill Omen

Skill · normal/earned/generated

Prototype resolution choice: modify another unresolved Attack/Defense. d6: 1 gives −1, 2–4 gives +1, 5 gives Pierce 2 (Defense +2 Block), 6 repeats an Attack or doubles Defense Block.

Modify an unresolved Attack or Defense with a random bonus, penalty, Pierce or repeat. Pick the affected die. See More rules for the six outcomes.

## 31. Stonewake

Skill - Channel · normal/earned/generated

Prototype Channel: gain 2 Block. While maintained, explicitly preserve existing Block at turn start and add 1 (cap 8). Any HP loss or 2 cumulative Block lost before your next turn breaks this Channel. End voluntarily to reroll the die. Prototype limit: one active Channel per hero; a second cannot replace it.

Gain 2 Block. Maintain: preserve Block and add 1, up to 8.

Any HP loss or 2 cumulative Block lost before your next turn interrupts this Channel.

## 32. Oath of Smoke

Skill · normal/earned/generated

Prototype: resolve another rolled Step, Stride or Guard now; store it as a Reaction until the next shared roll. Movement reaction steps 1; Defense grants 1 Block.

Resolve another rolled Step, Stride or Guard now. Then store it as a Reaction until the next shared roll.

## 33. Bone Mutation

Skill · normal/earned/generated

Choose a Blank on one of your dice and replace it with Bone for this fight. Bone grants 1 Block, then optionally steps 1.

Install Bone on one of your Blanks for this fight. Bone gains 1 Block and may step 1.

## 34. Strike Numeric

Attack · normal/earned/generated

Adjacent unit: roll Numeric and deal that much damage.

Roll for damage against an adjacent unit.

## 35. Short Shot

Attack · normal/earned/generated

Target a visible unit within 2. Damage capped at 2 per resolution, including Mark Prey; the mark is consumed on a damaging hit. Units block sight; no diagonal corner shooting.

Roll for damage against a visible unit within 2. Final damage is capped at 2, including Mark Prey.

## 36. Hooked Slash

Attack · normal/earned/generated

Catalog variant: adjacent Numeric Attack. If at least 2 HP damage is dealt, gain that much Block.

Roll for damage against an adjacent unit. At least 2 HP lost: gain that HP loss ×1 as Block.

## 37. Piercing Thrust

Attack · normal/earned/generated

Adjacent Numeric Attack. Bypass 1 Block without destroying the bypassed portion.

Roll for damage against an adjacent unit. Bypass 1 Block; the bypassed Block remains after this hit.

## 38. Cleave

Attack · normal/earned/generated

Adjacent Numeric Attack. A second enemy adjacent to that target takes 1. With no secondary enemy, there is no splash hit.

Roll for damage against an adjacent unit. Also deal 1 damage to one other enemy adjacent to the target.

## 39. Flanking Blow

Attack · normal/earned/generated

Prototype: adjacent Numeric Attack; add 1 when standing below the north-facing boss. Rear means its southern edge.

Roll for damage against an adjacent unit. Add 1 when standing at the boss’s southern edge.

## 40. Break Rhythm

Attack · normal/earned/generated

Adjacent Numeric Attack. If you break existing Block and deal HP damage, delay an upcoming boss activation one initiative slot when possible; normal initiative returns next round.

Roll for damage against an adjacent unit. Break existing Block and damage HP to delay an upcoming boss activation by 1 slot(s).

## 41. Engrave

Attack · normal/earned/generated

Prototype adjacent Numeric Attack. After dealing HP damage, once per hero turn, fill one Blank on this die with Engrave, up to 3 copies. Never overwrites abilities. 3 copies: +1 damage; no further scaling.

Roll for damage against an adjacent unit. On HP damage, grow on this die up to 1 time(s) per hero turn, capped at 3 copies.

At 6 copies: +1 damage. Never overwrites another ability.

## 42. Guard Numeric

Defense · normal/earned/generated

Gain Block equal to a Numeric roll.

Roll a value and gain that much Block.

## 43. Brace Hero

Defense · normal/earned/generated

If at zero Block, gain 3; otherwise gain 1.

At zero Block: gain 3. Otherwise: gain 1.

## 44. Shield Wall

Defense - Reaction · normal/earned/generated

Reaction when an ally within 2 is attacked: give both that hero and yourself 1 Block before the hit.

When an ally within 2 is attacked, give them 1 Block and yourself 1 before the hit. Clear sight required.

## 45. Taunt

Defense - Reaction · normal/earned/generated

Reaction when another hero is attacked: become the target if adjacent to the boss. You must be a legal target.

When another hero is attacked, take their place if you are a legal target within 1. Cannot redirect Sweep or Furnace Roar.

## 46. Defy Death

Defense - Reaction · normal/earned/generated

Reaction before a lethal Attack: stay at 1 HP instead, gain Stunned, then blank this face. Prototype sets aside your first available result.

Before a lethal Attack, remain at 1 HP instead and gain Stunned. This face becomes Blank.

## 47. Bulwark

Defense · normal/earned/generated

Gain Damage Reduction 1 and Weakness 1 until your next turn. Unavoidable damage bypasses reduction.

Gain Damage Reduction 1 and Weakness 1 until your next turn. Unavoidable damage bypasses reduction.

## 48. Echo of Pain

Defense - Reaction · normal/earned/generated

Reaction during an enemy Attack: deal your actual HP damage taken this round to the boss (cap 3), then blank this face. If unused, take 1 unavoidable damage at next turn start.

During an enemy Attack, deal the HP damage you took this round to the boss, capped at 3. This face becomes Blank.

Unused: take 1 unavoidable damage at your next turn.

## 49. Last Pulse

Defense - Channel · normal/earned/generated

Channel: at each maintained turn start, heal 1 if no HP damage got through. HP damage breaks this Channel and blanks it. Prototype limit: one active Channel per hero; a second cannot replace it.

Maintain: heal 1 at your turn start. Any HP loss interrupts the Channel and turns this face Blank.

## 50. Black Oath

Defense · normal/earned/generated

Gain Numeric +1 Block. Prototype timing: at your turn end, lose 1 HP if Block remains.

Gain a rolled value +1 Block. At your turn end, lose 1 HP if any Block remains.

## 51. Wither Ward

Defense · normal/earned/generated

Prototype: gain Numeric Block. Until your next turn, an adjacent boss Attack causing HP loss gives the boss Weakness 1 until its turn ends.

Gain rolled Block. Until your next turn, an adjacent boss Attack that removes HP gives the boss Weakness 1.

## 52. Ember Burst

Defense · normal/earned/generated

Prototype: gain Numeric Block, then burn up to 2 Block; each deals normal damage to every adjacent unit, including allies. Choose how much to burn.

Gain rolled Block, then burn up to 2 Block. Each burned point deals 1 damage to every other unit within 1, including allies.

## 53. Leap of Echoes

Movement · normal/earned/generated

Tabletop variant: leap up to 2 orthogonally over units, never land occupied. If ending adjacent to the boss, your next Numeric damage this turn gets +1.

Leap up to 2 spaces, over units but never onto them. End within 1 of the boss to gain +1 on your next rolled damage this turn.

## 54. Bone

Skill · normal/earned/generated

Gain 1 Block and optionally step 1.

Gain 1 Block and optionally step 1.

## 55. Recovery

Skill · normal/earned/generated

Heal yourself or an adjacent hero for Numeric.

Heal yourself or an ally within 1 for a rolled value.

## 56. Red Tile

Penalty · normal/earned/generated

Inert, non-rerollable, not a Blank, locked for this encounter.

No effect. Locked: cannot be rerolled and does not count as a Blank.

## 57. Ashstep

Movement · normal/earned/generated

Slip through ash: move up to 2 orthogonal spaces, turning allowed, then gain 1 Block. Cannot pass through units.

Move up to 2 spaces, turning allowed, then gain 1 Block. Occupied cells block the path.

## 58. Oathbound Exchange

Movement · normal/earned/generated

Swap positions with a living standing ally within 3 and clear sight. Both heroes gain 1 Block. Cannot swap with the boss or a Downed hero.

Swap with a standing ally within 3 and clear sight. Both gain 1 Block. Rooted prevents the swap.

## 59. Summon Nu’gh

Skill · normal/earned/generated

Summon one friendly Nu’gh on an adjacent empty tile: 1 HP, Move 2, bite range 1, Numeric 1,1,0,0,0,0. HP damage applies Poison 1. Acts after its owner’s turn. While alive, all copies become Command Nu’gh: activate it immediately as well. One worm per hero.

Summon a friendly Nu’gh on an adjacent empty cell: 1 HP, Move 2, reach 1. Numeric bite: 2 successful sides of six, 1 damage; HP damage applies Poison 1. Acts after owner’s turn. While alive: Command grants an immediate extra activation. One per hero across all copies.

## 60. Bone Growth

Skill · normal/earned/generated

Bone. Gain 1 Block and optionally Move 1.

Bone. Gain 1 Block and optionally Move 1.

## 61. Bone Strike

Attack · normal/earned/generated

Bone. Adjacent enemy: deal 1 damage per Bone result rolled this turn, spent results count; this face counts if rolled.

Bone. Adjacent enemy: deal 1 damage per Bone result rolled this turn, spent results count; this face counts if rolled.

## 62. Bone Guard

Defense · normal/earned/generated

Bone. Gain 1 Block per Bone result rolled this turn, spent results count; this face counts if rolled.

Bone. Gain 1 Block per Bone result rolled this turn, spent results count; this face counts if rolled.

## 63. Shared Remedy

Skill · normal/earned/generated

Healing. Heal yourself 1. Only if HP was actually restored, choose an ally within 2 to heal 1.

Healing. Heal yourself 1. Only if HP was actually restored, choose an ally within 2 to heal 1.

## 64. Sorrow’s Offering

Skill · normal/earned/generated

Optionally lose 1 HP, then choose an ally within 2: +2 Block or +1 damage on their next Attack. Decline spends the face without effect.

Optionally lose 1 HP, then choose an ally within 2: +2 Block or +1 damage on their next Attack. Decline spends the face without effect.

## 65. Shared Burden

Skill · normal/earned/generated

Choose another of your results rolled this round, spent or ready. An ally within 2 spends a ready die to resolve a copy immediately as a single-action interrupt. Their other dice and normal turn are unchanged. No Shared Burden copy loops.

Choose another of your results rolled this round, spent or ready. An ally within 2 spends a ready die to resolve a copy immediately as a single-action interrupt. Their other dice and normal turn are unchanged. No Shared Burden copy loops.

## 66. Retreat

Movement · normal/earned/generated

Move up to 2. If you end farther from every living enemy than at the start, gain 1 Block.

Move up to 2. If you end farther from every living enemy than at the start, gain 1 Block.

## 67. Momentum Strike

Attack · normal/earned/generated

After moving 2 spaces this turn: adjacent enemy takes 1 damage. After 3+ spaces: Numeric +1 damage instead.

After moving 2 spaces this turn: adjacent enemy takes 1 damage. After 3+ spaces: Numeric +1 damage instead.

## 68. Evasive Counter

Defense - Reaction · normal/earned/generated

Reaction when targeted: +1 Block before the Attack. If it removes no HP, optionally Move 1 after the entire Attack resolves.

Reaction when targeted: +1 Block before the Attack. If it removes no HP, optionally Move 1 after the entire Attack resolves.

## 69. Ember Cut

Attack · normal/earned/generated

Adjacent enemy: deal 2 damage. If HP is lost, gain 1 Block.

Adjacent enemy: deal 2 damage. If HP is lost, gain 1 Block.

## 70. Brood Needle

Attack · normal/earned/generated

Enemy in clear sight within 2: deal 1 damage. If HP is lost, apply Poison 1.

Enemy in clear sight within 2: deal 1 damage. If HP is lost, apply Poison 1.

## 71. Quiet Note

Skill · normal/earned/generated

Heal yourself 1 HP and clear your Weakness.

Heal yourself 1 HP and clear your Weakness.

## 72. Iron Shelter

Defense · normal/earned/generated

Gain 2 Block, or 3 Block if you already have Block.

Gain 2 Block, or 3 Block if you already have Block.

## 73. Jab

Attack · weapon projection

After moving at least 2 spaces this own turn, deal 1 damage to an enemy within 2. Once per own turn; spends this rolled die.

After moving at least 2 spaces this own turn, deal 1 damage to an enemy within 2. Once per own turn; spends this rolled die.

## 74. Crack

Attack · weapon projection

After another Attack this own turn, remove up to 2 Block from an adjacent enemy. No HP damage. Once per own turn; spends this rolled die.

After another Attack this own turn, remove up to 2 Block from an adjacent enemy. No HP damage. Once per own turn; spends this rolled die.

## 75. Wraith Exchange

Movement · Soulcaster encounter spell

Swap with a standing ally within 4. Then each hero may Move 1. Rooted prevents the swap; the follow-up steps stay Move 1.

Swap with a standing ally within 4. Then each hero may Move 1. Rooted prevents the swap; the follow-up steps stay Move 1.

## 76. Soul Harvester

Attack · Soulcaster encounter spell

Spend 1 Soul Charge to deal 1 normal Attack damage to an enemy within 3. Killing an enemy creature or boss grants 2 Soul Charges, up to 3.

Spend 1 Soul Charge to deal 1 normal Attack damage to an enemy within 3. Killing an enemy creature or boss grants 2 Soul Charges, up to 3.

## 77. Mirror of the Damned

Defense - Reaction · Soulcaster encounter spell

Reaction: when you or an ally within 2 is attacked, give the target 2 Block. If the entire Attack causes no HP loss, deal 1 normal damage to its attacker.

Reaction: when you or an ally within 2 is attacked, give the target 2 Block. If the entire Attack causes no HP loss, deal 1 normal damage to its attacker.

## 78. Grave Stitch

Skill · Soulcaster encounter spell

Heal yourself or an ally within 2 for 2 HP, then turn this spell side back into Blank. Can revive a Downed hero or heal the living Spirit.

Heal yourself or an ally within 2 for 2 HP, then turn this spell side back into Blank. Can revive a Downed hero or heal the living Spirit.

## 79. Hoarded Omen

Skill · Soulcaster encounter spell

Choose yourself or a standing ally within 3. On their next turn they may save one ordinary ready ability. Its original die stays aside and the saved result is ready on their turn in the following round. No Reactions, Channels, when-rolled results, penalties, Blanks or Hoarded Omen.

Choose yourself or a standing ally within 3. On their next turn they may save one ordinary ready ability. Its original die stays aside and the saved result is ready on their turn in the following round. No Reactions, Channels, when-rolled results, penalties, Blanks or Hoarded Omen.

## 80. Fatebreaker

Skill - When rolled · Soulcaster encounter spell

When rolled: gain 1 Action Reroll, up to its normal cap, then reroll one eligible unresolved enemy die. Each enemy die can be rerolled once per shared round. If none is eligible, only the Action Reroll is gained.

When rolled: gain 1 Action Reroll, up to its normal cap, then reroll one eligible unresolved enemy die. Each enemy die can be rerolled once per shared round. If none is eligible, only the Action Reroll is gained.

## 81. Poke

Attack · weapon projection

Deal 1 damage to an adjacent enemy after you have dealt actual enemy HP damage this own turn. Once per own turn; spends this rolled die.

Deal 1 damage to an adjacent enemy after you have dealt actual enemy HP damage this own turn. Once per own turn; spends this rolled die.

## 82. Poison Poke

Attack · weapon projection

Poke for 1 damage. If the target loses HP, apply Poison 1. Requires earlier enemy HP damage this own turn. Once per own turn; spends this rolled die.

Poke for 1 damage. If the target loses HP, apply Poison 1. Requires earlier enemy HP damage this own turn. Once per own turn; spends this rolled die.

## 83. Heavy Poke

Attack · weapon projection

Poke for 2 damage, then pay 1 HP unless combat ended. Requires earlier enemy HP damage this own turn. Once per own turn; spends this rolled die.

Poke for 2 damage, then pay 1 HP unless combat ended. Requires earlier enemy HP damage this own turn. Once per own turn; spends this rolled die.

## 84. Oath Cut

Attack · weapon projection

Deal 1 damage to an adjacent enemy. Spends this rolled die. Oathblade gives all your Attack faces Pierce 1.

Deal 1 damage to an adjacent enemy. Spends this rolled die. Oathblade gives all your Attack faces Pierce 1.


# Enemy families, boss dice and Trial role actions

The family registry includes harvesting records for summons/worms as well as selectable ordinary creatures. A family record is not a guarantee of a separate selectable encounter. Nu’gh worms/friendly summons use their specific summoner rules, not generic ordinary-creature dice.

## Bone Creature [bone_creature]

Scuttle 2 (Movement: 3), Bite 1, Guard 1. Support can Mend 1 within 2.

HP: 3

Ordinary-creature-profile dice: [["Scuttle", "Scuttle", "Bite", "Bite", "Guard", "Bite"], ["Scuttle", "Bite", "Guard", "Bite", "Scuttle", "Bite"], ["Bite", "Guard", "Scuttle", "Bite", "Guard", "Scuttle"]]

## Cinder Mite [cinder_mite]

Scuttle 2 (Movement: 3), Bite 1, Guard 1. Support can Mend 1 within 2.

HP: determined by the spawning encounter; see its boss/summon rules.

Ordinary-creature-profile dice: [["Scuttle", "Scuttle", "Bite", "Bite", "Guard", "Bite"], ["Scuttle", "Bite", "Guard", "Bite", "Scuttle", "Bite"], ["Bite", "Guard", "Scuttle", "Bite", "Guard", "Scuttle"]]

## Glasswing Moth [glasswing_moth]

3 HP. Needle 1 at range 3 with line of sight. Scuttle 2, Guard 1.

HP: 3

Ordinary-creature-profile dice: [["Needle", "Needle", "Scuttle", "Guard", "Needle", "Scuttle"], ["Scuttle", "Needle", "Guard", "Needle", "Scuttle", "Needle"], ["Needle", "Guard", "Scuttle", "Needle", "Guard", "Scuttle"]]

## Iron Husk [iron_husk]

5 HP. Bash 2 at reach 1. Scuttle 1, Iron Guard +2 Block. No passive armor.

HP: 5

Ordinary-creature-profile dice: [["Scuttle", "Scuttle", "Bash", "Iron Guard", "Bash", "Iron Guard"], ["Iron Guard", "Bash", "Scuttle", "Iron Guard", "Bash", "Scuttle"], ["Bash", "Iron Guard", "Scuttle", "Bash", "Iron Guard", "Scuttle"]]

## Mire Leech [mire_leech]

4 HP. Venom Bite 1 at reach 1; actual HP loss adds Poison 1. Scuttle 2, Guard 1.

HP: 4

Ordinary-creature-profile dice: [["Scuttle", "Scuttle", "Venom Bite", "Venom Bite", "Guard", "Venom Bite"], ["Venom Bite", "Guard", "Scuttle", "Venom Bite", "Scuttle", "Venom Bite"], ["Guard", "Venom Bite", "Scuttle", "Guard", "Venom Bite", "Scuttle"]]

## Movement Creature [movement_creature]

Scuttle 2 (Movement: 3), Bite 1, Guard 1. Support can Mend 1 within 2.

HP: 3

Ordinary-creature-profile dice: [["Scuttle", "Bite", "Bite", "Scuttle", "Guard", "Bite"], ["Bite", "Scuttle", "Bite", "Guard", "Scuttle", "Bite"], ["Scuttle", "Guard", "Bite", "Scuttle", "Bite", "Guard"]]

## Screaming Worm [nugh_worm]

Scuttle 2 (Movement: 3), Bite 1, Guard 1. Support can Mend 1 within 2.

HP: determined by the spawning encounter; see its boss/summon rules.

Ordinary-creature-profile dice: [["Scuttle", "Scuttle", "Bite", "Bite", "Guard", "Bite"], ["Scuttle", "Bite", "Guard", "Bite", "Scuttle", "Bite"], ["Bite", "Guard", "Scuttle", "Bite", "Guard", "Scuttle"]]

## Ash Scavenger [scavenger]

Scuttle 2 (Movement: 3), Bite 1, Guard 1. Support can Mend 1 within 2.

HP: determined by the spawning encounter; see its boss/summon rules.

Ordinary-creature-profile dice: [["Scuttle", "Scuttle", "Bite", "Bite", "Guard", "Bite"], ["Scuttle", "Bite", "Guard", "Bite", "Scuttle", "Bite"], ["Bite", "Guard", "Scuttle", "Bite", "Guard", "Scuttle"]]

## Support Creature [support_creature]

Scuttle 2 (Movement: 3), Bite 1, Guard 1. Support can Mend 1 within 2.

HP: 2

Ordinary-creature-profile dice: [["Mend", "Mend", "Guard", "Scuttle", "Bite", "Mend"], ["Mend", "Guard", "Bite", "Scuttle", "Mend", "Guard"], ["Bite", "Mend", "Scuttle", "Guard", "Mend", "Guard"]]

## The Hollow — action dice and upgrades

[["Advance", "Ashen Chain", "Smoking Strike", "Smoking Strike", "Brace", "Drive Back"], ["Skirmish", "Cinder Brand", "Smoking Strike", "Sweep", "Grave Tithe", "Distort"], ["Advance", "Skirmish", "Cinder Brand", "Sweep", "Drive Back", "Fracture"]]

### Advance

Targeting: Highest HP. Move up to 2 toward the focus hero. Already adjacent: gain 1 Block. No legal route: +1 Block.

Phase upgrade: Movement +1; adjacent Block +1.

### Ashen Chain

Targeting: Furthest hero. Reach 3 · pull up to 1 cells · strip 1 Block. No HP damage.

Phase upgrade: Also applies Rooted 1 until next boss turn.

### Smoking Strike

Targeting: Lowest HP. 1 damage · reach 1. Leave fire under the target. Existing fire detonates for 2 extra damage; ending a hero turn on fire deals 1.

Phase upgrade: Fire detonation damage +1.

### Skirmish

Targeting: Closest hero. Move up to 1, then attack for 1 in reach 1. Recheck targets after moving; if nobody is in reach, no attack.

Phase upgrade: Movement +1.

### Sweep

Targeting: All heroes in reach 1. 1 damage to EVERY hero in reach 1, including Downed heroes. Reactions apply.

Phase upgrade: Reach +1; damage +1 (each hero once).

### Brace

Targeting: Self. +1 Block to self. Expires at next boss turn.

Phase upgrade: Block +1; Die I instead becomes Furnace Roar.

### Drive Back

Targeting: Most Block. 1 damage · reach 1, then force the target away. Collision can cause damage and Stun. Reactions apply.

Phase upgrade: Push distance +1.

### Distort

Targeting: Most active buffs. Reach 2 · Weakness 1 until the next boss turn. No immediate HP damage.

Phase upgrade: Weakness +1.

### Fracture

Targeting: Most active buffs. Reach 1 · target chooses 1 installed ability side(s) to become Blank this encounter. Recorded results stay unchanged.

Phase upgrade: Reach +1; destruction count stays the same.

### Cinder Brand

Targeting: Most enemy HP damage last round. Reach 3 · mark tiles around the target. At next boss turn start, units still on marked tiles take 2 damage. Move away to evade.

Phase upgrade: New warnings become 3×3 squares; detonation damage +1. Already armed cells keep their marked area.

### Grave Tithe

Targeting: All heroes in reach 2. Reach 2 · remove 1 Block from every standing hero. Gain stolen Block up to 2. No HP damage.

Phase upgrade: Steal +1 Block per hero; gain cap +1.

### Furnace Roar

Targeting: All heroes in reach 2. 1 damage to all standing enemies in reach 2, then push survivors up to 1. Reactions apply.

Phase upgrade: Unlocks; reach +1 over its base test value.

## Nu’gh — action dice and upgrades

[["Birth Cry", "Brood Command", "Burrow", "Brood Command", "Gnashing Maw", "Brood Guard"], ["Brood Command", "Brood Command", "Birth Cry", "Burrow", "Gnashing Maw", "Devour Brood"], ["Brood Command", "Birth Cry", "Burrow", "Brood Command", "Devour Brood", "Brood Guard"]]

### Birth Cry

Targeting: Empty nearby cells. Summon 1 worms on empty cells within 2; cap 4 living, 1 HP each. Never on heroes, the boss or other worms.

Phase upgrade: Summon +1 worm(s); Soul Link switches OFF permanently.

### Brood Command

Targeting: All living worms. Each worm: move up to 2 toward a standing hero, then bite if adjacent.

Die: 1, 1, 0, 0, 0, 0. HP loss applies Poison 1 (next activation: damage equal to total Poison, then reduce by 1; applications stack). Reactions apply.

No worms: summon 2 instead. New worms can act after Nu’gh.

Phase upgrade: Worm movement +1; empty-brood summon +1.

### Gnashing Maw

Targeting: Lowest HP. Lowest-HP hero (closest legal fallback) within 1: 1 base + 1 brood pressure damage. No target: RETREAT 1 or gain 1 Block if cornered.

Phase upgrade: Reach +1; brood pressure cap +1.

### Burrow

Targeting: Self. RETREAT up to 1 cells to maximize distance from the nearest hero. No safer route: +1 Block.

Phase upgrade: Retreat +1 and leave 1 worm(s).

### Brood Guard

Targeting: Self. Gain 1 Block + one per living worm, bonus capped at 0.

Phase upgrade: Shield one worm with 1 non-stacking Block.

### Devour Brood

Targeting: Closest living worm. Consume the nearest worm (no Soul Link); heal 1 HP. No worms: summon 2.

Phase upgrade: Gain 1 Block.

## Veyl, the Brass Cantor — action dice and upgrades

[["Gathering Note", "Gathering Note", "Tuning Fork", "Seal the Bell", "Hushed Chime", "Crescendo"], ["Hushed Chime", "Tuning Fork", "Toll of Reckoning", "Seal the Bell", "Gathering Note", "Hushed Chime"], ["Toll of Reckoning", "Hushed Chime", "Tuning Fork", "Toll of Reckoning", "Seal the Bell", "Crescendo"]]

### Gathering Note

Targeting: Self. Gain 2 Resonance, up to 6. No immediate damage. Your own-turn Skills and Defenses calm it before the next boss turn.

Phase upgrade: Resonance gain +1.

### Crescendo

Targeting: Self. Gain 2 Resonance and OPEN THE CORE until next boss turn. Hero Attacks against Veyl gain +1 per hit before Block. Burst now or calm the next Toll.

Phase upgrade: Resonance gain +1; exposed-core Attack bonus +1.

### Seal the Bell

Targeting: Self. Gain 2 Block. Old Block expires next boss turn; this does not close an open core.

Phase upgrade: Block +1.

### Toll of Reckoning

Targeting: All heroes in reach 3. Attack EVERY standing hero within 3 for 1 NOW: 1 base + 1 per 2 Resonance. Spend the entire meter when declared. Reactions apply; the declared hit is fixed. No targets: fallback, keep meter.

Phase upgrade: Reach +1.

### Hushed Chime

Targeting: Most active buffs. Most-buffed hero (closest legal fallback) within 3: 1 damage NOW (1 base + 1 per 3 Resonance). Spend up to 2 Resonance when declared. No target: fallback, keep meter.

Phase upgrade: Reach +1.

### Tuning Fork

Targeting: Furthest hero. Advance up to 1, then attack within 1 for 1. Reactions apply. No reachable target: fallback advance / Block.

Phase upgrade: Movement +1.

## Iron Warden — action dice and upgrades

[["Iron Advance", "Shield Bash", "Iron Advance", "Hammerfall", "Raise Guard", "Crushing Sweep"], ["Shield Bash", "Driving Blow", "Iron Advance", "Raise Guard", "Crushing Sweep", "Raise Guard"], ["Driving Blow", "Shield Bash", "Crushing Sweep", "Iron Advance", "Crushing Sweep", "Raise Guard"]]

### Iron Advance

Targeting: Highest HP. Advance up to 1 toward the party. Occupied tiles block the full 2×2 footprint.

Phase upgrade: Move +1.

### Shield Bash

Targeting: Most Block. Most-Block hero (closest legal fallback) within 1: 1 normal damage. Fully preventing HP loss with Block / Damage Reduction breaks Bulwark and removes his Block. Reactions apply.

Phase upgrade: Damage +1.

### Hammerfall

Targeting: All heroes in reach 1. Attack each opponent within 1 for 2 normal damage. Spread out or guard. One fully defended hero hit breaks Bulwark. Reactions apply.

Phase upgrade: Area reach +1.

### Raise Guard

Targeting: Self. Gain 1 Block. Does not restore a broken Bulwark before his next turn.

Phase upgrade: Block +1; cannot restore Bulwark early.

### Crushing Sweep

Targeting: Marked tiles. Marked cells take 1 damage before his next three dice. The warning is fixed: move a threatened hero out to break Bulwark, or fully guard the impact. Reactions apply; movement Reactions can escape. After every boss turn a sweep is armed if none is already marked. Future warning reach 1.

Phase upgrade: Future warning reach +1; damage +1. Existing warnings do not expand.

### Driving Blow

Targeting: Highest HP. Highest-HP hero (closest legal fallback) within 1: 1 damage. A hero who loses HP is pushed up to 1; occupied cells stop the push. Fully guarding prevents the push and breaks Bulwark.

Phase upgrade: Damage +1; HP-hit push +1.

## Trial special actions

Shield Line: grant up to 2 Block to self and adjacent living enemy allies within 1. This ability will not raise the recipient above 3 Block; it does not remove pre-existing higher Block.

Restitch: heal one living wounded enemy ally within 3 for up to 2 HP, prioritizing most missing HP. Each Mender can use Restitch once per enemy turn.

Mark Charge: focus the furthest hero and mark a fixed cardinal lane of up to 5 tiles, stopping at board edges/barricades. The lane remains fixed. At the next enemy turn start, a living Ram attacks eligible victims still on that lane for 3 normal damage, with Reactions. Killing the source cancels its unresolved charge; empty lanes miss. Repeated marks from that source do not replace the pending lane.

Pilfer: with a legal hero within 2 and carried Run Essence available, take 1 from the Trial purse and store it as that thief's loot. No HP damage. Killing the thief recovers its loot; escaping loses it.

Flee: move up to 2 toward an arena edge away from pursuers. A thief reaching the edge with loot escapes with it. Without loot, it pursues a hero instead.

Needle: ranged attack with the role's ordinary range/line-of-sight checks. Scuttle, Bite, Bash and Guard use the source family/role model. Spirit objectives alter the listed attack/pursuit priorities: spirit first if reachable, otherwise hero fallback.

## Trial terrain and objective objects

Cover reduces normal enemy ranged damage by 1 when the source is farther than 1 and the victim occupies cover. It does not reduce unavoidable damage, melee or Poison.

Barricades block movement and sight. A hero can spend an adjacent Attack result to break one and open that cell. They are not ordinary enemies or free weapon-condition damage. No invented barricade HP counter is added.

Spikes deal 1 unavoidable damage when a living unit lands on a spike cell, including after forced movement. Remaining on that cell does not cause additional periodic ticks.

Ritual stones, the protected spirit and the Trial Hollow core are objects with their specified HP/objective rules. They are not extra enemy turns, ordinary harvest targets or hostile worm ownership entries. Poison/forced movement and enemy-damage conditions must follow the object restrictions.


# Equipment and construction data

These are the current shared equipment definitions. Body and Weapon limits are total counts across the three dice; Soul Blank minima apply to each die.

## Bodies

### Broken Body

Defense 0–3 · Movement 0–3 · Skill 0–3 across all three dice. Attack limits come from your Weapon.

limits: {"Defense": [0, 3], "Movement": [0, 3], "Skill": [0, 3]}

### Fleet Body

Defense 0–2 · Movement 0–4 · Skill 0–3 across all three dice. Movement uses its printed distance. Attack limits come from your Weapon.

limits: {"Defense": [0, 2], "Movement": [0, 4], "Skill": [0, 3]}

### Stone Body

Defense 0–4 · Movement 0–2 · Skill 0–3 across all three dice. Attack limits come from your Weapon.

limits: {"Defense": [0, 4], "Movement": [0, 2], "Skill": [0, 3]}

## Souls

### No Soul

6 HP · minimum 2 Blanks on every die. No strong Soul effect.

blanks: 2; hp: 6

### Ash Road Soul

6 HP · minimum 3 Blanks per die. Last Ember: once per encounter, lethal enemy damage leaves you at 1 HP.

blanks: 3; hp: 6

### Beginning Soul

6 HP · minimum 2 Blanks on every die. Last Ember: once per encounter, lethal enemy damage leaves you at 1 HP. Does not prevent voluntary HP costs.

blanks: 2; hp: 6

### Warden Soul

6 HP · minimum 3 Blanks per die. Keep up to 2 Block at own-turn start. Movement abilities travel 1 less, minimum 1.

blanks: 3; hp: 6

### Echo Soul

6 HP · minimum 3 Blanks per die. First Skill each own turn readies +1 next-Attack damage. Begin with 0 Action Rerolls.

blanks: 3; hp: 6

### Cinder Soul

6 HP · minimum 3 Blanks per die. Your first HP-damaging Attack each own turn adds Poison 1. Begin each encounter with Poison 1.

blanks: 3; hp: 6

### Brood Soul

5 HP · minimum 3 Blanks per die. First Poison you apply each own turn spreads Poison 1 to another adjacent enemy.

blanks: 3; hp: 5

### Soulcaster

6 HP · minimum 4 Blanks on every die. Gather Soul Charges or Manifest encounter spells using rolled Blanks. Charge cap 3; spell cap 4. Manifest costs charges + 1 HP. New spells activate only when rolled on a later turn.

blanks: 4; hp: 6

## Weapons

### Unarmed

Attack faces: minimum 0 / maximum 0. Equip a Weapon to use Attack faces.

max: 0; min: 0; modifiers: {}; replacements: []

### Dagger

Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poke (1 damage after earlier enemy HP damage). All-Attack passive: none.

max: 5; min: 2; modifiers: {}; replacements: [81]

### Hammer

Attack faces: minimum 2 / maximum 8. Replace 1 basic Strike → Crack (remove 2 adjacent Block after another Attack). All-Attack passive: none.

max: 8; min: 2; modifiers: {}; replacements: [74]

### Heavy Dagger

Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Heavy Poke (2 damage, then pay 1 HP). All-Attack passive: none.

max: 6; min: 2; modifiers: {}; replacements: [83]

### Oathblade

Attack faces: minimum 3 / maximum 6. Replace 3 basic Strikes → Oath Cut (1 adjacent damage each). Passive: ALL your Attack faces gain Pierce 1, including other equipped Attacks. Replacements spend rolled dice.

max: 6; min: 3; modifiers: {"pierce": 1}; replacements: [84, 84, 84]

### Spear

Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Jab (range 2; move 2 first). All-Attack passive: none.

max: 6; min: 2; modifiers: {}; replacements: [73]

### Poison Dagger

Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poison Poke (1 damage; HP loss adds Poison 1). All-Attack passive: none.

max: 5; min: 2; modifiers: {}; replacements: [82]

## Memories

### Memory of the First Step

Spend one rolled Blank as Move 1, once per own turn. The installed side remains Blank.

distance: 1; mode: move

### Glasswing Memory

Spend one rolled Blank to blink up to 2 orthogonal spaces, once per own turn. Landing must be empty; Rooted prevents this.

distance: 2; mode: blink

### Memory of Hearth

Spend one rolled Blank to heal yourself 1 HP, once per own turn. Cannot revive yourself.

distance: 0; mode: heal

### Ironbound Memory

Spend one rolled Blank to gain 2 Block, once per own turn.

distance: 0; mode: block

### Memory of the Mire

Spend one rolled Blank to heal yourself 1 HP, once per own turn. Cannot revive yourself.

distance: 0; mode: heal

### Memory of Wind

Spend one rolled Blank as Move 2, once per own turn.

distance: 2; mode: move

## Additional Trial Memories

### No Memory

Empty for the first encounter. Equip an earned Memory later for a passive effect.

### Memory of the First Step

Spend one rolled Blank as Move 1, once per own turn. The installed side remains Blank.

### Glasswing Memory

Spend one rolled Blank to blink up to 2 orthogonal spaces, once per own turn. Landing must be empty; Rooted prevents this.

### Memory of Guard

When Block prevents all HP damage from an enemy Attack, your next Attack against an enemy deals +1 damage.

### Memory of Hearth

Spend one rolled Blank to heal yourself 1 HP, once per own turn. Cannot revive yourself.

### Ironbound Memory

Spend one rolled Blank to gain 2 Block, once per own turn.

### Memory of the Mire

Spend one rolled Blank to heal yourself 1 HP, once per own turn. Cannot revive yourself.

### Memory of Shelter

Your first own-turn Defense ability grants 1 extra Block.

### Memory of Momentum

Move at least 2 spaces during your turn: your next Attack against an enemy deals +1 damage, once that turn.

### Memory of Venom

Your first own-turn Attack that damages an enemy adds Poison 1. Healing you receive restores 1 less HP.

### Memory of Wind

Spend one rolled Blank as Move 2, once per own turn.


# Progression and encounter data

Exact recipes and source data are exported here; effect timing and restrictions remain in the full rules and model.

## Normal Essence types

### Bone Creature [bone_creature]

**condition**: regular

**faces**: [60, 61, 62]

**hp**: 3

**rank**: normal

### Bu’gh, the Iron Warden [bugh]

**condition**: regular

**faces**: []

**rank**: boss

### Veyl, the Brass Cantor [cantor]

**condition**: regular

**faces**: []

**rank**: boss

### Cinder Mite [cinder_mite]

**condition**: regular

**faces**: []

**rank**: normal

### Glasswing Moth [glasswing_moth]

**condition**: regular

**faces**: []

**hp**: 3

**rank**: normal

### The Hollow [hollow]

**condition**: regular

**faces**: []

**rank**: boss

### Iron Husk [iron_husk]

**condition**: regular

**faces**: []

**hp**: 5

**rank**: normal

### Mire Leech [mire_leech]

**condition**: regular

**faces**: []

**hp**: 4

**rank**: normal

### Movement Creature [movement_creature]

**condition**: regular

**faces**: [66, 67, 68]

**hp**: 3

**rank**: normal

### Nu’gh [nugh]

**condition**: regular

**faces**: []

**rank**: boss

### Screaming Worm [nugh_worm]

**condition**: regular

**faces**: []

**rank**: normal

### Ash Scavenger [scavenger]

**condition**: regular

**faces**: []

**rank**: normal

### Support Creature [support_creature]

**condition**: regular

**faces**: [63, 64, 65]

**hp**: 2

**rank**: normal

## Normal recipes

### bone_growth [bone_growth]

**category**: Skill Face · Bone

**cost**: 1

**enemy**: bone_creature

**face**: 60

### bone_guard [bone_guard]

**category**: Defense Face · Bone

**cost**: 3

**enemy**: bone_creature

**face**: 62

### bone_strike [bone_strike]

**category**: Attack Face · Bone

**cost**: 2

**enemy**: bone_creature

**face**: 61

### brood_needle [brood_needle]

**category**: Attack Face

**cost**: 2

**enemy**: nugh

**face**: 70

### ember_cut [ember_cut]

**category**: Attack Face

**cost**: 2

**enemy**: hollow

**face**: 69

### evasive [evasive]

**category**: Defense Face · Reaction

**cost**: 3

**enemy**: movement_creature

**face**: 68

### Glasswing Memory [glasswing_soul]

**category**: Memory

**cost**: 3

**effect**: Spend one rolled Blank to blink up to 2 orthogonal spaces, once per own turn. Landing must be empty; Rooted prevents this.

**enemy**: glasswing_moth

**memory**: glasswing

### iron_shelter [iron_shelter]

**category**: Defense Face

**cost**: 2

**enemy**: bugh

**face**: 72

### Ironbound Memory [iron_soul]

**category**: Memory

**cost**: 3

**effect**: Spend one rolled Blank to gain 2 Block, once per own turn.

**enemy**: iron_husk

**memory**: ironbound

### Memory of the Brood [memory_brood]

**category**: Memory

**cost**: 3

**effect**: Your first Poison application each own turn adds 1 extra Poison. Your friendly Nu’gh counts.

**enemy**: nugh

### Memory of Embers [memory_embers]

**category**: Memory

**cost**: 3

**effect**: Your first actual enemy HP damage each own turn grants 1 Block.

**enemy**: hollow

### Memory of the First Step [memory_first_step]

**category**: Memory

**cost**: 1

**effect**: Spend one rolled Blank as Move 1, once per own turn. The installed side remains Blank.

**enemy**: movement_creature

**memory**: first_step

### Memory of Iron [memory_iron]

**category**: Memory

**cost**: 3

**effect**: The first Defense you resolve each own turn grants 1 extra Block.

**enemy**: bugh

### Memory of Loss [memory_loss]

**category**: Memory

**cost**: 4

**effect**: Healing abilities gain +1 range except Self/Adjacent. The first actual self-heal each combat restores 1 extra HP.

**enemy**: support_creature

### Memory of Silence [memory_silence]

**category**: Memory

**cost**: 3

**effect**: The first Skill you resolve each own turn grants 1 Block.

**enemy**: cantor

### Memory of the Mire [mire_soul]

**category**: Memory

**cost**: 3

**effect**: Spend one rolled Blank to heal yourself 1 HP, once per own turn. Cannot revive yourself.

**enemy**: mire_leech

**memory**: mire

### momentum [momentum]

**category**: Attack Face

**cost**: 2

**enemy**: movement_creature

**face**: 67

### quiet_note [quiet_note]

**category**: Skill Face

**cost**: 2

**enemy**: cantor

**face**: 71

### retreat [retreat]

**category**: Movement Face

**cost**: 1

**enemy**: movement_creature

**face**: 66

### shared_burden [shared_burden]

**category**: Skill Face · Copy

**cost**: 3

**enemy**: support_creature

**face**: 65

### shared_remedy [shared_remedy]

**category**: Skill Face · Healing

**cost**: 1

**enemy**: support_creature

**face**: 63

### sorrow [sorrow]

**category**: Skill Face

**cost**: 2

**enemy**: support_creature

**face**: 64

### Oathblade [weapon_oathblade]

**category**: Weapon

**cost**: 4

**effect**: Attack faces: minimum 3 / maximum 6. Replace 3 basic Strikes → Oath Cut (1 adjacent damage each). Passive: ALL your Attack faces gain Pierce 1, including other equipped Attacks. Replacements spend rolled dice.

**enemy**: bugh

**weapon**: oathblade

## Trial Forge ingredients

### Cinder Essence [cinder]

**source**: The Long Charge; Break the Ritual

### Hollow Essence [hollow]

**source**: The Hollow, final Trial boss

### Shade Essence [shade]

**source**: Essence Thieves

### Ward Essence [ward]

**source**: Ward & Whisper; Protect the Spirit

## Trial Forge recipes

### Fleet Body [fleet]

**cost**: {"cinder": 3}

**item**: fleet

**slot**: body

### Memory of Hearth [hearth_soul]

**cost**: {"ward": 3}

**item**: hearth

**slot**: memory

### Heavy Dagger [heavy]

**cost**: {"cinder": 2, "hollow": 1}

**item**: heavy

**slot**: weapon

### Oathblade [oathblade]

**cost**: {"hollow": 2, "ward": 4}

**item**: oathblade

**slot**: weapon

### Memory of Shelter [shelter_memory]

**cost**: {"ward": 2}

**item**: shelter

**slot**: memory

### Stone Body [stone]

**cost**: {"ward": 3}

**item**: stone

**slot**: body

### Poison Dagger [venom]

**cost**: {"shade": 2}

**item**: venom

**slot**: weapon

### Memory of Wind [wind_soul]

**cost**: {"cinder": 3}

**item**: wind

**slot**: memory

## Trial objectives

### Break the Ritual [ritual]

**text**: Break all three violet ritual stones (2 HP each). Any Attack can damage them; they cannot move or receive Poison. Enemies retreat when all three break. Clearing only the creatures does not complete this objective. Victory: +3 Run Essence and 2 Cinder Essence.

### Protect the Spirit [spirit]

**text**: Keep the blue spirit (5 HP) alive through three enemy turns, or defeat all its attackers sooner. Enemies prefer the spirit when their ability can reach it; otherwise they target a hero. First Aid can heal it. Shield Wall and Taunt can protect it. Its death ends this Trial. Victory: +3 Run Essence and 2 Ward Essence.

## Trial enemy roles

### Glasswing Sentry [archer]

**dice**: [["Needle", "Scuttle", "Needle", "Guard", "Needle", "Scuttle"], ["Scuttle", "Needle", "Guard", "Needle", "Scuttle", "Needle"], ["Needle", "Guard", "Scuttle", "Needle", "Guard", "Scuttle"]]

**hp**: 2

**type**: glasswing_moth

### Whisper Mender [healer]

**dice**: [["Restitch", "Restitch", "Scuttle", "Guard", "Bite", "Restitch"], ["Restitch", "Guard", "Bite", "Scuttle", "Restitch", "Guard"], ["Bite", "Restitch", "Scuttle", "Guard", "Restitch", "Guard"]]

**hp**: 3

**type**: support_creature

### Cinder Ram [ram]

**dice**: [["Mark Charge", "Mark Charge", "Scuttle", "Bash", "Guard", "Mark Charge"], ["Scuttle", "Bash", "Guard", "Scuttle", "Bash", "Guard"], ["Bash", "Guard", "Scuttle", "Bash", "Guard", "Scuttle"]]

**hp**: 6

**type**: bone_creature

### Ash Shieldbearer [shield]

**dice**: [["Shield Line", "Scuttle", "Bash", "Shield Line", "Guard", "Bash"], ["Shield Line", "Bash", "Scuttle", "Guard", "Shield Line", "Bash"], ["Bash", "Guard", "Shield Line", "Scuttle", "Bash", "Guard"]]

**hp**: 4

**type**: iron_husk

### Essence Cutpurse [thief]

**dice**: [["Scuttle", "Pilfer", "Pilfer", "Bite", "Flee", "Scuttle"], ["Pilfer", "Pilfer", "Flee", "Bite", "Scuttle", "Pilfer"], ["Flee", "Bite", "Pilfer", "Flee", "Scuttle", "Flee"]]

**hp**: 4

**type**: movement_creature
