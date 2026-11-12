# Ash & Oath — Current Rules v0.38

Prepared 12 November 2026. Default Tuned profile, no custom overrides.


## 1. Start here

Current playable rules for Ash & Oath v0.38. Prepared 12 November 2026. This is a consolidated rulebook, not a change log.

### Which rules does this document describe?

The browser prototype using Tuned numbers, with no custom numeric overrides. Optional Blank movement is described separately. The supplied draft documents inspired the game; this document describes the implemented prototype, including its declared interpretations. Older patch notes are historical.

### Playing on a phone

Choose Mobile mode on the main menu; small touch screens open it automatically unless a different preference was saved. Tap an ability name, then a highlighted board target; use Use for immediate effects. Details explains the selected ability. Three colored ability buttons, Reroll and End turn stay on screen with no combat-controls scrolling. More opens secondary actions. Tap a party status button for its effects. Turn the phone sideways to place controls beside the board. Reactions and other mandatory choices use scrollable panels. Full log contains Summary and Extensive tabs. Use Desktop mode in the menu or Options to switch back. Both layouts use the same rules and local rewards. Browser saves do not automatically transfer between devices.

### Your goal

Control Vesper, Rook and Wren against one chosen boss. Defeat the boss to win. If all three heroes are dead or at zero HP together, the fight ends in defeat. Against Nu’gh, defeating the summoner also removes his remaining worms.

### Before entering the arena

The main menu opens first. Build your party, visit Camp, or select a direct creature encounter. Choose two different bonus faces for each hero from the full 48-face bonus pool. These are faces, not whole dice. Click to quick-equip or drag them onto a die or exact slot. Each hero has a separate build and separate ownership limits. After all choices, the review screen lets you choose The Hollow, Nu’gh, Veyl or the optional fourth boss Bu’gh, Tuned or Original numbers, and Blank movement OFF, Move 1 or Move 2. Check the displayed party and rules, then Enter fight.

### Default starting values

Each hero starts at 6 HP, 0 Block and 1 banked Action Reroll. The reroll bank cap is 1. The Hollow starts at 12 HP; Nu’gh starts at 10 HP with two 1-HP worms. Veyl, the Brass Cantor starts at 14 HP with 0 Resonance. Bu’gh, the Iron Warden starts at 12 HP with Bulwark reducing normal incoming damage by 1; these values are provisional. The arena is a 9×9 grid. Each hero has three six-sided Action Dice. The boss occupies a 2×2 footprint.

### Where to look during play

The header names the active hero or boss and shows the round and boss intents. Hover an ability or boss intent to read its effect in the side panel; move away to restore the log. Clicking selects the ability without pinning its window. You may move onto the details to scroll them; the battlefield stays visible. Effects explains active buffs and durations. Hover a unit for its state. View dice shows every installed side, the current recorded result, and encounter mutations. Open the boss upgrade guide before or after the half-HP threshold. Full history provides detailed event ordering.

## 1A. Reading a battle in v0.38

Enemy intents and face-up choices now use dedicated panels on desktop and phones.

### Targeting priorities

Enemy intents lists each living enemy and each currently rolled ability, its current named target, priority, range and effect. Smoking Strike, Gnashing Maw and ordinary Bite prefer lowest HP. Driving Blow and Advance prefer highest HP. Shield Bash, Driving Back and Iron Husk Bash prefer most Block. Ashen Chain and Tuning Fork focus the furthest hero. Distort, Fracture and Hushed Chime prefer heroes with the most active buffs. Venom Bite prefers heroes with the most active debuffs. Cinder Brand and Needle prefer the hero who dealt the most actual enemy HP damage in the previous round, including credited friendly summon/Poison damage. Skirmish, Scuttle and worm pursuit prefer closest. Self, area, allied healing, summons and marked tile effects state their actual target type.

### Range, ties and live forecasts

Prefer a top-ranked hero who is currently legal. If none of the preferred heroes can be targeted, use the closest legal target. Random ties use a seed created by the shared round roll, so opening or redrawing the panel never consumes randomness or changes a tie. Forecasts update when HP, positions, statuses or eligibility change. Movement abilities show their pursuit focus; attacks recheck legal range after moving. Reactions can force a new legal target. No legal target retains each ability’s existing fallback or hold behavior. Area attacks hit everyone specified, not one preferred hero.

### Support healing

Mend restores 1 HP to the living ally with the most missing HP in reach 2. Equal injuries use the same stable round-seeded tie system. No wounded ally means no healing.

### Face-up picker and colors

Copy and ally-die choices show only the nine current rolled hero results, with ability names and category/spent colors, a preview and a separate Use confirmation. Borrow Shape can still copy spent and held results; eligibility follows the specific ability. Abilities that explicitly install, bind or convert an installed side still expose the required installed slots. Attack red; Defense blue; Movement yellow; Blank light gray; Skill purple. Spent dice turn dark gray; held Reactions and Channels remain distinct.

### Feedback and Engrave

Actual Poison HP loss, positive healing and new Stun have distinct effects and SFX, controlled by SFX volume and mute. Poison ticks reduce HP and stacks immediately, play a distinct sound and briefly tint the unit; no damage text or acknowledgement window appears. Every living poisoned unit carries persistent green smoke until Poison clears. Healing and Stun retain their own cues. Engrave displays the updated six installed sides after growth and explains a failed trigger. It still requires actual HP damage, fills a Blank on the same die, obeys growth/copy caps and lasts only for this encounter. A recorded Blank does not retroactively become Engrave; the new side can be rolled later.

### Essence planning

Read exact recipe names and effects before spending. The Forge shows banked Essence, price and missing amount. Face copies are physical shared party copies: owned minus equipped equals free. Crafting adds ownership; Refit equips it. Bound Souls belong to their selected hero; Memory of Loss remains one shared item. Prices, bank contents, recipe effects and old owned inventory are unchanged.

## 2. Dice construction and ownership

Limits apply to each hero individually. Do not confuse limits per die with limits across the hero’s three dice.

### Six sides; at least two Blanks per die

Each of the three dice has exactly six sides. Each die must start with at least two Blanks, leaving at most four equipped abilities. A Red Tile is a penalty face, not a Blank. There is no additional per-die category cap in the current implementation.

### Category caps across all three dice

A hero may equip at most 3 Movement faces, 3 Defense faces and 3 Skill faces in total across all three dice. Attack faces have no separate category cap, but ownership, six-side construction and minimum Blanks still restrict them. Extra Attack designs do not grant unlimited copies.

### Owned starting faces per hero

Strike ×4; Step ×2; Stride ×1; Guard ×2; Reaction ×1; Focus ×1; First Aid ×1; Shove ×1. Each of the hero’s two selected bonus designs adds one owned copy. Shove is available to build with, but is not installed in the default layout below.

### Default layout before bonus placement

Die I: Strike / Step / Guard / Strike / Blank / Blank. Die II: Strike / Stride / Reaction / Step / Blank / Blank. Die III: Strike / First Aid / Focus / Guard / Blank / Blank. Equipping bonus faces replaces existing sides as necessary to keep the build legal; inspect the final nets before entering.

### Changes during a fight

Generated faces, Engrave growth and other explicit mutations can change dice during combat; the opening construction validator is not reapplied to these effects. Mutations are for this encounter. A recorded result can remain usable even if its installed side later changes, unless the effect explicitly removes a held result. View dice distinguishes the installed side from the recorded roll. Rebuilding/retrying restores the recorded starting build.

## 3. Round and turn sequence

A round is one circuit of the initiative order. A turn is one hero’s or the boss’s activation. Dice roll together at round start, not at every normal hero turn.

### A. Set initiative once

At encounter start, each hero and the boss rolls initiative from 1 to 6. Higher goes first. The boss wins an initiative tie with a hero; hero ties use Vesper, then Rook, then Wren. This order stays fixed, except a temporary Break Rhythm delay that resets next round.

### B. Begin the shared round

Clear the previous round’s stored Reactions and Mark Prey. If a hero is still Stunned, choose a die to set aside before rolling; an actively Channeling die cannot be chosen. Roll each available Action Die once for all heroes and the boss. Held Channel dice do not roll. Reaction results automatically become held Reactions. When-rolled effects such as Clairvoyance trigger now.

### C. Start a hero turn

First, Poison triggers if present: lose its value as unavoidable HP damage and reduce Poison by 1. If this Downs the hero, skip their normal turn. Expired temporary defenses clear, and ordinary old Block disappears. Stonewake is the exception that can preserve Block. Resolve an unused Echo of Pain penalty if due. Debt’s deferred penalty becomes active; the hero’s Lethargic Bind expires. Refresh that hero’s Blank-conversion allowance and Engrave growth allowance. If a Channel is active, choose Maintain or End before normal actions.

### D. Reroll when desired

By default a banked Action Reroll is allowed at any point during the active hero’s turn on a ready die or held Reaction. Options → Action Rerolls switches to Opening only for comparison. It costs 1 charge. You keep the new result, even if it is another Blank or the same face. A reroll does not itself close the opening window. In Opening only mode, resolving or declining an ordinary face closes it. Spent dice and Channels cannot be refreshed; pending choices and forced results must finish first. Focus is a separate ability, explained in section 4.

### E. Resolve hero dice

Use ready immediate results in any order. Select a die, then click a legal board target or destination; use Resolve for untargeted effects. A legal resolution spends that die. Invalid targets spend nothing. Finish any pending choice or forced result before taking another ordinary action. You may end the turn with immediate dice unused; stored Reactions can still respond afterward, until the next shared roll.

### Numeric feedback

Numeric abilities show a rotating projected 3D cube using the model-recorded side and value. Animation never rolls again or changes randomness. Ordinary Action Dice remain instant. Stored Numeric values are explicitly labelled as stored rather than new rolls. Gambler shows its multiplier and additional base roll.

### F. End a hero turn

Clear the hero’s Stunned state and unused turn-only boosts. If Black Oath is armed, pay its 1 unavoidable HP cost only if Block remains. Downed protection for all heroes ends when this full turn ends. Then the owner’s living friendly Nu’gh activates: resolve its Poison, move up to two orthogonal steps toward enemies and bite the closest enemy within one. This is additional to any Command activation. Process queued recovery turns, then continue the initiative order.

### G. Take the boss turn

At boss turn start, The Hollow expires Chain’s Rooted and Distort and detonates armed Cinder Brand cells; then old boss Block clears. Every boss first resolves its Poison as unavoidable HP loss and reduces it by 1. Nu’gh and Bu’gh clear old boss Block but have no Cinder Brand. Bu’gh restores Bulwark at its turn start, resolves any marked sweep before its three dice, and arms a sweep at turn end if none is already marked. Veyl closes any exposed core at boss turn start, then clears old Block; Resonance persists until changed by a face or spent by an attack. Resolve boss dice I → II → III. A Nu’gh Brood Command must finish all queued worms, including their Reactions, before the next boss die. Click Resolve end of turn after all three. Boss Weakness from Wither Ward expires at boss turn end. LAST ENEMY RESULT below the controls keeps fallback outcomes visible, including movement cells and Block gained.

### H. Start the next round

After the last initiative slot and any recovery turns, return to the round-start sequence. Unspent immediate results are replaced by the new shared roll. Reroll charges do not automatically refill.

## 4. Timing: actions, rerolls, Reactions and Channels

Category describes the effect family. Timing describes when it can happen. For example, Shield Wall is Defense – Reaction; Stonewake is Skill – Channel.

### Ordinary actions

Attack, Defense, Skill and Movement results usually resolve during their owner’s turn. They are spent once resolved or declined. A grey card may be spent, held as a Reaction, or held as a Channel: inspect its state label. Clicking a grey card still lets you read it.

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

## 5. Movement, targeting and damage

An ability’s own text takes precedence over these general procedures.

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

## 6. Status, Downed heroes and recovery

Read the duration on each source. “Until your next turn” is different from “until the next boss turn” or “until round end”.

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

Positive healing revives them and marks them Broken. At the end of the currently active full turn, the revived hero receives a fresh, immediate recovery turn with rerolled Action Dice. Their later normal slot in that round is replaced rather than added as a second turn. Their Blank-conversion allowance refreshes for recovery, but a starting reroll is not automatically restored.

### Broken and dead

Broken means the next fall to zero HP is lethal. Dead heroes cannot act or revive during the encounter. Physical die mutations remain through Downing/revival, while temporary combat statuses do not. Retry starts a clean encounter using the saved starting build and selected rules.

### The Hollow’s Original dice

Die 1: Advance, Advance, Smoking Strike, Smoking Strike, Brace, Drive Back | Die 2: Advance, Skirmish, Smoking Strike, Sweep, Brace, Distort | Die 3: Advance, Skirmish, Smoking Strike, Sweep, Drive Back, Fracture

## 7. Blank movement and custom rules

Optional movement is one explicit rule choice, separate from an ordinary Blank’s lack of effect.

### No equipped Soul and sandbox OFF

Without an equipped Soul or sandbox override, a rolled Action Die Blank has no normal effect. It can be spent without moving. It is not a free Numeric roll, a reroll charge, or a movement resource.

### Blank → Move 1 or Move 2

Beginning Soul is owned and equipped by new parties: spend one rolled Blank as Move 1, once per own turn. The earned Hollow and Ash Road Souls retain Move 2. Equipment is scoped to each hero. The separate sandbox override can test Move 1 / Move 2 using its configured allowance. Spend the Blank to move up to the equipped or overridden distance. It still stays Blank on the installed die. Other Blanks can be spent without movement. Rooted prevents the voluntary movement. A successful conversion consumes the allowance; an invalid move does not.

### Exactly when it resets

Reset at that hero’s next normal own turn or full recovery turn. The allowance is separate for each hero. A shared round roll, reroll, Focus, or toggling the Soul OFF and ON does not refresh it. The default is one conversion, not one per die and not one per entire combat.

### Original preset

Original changes the ordinary Numeric die to 1, 1, 1, 1, 0, 0 and The Hollow to 18 HP, Smoking Strike 2, Brace 2 and its older boss dice. It also enables 1 idle fallback Block. Construction, timing and most current systems remain in place: Original is a prototype preset, not a complete recreation of every supplied draft rule. Nu’gh and Veyl keep their own boss values; the preset can still affect shared hero Numeric values. Original disables the new end-of-turn fire burn by default; the Tuned profile enables it.

### Advanced numeric rules

Open Advanced numeric rules on review, or Menu → Game options → Balance workshop. Search and change values; Apply saves the profile and restarts the current fight/test. Saved local overrides take precedence over the selected preset and this document’s defaults. Reset all values and Apply to restore that preset’s defaults. JSON imports remain a draft until applied. Applying incompatible construction limits returns you to the forge.

### What is saved

Build presets store the three heroes’ legal layouts and bonus ownership; balance profiles store numeric overrides and a base preset. These do not save a campaign or a mid-fight checkpoint. Retry preserves your selected boss and reviewed fight settings. In-fight mutations reset for the fresh encounter.

## 8. Practice and prototype scope

Use the Ability Lab to test interactions without rebuilding a normal team.

### Practice tools

The guided tutorial introduces play; the Ability Lab can prepare individual abilities, combine a second face, force Numeric values, reroll prepared results, trigger test attacks, reset and copy a reproducible log. Lab fixture HP/Block differs from ordinary encounter defaults, and has its own numeric settings.

### Implemented limits

Encounter Gold is recorded; shared expedition Gold funds shrine offerings, but there is no shop. Conjure and Second Chance only support the listed immediate abilities and prevent copy/repeat loops. One Channel per hero is an explicit prototype limit. The four bosses remain selectable; an event precedes each attempt. Camp provides Essence crafting/refitting after encounters. This is not a full campaign economy. Generated Bone/Recovery and Red Tile are not normal bonus-pool offers.

### Reading an uncertain outcome

First inspect the exact face, active effects, reroll state and current dice net; then check Full history. A zero Numeric roll, blocked hit, same-result reroll, expired marker or closed opening window can be a legal outcome. The following catalog describes current default effects, including prototype interpretations.

## 8a. The Ash Road: events and earned rewards

On boss review, choose Expedition events. Every boss attempt passes through one event first. Choose the boss and rules, resolve an event, then enter that selected boss. Each rematch starts another event. This first version is not a campaign, settlement or shop.

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

### Soul Fragments preserve Blank progression

Spend exactly 3 Fragments through the events screen to bind the existing reward Soul to the chosen hero, once. Equip/swap that hero’s owned Souls at Camp; Souls cannot trade. This enables the default one rolled Blank per hero turn as Move 2; it grants no free movement or extra dice. Equip the earned Soul in Camp Equipment. Beginning Soul remains the weaker Move 1 starter. Manual Blank-movement overrides remain separate prototype options; custom numeric overrides still apply.

### Persistence, fresh fights and limitations

Gold, supplies, fragments, Soul unlock and event claim state save locally on this device/browser. They are not cloud accounts and clearing browser storage removes them. Active combat is not saved: reload during a monster encounter records interruption with no reward, and spent supplies stay spent. Boss encounters and event encounters each start fresh with full HP and starting dice. Event injuries and temporary mutations do not carry over; only earned inventory persists. Rewards are granted once when the outcome screen records a victory. Closing before the outcome is recorded cannot grant a reward. Exported Windows builds are unchanged. Balance and reward quantities are provisional.

## 8b. Combat feedback and navigation

The v0.38 development update changes Poison, Borrow Shape, reroll timing and the route into boss fights.

### Poison stacks and decays

Each application adds its amount: Poison 1 plus Poison 1 is Poison 2. On activation, deal unavoidable HP damage equal to the total, then reduce Poison by 1. Thus 2 deals 2, then next activation 1 deals 1, then it ends. Downing or death clears it. HP and Poison update immediately with sound and green feedback, without a damage popup. Exact changes remain in the log.

### Borrow Shape selects face-up results

Choose among all nine current rolled hero results, even spent dice and held Reactions. Copy onto the Borrow Shape die, leaving the source alone, then resolve the copied face next; a Reaction is held. Borrow Shape itself and locked Red Tile are excluded, preventing copy loops. It does not choose hidden installed sides.

### Reroll feedback and timing

Action Rerolls default to any time during the active hero’s turn. Options can select Opening only. One charge is consumed; unused and held Reaction dice can be rerolled, but spent or channelled dice cannot. Focus is separate and costs its Action Die, not a banked charge. Its new result resolves next or is held if a Reaction. The die animates and displays its new result without an acknowledgement window. The same ability can roll again. Exact old/new results remain in the battle log.

### Reaction is mitigation, not permanent HP

Default Reaction grants 2 Block before the hit. Incoming normal damage consumes Block first; a 2-damage hit can leave 0 Block while removing no HP. The reaction grant and damage breakdown are separate chronological entries. Workshop overrides still apply.

### Two battle log tabs

Summary omits explanatory info and turn guides. Extensive full log includes all recorded entries in chronological order, with no 2,000-entry truncation. The expanded view has the same tabs and can copy the complete log. Labels show round, sequence and event type; rolls, decisions, gains, mitigation, HP damage and expiry remain distinct.

### Restart and the event route

Options → Main menu restarts from first face selection and abandons active combat; earned inventory and audio settings remain. No inventory is erased. Every boss attempt, including rematches, requires an event first; safe event choices are still legal.

## 9. Starting abilities

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Blank · Blank

Beginning Soul: spend one rolled Blank as Move 1, once per own turn. Earned Souls grant Move 2. No equipped Soul: no ordinary effect. The separate sandbox can test Move 2 with 1 use(s).

### Strike · Attack

Deal 1 damage to an adjacent unit.

### Step · Movement

Move up to 1 orthogonal spaces. Occupied cells block the path.

### Stride · Movement

Move up to 3 spaces in a straight line. No turning or passing through units.

### Guard · Defense

Gain 1 Block. Unspent Block expires at your next turn.

### Reaction · Defense - Reaction

When personally attacked, gain 2 Block before the hit. No movement.

### Focus · Skill

Click another ready die or held Reaction to reroll it. Resolve its new result next, or decline it. Works after other actions. Uses this Focus face, not a reroll charge. Locked faces cannot be rerolled.

### First Aid · Skill

Heal yourself or an ally within 1 for 1 HP. A Downed ally revives as Broken.

### Shove · Skill

Push an adjacent unit up to 1 spaces away. No collision damage.

## 10. Bonus Skills

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Gambler's Coin · Skill

First use: arm Numeric ×0 / ×2. Next use: gain 1 Gold and turn this face Blank. Non-rerollable. Gold has no shop in this encounter.

### Weak Point · Skill

Arm Weak Point through the end of the next 1 round(s). Your next Attack from the boss’s southern edge repeats 1 extra time(s). The gold marker stays until used or expired. The repeat requires an Attack against the boss from its southern edge, not merely standing behind another enemy.

### Conjure · Skill

Copy another visible immediate hero ability within 99. Choose its hero and die, then resolve the copy. No setup or copy chains. Non-rerollable.

### Blessing of Recovery · Skill

Install Recovery on a chosen Blank belonging to a hero. Recovery heals a rolled value at range 1. After 2 placements, this face becomes Blank.

### Clairvoyance · Skill

When rolled, gain 1 Action Reroll, up to the bank cap of 1. A full bank gains nothing.

### Forgotten Strength · Skill

Your next rolled damage this turn gets +1.

### Passing Grace · Skill

Heal another hero within 3 for a rolled value. Move this face to a Blank on that hero. Cannot heal yourself. Non-rerollable. Passing Grace requires a recipient with a Blank; if no legal recipient slot exists, it does not destroy itself.

### Borrow Shape · Skill

Choose any of the nine face-up hero dice, including spent or held results. Copy its result onto this die and resolve it next (or hold its Reaction). The source die is unchanged. Borrow Shape and Red Tile are excluded to prevent loops and copying a locked penalty.

### Numeric Echo · Skill

Roll and store one ordinary value. Use it instead of your next Numeric roll. Only one value can be stored.

### Lethargic Bind · Skill

Bind a chosen boss die and face until your next turn. Each matching roll is skipped, but you take 1 normal damage.

### Restore · Skill

Heal another hero within 3 for a rolled value, at least 1. Clear sight required. Gambler ×0 stays zero.

### Focus Numeric · Skill

Your next Numeric roll this turn treats Blank as 1.

### Mark Prey · Skill

Mark the boss until round end. Its next damaging Attack hit while at zero Block gains 1 damage, then removes the mark.

### Last Word · Skill

After your other non-Blank dice are spent, deal 1 unavoidable damage to the boss.

### Second Chance · Skill

Skip another unresolved non-Blank die. Repeat a different, already-spent immediate ability. No repeat or copy chains.

### Spiral Instability · Skill

Choose an Attack from this die and resolve it 2 times at random legal targets, including allies. No Attack on this die means no effect.

### Contained Power · Skill - Channel

Maintain: future Blank rolls grant 1 Block; other rolls add +1 to Numeric, capped at +2. HP loss breaks it, causes 2 normal backlash damage and leaves a Red Tile.

### Corruption Conversion · Skill

Choose an unresolved Blank die, then an ability installed on it. Resolve that result. This Conversion face becomes a locked Red Tile.

### Blood Bargain · Skill

The next 2 Attacks against the boss gain +1 damage. After the last, you take 1 unavoidable damage.

### Target Override · Skill - Reaction

When personally targeted, redirect to a different legal adjacent hero. With no alternative, the original target remains.

### Debt · Skill

Next Attack or Defense this turn: +2. At your next turn, your first such face suffers −2, minimum zero.

### Ill Omen · Skill

Modify an unresolved Attack or Defense with a random bonus, penalty, Pierce or repeat. Pick the affected die. See More rules for the six outcomes. Ill Omen uses a d6: 1 = −1 value; 2–4 = +1 value; 5 = Pierce 2 on an Attack or +2 Block on a Defense; 6 = repeat an Attack once or double Defense Block.

### Stonewake · Skill - Channel

Gain 2 Block. Maintain: preserve Block and add 1, up to 8. Any HP loss or 2 cumulative Block lost before your next turn interrupts this Channel.

### Oath of Smoke · Skill

Resolve another rolled Step, Stride or Guard now. Then store it as a Reaction until the next shared roll. The stored movement Reaction steps 1; the stored Guard Reaction grants 1 Block. It expires at the next shared roll.

### Bone Mutation · Skill

Install Bone on one of your Blanks for this fight. Bone gains 1 Block and may step 1.

### Summon Nu’gh · Skill

Summon a friendly Nu’gh on an adjacent empty cell: 1 HP, Move 2, reach 1. Numeric bite: 2 successful sides of six, 1 damage; HP damage applies Poison 1. Acts after owner’s turn. While alive: Command grants an immediate extra activation. One per hero across all copies.

## 11. Bonus Attacks

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Strike Numeric · Attack

Roll for damage against an adjacent unit.

### Short Shot · Attack

Roll for damage against a visible unit within 2. Final damage is capped at 2, including Mark Prey.

### Hooked Slash · Attack

Roll for damage against an adjacent unit. At least 2 HP lost: gain that HP loss ×1 as Block.

### Piercing Thrust · Attack

Roll for damage against an adjacent unit. Bypass 1 Block; the bypassed Block remains after this hit.

### Cleave · Attack

Roll for damage against an adjacent unit. Also deal 1 damage to one other enemy adjacent to the target. The secondary splash applies when the main target is an enemy; attacking an ally does not trigger it.

### Flanking Blow · Attack

Roll for damage against an adjacent unit. Add 1 when standing at the boss’s southern edge.

### Break Rhythm · Attack

Roll for damage against an adjacent unit. Break existing Block and damage HP to delay an upcoming boss activation by 1 slot(s).

### Engrave · Attack

Roll for damage against an adjacent unit. On HP damage, grow on this die up to 1 time(s) per hero turn, capped at 3 copies. At 6 copies: +1 damage. Never overwrites another ability. Growth fills one Blank on this die per qualifying turn, up to 3 copies; at 3 copies the attack gains +1. It cannot overwrite another ability.

## 12. Bonus Defenses

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Guard Numeric · Defense

Roll a value and gain that much Block.

### Brace Hero · Defense

At zero Block: gain 3. Otherwise: gain 1.

### Shield Wall · Defense - Reaction

When an ally within 2 is attacked, give them 1 Block and yourself 1 before the hit. Clear sight required.

### Taunt · Defense - Reaction

When another hero is attacked, take their place if you are a legal target within 1. Cannot redirect Sweep or Furnace Roar.

### Defy Death · Defense - Reaction

Before a lethal Attack, remain at 1 HP instead and gain Stunned. This face becomes Blank. Defy Death automatically spends the first available unused result when applying its Stunned consequence; this is a specific exception to the usual die-choice window.

### Bulwark · Defense

Gain Damage Reduction 1 and Weakness 1 until your next turn. Unavoidable damage bypasses reduction.

### Echo of Pain · Defense - Reaction

During an enemy Attack, deal the HP damage you took this round to the boss, capped at 3. This face becomes Blank. Unused: take 1 unavoidable damage at your next turn. The unused penalty is armed when rolled and is checked at the next own turn start; spending the Reaction disarms it.

### Last Pulse · Defense - Channel

Maintain: heal 1 at your turn start. Any HP loss interrupts the Channel and turns this face Blank.

### Black Oath · Defense

Gain a rolled value +1 Block. At your turn end, lose 1 HP if any Block remains.

### Wither Ward · Defense

Gain rolled Block. Until your next turn, an adjacent boss Attack that removes HP gives the boss Weakness 1.

### Ember Burst · Defense

Gain rolled Block, then burn up to 2 Block. Each burned point deals 1 damage to every other unit within 1, including allies.

## 13. Bonus Movement and generated faces

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Leap of Echoes · Movement

Leap up to 2 spaces, over units but never onto them. End within 1 of the boss to gain +1 on your next rolled damage this turn.

### Ashstep · Movement

Move up to 2 spaces, turning allowed, then gain 1 Block. Occupied cells block the path.

### Oathbound Exchange · Movement

Swap with a standing ally within 3 and clear sight. Both gain 1 Block. Rooted prevents the swap.

### Bone · Skill

Gain 1 Block and optionally step 1.

### Recovery · Skill

Heal yourself or an ally within 1 for a rolled value.

### Red Tile · Penalty

No effect. Locked: cannot be rerolled and does not count as a Blank.

## 14. The Hollow

12 starting HP. At 6 HP or less, phase II begins immediately and never reverses. Phase-I Brand deals 2; phase-II Brand deals 3. Sweep rises from 1 damage / reach 1 to 2 damage / reach 2. Persistent fire burns for 1 at hero turn end. The boss’s upgraded detonation deals 3 extra normal damage. Every action upgrades. Newly armed Brands use the new shape; already marked cells do not expand. Furnace Roar replaces the next unresolved boss die once, then replaces Brace on Die I in later rolls.

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

## 15. Nu’gh, Worm Summoner

10 starting HP. Nu’gh is a huge human-worm who retreats rather than chasing heroes. At 5 HP or less, Severed Brood begins immediately and never reverses, even after healing. Soul Link switches OFF permanently. Living worms add up to +1 damage to Gnashing Maw before half HP, +2 afterward. Both Commands and the automatic brood turn make the brood dangerous. Bites are chance-based with delayed poison rather than guaranteed damage.

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

## 16. Veyl, the Brass Cantor

Optional third boss. 14 HP; half-HP threshold 7. Select Veyl on the pre-fight review screen after choosing all heroes’ faces.

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

## 17. Bu’gh, the Iron Warden

Optional fourth boss. Armored shield-and-hammer duelist, 12 HP, half-HP threshold 6. No cocoons or enemy summons. All active numbers appear in Balance Workshop; legacy cocoon overrides are inactive.

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

## 18. Quick timing reference

Use this page during a fight; the preceding chapters explain each rule in full.

### Before the shared roll

Set aside a die for any still-Stunned hero. Then roll available dice together; hold Reactions, keep Channel dice held, trigger when-rolled effects.

### At your turn start

Resolve due costs and expiry, refresh Blank allowance, decide Maintain/End Channel. Ordinary old Block disappears; Stonewake can preserve it.

### Before your first action

Optional banked reroll. A charge does not refill automatically. Locked/spent/held results cannot be selected.

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

## 19. Soundtrack and interface

The original score and shared interface theme are part of v0.38. The v0.23 soundtrack and interface remain in v0.38.

### Three musical themes

Embers at the Forge accompanies preparation. Oathbound accompanies combat. The Crown Splinters accompanies phase II. Each is an original 16-bar looping composition using synthesized plucked strings, bells, sustained harmony, bass and percussion, with no external samples. The game crossfades between cues; music never consumes gameplay randomness.

### Browser playback

Music begins with the first click or keypress in the game, as required by browser audio policies. The footer names the current cue. A muted mix is labelled as muted.

### Volume and mute

Open Audio in the footer or Soundtrack & volume in Game options. Music and Effects have independent sliders; All sound toggles both. Zero volume is silent. Mix settings are saved on this device and restored after reloading. Display / advanced audio opens the existing display and bus settings.

### Reading the interface

Ability cards separate their name, category/timing and a short effect. Hover still shows the full effect, and drag placement is unchanged. Primary buttons and keyboard focus have stronger outlines. Patch topics scroll. The themed Balance Workshop edits the same values as before.

## 20. Essence harvesting and Camp Forge

The following v0.27 implementation reference is historical: v0.38 overrides boss token counts/rewards and recipe visibility. Every recipe is now inspectable before payment. Bosses yield 3 matching Essence and have original ability/Memory recipes in section 23. Normal creatures still yield 1 each; their prices are unchanged.

### Camp rules

Based on the supplied [Essence Harvesting & Prototype Enemies v1](design/Essence-Harvesting-and-Prototype-Enemies-v1.pdf). Its fixed reward effects and prices are implemented. Its candidate services, unique-boss opportunities and Hunt scheduling are deliberately not invented.

### Harvest and discovery



### Camp rules

Each eligible ordinary individual enemy death puts exactly one token of that enemy's own Essence type on its defeated card. Multiple copies and repeat encounters each yield tokens. Friendly summons yield none. Cards are available through Menu → Enemy cards → harvesting, and from the outcome screen; no token is placed on a grid cell.

### Camp rules

Victory banks all this encounter's tokens in the shared collection; defeat or interruption banks none. Banked Essence is never deducted by damage, enemies, curses or events. Only voluntary crafting spends it. Settlements are idempotent across redraw/reload. Conditional checks use actual state at death, before death cleanup: an earlier qualifying state does not count. The engine supports regular, zero-Block, Poisoned and Rooted conditions; only regular harvesting is assigned to the three new creatures. Boss requirements/eligibility reveal after first individual defeat, even if the party later loses. Recipe names/effects are always inspectable; crafting still requires discovery. Normal creature conditions and current eligibility are public.

### Camp rules

Bosses use regular harvesting and yield three matching Essence on defeat. Victory banks them once. Each boss has an original ability and Memory recipe, described in section 23. The Hollow still grants its bound Soul to every hero.

### Fixed recipes



### Camp rules

The exact design name/effect and price are inspectable in the Forge before payment. The rulebook deliberately remains a full designer reference.

### Bone Growth — Bone Creature

Skill / Bone; cost 1 matching Essence.

### Bone Strike — Bone Creature

Attack / Bone; cost 2 matching Essence.

### Bone Guard — Bone Creature

Defense / Bone; cost 3 matching Essence.

### Shared Remedy — Support Creature

Skill / Healing; cost 1 matching Essence.

### Sorrow's Offering — Support Creature

Skill; cost 2 matching Essence.

### Shared Burden — Support Creature

Skill / Copy; cost 3 matching Essence.

### Memory of Loss — Support Creature

Memory; cost 4 matching Essence.

### Retreat — Movement Creature

Movement; cost 1 matching Essence.

### Momentum Strike — Movement Creature

Attack; cost 2 matching Essence.

### Evasive Counter — Movement Creature

Defense / Reaction; cost 3 matching Essence.

### Camp rules

First face crafting unlocks the design, reveals the effect and grants copy one. Every further copy costs the same Essence amount, including immediately in the same Camp visit. There is no owned-copy cap or mutually exclusive recipe choice. Faces stay owned when unequipped. There is no dismantling/refund. Memory of Loss is a one-time permanent unlock, with one shared physical Memory that may be transferred during refitting. The four original boss Memory recipes extend permanent rewards in section 23; no new Body or Weapon recipes are added.

### Camp rules

Camp → choose a crafted face → choose hero → choose die square. Toggle Unequip mode to return a crafted face to the collection, then switch heroes and place that copy. Memory can also be unequipped while remaining permanently owned. The normal two-Blanks-per-die and body/category limits remain, as do the original two selected bonus designs. The party cannot equip more physical copies than it owns across all three heroes. A replaced crafted face remains in the collection. Saved build presets validate crafted ownership and total party allocation on load. Repositioning owned faces in the existing forge remains supported.

### Camp rules

Souls are tracked per recipient and cannot be traded. A hero can own multiple Souls and cycle their equipped Soul at Camp. The Hollow and Ash Road reward Souls retain the existing Blank → Move 2 effect, limited to one rolled Blank per own turn; equipping one never enables it for another hero. The existing Fragment event now binds its unlock to the chosen hero. Previously unlocked legacy Fragment Souls are preserved for all previously entitled heroes when migrating the old save. The optional manual Blank-movement test rule remains in rules/options and is distinct from earned equipment.

### Reward effects and playtest clarifications



### Camp rules

- Bone Growth: gain 1 Block and optionally Move 1. Bone Strike/Guard count that hero's Bone results rolled for the current turn, including results already spent. The three new faces and the existing generated Bone have the Bone trait. Actual rerolls that produce Bone add another result; copy/rotate effects do not add a fictitious roll. Bone Strike/Guard count themselves when actually rolled. Bone Guard uses the normal immediate Defense modifiers. - Shared Remedy: first heal self 1. Only actual restored HP opens the ally-heal choice, within range 2 (3 with Memory). A full-health self-heal grants no ally heal. The ally can be Downed if normal healing permits revival. - Sorrow's Offering: decline spends the face without HP cost or benefit. Otherwise pay 1 unavoidable HP, possibly Downing/killing the owner, then grant a standing ally within 2 either 2 Block or +1 next-Attack damage. Multiple paid offerings add their next-Attack bonuses; the next hit consumes them once (repeat hits do not reuse the bonus), before normal modifiers, Weakness, mitigation and absolute-zero rules. - Shared Burden: select another die's actual rolled result from this round's history, including already resolved results. A standing ally within 2 spends one ready die (or a held, unspent Reaction) to resolve the copy immediately in a single-action interrupt, even if they already took their normal slot. No full turn, activation-start effects, Poison tick, Block expiry, initiative change or shared roll is granted. Usual copied text, targeting and costs apply; Focus may consume its normal target die as well. Reactions are held normally. Shared Burden itself cannot be copied, and indirect copy loops are blocked. Finish/decline the result, then click Return to the original hero. Installed faces are unchanged by the copy process; explicit mutations in copied text follow their own normal rules. The interrupt has a fresh movement scope and restores the recipient's prior normal-turn counter afterwards. It uses the recipient's current rolled Bone history. This timing is a prototype clarification, not a finalized master-rule claim. - Memory of Loss: the implemented Healing keyword covers the existing healing faces and Shared Remedy. Eligible ranged heals gain +1 range; Self and Adjacent heals do not. Only the first actual self-heal per combat gains +1 HP, capped at maximum. An ally healing the Memory owner does not spend that bonus. Supplies are not Healing abilities. - Retreat: up to 2 legal orthogonal spaces, then 1 Block only if farther from every living enemy than at the start. - Momentum Strike: after 2 moved spaces this own turn, deal 1 adjacent-enemy damage; after 3+, use Numeric +1. Movement counts the actual legal path of voluntary actions during the hero's turn; outside-turn forced movement does not carry into it. Leaps/swaps use their displacement if no walking path describes them. Normal attack modifiers and absolute Numeric zero remain. - Evasive Counter: +1 Block before the Attack. If the complete Attack and its riders remove no HP, offer Move 1 afterwards. Block absorption qualifies. Rooted still prevents moving. Multiple successful copies each offer a step. Forced-push/collision HP damage denies the step. This also works on non-boss monsters and confirmed friendly hero Attacks; pending movement resolves before the next creature acts.

### Provisional encounters, not reward-face AI



### Camp rules

The PDF intentionally leaves enemy stats/dice and composition unfinished. The prototype uses:

### Camp rules

- Event 4: two Bone Creatures, 3 HP each, Scuttle 2 / Bite 1 / Guard 1 dice. Victory also keeps the existing 3 Gold + 1 Salve reward. - Event 5: one Support Creature, 2 HP, and two Movement Creatures, 3 HP each. Support can Mend itself/a living ally within 2 for 1; Movement Scuttle moves 3. Bite is 1 normal damage in reach 1; Guard grants 1 Block. Victory keeps the existing 5 Gold + 1 Fragment + 1 Reroll Seal, plus the individual Essence tokens. - Each creature rolls its own three public six-sided dice. The group resolves each numbered die in card order, with Reactions and Evasive movement pausing it. The enemy-card window prints every die's six sides and the current results. No boss phases or enemy summons are added.

### Camp rules

These are visible provisional AI choices, not claims that Bone Growth or Shared Burden were prescribed as enemy actions. Original geometric pixel sprites are generated by tools/make_essence_art.py. Names remain working labels; difficulty and duplicate/Bone scaling require playtesting.

### Camp rules

Cleansing, Reforging, Restoration, Transmutation and Empowerment are shown only as unavailable candidates. No illustrative service price is charged and no effect/milestone is invented. Hunt frequency/persistence and the PDF’s candidate unique-boss opportunities remain undefined; the original boss reward recipes in section 23 are separate additions. The implementation does not add a separate spendable Bone currency, settlement or campaign.

### Camp rules

The Essence ledger, unlocks, copies, memories and bound Souls save locally alongside existing rewards. Clearing browser storage removes that local data; Git does not back up player saves. Active combat is still not checkpointed. Previously banked Essence/owned rewards survive restarting a run, defeat and refitting. Windows downloads are unchanged.

## 20a. Main menu, equipment and direct creature encounters

The interface separates preparation into clear workspaces. Current equipment and weapon rules below supersede historical starting-Soul descriptions.

### Main menu and Camp

The game opens on Main menu. Build your party, visit Camp & Essence Forge, Fight creatures, start guided practice, read rules or open options. Camp has separate Essence Forge, Refit dice, Equipment and Creature encounters tabs. Descriptions scroll within their panels. The starter Forge edits a selected square through its detail panel; illegal replacements do not alter the build. Main menu abandons a live encounter without banking its tokens and keeps prepared dice. Restart party in Options also clears bonus choices; owned rewards stay safe. Combat is not checkpointed.

### Body, Weapon, Soul and Memory slots

Choose a hero in Camp Equipment and use the four selectors. The available body is Broken Body, retaining current HP, at least two Blanks per die and existing category/ownership limits. No extra body types are invented. Each hero owns one starter Dagger and their own bound Beginning Soul. Weapons may be unequipped; a body is required. Memory of Loss remains a single shared permanent copy, transferable or unequippable; Souls remain bound to their recipient. All equipment saves locally and takes effect in the next encounter.

### Beginning Soul

New parties equip Beginning Soul by default. Spend exactly one rolled Action Blank as Move 1, at most once during each own turn. It grants no free movement and does not install a Movement face. The normal construction requirements remain: a legal body/owned-face build and at least two Blanks on every die. Rooted prevents voluntary movement. Failed destinations do not consume the result or allowance. Rerolls, shared rolls and sandbox toggles do not refresh it. The next normal own turn or full recovery turn refreshes it. Earned Hollow/Ash Road Souls retain one Blank as Move 2, scoped to the equipped hero. Old saves gain Beginning Soul ownership without replacing an earned equipped Soul or a saved empty choice.

### Dagger — Poke

After this hero causes actual enemy HP loss during this same own turn, Poke one adjacent enemy for base 1 normal Attack damage. Once per own turn, with no Action Die or reroll spent; ready or spent dice do not change its availability. Finish pending choices/forced dice first. Fully blocked hits, friendly fire, another actor or summon and Shared Burden interrupts do not unlock it. Poke cannot target allies or corpses. Normal Attack modifiers, Weakness, Block, armor, exposed-core/Mark/Bargain/Weak Point effects apply. It charges Veyl Resonance as an Attack. No Numeric roll or die-specific modifiers apply. A prevented Poke still consumes its once-per-turn use. Its use and earlier-damage condition both reset at the next own turn, including full recovery. Starter availability and once-per-turn/no-die cost are explicit prototype choices.

### Direct creature groups

Choose Bone Patrol: two 3-HP Bone Creatures; Mixed Group: a 2-HP Support Creature and two 3-HP Movement Creatures; or Swift Pack: two 3-HP Movement Creatures. Incomplete parties go through bonus selection and then return to the chosen fight. Existing public creature dice and AI apply. Victory banks individual enemy Essence once. Defeat or leaving discards only the current encounter tokens. Direct groups grant no Gold, supplies, Fragments or boss Souls, and do not roll, consume or replace the required event before a boss. Random creature events and all four boss encounters remain. AI/stats/group compositions are provisional; this is not a campaign Hunt scheduler.

### Sprites and smooth recorded rolls

Equipment displays separate Beginning, Hollow and Ash Road Soul sprites and Memory of Loss. Owned items are coloured; unowned rewards stay visually distinct. Recipe names and Memory effects are inspectable before crafting. Available Action Dice animate together; Numeric Dice retain a separate rolling panel. Rotation decelerates and lands smoothly. Input waits until the animation finishes, then queued notices appear. All final sides/results are already recorded by the model: animation cannot change outcomes or reroll dice.

## 21. Crafted reward face catalog

All thirteen are permanently crafted rewards, not free initial bonus picks. Copies are shared; construction/category caps still apply.

### Bone Growth · Skill

Bone. Gain 1 Block and optionally Move 1.

### Bone Strike · Attack

Bone. Adjacent enemy: deal 1 damage per Bone result rolled this turn, spent results count; this face counts if rolled.

### Bone Guard · Defense

Bone. Gain 1 Block per Bone result rolled this turn, spent results count; this face counts if rolled.

### Shared Remedy · Skill

Healing. Heal yourself 1. Only if HP was actually restored, choose an ally within 2 to heal 1.

### Sorrow’s Offering · Skill

Optionally lose 1 HP, then choose an ally within 2: +2 Block or +1 damage on their next Attack. Decline spends the face without effect.

### Shared Burden · Skill

Choose another of your results rolled this round, spent or ready. An ally within 2 spends a ready die to resolve a copy immediately as a single-action interrupt. Their other dice and normal turn are unchanged. No Shared Burden copy loops.

### Retreat · Movement

Move up to 2. If you end farther from every living enemy than at the start, gain 1 Block.

### Momentum Strike · Attack

After moving 2 spaces this turn: adjacent enemy takes 1 damage. After 3+ spaces: Numeric +1 damage instead.

### Evasive Counter · Defense - Reaction

Reaction when targeted: +1 Block before the Attack. If it removes no HP, optionally Move 1 after the entire Attack resolves.

### Ember Cut · Attack

Adjacent enemy: deal 2 damage. If HP is lost, gain 1 Block.

### Brood Needle · Attack

Enemy in clear sight within 2: deal 1 damage. If HP is lost, apply Poison 1.

### Quiet Note · Skill

Heal yourself 1 HP and clear your Weakness.

### Iron Shelter · Defense

Gain 2 Block, or 3 Block if you already have Block.

## 22. Creatures and Souls of the Wilds

Three original Wilds creature/Soul designs expand the game, independently of the PDF’s unfinished candidates.

### Glasswing Moth — 3 HP

3 HP. Needle 1 at range 3 with line of sight. Scuttle 2, Guard 1. Public dice: Die I: Needle / Needle / Scuttle / Guard / Needle / Scuttle; Die II: Scuttle / Needle / Guard / Needle / Scuttle / Needle; Die III: Needle / Guard / Scuttle / Needle / Guard / Scuttle. Regular harvest: one matching Essence token per defeated individual.

### Iron Husk — 5 HP

5 HP. Bash 2 at reach 1. Scuttle 1, Iron Guard +2 Block. No passive armor. Public dice: Die I: Scuttle / Scuttle / Bash / Iron Guard / Bash / Iron Guard; Die II: Iron Guard / Bash / Scuttle / Iron Guard / Bash / Scuttle; Die III: Bash / Iron Guard / Scuttle / Bash / Iron Guard / Scuttle. Regular harvest: one matching Essence token per defeated individual.

### Mire Leech — 4 HP

4 HP. Venom Bite 1 at reach 1; actual HP loss adds Poison 1. Scuttle 2, Guard 1. Public dice: Die I: Scuttle / Scuttle / Venom Bite / Venom Bite / Guard / Venom Bite; Die II: Venom Bite / Guard / Scuttle / Venom Bite / Scuttle / Venom Bite; Die III: Guard / Venom Bite / Scuttle / Guard / Venom Bite / Scuttle. Regular harvest: one matching Essence token per defeated individual.

### Glasswing Soul

Spend one rolled Blank to blink up to 2 orthogonal spaces, once per own turn. May cross occupied cells; landing must be empty. Rooted prevents it. No extra action. Bind for 3 Glasswing Moth Essence per recipient. One permanent ownership per hero, never traded; equip in the Soul slot afterwards.

### Ironbound Soul

Spend one rolled Blank to gain 2 Block, once per own turn. Block expires normally at the next own turn. No movement. Bind for 3 Iron Husk Essence per recipient. One permanent ownership per hero, never traded; equip in the Soul slot afterwards.

### Soul of the Mire

Spend one rolled Blank to heal yourself 1 HP, once per own turn. Requires missing HP. No movement; cannot revive a Downed hero. Bind for 3 Mire Leech Essence per recipient. One permanent ownership per hero, never traded; equip in the Soul slot afterwards.

### Find the new encounters

Camp → Creature encounters → Wilds creatures. The Sunken Bank contains two 4-HP Mire Leeches; Glasswing Swarm contains two 3-HP Moths; Rusted Procession contains one 5-HP Iron Husk and one 3-HP Movement Creature. All enemies have their own public dice. Defeat the whole group to win and bank Essence. Direct groups award Essence only, without resolving a pre-boss event. AI, values, prices and group compositions are provisional.

### Bind and equip a Soul

Essence Forge → More shows the three new resources and Soul recipes. Choose Vesper, Rook or Wren before binding. Each Soul costs 3 matching Essence for that specific hero. A hero cannot buy the same Soul twice; other heroes pay the same cost. Read the design name and effect before paying. Ownership is bound, equipping is a separate Camp choice, and only one Soul can be equipped per hero.

### Shared Blank allowance and timing

These abilities spend a rolled Blank and the equipped hero’s once-per-own-turn conversion allowance, rather than granting a free action. Mire requires missing HP; invalid/full-HP attempts spend nothing. Glasswing requires an empty legal landing within Manhattan distance 2; occupied intermediate cells are allowed and Rooted prevents it. Ironbound gains normal temporary Block. Extra Blanks can still be spent without another Soul benefit. Normal/recovery own turns refresh the allowance; rerolls, shared rolls, toggles and Shared Burden do not. The new Souls cannot activate inside Shared Burden. Mire can receive Memory of Loss’s first-actual-self-heal bonus. These are Blank effects, not new Attack/Skill/Defense faces, so they do not change Veyl Resonance.

### Existing systems

Beginning Soul and the Hollow/Ash Road movement Souls, all thirteen crafted faces, the original 48-design free bonus pool, Dagger, four bosses, events and old banks remain. Selecting a new Soul replaces its movement alternative in the same slot. The separate sandbox can override the equipped Soul with ordinary Blank movement for tests. Campaign Hunt scheduling and undefined services remain future content. Original boss ability and Memory rewards are described below. No Windows rebuild.

## 23. Compact combat and boss rewards

Current rules supersede earlier interface and boss-reward limitations.

### Phone combat

Abilities show names only. Attack is red, Defense blue, Movement yellow, Skill purple, Blank light gray, and spent dice dark gray. Details opens full text. Reroll and End turn are fixed controls. During the enemy turn, Next action becomes End enemy turn when all actions finish; no controls scrolling is required. Tap an enemy ability name to see its target, priority and effect. Enemy HP and Block remain visible; tap their statistics for details. More contains secondary controls and the full log.

### Poison

Poison adds normally. At activation it deals its value as unavoidable HP damage, then reduces by 1. The tick has a distinct sound and green effect, without a popup, floating damage number or acknowledgement. Persistent green smoke identifies every living poisoned hero, boss and summon. Exact damage remains in the battle log.

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

One Memory slot per hero. Each Memory type is one shared transferable copy; different Memories may be equipped by different heroes. Bound Souls remain per-recipient. New faces use the existing physical-copy, category and Blank requirements. All four boss designs and Memories are original requested prototype content, not finalized PDF candidate services. The original free bonus pool stays at 48 designs.

### Debug unlocks

Enable Debug in Options or Camp’s Souls & Memories collection. With Debug on, hold a locked Soul/Memory card in the collection, or a locked ability recipe in the Essence Forge, for at least 650 ms without dragging. It permanently grants one owned item without payment; Souls bind to the selected hero. Moving more than 18 virtual pixels or releasing early cancels. Normal taps inspect. Already-owned items are not duplicated by this shortcut. It does not auto-equip items or bypass construction limits. Debug defaults off, saves separately on this device and can be switched off again.

## 24. Trials — equipment and expeditions

Main menu → Trials. Choose a class for each hero using the class card, then tap Body, Memory, Soul or Weapon to inspect or adjust equipment. Those are the four equipment slots. Descriptions state exactly when an item works; there is no separate passive or dice-edge equipment system.

### Body

Broken Body gives 6 base HP. Crafted Fleet Body gives 5 base HP and adds 1 space to Movement abilities. Crafted Stone Body gives 7 base HP and subtracts 1 space from Movement abilities, minimum 1. Blank conversion distance follows the equipped Soul instead; Fleet Body does not increase it. Every Body keeps normal construction: three six-sided dice, at least two Blanks per die, and at most three Movement, three Defense and three Skill faces per hero. Memory and Soul penalties can change maximum HP; the lobby shows the result.

### Memory

Each Trial hero may equip one test Memory. Memory of Venom: first own-turn Attack that removes enemy HP adds Poison 1 to a surviving enemy; healing received restores 1 less HP. Memory of Guard: fully blocking a positive enemy hit with Block readies +1 damage on the next Attack you make against an enemy; maximum HP -1. Memory of Momentum: after moving two spaces in your own turn, the next Attack against an enemy gains +1 damage once that turn; maximum HP -1. Crafted Memory of Shelter grants 1 additional Block after your first own-turn Defense ability; maximum HP -1. These are automatic effects of the equipped item, not extra ability buttons. Memory selection never rewrites the dice.

### Starting dice and classes

Each hero chooses Skirmisher or Vanguard. Repeated classes are allowed. Class selection supplies its starting Body, Memory, Weapon, Beginning Soul and three class dice for free. Skirmisher uses Spear / Fleet Body / Memory of Momentum, for 4 maximum HP; Vanguard uses Hammer / Stone Body / Memory of Guard, for 6. The class card previews the actual six sides of every die, including Jab or Crack replacing one Strike side. Use applies the chosen class to that hero only. Class determines future face reward offers. Equipment may be adjusted before a run and upgraded through existing rewards; changed starting gear is marked adjusted gear. Changing Memory alone never rewrites the class dice. Old saved active runs keep their previous hero-specific dice until a new Trial.

### Soul

Each hero equips one Soul. Beginning Soul spends one rolled Blank as Move 1 per own turn. Defeating a Trial boss unlocks an experimental Soul for future Trials: Hollow / Cinder adds Poison 1 on the first damaging own-turn Attack but starts each encounter with Poison 1; Nu’gh / Brood spreads the first own-turn Poison application to one other adjacent enemy but reduces maximum HP by 1; Veyl / Echo grants +1 next-Attack damage after the first own-turn Skill but starts with zero Action Rerolls; Bu’gh / Warden preserves up to 2 Block at turn start but shortens Movement by 1, minimum 1. These four boss Souls retain one Blank as Move 1. Crafted Wind Soul instead converts one Blank to Move 2. Crafted Hearth Soul converts one Blank to heal self 1, replacing movement. All are once per own turn. The item description explains the effect and cost.

### Weapon

Skirmisher begins with Spear; Vanguard begins with Hammer. You can adjust weapons in the lobby, including Dagger or crafted Dagger variants. Dagger Poke deals 1 to an adjacent enemy, once per own turn, after that hero has caused enemy HP damage that turn; it spends no die. Spear and Hammer instead replace one Strike side with a rolled weapon ability: Jab or Crack. The first Strike side, scanning Die I to III in side order, becomes that weapon face; other Strikes remain normal. Keep at least one Strike side while using these weapons. Jab requires two spaces moved this own turn, then deals 1 within 2. Crack requires another Attack used this own turn, then removes up to 2 Block from an adjacent enemy without HP damage. Both consume their rolled die and are once per own turn; invalid attempts spend nothing. They grant no free Poke. After a paid Weapon replacement, the next encounter uses that Weapon. Poison Dagger Poke deals 1 and adds Poison 1 after HP loss. Heavy Dagger Poke deals 2, then costs 1 unavoidable HP, except after victory. Both retain Poke’s requirement; their effects do not modify rolled Attacks.

### Route and HP

Choose one of the four bosses. Five stops precede it: regular battle or Break the Ritual; Camp or battle; Protect the Spirit or elite; cache or elite; Camp or elite; then the boss. Group choices vary by run seed and display lineup, HP and reward first. HP carries between fights. Combat statuses, mutations, Broken and rerolls reset for a new encounter. Fallen heroes remain out until Camp restores HP. All heroes fallen ends the Trial. Camp either heals everyone 2, including fallen heroes, or grants 2 Trial Essence. A cache grants safe +1 Essence or one d6: 4–6 gives +5; 1–3 costs everyone 1 HP and can end the run.

### Victory rewards

Begin with 3 Trial Essence. A regular group awards 2 carried Trial Essence; an elite awards 4; an objective victory awards 3. Then pick one reward: pay 2 to install one offered dice ability on a legal chosen side; pay 2 to equip a different Weapon; or take +2 Essence. No die-side edges or tempering are offered. Invalid side replacements cost nothing, retain normal category/copy/Blank limits, and do not grant a second reward. A boss victory records +6 Essence and unlocks its Trial Soul. Matching crafting Essence is also banked on victory: regular/objective 2; elite 3; Hollow boss 3 Hollow Essence. Carried Trial Essence and the Trial Forge’s matching ingredients are separate balances. All stay separate from ordinary Camp inventory.

### Ward & Whisper

Shieldbearer: 4 HP. Shield Line adds 2 Block to itself and adjacent enemy allies, capped at 3 Block from this ability. Mender: 3 HP. Restitch restores up to 2 HP to the most wounded ally within 3, once per enemy turn. Separate them or focus the Mender. Elite adds a Sentry and gives every enemy +1 HP. Blue cover reduces normal ranged hits from beyond 1 by 1 before Block; melee and unavoidable damage ignore it.

### The Long Charge

Ram: 6 HP. It marks a fixed cardinal lane of up to five gold tiles toward the furthest hero. At next enemy turn start that lane deals 3 damage before rolled actions. It does not chase, stack or fire after the Ram dies. Step aside or defend; Reactions apply. A 2-HP Sentry shoots with Needle. Elite adds a Mender and +1 HP per enemy. Brown barricades block movement and sight; an adjacent Attack can spend its result to break one without enemy HP damage or on-hit rewards.

### Essence Thieves

Two 4-HP Cutpurses. Pilfer steals 1 carried Trial Essence when a hero is within 2; killing a thief returns its loot once. Flee moves 2 toward an edge while carrying loot; reaching the edge removes it and loses the loot. Without loot it pursues a hero. Elite adds a Shieldbearer and +1 HP per enemy. Landing on a red spike tile deals 1 unavoidable damage, including Shove targets; standing still adds no tick and leaping over without landing is safe. No normal Camp currency can be stolen.

### Saved Trials and old upgrades

Safe route, Camp, cache and reward checkpoints save on this device. Leaving or reloading during a fight fails that Trial without a victory reward. Class choices, boss Soul unlocks, crafted Trial equipment, matching crafting Essence and the wishlist remain between runs. Pre-class safe checkpoints preserve their equipment, dice, injuries and route; the next new lobby offers class kits. An equipment craft unlocks that design for the Trial collection; it is available to all heroes in future Trial lobbies. Old v0.34 build-path selections migrate into the Memory slot. Old dice-edge purchases are removed and refunded at 2 Trial Essence each, once; dice, HP, current route and Trial Soul ownership remain. Existing Debug mode can unlock locked Trial Soul cards by a stationary 650 ms hold in Equipment & how to play; moving cancels. The Trial Forge has a corresponding stationary Debug hold for locked equipment recipes. Normal game equipment and inventory are preserved. These are original experimental items, separate from unfinished PDF services/Hunts; balance still needs human playtesting.

## 25. Reading range and rerolls

Selecting a combat ability shows its board reach in both layouts.

### Range and targets

Faint category-colored tiles show reach, including empty tiles. Bright outlines identify targets or legal movement destinations. Red stripes identify sight-blocked cells. Range uses orthogonal distance, the existing minimum distance to a boss’s footprint, sight rules and equipped range bonuses. Movement uses actual legal reachable cells; Stride stays straight and Leap follows its own rules. A range preview never rolls dice or changes combat. Ready and inspected spent/held faces can be read; an outline does not restore a spent action.

### Creature footprints

Ordinary creatures occupy one grid cell. Their sprites, HP dots and small Block badge stay inside that cell; the large boss shadow and wide boss HP label are not drawn on them. Two-by-two bosses retain their normal footprint.

### Reroll presentation

Action Reroll and Focus animate the real new result and update the ability card without a blocking text prompt or Continue acknowledgement. Charges, forced-result timing and held Reactions are unchanged. A same-face result is legal. Detailed old/new results remain in the full log. Required gameplay choices, such as a Reaction or a Channel decision, still need their normal input.

## 26. Trial experiments — objectives, previews and crafting

All features in this section are confined to Main menu → Trials. Ordinary Camp, its collection and its encounters retain their normal rules.

### Target confirmation

Select a rolled ability, then tap a target or destination. The compact inline preview shows HP damage after Block, Block consumed or removed, healing, Poison and movement. Confirm performs the real action; Cancel returns to dice. Retargeting updates the preview. Immediate supported abilities such as Guard show their preview when selected. Required setup and copy choices still open their normal chooser. On phones, the preview temporarily occupies the dice row; Cancel reveals the dice, More → Forecast details shows the full preview, and Reroll / End turn stay accessible. Friendly fire is clearly labelled before confirming.

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

### Wishlist and crafting

Open Forge / builds in the Trial lobby, or Trial Forge at a safe stop. Choose a recipe to read its exact effect, owned / required ingredients and encounter sources. Pin one item to the wishlist; route and victory screens show its progress. Craft only when every ingredient is available. Crafting spends the stated matching ingredients and unlocks the equipment once. It does not spend ordinary Camp Essence. Each class includes its own starting Body free for that hero; crafting that Body unlocks it for the other class. Equip crafted items in the lobby for a new Trial; crafting during a safe stop does not change current equipment mid-fight. Builds and crafting remain inspectable independently; applying a build changes only the chosen hero’s equipment and does not grant missing items. Boss Souls keep their existing defeat unlocks.

### Build suggestions

Poison uses Memory of Venom, Poison Dagger and, when unlocked, Brood Soul. Movement uses Fleet Body, Memory of Momentum, Spear and Wind Soul. Protection uses Stone Body, Memory of Guard, Hammer and, when unlocked, Warden Soul. Each build explains its actual turn sequence and tradeoffs. Apply available pieces uses Broken Body, Dagger or Beginning Soul for missing items and lists what is missing. It never changes the selected class, rewrites class dice or bypasses ownership. A class can use its own starting Body without crafting it.

### Fleet Body — Body

5 base HP. Movement abilities travel 1 extra space. Blank movement stays unchanged. Normal dice limits. Craft: 3 Cinder Essence.

### Hearth Soul — Soul

Spend one rolled Blank to heal yourself 1 HP, once per own turn. Replaces Blank movement. Craft: 3 Ward Essence.

### Heavy Dagger — Weapon

Poke: deal 2 damage to an adjacent enemy, then lose 1 HP. Once per own turn after you have damaged an enemy. Costs no die. No HP cost after victory. Craft: 2 Cinder Essence, 1 Hollow Essence.

### Memory of Shelter — Memory

Your first own-turn Defense ability grants 1 extra Block. Maximum HP -1. Craft: 2 Ward Essence.

### Stone Body — Body

7 base HP. Movement abilities travel 1 less space, minimum 1. Blank movement stays unchanged. Normal dice limits. Craft: 3 Ward Essence.

### Poison Dagger — Weapon

Poke: deal 1 damage to an adjacent enemy; if it loses HP, apply Poison 1. Once per own turn after you have damaged an enemy. Costs no die. Craft: 2 Shade Essence.

### Wind Soul — Soul

Spend one rolled Blank as Move 2, once per own turn. Replaces Beginning Soul’s Move 1. Craft: 3 Cinder Essence.

## 27. Two Trial classes

Main menu → Trials → tap the class card. Choose Skirmisher or Vanguard for each of the three heroes. This system is confined to Trials.

### Choose, inspect, apply

The two class buttons preview a kit without changing your hero. Tap Die 1, Die 2 or Die 3 to see its six colored faces, and tap a face for its exact effect. How to play opens an example turn and tradeoff explanation. Use applies the displayed class, starting gear and dice only to the selected hero. Class changes are available in the lobby, not during a run. Choosing a class again resets its starting equipment, including Beginning Soul; the earned collection is retained.

### How a class works

A class defines starting equipment, starter dice and the three face reward offers for that role. Actual combat effects come from the four equipment slots: Body, Memory, Soul and Weapon. There is no additional hidden class stat bonus. The lobby calculates real maximum HP after equipment. Adjusting equipment marks the class card adjusted gear; changing Memory does not alter dice. The same class may be chosen for multiple heroes.

### Free starting equipment and crafting

Selecting Skirmisher includes Fleet Body for that hero; selecting Vanguard includes Stone Body. Both starting Memories and weapons are available at no Essence cost, and both start with Beginning Soul. The class Body is usable by that class without granting its global crafting recipe. Crafting the Body permits the other class to equip it. Switching class applies the new kit and does not spend or duplicate crafting ingredients. Existing owned equipment and currencies remain.

### Weapons really appear on dice

Both class weapons replace the first Strike side on Die 1 with their rolled ability. Skirmisher has Jab; Vanguard has Crack. Exactly one side changes, and other normal Strikes remain for setup and ordinary attacks. The class preview, actual shared roll, reroll, combat buttons, copy choices and dice view use the equipped face name. Jab/Crack must be rolled, spend their Action Die and remain once per own turn. Invalid requirements spend nothing. These weapons grant no extra free Poke.

### Saved games

Class choices and adjusted gear save on this device. Safe route/reward checkpoints retain their class, actual dice, injuries, equipment and resource balances. Leaving or reloading during combat retains the existing interrupted-Trial failure rule. Pre-v0.37 safe checkpoints continue with their old setup, not a retrofitted class build; their next new Trial can choose the new classes. Normal Camp and normal game setup do not acquire classes.

### Skirmisher — Move first, then strike from range 2.

Starting Body: Fleet Body. Starting Memory: Memory of Momentum. Starting Weapon: Spear. Starting Soul: Beginning Soul. 4 maximum HP: Fleet Body 5, Memory of Momentum −1. Example: roll Step and Jab on different dice. Fleet Body makes Step move 2; move first, then Jab reaches an enemy within 2 and deals 2 damage with Memory of Momentum. That Memory boosts only the first eligible Attack. Jab itself is once per own turn and spends its die. Fast but fragile. Beginning Soul still converts one Blank to Move 1; Fleet Body does not increase Blank movement. Keep ordinary Strikes or Strike Numeric for turns without enough movement. Starter dice: Die 1: Jab, Strike Numeric, Guard, Strike, Blank, Blank; Die 2: Step, Stride, Reaction, Step, Blank, Blank; Die 3: Momentum Strike, First Aid, Focus, Guard, Blank, Blank. Face reward offers: Momentum Strike, Retreat, Leap of Echoes.

### Vanguard — Guard the front line and break enemy Block.

Starting Body: Stone Body. Starting Memory: Memory of Guard. Starting Weapon: Hammer. Starting Soul: Beginning Soul. 6 maximum HP: Stone Body 7, Memory of Guard −1. Use Guard, Iron Shelter or a held Reaction to block an enemy Attack completely; Memory of Guard readies +1 damage for your next Attack. During your own turn, use another rolled Attack first, then spend a rolled Crack to remove up to 2 Block from an adjacent enemy. Crack deals no HP damage. Durable but slower: Stone Body makes Stride travel 2 instead of 3. Beginning Soul still converts one Blank to Move 1. Ordinary Strikes, Strike Numeric and Engrave give you attacks to set up Crack. Starter dice: Die 1: Crack, Guard, Iron Shelter, Strike, Blank, Blank; Die 2: Strike Numeric, Strike, Strike, Stride, Blank, Blank; Die 3: Engrave, First Aid, Shove, Reaction, Blank, Blank. Face reward offers: Iron Shelter, Evasive Counter, Wither Ward.

## 28. Soulcaster — free Trial starter Soul

Trials → Soul → Soulcaster. Either class may equip it free before a new run. This section implements the supplied Soulcaster Soul Rules and Spells document. It overrides ordinary Blank movement only for the equipped hero.

### Starting build and HP

Soulcaster supplies 6 base maximum HP before the equipped Memory penalty: Guard / Momentum makes 5, while No Memory keeps 6. Existing Body movement modifiers remain. Starting dice adapt to four Blanks each; the Weapon still projects its first Strike to Jab / Crack. Exact physical starter dice: Die 1: Strike, Guard, Blank, Blank, Blank, Blank; Die 2: Step, Strike Numeric, Blank, Blank, Blank, Blank; Die 3: First Aid, Focus, Blank, Blank, Blank, Blank. The four-Blank minimum applies when constructing or upgrading the run build; manifested spells replace those Blanks during combat.

### Gather and Manifest

Use a ready rolled Blank to open the casting picker. Gather spends the result for +1 Soul Charge, maximum 3. Manifest spends the result, the chosen charge cost and 1 unavoidable HP, replacing that exact physical Blank side. The HP payment may Down or kill the caster under the existing Broken rules. Maximum four manifested spells per caster. No once-per-turn limit applies to using different ready Blanks. Back closes the picker without spending the result. Soulcasting replaces Blank movement.

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

### Clarity and purchasing

Help is split into How to play, My heroes, Rewards & resources, Arena, Boss Souls and Soulcaster. Run Essence is the temporary carried reward currency; Ward / Cinder / Shade / Hollow Essence are permanent Forge ingredients; Soul Charges and Action Rerolls are separate combat banks. At face rewards choose a physical side, inspect the replacement and price, then Buy. Unavailable slots explain the validation error; previews do not mutate builds, ownership or currency.

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
