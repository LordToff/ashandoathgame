extends RefCounted
## Experimental rules are gated by trial.enabled. Normal encounters do not use them.
const PATHS = {
 "venom":{"name":"Venom pact","text":"First HP-damaging Attack each own turn adds Poison 1. Healing restores 1 less HP.","faces":[70,59,69]},
 "guard":{"name":"Iron vow","text":"Fully blocking a positive enemy Attack readies +1 damage on your next Attack. 5 maximum HP.","faces":[72,68,51]},
 "stride":{"name":"Wayfarer","text":"After moving 2 spaces in your own turn, your next Attack gains +1 damage, once that turn. 5 maximum HP.","faces":[67,66,53]}
}
const SOULS = {
 "hollow":{"name":"Cinder Soul","text":"First HP-damaging Attack each own turn adds Poison 1. Start each encounter with 1 Poison."},
 "nugh":{"name":"Brood Soul","text":"First Poison you apply each own turn spreads Poison 1 to another adjacent enemy. Maximum HP -1."},
 "cantor":{"name":"Echo Soul","text":"Your first Skill each own turn grants +1 next-Attack damage. Start with 0 Action Rerolls."},
 "bugh":{"name":"Warden Soul","text":"Preserve up to 2 Block at turn start. Movement abilities travel 1 less space, minimum 1."}
}
static func enabled(g) -> bool:return bool(g.balance.get("trial.enabled",false))
static func path(g, hero: int) -> String:return str(g.balance.get("trial.paths",["venom","guard","stride"])[hero])
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
  h.max_hp = 6 if path(g,id)=="venom" else 5
  if soul(g,id)=="nugh":h.max_hp -= 1
  h.hp = mini(h.max_hp,int(saved[id])) if saved.size()==3 else h.max_hp
  if h.hp<=0:h.dead = true;h.used = [true,true,true]
  if soul(g,id)=="hollow":h.poison = 1;h.poison_source = id
  if soul(g,id)=="cantor":h.rerolls = 0
 for id in range(g.unit_count()):g.trial_state.positions[id] = g.unit_data(id).pos
static func turn_start(g, hero: int) -> void:
 if not enabled(g) or hero not in range(3):return
 var h: Dictionary = g.heroes[hero]
 h.trial_venom_used = false;h.trial_stride_used = false;h.trial_cinder_used = false;h.trial_brood_used = false;h.trial_echo_used = false
static func attack_bonus(g, d: int, target: int, weapon: bool) -> Dictionary:
 var result := {"bonus":0,"venom":false,"heavy":false}
 if not enabled(g) or not g.enemies(g.active,target):return result
 var h: Dictionary = g.heroes[g.active]
 if h.get("trial_counter",false):result.bonus += 1;h.trial_counter = false;g.note("Iron vow: counterattack +1.")
 if path(g,g.active)=="stride" and int(h.get("moved_turn",0))>=2 and not h.get("trial_stride_used",false) and g.burden_interrupt.is_empty():
  result.bonus += 1;h.trial_stride_used = true;g.note("Wayfarer: movement empowers this Attack +1.")
 result.bonus += int(h.get("trial_echo",0));h.trial_echo = 0
 if not weapon:
  var key := "%d:%d:%d" % [g.active,d,h.rolls[d]]
  var mod: String = g.balance.get("trial.mods",{}).get(key,"")
  if mod=="venom":result.bonus -= 1;result.venom = true
  if mod=="heavy":result.bonus += 1;result.heavy = true
 return result
static func after_hit(g, target: int, lost: int, mod: Dictionary) -> void:
 if not enabled(g) or lost<=0 or g.outcome!="" or not g.enemies(g.active,target) or g.unit_data(target).hp<=0:return
 var h: Dictionary = g.heroes[g.active];var own: bool = g.burden_interrupt.is_empty()
 if own and path(g,g.active)=="venom" and not h.get("trial_venom_used",false):
  h.trial_venom_used = true;g.apply_poison(g.active,target,1)
 if own and soul(g,g.active)=="hollow" and not h.get("trial_cinder_used",false):
  h.trial_cinder_used = true;g.apply_poison(g.active,target,1)
 if mod.venom:g.apply_poison(g.active,target,1)
static func after_attack(g, mod: Dictionary) -> void:
 if enabled(g) and mod.heavy and g.outcome=="":g.damage(g.active,1,true,"Heavy edge cost",g.active)
static func poison_spread(g, source: int, target: int) -> void:
 if not enabled(g) or source not in range(3) or g.active!=source or not g.burden_interrupt.is_empty() or soul(g,source)!="nugh" or g.heroes[source].get("trial_brood_used",false):return
 g.heroes[source].trial_brood_used = true
 for id in [3]+g.living_minions():
  if id!=target and g.enemies(source,id) and g.unit_data(id).hp>0 and g.distance(target,id)<=1:
   g.apply_poison(source,id,1);g.note("Brood Soul spreads Poison to "+g.unit_name(id)+".");return
static func spent(g, d: int) -> void:
 if not enabled(g) or not g.burden_interrupt.is_empty() or g.heroes[g.active].used[d]:return
 var h: Dictionary = g.heroes[g.active]
 if soul(g,g.active)=="cantor" and g.Catalog.category(g.face(g.active,d))=="Skill" and not h.get("trial_echo_used",false):
  h.trial_echo_used = true;h.trial_echo = int(h.get("trial_echo",0))+1;g.note("Echo Soul: next Attack +1.")
static func incoming(g, id: int, amount: int, unavoidable: bool, attacker: int) -> int:
 if not enabled(g) or unavoidable or amount<=0:return amount
 var source: int = attacker if attacker>=0 else g.action_owner
 if source>=0 and g.enemies(source,id) and g.distance(source,id)>1 and g.cells(id).any(func(cell):return cell in g.trial_state.cover):
  g.record_event("terrain","Cover reduces ranged damage by 1.",source,id,1);return maxi(0,amount-1)
 return amount
static func blocked(g, id: int, incoming: int, lost: int, absorbed: int, attacker: int) -> void:
 if not enabled(g) or id not in range(3) or incoming<=0 or lost>0 or absorbed<=0 or attacker<3 or g.friendly(attacker) or path(g,id)!="guard":return
 g.heroes[id].trial_counter = true;g.record_event("buff","Iron vow: next Attack +1 after a perfect block.",id,id,1)
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
 var text := "TRIAL ARENA · %d carried Trial Essence\n" % int(g.trial_state.get("purse",0))
 if not g.trial_state.get("cover",[]).is_empty():text += "Blue cover: ranged damage from beyond 1 is reduced by 1. Melee and Poison ignore cover.\n"
 if not g.trial_state.get("crates",[]).is_empty():text += "Brown barricades block movement and sight. Select an Attack, then tap an adjacent barricade to spend that result and break it.\n"
 if not g.trial_state.get("spikes",[]).is_empty():text += "Red spikes: landing on a tile deals 1 unavoidable damage, including forced movement. Staying there causes no extra ticks.\n"
 text += "Gold striped tiles: a Ram’s charge is locked to those tiles until the next enemy turn. Step aside to avoid its 3 damage.\n"
 for id in range(3):
  var key := path(g,id);text += "\n"+g.unit_name(id)+" · "+PATHS[key].name+"\n"+PATHS[key].text
  var h: Dictionary = g.heroes[id]
  if h.get("trial_counter",false):text += "\nCounterattack +1 READY"
  if key=="stride" and int(h.get("moved_turn",0))>=2 and not h.get("trial_stride_used",false):text += "\nMovement bonus +1 READY"
  if int(h.get("trial_echo",0))>0:text += "\nEcho +1 READY"
  var s := soul(g,id)
  if SOULS.has(s):text += "\n"+SOULS[s].name+": "+SOULS[s].text
 return text
