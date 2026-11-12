extends RefCounted
## Trials-only Soul from Soulcaster Soul Rules and Spells. No normal catalog ownership.
const FIRST = 75
const LAST = 80
const STARTER_DICE = [[1,4,0,0,0,0],[2,34,0,0,0,0],[7,6,0,0,0,0]]
const SPELLS = {
 75:{"name":"Wraith Exchange","category":"Movement","cost":2,"range":4,"text":"Swap with a standing ally within 4. Then each hero may Move 1. Rooted prevents the swap; the follow-up steps stay Move 1."},
 76:{"name":"Soul Harvester","category":"Attack","cost":1,"range":3,"text":"Spend 1 Soul Charge to deal 1 normal Attack damage to an enemy within 3. Killing an enemy creature or boss grants 2 Soul Charges, up to 3."},
 77:{"name":"Mirror of the Damned","category":"Defense","cost":2,"range":2,"text":"Reaction: when you or an ally within 2 is attacked, give the target 2 Block. If the entire Attack causes no HP loss, deal 1 normal damage to its attacker."},
 78:{"name":"Grave Stitch","category":"Skill","cost":1,"range":2,"text":"Heal yourself or an ally within 2 for 2 HP, then turn this spell side back into Blank. Can revive a Downed hero or heal the living Spirit."},
 79:{"name":"Hoarded Omen","category":"Skill","cost":1,"range":3,"text":"Choose yourself or a standing ally within 3. On their next turn they may save one ordinary ready ability. Its original die stays aside and the saved result is ready on their turn in the following round. No Reactions, Channels, when-rolled results, penalties, Blanks or Hoarded Omen."},
 80:{"name":"Fatebreaker","category":"Skill","cost":2,"range":0,"text":"When rolled: gain 1 Action Reroll, up to its normal cap, then reroll one eligible unresolved enemy die. Each enemy die can be rerolled once per shared round. If none is eligible, only the Action Reroll is gained."}
}
static func enabled(g) -> bool:return bool(g.balance.get("trial.enabled",false))
static func equipped(g, hero: int) -> bool:return enabled(g) and hero in range(3) and str(g.balance.get("trial.souls",["","",""])[hero])=="soulcaster"
static func is_spell(face: int) -> bool:return SPELLS.has(face)
static func text(face: int) -> String:return SPELLS[face].text if is_spell(face) else ""
static func charges(g, hero: int) -> int:return int(g.heroes[hero].get("soul_charges",0))
static func count_spells(g, hero: int) -> int:
 var count := 0
 for die in g.heroes[hero].build:
  for face in die:
   if is_spell(int(face)):count += 1
 return count
static func held(g, hero: int, die: int) -> bool:return enabled(g) and int(g.heroes[hero].get("omen_held",{}).get("die",-1))==die
static func setup(g) -> void:
 if not enabled(g):return
 g.trial_state.fate_queue = [];g.trial_state.fate_used = [];g.trial_state.enemy_resolved = {};g.trial_state.mirrors = [];g.trial_state.fate_resume = "";g.trial_state.fate_defer_binds = false
 for h in g.heroes:
  h.soul_charges = 0;h.spell_created = {};h.spell_turn = 0;h.omen_offer = -1;h.omen_ready = false;h.omen_held = {}
static func round_prepare(g) -> void:
 if not enabled(g):return
 g.trial_state.fate_queue = [];g.trial_state.fate_used = [];g.trial_state.enemy_resolved = {};g.trial_state.fate_defer_binds = false
static func turn_start(g, hero: int) -> void:
 if not enabled(g):return
 var h: Dictionary = g.heroes[hero];h.spell_turn = int(h.get("spell_turn",0))+1
 h.omen_ready = int(h.get("omen_offer",-1))==h.spell_turn;h.omen_prompted = false
 if int(h.get("omen_offer",-1))<h.spell_turn:h.omen_offer = -1
 var saved: Dictionary = h.get("omen_held",{})
 if not saved.is_empty() and g.round_no>=int(saved.round):
  h.results[int(saved.die)] = int(saved.face);h.used[int(saved.die)] = false;h.omen_held = {}
  g.record_event("soulcaster","Hoarded Omen releases %s’s saved %s. Its die did not roll again." % [g.unit_name(hero),g.Catalog.name_for(int(saved.face))],hero,hero)
static func turn_end(g, hero: int) -> void:
 if not enabled(g):return
 if g.heroes[hero].get("omen_ready",false):g.heroes[hero].omen_offer = -1
 g.heroes[hero].omen_ready = false
static func downed(g, hero: int) -> void:
 if not enabled(g):return
 g.heroes[hero].omen_offer = -1;g.heroes[hero].omen_ready = false;g.heroes[hero].omen_held = {}
static func created_this_turn(g, hero: int, die: int) -> bool:
 if not enabled(g):return false
 var h: Dictionary = g.heroes[hero];var entry: Dictionary = h.get("spell_created",{}).get(str(die)+":"+str(h.rolls[die]),{})
 return not entry.is_empty() and int(entry.round)==g.round_no and int(entry.turn)==int(h.get("spell_turn",0)) and is_spell(int(h.results[die])) and int(h.results[die])==int(h.build[die][h.rolls[die]])
static func on_roll(g, hero: int, die: int) -> void:
 if created_this_turn(g,hero,die):
  var h: Dictionary = g.heroes[hero];h.used[die] = true;h.reaction.erase(die)
  g.record_event("soulcaster","%s rolls a newly created %s. It stays spent this creation turn; roll it on a later turn to activate it." % [g.unit_name(hero),g.Catalog.name_for(int(h.results[die]))],hero,hero)
  return
 if not enabled(g) or int(g.heroes[hero].results[die])!=80:return
 var h: Dictionary = g.heroes[hero];var before: int = h.rerolls
 h.rerolls = mini(g.v("hero.reroll_cap"),h.rerolls+1);h.used[die] = true
 g.trial_state.fate_queue.append({"hero":hero,"die":die})
 g.record_event("soulcaster","Fatebreaker: %s gains %d Action Reroll; bank %d/%d. Choose an eligible enemy die." % [g.unit_name(hero),h.rerolls-before,h.rerolls,g.v("hero.reroll_cap")],hero,hero)
static func gain(g, hero: int, amount: int, reason: String) -> void:
 var before: int = charges(g,hero);g.heroes[hero].soul_charges = mini(3,before+amount)
 g.record_event("soulcaster","%s: %s gains %d Soul Charge; %d/3." % [reason,g.unit_name(hero),charges(g,hero)-before,charges(g,hero)],hero,hero,charges(g,hero)-before)
static func blank(g, die: int) -> bool:
 if not equipped(g,g.active):return false
 g.pending = {"kind":"soul_blank","hero":g.active,"die":die};return true
static func gather(g) -> bool:
 if g.pending.get("kind","")!="soul_blank":return false
 var hero: int = g.pending.hero;var die: int = g.pending.die
 if charges(g,hero)>=3:return false
 g.pending = {};g.spend(die);gain(g,hero,1,"Gather");return true
static func manifest_reason(g, hero: int, face: int) -> String:
 if not equipped(g,hero) or not is_spell(face):return "Equip Soulcaster to manifest spells."
 if count_spells(g,hero)>=4:return "4 manifested spells already exist. Grave Stitch returning to Blank frees a slot."
 if charges(g,hero)<int(SPELLS[face].cost):return "Need %d Soul Charges; you have %d." % [int(SPELLS[face].cost),charges(g,hero)]
 if g.heroes[hero].hp<1:return "A standing hero must pay 1 HP."
 return ""
static func manifest(g, face: int) -> bool:
 if g.pending.get("kind","")!="soul_blank":return false
 var hero: int = g.pending.hero;var die: int = g.pending.die;var h: Dictionary = g.heroes[hero]
 if manifest_reason(g,hero,face)!="" or int(h.results[die])!=0 or int(h.build[die][h.rolls[die]])!=0:return false
 g.pending = {};h.soul_charges -= int(SPELLS[face].cost);g.spend(die);g.mutate(hero,die,h.rolls[die],face)
 h.spell_created[str(die)+":"+str(h.rolls[die])] = {"round":g.round_no,"turn":int(h.get("spell_turn",0))}
 g.record_event("soulcaster","%s manifests %s for %d Soul Charges and 1 HP on Die %s. The spent result stays Blank; roll the spell on a later turn. %d/4 spell slots." % [g.unit_name(hero),SPELLS[face].name,int(SPELLS[face].cost),["I","II","III"][die],count_spells(g,hero)],hero,hero)
 g.damage(hero,1,true,"Manifest: "+SPELLS[face].name,hero);return true
static func decline_blank(g) -> void:
 if g.pending.get("kind","")!="soul_blank":return
 var die: int = g.pending.die;g.pending = {};g.decline(die)
static func ally(g, hero: int, target: int, standing: bool = false) -> bool:
 if target<0 or target>=g.unit_count():return false
 var unit: Dictionary = g.unit_data(target)
 if unit.get("dead",false):return false
 if target in range(3):return not standing or unit.hp>0
 return str(unit.get("trial_object",""))=="spirit" and unit.hp>0
static func enemy(g, hero: int, target: int) -> bool:
 return target>=0 and target<g.unit_count() and g.enemies(hero,target) and str(g.unit_data(target).get("trial_object",""))!="spirit" and g.unit_data(target).hp>0 and not g.unit_data(target).get("dead",false)
static func legal_target(g, face: int, hero: int, target: int) -> bool:
 if not enabled(g) or not is_spell(face) or target<0 or target>=g.unit_count() or g.distance(hero,target)>int(SPELLS[face].range):return false
 match face:
  75:return target in range(3) and target!=hero and ally(g,hero,target,true) and int(g.heroes[hero].get("rooted",0))<=0 and int(g.heroes[target].get("rooted",0))<=0
  76:return enemy(g,hero,target) and charges(g,hero)>=1
  78:return ally(g,hero,target)
  79:return target in range(3) and ally(g,hero,target,true)
 return false
static func action(g, die: int, target: int) -> bool:
 var hero: int = g.active;var face: int = g.face(hero,die)
 if not enabled(g) or not legal_target(g,face,hero,target):return false
 var h: Dictionary = g.heroes[hero]
 match face:
  75:
   var old: Vector2i = h.pos;h.pos = g.heroes[target].pos;g.heroes[target].pos = old
   g.spend(die)
   if g.outcome=="":g.pending = {"kind":"soul_steps","heroes":[hero,target],"owner":hero}
  76:
   h.soul_charges = charges(g,hero)-1
   var was_alive: bool = g.unit_data(target).hp>0
   g.strike(die,target,1)
   if was_alive and g.unit_data(target).hp<=0 and not g.TrialRules.objective_unit(g,target):gain(g,hero,2,"Soul Harvester kill")
   g.spend(die)
  78:
   if target<3:g.heal(target,2)
   else:
    var unit: Dictionary = g.unit_data(target);var amount: int = mini(2,unit.max_hp-unit.hp);unit.hp += amount;g.record_event("heal","Grave Stitch heals %s for %d HP." % [g.unit_name(target),amount],hero,target,amount)
   g.spend(die);g.mutate(hero,die,h.rolls[die],0)
   g.record_event("soulcaster","Grave Stitch returns its physical side to Blank; a spell slot is free.",hero,hero)
  79:
   g.heroes[target].omen_offer = int(g.heroes[target].get("spell_turn",0))+1
   g.spend(die);g.record_event("soulcaster","Hoarded Omen: %s may save one ordinary result on their next turn. Its original die waits until the following round." % g.unit_name(target),hero,target)
 return true
static func optional_step(g, direction: Vector2i) -> bool:
 if g.pending.get("kind","")!="soul_steps":return false
 var queue: Array = g.pending.heroes;var hero: int = int(queue[0])
 if direction!=Vector2i.ZERO:
  if direction not in g.DIRS or g.heroes[hero].hp<=0 or g.heroes[hero].dead or int(g.heroes[hero].get("rooted",0))>0 or not g.legal(hero,g.heroes[hero].pos+direction):return false
  g.begin_action(hero,"Wraith Exchange optional Move 1");g.heroes[hero].pos += direction;g.report_changes()
 queue.pop_front()
 while not queue.is_empty() and (g.heroes[int(queue[0])].dead or g.heroes[int(queue[0])].hp<=0):queue.pop_front()
 if queue.is_empty():g.pending = {}
 return true
static func can_store(g, hero: int, die: int) -> bool:
 if not enabled(g) or hero!=g.active or not g.heroes[hero].get("omen_ready",false) or not g.heroes[hero].get("omen_held",{}).is_empty() or (not g.pending.is_empty() and g.pending.get("kind","")!="soul_omen") or not g.burden_interrupt.is_empty() or g.forced_die>=0:return false
 if die not in range(3) or g.heroes[hero].used[die]:return false
 var face: int = g.face(hero,die)
 return face>0 and face not in [13,56,79,80] and g.Catalog.timing(face)=="Action"
static func store(g, die: int) -> bool:
 var hero: int = g.active
 if not can_store(g,hero,die):return false
 g.pending = {}
 var h: Dictionary = g.heroes[hero];h.omen_held = {"die":die,"face":g.face(hero,die),"side":h.rolls[die],"round":g.round_no+1}
 h.used[die] = true;h.opening = false;h.omen_ready = false;h.omen_offer = -1
 g.record_event("soulcaster","%s saves %s. Die %s stays aside until their turn in round %d." % [g.unit_name(hero),g.Catalog.name_for(int(h.omen_held.face)),["I","II","III"][die],g.round_no+1],hero,hero);return true
static func mutated(g, hero: int, die: int, side: int) -> void:
 if enabled(g):g.heroes[hero].get("spell_created",{}).erase(str(die)+":"+str(side))
 if not held(g,hero,die) or int(g.heroes[hero].omen_held.side)!=side:return
 g.heroes[hero].omen_held = {};g.record_event("soulcaster","Hoarded Omen ends because its saved physical side changed; the die waits for the next shared roll.",hero,hero)
static func mark_enemy_result(g, source: int, slot: int) -> void:
 if not enabled(g) or source<3 or g.friendly(source) or slot not in range(3):return
 if source!=3 and not g.unit_data(source).has("trial_role"):return
 g.trial_state.enemy_resolved[str(source)+":"+str(slot)] = true
static func fate_options(g) -> Array:
 var result: Array = []
 if not enabled(g):return result
 for source in range(3,g.unit_count()):
  var unit: Dictionary = g.unit_data(source)
  if g.friendly(source) or unit.get("dead",false) or unit.hp<=0:continue
  if source!=3 and not unit.has("trial_role"):continue
  var rolls: Array = g.boss_rolls if source==3 else unit.get("creature_rolls",[])
  for slot in range(rolls.size()):
   var key: String = str(source)+":"+str(slot)
   if not g.trial_state.enemy_resolved.has(key) and key not in g.trial_state.fate_used:result.append({"source":source,"slot":slot,"action":rolls[slot]})
 return result
static func open_fate(g, resume: String = "") -> bool:
 if not enabled(g) or g.trial_state.get("fate_queue",[]).is_empty() or not g.pending.is_empty():return false
 if resume!="":g.trial_state.fate_resume = resume
 var entry: Dictionary = g.trial_state.fate_queue.pop_front();g.pending = {"kind":"soul_fate","hero":entry.hero,"die":entry.die}
 if g.forced_die==entry.die and g.active==entry.hero:g.forced_die = -1
 return true
static func apply_binds(g) -> void:
 for slot in range(g.boss_rolls.size()):
  for bind in g.boss.binds:
   if bind.die==slot and bind.action==g.boss_rolls[slot]:
    g.boss_rolls[slot] = "Bound";g.damage(bind.owner,g.v("face18.backlash"));break
static func finish_fate(g) -> void:
 g.pending = {}
 if open_fate(g):return
 var resume: String = str(g.trial_state.get("fate_resume",""));g.trial_state.fate_resume = ""
 if g.trial_state.get("fate_defer_binds",false):
  g.trial_state.fate_defer_binds = false;apply_binds(g)
  if g.has_method("finalize_trial_roll"):g.finalize_trial_roll()
 if g.outcome!="":return
 if resume=="activate":g.activate()
 elif resume=="recovery":g.complete_recovery_start()
 else:offer_omen(g)
static func choose_fate(g, source: int, slot: int) -> bool:
 if g.pending.get("kind","")!="soul_fate":return false
 var options: Array = fate_options(g)
 if not options.any(func(entry):return entry.source==source and entry.slot==slot):return false
 var choices: Array = g.boss_dice() if source==3 else g.creature_dice(g.essence_type(source))
 var side: int = g.rng.randi_range(0,5);var action: String = str(choices[slot][side]);var old: String = str(g.boss_rolls[slot] if source==3 else g.unit_data(source).creature_rolls[slot])
 var hero: int = g.pending.hero
 if source==3:
  g.boss_sides[slot] = side;g.boss_rolls[slot] = action
  if not g.trial_state.get("fate_defer_binds",false):
   for bind in g.boss.binds:
    if bind.die==slot and bind.action==action:g.boss_rolls[slot] = "Bound";g.damage(bind.owner,g.v("face18.backlash"));break
 else:g.unit_data(source).creature_rolls[slot] = action
 g.trial_state.fate_used.append(str(source)+":"+str(slot))
 g.record_event("roll","Fatebreaker: %s rerolls %s Die %s: %s → %s. Keep the new result." % [g.unit_name(hero),g.unit_name(source),["I","II","III"][slot],old,action],hero,source)
 g.roll_serial += 1;finish_fate(g);return true
static func no_fate(g) -> bool:
 if g.pending.get("kind","")!="soul_fate" or not fate_options(g).is_empty():return false
 g.record_event("soulcaster","Fatebreaker: no unresolved enemy die is eligible; the gained Action Reroll remains.",g.pending.hero);finish_fate(g);return true
static func mirror_trigger(g, hero: int, victim: int) -> bool:
 if not enabled(g) or victim<0 or victim>=g.unit_count():return false
 return (g.friendly(victim) or (g.TrialRules.objective_unit(g,victim) and g.unit_data(victim).trial_object=="spirit")) and g.distance(hero,victim)<=2
static func mirror(g, hero: int, victim: int, source: int) -> void:
 g.unit_data(victim).block += 2
 g.trial_state.mirrors.append({"hero":hero,"victim":victim,"source":source,"hp":g.unit_data(victim).hp})
 g.record_event("reaction","Mirror of the Damned grants %s 2 Block; reflect 1 only if the whole Attack causes no HP loss." % g.unit_name(victim),hero,victim,2)
static func complete_mirrors(g) -> void:
 if not enabled(g) or not g.pending.is_empty():return
 var queue: Array = g.trial_state.get("mirrors",[]).duplicate();g.trial_state.mirrors = []
 for entry in queue:
  if g.outcome!="":break
  var victim: Dictionary = g.unit_data(int(entry.victim));var source: int = int(entry.source)
  if victim.hp!=entry.hp or victim.get("dead",false) or source<0 or source>=g.unit_count() or g.unit_data(source).hp<=0 or g.unit_data(source).get("dead",false):continue
  var old_owner: int = g.action_owner;var old_label: String = g.action_label;g.action_owner = entry.hero;g.action_label = "Mirror of the Damned reflection"
  g.damage(source,1,false,"Mirror of the Damned reflection",int(entry.hero));g.action_owner = old_owner;g.action_label = old_label
static func offer_omen(g) -> bool:
 if not enabled(g) or g.active not in range(3) or not g.pending.is_empty() or g.outcome!="" or not g.burden_interrupt.is_empty():return false
 var h: Dictionary = g.heroes[g.active]
 if not h.get("omen_ready",false) or h.get("omen_prompted",false):return false
 h.omen_prompted = true;g.pending = {"kind":"soul_omen","hero":g.active};return true
static func open_omen(g) -> bool:
 if not enabled(g) or g.active not in range(3) or not g.pending.is_empty() or not g.heroes[g.active].get("omen_ready",false):return false
 g.pending = {"kind":"soul_omen","hero":g.active};return true
static func later_omen(g) -> void:
 if g.pending.get("kind","")=="soul_omen":g.pending = {}
static func prepare_friendly_mirror(g, die: int, target: int, destination: Vector2i) -> bool:
 if not enabled(g) or g.trial_state.get("friendly_mirror_guard",false) or target not in range(3) or target==g.active:return false
 var face: int = g.face(g.active,die)
 if face not in [1,34,35,36,37,38,39,40,41] or g.distance(g.active,target)>g.face_range(face) or (face==35 and not g.sight(g.active,target,g.face_range(face))):return false
 var choices: Array = []
 for hero in range(3):
  if g.heroes[hero].hp<=0 or g.heroes[hero].dead:continue
  for held_die in g.heroes[hero].reaction:
   if g.face(hero,int(held_die))==77 and mirror_trigger(g,hero,target):choices.append({"hero":hero,"die":int(held_die)})
 if choices.is_empty():return false
 g.pending = {"kind":"soul_friendly_mirror","choices":choices,"index":0,"attack_die":die,"victim":target,"attacker":g.active,"destination":destination}
 return true
static func friendly_mirror(g, use: bool) -> bool:
 if g.pending.get("kind","")!="soul_friendly_mirror":return false
 var p: Dictionary = g.pending.duplicate(true);var choice: Dictionary = p.choices[int(p.index)]
 if use:
  g.heroes[int(choice.hero)].reaction.erase(int(choice.die));mirror(g,int(choice.hero),int(p.victim),int(p.attacker))
 p.index += 1
 if int(p.index)<p.choices.size():g.pending = p;return true
 g.pending = {};g.trial_state.friendly_mirror_guard = true
 var waiting: bool = g.prepare_friendly_evasive(int(p.attack_die),int(p.victim),p.destination)
 g.trial_state.friendly_mirror_guard = false
 if waiting:return true
 g.resuming_friendly_attack = true
 var resolved: bool = g.hero_action(int(p.attack_die),int(p.victim),p.destination)
 g.resuming_friendly_attack = false;complete_mirrors(g);return resolved
