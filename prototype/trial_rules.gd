extends RefCounted
## Shared equipment hooks; arena terrain and objectives remain gated by trial.enabled.
const Equipment = preload("res://prototype/equipment.gd")
const Soulcaster = preload("res://prototype/soulcaster.gd")
const Classes = preload("res://prototype/trial_classes.gd")
const MEMORIES = {
 "":{"name":"No Memory","text":"Empty for the first encounter. Equip an earned Memory later for a passive effect."},
 "venom":{"name":"Memory of Venom","text":"Your first own-turn Attack that damages an enemy adds Poison 1. Healing you receive restores 1 less HP."},
 "guard":{"name":"Memory of Guard","text":"When Block prevents all HP damage from an enemy Attack, your next Attack against an enemy deals +1 damage."},
 "shelter":{"name":"Memory of Shelter","text":"Your first own-turn Defense ability grants 1 extra Block."},
 "stride":{"name":"Memory of Momentum","text":"Move at least 2 spaces during your turn: your next Attack against an enemy deals +1 damage, once that turn."}
}
const SOULS = Equipment.SOULS
const BODIES = Equipment.BODIES
const WEAPONS = Equipment.WEAPONS
static func enabled(g) -> bool:return bool(g.balance.get("trial.enabled",false))
static func gear_enabled(g) -> bool:return enabled(g) or Equipment.active(g.balance)
static func memory(g, hero: int) -> String:return Equipment.key(g.balance,"memories",hero) if Equipment.active(g.balance) else str(g.balance.get("trial.memories",["","",""])[hero])
static func weapon(g, hero: int) -> String:return Equipment.key(g.balance,"weapons",hero)
static func body(g, hero: int) -> String:return Equipment.body_key(Equipment.key(g.balance,"bodies",hero))
static func weapon_slot(build: Array) -> Vector2i:
 for die in range(build.size()):
  for side in range(build[die].size()):
   if int(build[die][side])==1:return Vector2i(die,side)
 return Vector2i(-1,-1)
static func effective_face(g, hero: int, rolled: int, die: int = -1, side: int = -1) -> int:
 if not gear_enabled(g) or rolled!=1 or die<0:return rolled
 var h: Dictionary = g.heroes[hero]
 var shown: int = side if side>=0 else int(h.rolls[die])
 var replacements: Array = WEAPONS.get(weapon(g,hero),WEAPONS[""]).replacements
 var slots: Array = h.get("weapon_slots",[])
 var index: int = slots.find(Vector2i(die,shown))
 return int(replacements[index]) if index>=0 and index<replacements.size() else rolled
static func soul(g, hero: int) -> String:
 var equipped: String = Equipment.key(g.balance,"souls",hero)
 return Equipment.soul_key(equipped)
static func setup(g) -> void:
 g.trial_state = {}
 if not gear_enabled(g):return
 g.trial_state = {"positions":{},"crates":[],"cover":[],"spikes":[],"charges":[],"purse":int(g.balance.get("trial.purse",0)),"escaped":0}
 match g.balance.get("trial.terrain","cover" if enabled(g) else ""):
  "cover":g.trial_state.cover = [Vector2i(1,5),Vector2i(7,5),Vector2i(2,6),Vector2i(6,6)]
  "crates":g.trial_state.crates = [Vector2i(2,5),Vector2i(6,5)]
  "spikes":g.trial_state.spikes = [Vector2i(3,5),Vector2i(5,5)]
 var saved: Array = g.balance.get("trial.hp",[])
 for id in range(3):
  var h: Dictionary = g.heroes[id]
  h.weapon_slots = []
  for die in range(3):
   for side in range(6):
    if int(h.build[die][side])==1:h.weapon_slots.append(Vector2i(die,side))
  h.max_hp = int(Equipment.SOULS.get(soul(g,id),Equipment.SOULS.beginning).hp)
  h.hp = mini(h.max_hp,int(saved[id])) if saved.size()==3 else h.max_hp
  if h.hp<=0:h.dead = true;h.used = [true,true,true]
  if soul(g,id)=="hollow":h.poison = 1;h.poison_source = id
  if soul(g,id)=="cantor":h.rerolls = 0
 Soulcaster.setup(g)
 for id in range(g.unit_count()):g.trial_state.positions[id] = g.unit_data(id).pos
static func turn_start(g, hero: int) -> void:
 if not gear_enabled(g) or hero not in range(3):return
 Soulcaster.turn_start(g,hero)
 var h: Dictionary = g.heroes[hero]
 h.trial_weapon_used = false;h.trial_attack_used = false;h.trial_shelter_used = false;h.trial_venom_used = false;h.trial_stride_used = false;h.trial_cinder_used = false;h.trial_brood_used = false;h.trial_echo_used = false
static func attack_bonus(g, d: int, target: int, weapon_attack: bool) -> Dictionary:
 var result := {"bonus":0,"venom":false,"heavy":false,"pierce":0}
 if not gear_enabled(g):return result
 var equipped: Dictionary = WEAPONS.get(weapon(g,g.active),WEAPONS[""])
 result.pierce = int(equipped.modifiers.get("pierce",0))
 result.bonus = int(equipped.modifiers.get("damage",0))
 if not g.enemies(g.active,target):return result
 var h: Dictionary = g.heroes[g.active]
 if h.get("trial_counter",false):result.bonus += 1;h.trial_counter = false;g.note("Memory of Guard: counterattack +1.")
 if memory(g,g.active)=="stride" and int(h.get("moved_turn",0))>=2 and not h.get("trial_stride_used",false) and g.burden_interrupt.is_empty():
  result.bonus += 1;h.trial_stride_used = true;g.note("Memory of Momentum: movement empowers this Attack +1.")
 result.bonus += int(h.get("trial_echo",0));h.trial_echo = 0
 var face: int = g.face(g.active,d) if d>=0 else -1
 if weapon_attack and face==82:result.venom = true
 if weapon_attack and face==83:result.bonus += 1;result.heavy = true
 return result
static func after_hit(g, target: int, lost: int, mod: Dictionary) -> void:
 if immobile_object(g,target) or not gear_enabled(g) or lost<=0 or g.outcome!="" or not g.enemies(g.active,target) or g.unit_data(target).hp<=0:return
 var h: Dictionary = g.heroes[g.active];var own: bool = g.burden_interrupt.is_empty()
 if own and memory(g,g.active)=="venom" and not h.get("trial_venom_used",false):
  h.trial_venom_used = true;g.apply_poison(g.active,target,1)
 if own and soul(g,g.active)=="hollow" and not h.get("trial_cinder_used",false):
  h.trial_cinder_used = true;g.apply_poison(g.active,target,1)
 if mod.venom:g.apply_poison(g.active,target,1)
static func after_attack(g, mod: Dictionary) -> void:
 if gear_enabled(g) and mod.heavy and g.outcome=="":g.damage(g.active,1,true,"Heavy Dagger cost",g.active)
static func poison_spread(g, source: int, target: int) -> void:
 if not gear_enabled(g) or source not in range(3) or g.active!=source or not g.burden_interrupt.is_empty() or soul(g,source)!="nugh" or g.heroes[source].get("trial_brood_used",false):return
 g.heroes[source].trial_brood_used = true
 for id in [3]+g.living_minions():
  if id!=target and g.enemies(source,id) and g.unit_data(id).hp>0 and g.distance(target,id)<=1:
   g.apply_poison(source,id,1);g.note("Brood Soul spreads Poison to "+g.unit_name(id)+".");return
static func spent(g, d: int) -> void:
 if not gear_enabled(g) or not g.burden_interrupt.is_empty() or g.heroes[g.active].used[d]:return
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
 if not gear_enabled(g) or id not in range(3) or incoming<=0 or lost>0 or absorbed<=0 or attacker<3 or g.friendly(attacker) or memory(g,id)!="guard":return
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
  var key := memory(g,id);text += "\n"+g.unit_name(id)+" · "+Classes.name_for(str(g.balance.get("trial.classes",["","",""])[id]))+"\nBody: "+BODIES[body(g,id)].name+"\n"+BODIES[body(g,id)].text+"\nMemory: "+memory_data(key).name+"\n"+memory_data(key).text+"\nWeapon: "+WEAPONS[weapon(g,id)].name+"\n"+WEAPONS[weapon(g,id)].text
  var h: Dictionary = g.heroes[id]
  if h.get("trial_counter",false):text += "\nCounterattack +1 READY"
  if key=="stride" and int(h.get("moved_turn",0))>=2 and not h.get("trial_stride_used",false):text += "\nMovement bonus +1 READY"
  if int(h.get("trial_echo",0))>0:text += "\nEcho +1 READY"
  var s := soul(g,id)
  text += "\nSoul: "+(SOULS[s].name+" · "+SOULS[s].text if SOULS.has(s) else "Beginning Soul · 6 HP / 2 Blanks per die; Last Ember once per encounter.")
 return text

static func weapon_reason(g, face: int, target: int = -1) -> String:
 if not gear_enabled(g) or not Equipment.FACES.has(face):return "Equip a Weapon to use this face."
 if g.active not in range(3) or not g.burden_interrupt.is_empty():return "Use this weapon during your own turn."
 var h: Dictionary = g.heroes[g.active]
 if face!=84 and h.get("trial_weapon_used",false):return "This weapon ability was already used this own turn."
 if face in [81,82,83] and not h.get("damaged_enemy_turn",false):return "First deal actual HP damage to an enemy this own turn."
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
 if face!=84:h.trial_weapon_used = true
 if face in [73,84]:g.strike(die,target,1)
 elif face in [81,82,83]:g.strike(die,target,1,0,false,true)
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

static func memory_data(key: String) -> Dictionary:return Equipment.BLANK_MEMORIES.get(key,MEMORIES.get(key,MEMORIES[""]))
