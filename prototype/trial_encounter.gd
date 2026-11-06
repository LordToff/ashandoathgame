extends "res://prototype/event_battle.gd"
## Original Trials role encounters; reuse standard attacks, Reactions and public dice.
const ROLES = {
 "shield":{"name":"Ash Shieldbearer","type":"iron_husk","hp":4,"dice":[["Shield Line","Scuttle","Bash","Shield Line","Guard","Bash"],["Shield Line","Bash","Scuttle","Guard","Shield Line","Bash"],["Bash","Guard","Shield Line","Scuttle","Bash","Guard"]]},
 "healer":{"name":"Whisper Mender","type":"support_creature","hp":3,"dice":[["Restitch","Restitch","Scuttle","Guard","Bite","Restitch"],["Restitch","Guard","Bite","Scuttle","Restitch","Guard"],["Bite","Restitch","Scuttle","Guard","Restitch","Guard"]]},
 "ram":{"name":"Cinder Ram","type":"bone_creature","hp":6,"dice":[["Mark Charge","Mark Charge","Scuttle","Bash","Guard","Mark Charge"],["Scuttle","Bash","Guard","Scuttle","Bash","Guard"],["Bash","Guard","Scuttle","Bash","Guard","Scuttle"]]},
 "thief":{"name":"Essence Cutpurse","type":"movement_creature","hp":4,"dice":[["Scuttle","Pilfer","Pilfer","Bite","Flee","Scuttle"],["Pilfer","Pilfer","Flee","Bite","Scuttle","Pilfer"],["Flee","Bite","Pilfer","Flee","Scuttle","Flee"]]},
 "archer":{"name":"Glasswing Sentry","type":"glasswing_moth","hp":2,"dice":[["Needle","Scuttle","Needle","Guard","Needle","Scuttle"],["Scuttle","Needle","Guard","Needle","Scuttle","Needle"],["Needle","Guard","Scuttle","Needle","Guard","Scuttle"]]}
}
const GROUPS = [
 {"title":"Ward & Whisper","roles":["shield","healer"],"elite":"archer","terrain":"cover","text":"Shieldbearer grants nearby allies Block, capped at 3; Mender repairs wounded allies. Blue cover softens ranged hits. Separate them or focus the Mender."},
 {"title":"The Long Charge","roles":["ram","archer"],"elite":"healer","terrain":"crates","text":"Ram marks a fixed charge lane for the next enemy turn. Step aside; break brown barricades with an adjacent Attack to open movement and sight."},
 {"title":"Essence Thieves","roles":["thief","thief"],"elite":"shield","terrain":"spikes","text":"Cutpurses steal 1 Trial Essence within 2, then flee toward the edge. Kill one to recover its loot; an escape loses it. Red spikes hurt any unit landing on them, including Shove targets."}
]
var group_index := 0
var elite := false
var roles: Array = []
func prepare_encounter() -> void:
 prototype_pack = true
 roles = GROUPS[group_index].roles.duplicate()
 if elite:roles.append(GROUPS[group_index].elite)
 creature_types = roles.map(func(role):return ROLES[role].type)
 super.prepare_encounter()
 for index in range(roles.size()):
  var id := index+3;var unit: Dictionary = unit_data(id);var role: String = roles[index]
  unit.trial_role = role;unit.hp = int(ROLES[role].hp)+(1 if elite else 0);unit.max_hp = unit.hp
  unit.pos = [Vector2i(3,4),Vector2i(4,4),Vector2i(5,3)][index];unit.loot = 0
func boss_name() -> String:return ROLES[roles[0]].name if not roles.is_empty() else "Trial creatures"
func unit_name(id: int) -> String:
 if id>=3 and id<3+roles.size():return ROLES[roles[id-3]].name+(" II" if id>3 and roles[id-3]==roles[0] else "")
 return super.unit_name(id)
func dice_for(id: int) -> Array:return ROLES[unit_data(id).trial_role].dice
func boss_dice() -> Array:return dice_for(3)
func creature_dice(type: String) -> Array:
 for role in roles:
  if ROLES[role].type==type:return ROLES[role].dice
 return super.creature_dice(type)
func creature_move(type: String) -> int:return 2 if type=="iron_husk" else super.creature_move(type)
func special_monster_action(id: int, action: String) -> bool:
 match action:
  "Shield Line":
   for ally in [3]+living_minions():
    if not friendly(ally) and unit_data(ally).hp>0 and distance(id,ally)<=1:
     var amount: int = mini(2,maxi(0,3-unit_data(ally).block))
     unit_data(ally).block += amount;record_event("block_gain",unit_name(id)+" shields "+unit_name(ally)+" for %d Block (Shield Line cap 3)." % amount,id,ally,amount)
   return true
  "Restitch":
   if unit_data(id).get("restitch_used",false):note("Restitch already used this enemy turn.");return true
   var options: Array = ([3]+living_minions()).filter(func(ally):return not friendly(ally) and unit_data(ally).hp>0 and unit_data(ally).hp<unit_data(ally).max_hp and distance(id,ally)<=3)
   var ally: int = mend_target(id,options,boss_index-1)
   if ally>=0:
    unit_data(id).restitch_used = true
    var amount: int = mini(2,unit_data(ally).max_hp-unit_data(ally).hp);unit_data(ally).hp += amount
    record_event("heal",unit_name(id)+" restitches "+unit_name(ally)+" for %d HP." % amount,id,ally,amount)
   else:note("Restitch: no wounded ally within 3.")
   return true
  "Mark Charge":
   var target: int = enemy_target(id,attack_targets(id,99),action)
   if target<0:return true
   if trial_state.charges.any(func(mark):return mark.source==id):note("Charge already marked; the lane stays fixed.");return true
   var delta: Vector2i = unit_data(target).pos-unit_data(id).pos
   var dir := Vector2i(signi(delta.x),0) if absi(delta.x)>absi(delta.y) else Vector2i(0,signi(delta.y))
   var tiles: Array = []
   for step in range(1,6):
    var cell: Vector2i = unit_data(id).pos+dir*step
    if cell.x<0 or cell.y<0 or cell.x>8 or cell.y>8 or TrialRules.blocked_cell(self,cell):break
    tiles.append(cell)
   trial_state.charges.append({"source":id,"tiles":tiles,"round":round_no})
   record_event("warning",unit_name(id)+" marks a fixed charge lane: 3 damage at next enemy turn start. Step off gold tiles.",id,target,3)
   return true
  "Pilfer":
   var target: int = enemy_target(id,attack_targets(id,2),action)
   if target>=0 and int(trial_state.purse)>0:
    trial_state.purse -= 1;unit_data(id).loot += 1
    record_event("theft",unit_name(id)+" steals 1 Trial Essence. Kill it before it escapes to recover the loot.",id,target,1)
   else:note("Pilfer: no hero within 2, or no Trial Essence to steal.")
   return true
  "Flee":
   if int(unit_data(id).loot)<=0:move_friendly_summon(id,2);return true
   for step in range(2):
    var origin: Vector2i = unit_data(id).pos;var best: Vector2i = origin;var best_score := -999
    for dir in DIRS:
     var cell: Vector2i = origin+dir
     if not legal(id,cell):continue
     var edge: int = mini(mini(cell.x,8-cell.x),mini(cell.y,8-cell.y))
     var nearest := 99
     for hero in attack_targets(id,99):nearest = mini(nearest,absi(cell.x-unit_data(hero).pos.x)+absi(cell.y-unit_data(hero).pos.y))
     var score: int = -edge*20+nearest
     if score>best_score:best_score = score;best = cell
    unit_data(id).pos = best
   TrialRules.moved(self)
   var p: Vector2i = unit_data(id).pos
   if unit_data(id).hp>0 and (p.x in [0,8] or p.y in [0,8]):
    var stolen: int = unit_data(id).loot;unit_data(id).loot = 0;unit_data(id).hp = 0;unit_data(id).dead = true;trial_state.escaped += stolen
    record_event("escape",unit_name(id)+" escapes with %d Trial Essence." % stolen,id,-1,stolen);check_end()
   else:note(unit_name(id)+" retreats toward the edge with its loot.")
   return true
 return false
func activate() -> void:
 super.activate()
 if active!=3 or outcome!="" or not pending.is_empty() or trial_state.is_empty():return
 for id in [3]+living_minions():
  if not friendly(id):unit_data(id).restitch_used = false
 var marks: Array = trial_state.charges.duplicate(true);trial_state.charges.clear()
 # There is one Ram per group. Its locked lane resolves before rolled actions.
 for mark in marks:
  var source: int = mark.source
  if unit_data(source).hp<=0 or unit_data(source).get("dead",false):continue
  var victims: Array = attack_targets(source,99).filter(func(id):return unit_data(id).pos in mark.tiles)
  if victims.is_empty():record_event("evade","Charge misses: nobody remains on its marked lane.",source);continue
  begin_action(source,"Ram Charge");pending = {"kind":"attack","action":"Ram Charge","victims":victims,"reacted":[],"amount":3,"source":source,"range":99,"needs_sight":false,"area":true,"tiles":mark.tiles};continue_attack()
func harvest_death(id: int) -> void:
 if friendly(id) or harvest_claimed.has(id):return
 harvest_claimed[id] = true
 var amount: int = int(unit_data(id).get("loot",0))
 if amount>0:trial_state.purse += amount;unit_data(id).loot = 0;record_event("recover","Recovered %d stolen Trial Essence." % amount,-1,id,amount)
 record_event("trial_death",unit_name(id)+" defeated. Clear the whole group for the Trial reward.",-1,id)
func enemy_intent(source: int, action: String, slot: int) -> Dictionary:
 var result: Dictionary = super.enemy_intent(source,action,slot)
 match action:
  "Shield Line":result.target = source;result.policy = "Living allies within 1";result.target_text = "Self and adjacent allies";result.detail = "+2 Block to self and each adjacent enemy ally, capped at 3 Block from this ability. Separate the group to prevent shared shields."
  "Restitch":
   var options: Array = ([3]+living_minions()).filter(func(id):return not friendly(id) and unit_data(id).hp>0 and unit_data(id).hp<unit_data(id).max_hp and distance(source,id)<=3)
   var target: int = mend_target(source,options,slot);result.target = target;result.target_text = unit_name(target) if target>=0 else "No wounded ally";result.policy = "Most missing HP within 3";result.detail = "Restore up to 2 HP to one wounded ally, once per enemy turn."
  "Mark Charge":result.target = enemy_target(source,attack_targets(source,99),action);result.target_text = unit_name(result.target) if result.target>=0 else "No target";result.policy = "Furthest hero; cardinal lane";result.detail = "Mark up to 5 gold tiles toward the focus. The fixed lane deals 3 damage at next enemy turn start; move off it or prepare Block. Reactions apply."
  "Pilfer":result.target = enemy_target(source,attack_targets(source,2),action);result.target_text = unit_name(result.target) if result.target>=0 else "Nobody within 2";result.policy = "Closest hero within 2";result.detail = "Steal 1 carried Trial Essence. Defeating the thief returns its loot; escaping loses it. No HP damage."
  "Flee":result.target = source;result.target_text = "Arena edge";result.policy = "Escape with stolen Essence";result.detail = "Move 2 away toward an edge. Reaching an edge while carrying loot removes this thief and its stolen Essence. Without loot, pursue a hero instead."
 return result
func default_boss_help(_action: String) -> String:return GROUPS[group_index].text
func phase_description() -> String:return GROUPS[group_index].text

func check_end() -> void:
 if atomic_damage or outcome!="":return
 if boss.hp<=0:boss.dead = true
 if heroes.all(func(h):return h.dead or h.hp<=0):outcome = "defeat"
 elif boss.hp<=0 and living_minions().is_empty():outcome = "victory"
 if outcome!="":
  pending = {};record_event("trial_result","Trial group cleared. Choose a reward before the next route." if outcome=="victory" else "Trial party defeated; this run ends.")
func boss_display_action() -> String:return "Turn complete" if boss_index>=3 else "Resolve group actions"
