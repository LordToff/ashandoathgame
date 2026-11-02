extends "res://prototype/battle.gd"
## Two ordinary one-cell monsters. Slot 3 shares existing enemy-turn controls.
var hard := false
var prototype_pack := false
const DICE = [["Scuttle","Scuttle","Bite","Bite","Guard","Bite"],["Scuttle","Bite","Guard","Bite","Scuttle","Bite"],["Bite","Guard","Scuttle","Bite","Guard","Scuttle"]]
func prepare_encounter() -> void:
 encounter_id = "event"
 if prototype_pack:
  var types: Array = ["support_creature","movement_creature","movement_creature"] if hard else ["bone_creature","bone_creature"]
  boss.essence_type = types[0];boss.hp = Essence.TYPES[types[0]].hp;boss.max_hp = boss.hp;boss.pos = Vector2i(3,4)
  for i in range(1,types.size()):
   var type: String = types[i];var hp: int = Essence.TYPES[type].hp
   minions.append({"name":Essence.type_name(type)+" "+str(i+1),"essence_type":type,"hp":hp,"max_hp":hp,"pos":Vector2i(5,3+i),"block":0,"dead":false,"faction":"enemy","weak":0,"rooted":0,"poison":0})
 else:
  boss.hp = 4 if hard else 3;boss.max_hp = boss.hp;boss.pos = Vector2i(3,4);boss.essence_type = "cinder_mite" if hard else "scavenger"
  minions.append({"name":boss_name()+" II","essence_type":boss.essence_type,"hp":boss.hp,"max_hp":boss.hp,"pos":Vector2i(5,4),"block":0,"dead":false,"faction":"enemy","weak":0,"rooted":0,"poison":0})

func boss_name() -> String:
 if prototype_pack:return Essence.type_name("support_creature" if hard else "bone_creature")
 return "Cinder Mite" if hard else "Ash Scavenger"
func cells(id: int, at: Vector2i = Vector2i(-99,-99)) -> Array:
 return [at if at.x != -99 else unit_data(id).pos]
func boss_dice() -> Array:return creature_dice(essence_type(3)) if prototype_pack else DICE
func check_phase() -> void:pass
func phase_upgrades() -> Array:return []
func phase_description() -> String:return "Ordinary monsters: no phase transition, no boss Soul. Defeat all creatures for the listed event reward."
func check_end() -> void:
 if atomic_damage:return
 if boss.hp <= 0:boss.dead = true
 if heroes.all(func(h):return h.dead or h.hp <= 0):outcome = "defeat"
 elif boss.hp <= 0 and living_minions().is_empty():outcome = "victory"
 if outcome != "":pending = {};note("All monsters defeated. Claim the event completion reward." if outcome == "victory" else "Party defeated. No event reward.")
func damage_minion(id: int, amount: int, unavoidable: bool = false, reason: String = "") -> void:
 super.damage_minion(id,amount,unavoidable,reason);check_end()
func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty():return
 if boss_index >= 3:finish_turn();return
 var action: String = boss_rolls[boss_index];boss_index += 1
 # Each monster gets the same public rolled result, one at a time; reactions remain available.
 queued_actions = []
 for id in [3]+living_minions():
  if unit_data(id).hp > 0:queued_actions.append({"id":id,"action":unit_data(id).get("creature_rolls",boss_rolls)[boss_index-1] if prototype_pack and id >= 4 else action})
 continue_monsters()
var queued_actions: Array = []
func continue_monsters():
 while not queued_actions.is_empty() and pending.is_empty() and outcome == "":
  var entry: Dictionary = queued_actions.pop_front();var id: int = entry.id;var action: String = entry.action
  if unit_data(id).hp <= 0:continue
  begin_action(id,action)
  if action == "Bound":note("Bound result: no action.");continue
  if action == "Mend":
   var wounded: Array = ([3]+living_minions()).filter(func(target):return unit_data(target).hp > 0 and unit_data(target).hp < unit_data(target).max_hp and distance(id,target) <= 2)
   if not wounded.is_empty():
    var target: int = wounded[0];unit_data(target).hp += 1;record_event("heal",unit_name(id)+" mends "+unit_name(target)+" for 1 HP (provisional AI).",id,target,1)
   else:note(unit_name(id)+" has no wounded ally in range 2; Mend does nothing.")
   continue
  if action == "Guard":unit_data(id).block += 1;note(unit_name(id)+" gains 1 Block.");continue
  var target := nearest_attacked(id,attack_targets(id,99))
  if target < 0:continue
  if action == "Scuttle":
   if unit_data(id).get("rooted",0) <= 0:move_friendly_summon(id,3 if essence_type(id) == "movement_creature" else 2)
   note(unit_name(id)+" scuttles up to %d cells." % (3 if essence_type(id) == "movement_creature" else 2))
  elif action == "Bite" and distance(id,target) <= 1:
   pending = {"kind":"attack","action":"Ordinary Bite","victims":[target],"reacted":[],"amount":maxi(0,1-int(unit_data(id).get("weak",0))) if id >= 4 else 1,"source":id,"range":1,"area":false}
   continue_attack()
  else:note(unit_name(id)+" has no target in Bite reach 1; holds.")
 report_changes()
func react(use: bool, dir: Vector2i = Vector2i.ZERO) -> void:
 super.react(use,dir)
 if pending.is_empty():continue_monsters()
func activate() -> void:
 super.activate()
 if active == 3:
  for id in living_minions():
   tick_poison(id);unit_data(id).block = 0;unit_data(id).weak = 0;unit_data(id).rooted = 0

func summon_description(id: int) -> String:
 if friendly(id):return super.summon_description(id)
 return "Ordinary monster, not a summon. Shares the public enemy dice. 1-cell footprint; Bite 1, Scuttle 2, Guard 1. No Poison on bite, no phase. " + super.summon_description(id).replace("Enemy summon.","")

func creature_dice(type: String) -> Array:
 if type == "support_creature":return [["Mend","Mend","Guard","Scuttle","Bite","Mend"],["Mend","Guard","Bite","Scuttle","Mend","Guard"],["Bite","Mend","Scuttle","Guard","Mend","Guard"]]
 if type == "movement_creature":return [["Scuttle","Bite","Bite","Scuttle","Guard","Bite"],["Bite","Scuttle","Bite","Guard","Scuttle","Bite"],["Scuttle","Guard","Bite","Scuttle","Bite","Guard"]]
 return DICE
func shared_roll() -> void:
 if prototype_pack:
  for id in living_minions():
   var dice := creature_dice(essence_type(id));var rolls: Array = []
   for die in dice:rolls.append(die[rng.randi_range(0,5)])
   unit_data(id).creature_rolls = rolls
 super.shared_roll()
func boss_display_action() -> String:
 return "Group die "+["I","II","III"][boss_index] if prototype_pack and boss_index < 3 else super.boss_display_action()
func default_boss_help(action: String) -> String:
 if prototype_pack:return "Provisional creature AI. Resolve this numbered result for each living creature, in card order. Each card lists its own public result. Scuttle moves 2 (Movement Creature: 3); Bite deals 1 in reach 1; Guard grants 1 Block; Support Mend heals one living ally within 2 by 1. No boss phases."
 return "Each living monster: "+{"Scuttle":"move up to 2 cells.","Bite":"1 normal damage in reach 1; no Poison.","Guard":"+1 Block until next enemy turn."}.get(action,"no action.")
