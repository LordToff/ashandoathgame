extends "res://prototype/battle.gd"
## The interrupt experiment belongs only to the Trial Hollow.
var rupture_resolved := false
var rupture_cancelled := false
var core_id := -1
func prepare_encounter() -> void:
 super.prepare_encounter()
 rupture_resolved = false;rupture_cancelled = false
 minions.append(TrialRules.object_data("Rupture Core",Vector2i(4,6),2,"core"));core_id = unit_count()-1
func boss_dice() -> Array:
 var dice: Array = super.boss_dice().duplicate(true)
 if round_no>=2 and not rupture_resolved:dice[0] = range(6).map(func(_side):return "Rupture cancelled" if rupture_cancelled else "Soul Rupture")
 return dice
func cells(id: int, at: Vector2i = Vector2i(-99,-99)) -> Array:
 return [at if at.x!=-99 else unit_data(id).pos] if id==core_id else super.cells(id,at)
func harvest_death(id: int) -> void:
 if id!=core_id:super.harvest_death(id);return
 rupture_cancelled = true
 for index in range(boss_index if active==3 else 0,boss_rolls.size()):
  if boss_rolls[index]=="Soul Rupture":boss_rolls[index] = "Rupture cancelled"
 record_event("objective","Rupture Core destroyed: Soul Rupture is cancelled. The Hollow loses that action.",action_owner,id)
func boss_step() -> void:
 if active!=3 or outcome!="" or not pending.is_empty():return
 if boss_index<3 and boss_rolls[boss_index] in ["Soul Rupture","Rupture cancelled"]:
  begin_action(3,"Soul Rupture",-1,boss_index);boss_index += 1;rupture_resolved = true;last_action = "Soul Rupture"
  if rupture_cancelled:
   last_boss_result = "Soul Rupture cancelled: the core was destroyed."
   record_event("interrupt",last_boss_result,3);return
  var victims: Array = attack_targets(3,99)
  pending = {"kind":"attack","action":"Soul Rupture","victims":victims,"reacted":[],"amount":3,"source":3,"range":99,"needs_sight":false,"area":true}
  if victims.is_empty():pending = {}
  else:continue_attack()
  if core_id>=0:unit_data(core_id).hp = 0;unit_data(core_id).dead = true
  return
 super.boss_step()
func enemy_intent(source: int, action: String, slot: int) -> Dictionary:
 if action in ["Soul Rupture","Rupture cancelled"]:
  return {"source":3,"slot":slot,"action":action,"policy":"All standing heroes and friendly summons","target":-1,"target_text":"Cancelled — core broken" if rupture_cancelled else "All allies · 3 damage","detail":rupture_help(),"done":active==3 and slot<boss_index}
 return super.enemy_intent(source,action,slot)
func default_boss_help(action: String) -> String:
 return rupture_help() if action in ["Soul Rupture","Rupture cancelled"] else super.default_boss_help(action)
func intent_effect(action: String) -> String:
 return rupture_help() if action in ["Soul Rupture","Rupture cancelled"] else super.intent_effect(action)
func summon_description(id: int) -> String:
 return rupture_help() if id==core_id else super.summon_description(id)
func objective_summary() -> String:
 if rupture_resolved:return "Rupture cancelled" if rupture_cancelled else "Soul Rupture resolved"
 return "Core broken · Rupture cancelled" if rupture_cancelled else "Break core · 2 HP · Rupture in R2"
func rupture_help() -> String:
 return "TRIAL EXPERIMENT: the violet Rupture Core has 2 HP at G5. At the Hollow’s first action in round 2, Soul Rupture deals 3 damage to all standing heroes and friendly summons, ignoring distance. Block and Reactions work. Destroy the core with Attacks before that action to cancel it. The core cannot move or receive Poison. This happens once; normal Hollow fire and phase mechanics continue."

func shared_roll() -> void:
 super.shared_roll()
 if round_no<2 or rupture_resolved or boss_rolls.size()!=3:return
 if boss_rolls[0]=="Bound":rupture_resolved = true;return
 if boss_rolls[0]=="Furnace Roar":roar_queued = true
 boss_rolls[0] = "Rupture cancelled" if rupture_cancelled else "Soul Rupture"
 for display in roll_presentations:
  if display.actor==boss_name() and display.kind=="Shared roll":
   display.faces[0] = range(6).map(func(_side):return boss_rolls[0]);display.results[0] = boss_rolls[0]
 record_event("intent",boss_rolls[0]+" replaces the Hollow’s first die this round. "+rupture_help(),3)
func check_phase() -> void:
 var reserved: bool = not rupture_resolved and boss_rolls.size()==3 and boss_rolls[0] in ["Soul Rupture","Rupture cancelled"] and (active!=3 or boss_index==0)
 super.check_phase()
 if reserved and boss_rolls[0]=="Furnace Roar":
  boss_rolls[0] = "Rupture cancelled" if rupture_cancelled else "Soul Rupture";roar_queued = true
