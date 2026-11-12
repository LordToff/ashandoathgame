extends RefCounted
## Experimental rules are gated by trial.enabled. Normal encounters do not use them.
const Soulcaster = preload("res://prototype/soulcaster.gd")
const Classes = preload("res://prototype/trial_classes.gd")
const MEMORIES = {
 "":{"name":"No Memory","text":"No automatic bonus or maximum-HP penalty."},
 "venom":{"name":"Memory of Venom","text":"Your first own-turn Attack that damages an enemy adds Poison 1. Healing you receive restores 1 less HP."},
 "guard":{"name":"Memory of Guard","text":"When Block prevents all HP damage from an enemy Attack, your next Attack against an enemy deals +1 damage. Maximum HP -1."},
 "shelter":{"name":"Memory of Shelter","text":"Your first own-turn Defense ability grants 1 extra Block. Maximum HP -1."},
 "stride":{"name":"Memory of Momentum","text":"Move at least 2 spaces during your turn: your next Attack against an enemy deals +1 damage, once that turn. Maximum HP -1."}
}
const SOULS = {
 "soulcaster":{"name":"Soulcaster","text":"Starter Soul. 6 base maximum HP before Memory penalties; at least 4 Blanks per die. Each rolled Blank can Gather 1 Soul Charge (cap 3), or Manifest a spell for charges + 1 HP. Start each encounter at 0 charges; up to 4 spells. New spells must be rolled on a later turn. Replaces Blank movement; starting dice adapt automatically."},
 "hearth":{"name":"Hearth Soul","text":"Spend one rolled Blank to heal yourself 1 HP, once per own turn. Replaces Blank movement."},
 "wind":{"name":"Wind Soul","text":"Spend one rolled Blank as Move 2, once per own turn. Replaces Beginning Soul’s Move 1."},
 "hollow":{"name":"Cinder Soul","text":"First HP-damaging Attack each own turn adds Poison 1. Start each encounter with 1 Poison."},
 "nugh":{"name":"Brood Soul","text":"First Poison you apply each own turn spreads Poison 1 to another adjacent enemy. Maximum HP -1."},
 "cantor":{"name":"Echo Soul","text":"Your first Skill each own turn grants +1 next-Attack damage. Start with 0 Action Rerolls."},
 "bugh":{"name":"Warden Soul","text":"Preserve up to 2 Block at turn start. Movement abilities travel 1 less space, minimum 1."}
}
const BODIES = {
 "broken":{"name":"Broken Body","hp":6,"text":"6 base HP. At least 2 Blanks per die; maximum 3 Movement, 3 Defense and 3 Skill faces per hero."},
 "fleet":{"name":"Fleet Body","hp":5,"text":"5 base HP. Movement abilities travel 1 extra space. Blank movement stays unchanged. Normal dice limits."},
 "stone":{"name":"Stone Body","hp":7,"text":"7 base HP. Movement abilities travel 1 less space, minimum 1. Blank movement stays unchanged. Normal dice limits."}
}
static func enabled(g) -> bool:return bool(g.balance.get("trial.enabled",false))
const WEAPONS = {
 "spear":{"name":"Spear","text":"Replaces one Strike side with Jab: 1 damage within 2. Move at least 2 spaces first. Once per own turn; spends its rolled die."},
 "hammer":{"name":"Hammer","text":"Replaces one Strike side with Crack: remove up to 2 Block from an adjacent enemy after another Attack this turn. No HP damage. Once per own turn; spends its rolled die."},
 "dagger":{"name":"Dagger","text":"Poke: 1 adjacent-enemy damage, once per own turn after you have damaged an enemy. Costs no die."},
 "venom":{"name":"Poison Dagger","text":"Poke: deal 1 damage to an adjacent enemy; if it loses HP, apply Poison 1. Once per own turn after you have damaged an enemy. Costs no die."},
 "heavy":{"name":"Heavy Dagger","text":"Poke: deal 2 damage to an adjacent enemy, then lose 1 HP. Once per own turn after you have damaged an enemy. Costs no die. No HP cost after victory."}
}
static func memory(g, hero: int) -> String:return str(g.balance.get("trial.memories",["venom","guard","stride"])[hero])
static func weapon(g, hero: int) -> String:return str(g.balance.get("trial.weapons",["dagger","dagger","dagger"])[hero])
static func body(g, hero: int) -> String:return str(g.balance.get("trial.bodies",["broken","broken","broken"])[hero])
static func weapon_slot(build: Array) -> Vector2i:
 for die in range(build.size()):
  for side in range(build[die].size()):
   if int(build[die][side])==1:return Vector2i(die,side)
 return Vector2i(-1,-1)
static func effective_face(g, hero: int, rolled: int, die: int = -1, side: int = -1) -> int:
 if not enabled(g) or rolled!=1 or die<0:return rolled
 var h: Dictionary = g.heroes[hero]
 var slot: Vector2i = h.get("trial_weapon_slot",weapon_slot(h.build))
 var shown: int = side if side>=0 else int(h.rolls[die])
 if slot!=Vector2i(die,shown):return rolled
 return 73 if weapon(g,hero)=="spear" else 74 if weapon(g,hero)=="hammer" else rolled
static func soul(g, hero: int) -> String:return str(g.balance.get("trial.souls",["","",""])[hero])
static func setup(g) -> void:
 g.trial_state = {}
 if not enabled(g):return
 g.trial_state = {"positions":{},"crates":[],"cover":[],"spikes":[],"charges":[],"purse":int(g.balance.get("trial.purse",0)),"escaped":0}
 match g.balance.get("trial.terrain","cover"):
  "cover":g.trial_state.cover = [Vector2i(1,5),Vector2i(7,5),Vector2i(2,6),Vector2i(6,6)]
  "crates":g.trial_state.crates = [Vector2i(2,5),Vector2i(6,5)]
  "spikes":g.trial_state.spikes = [Vector2i(3,5),Vector2i(5,5)]
 var saved: Array = g.balance.get("trial.hp",[])
 for id in range(3):
  var h: Dictionary = g.heroes[id]
  h.trial_weapon_slot = weapon_slot(h.build)
  h.max_hp = (6 if soul(g,id)=="soulcaster" else int(BODIES[body(g,id)].hp))-(0 if memory(g,id) in ["","venom"] else 1)
  if soul(g,id)=="nugh":h.max_hp -= 1
  h.hp = mini(h.max_hp,int(saved[id])) if saved.size()==3 else h.max_hp
  if h.hp<=0:h.dead = true;h.used = [true,true,true]
  if soul(g,id)=="hollow":h.poison = 1;h.poison_source = id
  if soul(g,id)=="cantor":h.rerolls = 0
 Soulcaster.setup(g)
 for id in range(g.unit_count()):g.trial_state.positions[id] = g.unit_data(id).pos
static func turn_start(g, hero: int) -> void:
 if not enabled(g) or hero not in range(3):return
 Soulcaster.turn_start(g,hero)
 var h: Dictionary = g.heroes[hero]
 h.trial_weapon_used = false;h.trial_attack_used = false;h.trial_shelter_used = false;h.trial_venom_used = false;h.trial_stride_used = false;h.trial_cinder_used = false;h.trial_brood_used = false;h.trial_echo_used = false
static func attack_bonus(g, d: int, target: int, weapon: bool) -> Dictionary:
 var result := {"bonus":0,"venom":false,"heavy":false}
 if not enabled(g) or not g.enemies(g.active,target):return result
 var h: Dictionary = g.heroes[g.active]
 if h.get("trial_counter",false):result.bonus += 1;h.trial_counter = false;g.note("Memory of Guard: counterattack +1.")
 if memory(g,g.active)=="stride" and int(h.get("moved_turn",0))>=2 and not h.get("trial_stride_used",false) and g.burden_interrupt.is_empty():
  result.bonus += 1;h.trial_stride_used = true;g.note("Memory of Momentum: movement empowers this Attack +1.")
 result.bonus += int(h.get("trial_echo",0));h.trial_echo = 0
 var equipped: String = str(g.balance.get("trial.weapons",["dagger","dagger","dagger"])[g.active])
 if weapon and equipped=="venom":result.venom = true
 if weapon and equipped=="heavy":result.bonus += 1;result.heavy = true
 return result
static func after_hit(g, target: int, lost: int, mod: Dictionary) -> void:
 if immobile_object(g,target) or not enabled(g) or lost<=0 or g.outcome!="" or not g.enemies(g.active,target) or g.unit_data(target).hp<=0:return
 var h: Dictionary = g.heroes[g.active];var own: bool = g.burden_interrupt.is_empty()
 if own and memory(g,g.active)=="venom" and not h.get("trial_venom_used",false):
  h.trial_venom_used = true;g.apply_poison(g.active,target,1)
 if own and soul(g,g.active)=="hollow" and not h.get("trial_cinder_used",false):
  h.trial_cinder_used = true;g.apply_poison(g.active,target,1)
 if mod.venom:g.apply_poison(g.active,target,1)
static func after_attack(g, mod: Dictionary) -> void:
 if enabled(g) and mod.heavy and g.outcome=="":g.damage(g.active,1,true,"Heavy Dagger cost",g.active)
static func poison_spread(g, source: int, target: int) -> void:
 if not enabled(g) or source not in range(3) or g.active!=source or not g.burden_interrupt.is_empty() or soul(g,source)!="nugh" or g.heroes[source].get("trial_brood_used",false):return
 g.heroes[source].trial_brood_used = true
 for id in [3]+g.living_minions():
  if id!=target and g.enemies(source,id) and g.unit_data(id).hp>0 and g.distance(target,id)<=1:
   g.apply_poison(source,id,1);g.note("Brood Soul spreads Poison to "+g.unit_name(id)+".");return
static func spent(g, d: int) -> void:
 if not enabled(g) or not g.burden_interrupt.is_empty() or g.heroes[g.active].used[d]:return
 var h: Dictionary = g.heroes[g.active]
 if memory(g,g.active)=="shelter" and g.Catalog.category(g.face(g.active,d))=="Defense" and not h.get("trial_shelter_used",false):
  h.trial_shelter_used = true;h.block += 1;g.record_event("buff","Memory of Shelter grants 1 extra Block.",g.active,g.active,1)
 if soul(g,g.active)=="cantor" and g.Catalog.category(g.face(g.active,d))=="Skill" and not h.get("trial_echo_used",false):
  h.trial_echo_used = true;h.trial_echo = int(h.get("trial_echo",0))+1;g.note("Echo Soul: next Attack +1.")
static func incoming(g, id: int, amount: int, unavoidable: bool, attacker: int) -> int:
 if not enabled(g) or unavoidable or amount<=0:return amount
 var source: int = attacker if attacker>=0 else g.action_owner
 if source>=0 and g.enemies(source,id) and g.distance(source,id)>1 and g.cells(id).any(func(cell):return cell in g.trial_state.cover):
  g.record_event("terrain","Cover reduces ranged damage by 1.",source,id,1);return maxi(0,amount-1)
 return amount
static func blocked(g, id: int, incoming: int, lost: int, absorbed: int, attacker: int) -> void:
 if not enabled(g) or id not in range(3) or incoming<=0 or lost>0 or absorbed<=0 or attacker<3 or g.friendly(attacker) or memory(g,id)!="guard":return
 g.heroes[id].trial_counter = true;g.record_event("buff","Memory of Guard: next Attack +1 after a perfect block.",id,id,1)
static func blocked_cell(g, cell: Vector2i) -> bool:
 return enabled(g) and cell in g.trial_state.get("crates",[])
static func smash(g, d: int, cell: Vector2i) -> bool:
 if not blocked_cell(g,cell) or not g.Catalog.is_attack(g.face(g.active,d)) or absi(g.heroes[g.active].pos.x-cell.x)+absi(g.heroes[g.active].pos.y-cell.y)>1:return false
 g.begin_action(g.active,"Break barricade",-1,d);g.trial_state.crates.erase(cell)
 g.record_event("terrain","Barricade broken at "+g.cell_name(cell)+". The route and sightline open.",g.active)
 g.spend(d);return true
static func moved(g) -> void:
 if not enabled(g) or g.trial_state.is_empty():return
 var entered: Array = []
 for id in range(g.unit_count()):
  var unit: Dictionary = g.unit_data(id);var old: Vector2i = g.trial_state.positions.get(id,unit.pos)
  g.trial_state.positions[id] = unit.pos
  if old!=unit.pos and unit.hp>0 and not unit.get("dead",false) and g.cells(id).any(func(cell):return cell in g.trial_state.spikes):entered.append(id)
 for id in entered:
  if g.outcome!="":break
  g.record_event("terrain",g.unit_name(id)+" lands on spikes: 1 unavoidable damage. Forced movement counts.",-1,id,1)
  g.damage(id,1,true,"Spikes",-1)
static func guide(g) -> String:
 var text := "TRIAL ARENA · %d carried Run Essence\n" % int(g.trial_state.get("purse",0))
 if not g.trial_state.get("cover",[]).is_empty():text += "Blue cover: ranged damage from beyond 1 is reduced by 1. Melee and Poison ignore cover.\n"
 if not g.trial_state.get("crates",[]).is_empty():text += "Brown barricades block movement and sight. Select an Attack, then tap an adjacent barricade to spend that result and break it.\n"
 if not g.trial_state.get("spikes",[]).is_empty():text += "Red spikes: landing on a tile deals 1 unavoidable damage, including forced movement. Staying there causes no extra ticks.\n"
 text += "Gold striped tiles: a Ram’s charge is locked to those tiles until the next enemy turn. Step aside to avoid its 3 damage.\n"
 for id in range(3):
  var key := memory(g,id);text += "\n"+g.unit_name(id)+" · "+Classes.name_for(str(g.balance.get("trial.classes",["","",""])[id]))+"\nBody: "+BODIES[body(g,id)].name+"\n"+BODIES[body(g,id)].text+"\nMemory: "+MEMORIES[key].name+"\n"+MEMORIES[key].text+"\nWeapon: "+WEAPONS[weapon(g,id)].name+"\n"+WEAPONS[weapon(g,id)].text
  var h: Dictionary = g.heroes[id]
  if h.get("trial_counter",false):text += "\nCounterattack +1 READY"
  if key=="stride" and int(h.get("moved_turn",0))>=2 and not h.get("trial_stride_used",false):text += "\nMovement bonus +1 READY"
  if int(h.get("trial_echo",0))>0:text += "\nEcho +1 READY"
  var s := soul(g,id)
  text += "\nSoul: "+(SOULS[s].name+" · "+SOULS[s].text if SOULS.has(s) else "Beginning Soul · spend one rolled Blank as Move 1, once per own turn.")
 return text

static func weapon_reason(g, face: int, target: int = -1) -> String:
 if not enabled(g) or face not in [73,74]:return "This is a Trial weapon face."
 if g.active not in range(3) or not g.burden_interrupt.is_empty():return "Use this weapon during your own turn."
 var h: Dictionary = g.heroes[g.active]
 if h.get("trial_weapon_used",false):return "This weapon ability was already used this own turn."
 if face==73 and int(h.get("moved_turn",0))<2:return "Jab requires at least 2 spaces moved this turn."
 if face==74 and not h.get("trial_attack_used",false):return "Use another Attack before Crack this turn."
 if target>=0:
  if not g.enemies(g.active,target) or g.unit_data(target).hp<=0:return "Choose a living enemy."
  if g.distance(g.active,target)>g.face_range(face):return "Target is out of range."
  if face==74 and g.unit_data(target).block<=0:return "This target has no Block to crack."
 return ""
static func weapon_action(g, die: int, target: int) -> bool:
 var face: int = g.face(g.active,die)
 if target<0 or weapon_reason(g,face,target)!="":return false
 var h: Dictionary = g.heroes[g.active]
 g.begin_action(g.active,g.Catalog.name_for(face),target,die)
 h.trial_weapon_used = true
 if face==73:g.strike(die,target,1)
 else:
  var removed: int = g.remove_block(target,2)
  g.record_event("block_remove","Crack strips %d Block from %s; no HP damage." % [removed,g.unit_name(target)],g.active,target,removed)
 g.spend(die);return true
static func objective_unit(g, id: int) -> bool:
 return id>=4 and str(g.unit_data(id).get("trial_object",""))!=""
static func immobile_object(g, id: int) -> bool:
 return objective_unit(g,id) and g.unit_data(id).trial_object!="spirit"
static func object_data(name: String, at: Vector2i, hp: int, kind: String) -> Dictionary:
 return {"name":name,"pos":at,"hp":hp,"max_hp":hp,"block":0,"dead":false,"faction":"objective","trial_object":kind,"poison":0,"weak":0,"rooted":0}
