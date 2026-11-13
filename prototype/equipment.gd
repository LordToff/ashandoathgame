extends RefCounted
## Shared four-slot rules. Bodies never constrain Attacks; Weapons alone do.
const VERSION = 40
const BODIES = {
 "broken":{"name":"Broken Body","limits":{"Defense":[0,3],"Movement":[0,3],"Skill":[0,3]},"text":"Defense 0–3 · Movement 0–3 · Skill 0–3 across all three dice. Attack limits come from your Weapon."},
 "fleet":{"name":"Fleet Body","limits":{"Defense":[0,2],"Movement":[0,4],"Skill":[0,3]},"text":"Defense 0–2 · Movement 0–4 · Skill 0–3 across all three dice. Movement uses its printed distance. Attack limits come from your Weapon."},
 "stone":{"name":"Stone Body","limits":{"Defense":[0,4],"Movement":[0,2],"Skill":[0,3]},"text":"Defense 0–4 · Movement 0–2 · Skill 0–3 across all three dice. Attack limits come from your Weapon."}
}
const SOULS = {
 "":{"name":"No Soul","hp":6,"blanks":2,"text":"6 HP · minimum 2 Blanks on every die. No strong Soul effect."},
 "beginning":{"name":"Beginning Soul","hp":6,"blanks":2,"text":"6 HP · minimum 2 Blanks on every die. Last Ember: once per encounter, lethal enemy damage leaves you at 1 HP. Does not prevent voluntary HP costs."},
 "soulcaster":{"name":"Soulcaster","hp":6,"blanks":4,"text":"6 HP · minimum 4 Blanks on every die. Gather Soul Charges or Manifest encounter spells using rolled Blanks. Charge cap 3; spell cap 4. Manifest costs charges + 1 HP. New spells activate only when rolled on a later turn."},
 "hollow":{"name":"Cinder Soul","hp":6,"blanks":3,"text":"6 HP · minimum 3 Blanks per die. Your first HP-damaging Attack each own turn adds Poison 1. Begin each encounter with Poison 1."},
 "ashroad":{"name":"Ash Road Soul","hp":6,"blanks":3,"text":"6 HP · minimum 3 Blanks per die. Last Ember: once per encounter, lethal enemy damage leaves you at 1 HP."},
 "nugh":{"name":"Brood Soul","hp":5,"blanks":3,"text":"5 HP · minimum 3 Blanks per die. First Poison you apply each own turn spreads Poison 1 to another adjacent enemy."},
 "cantor":{"name":"Echo Soul","hp":6,"blanks":3,"text":"6 HP · minimum 3 Blanks per die. First Skill each own turn readies +1 next-Attack damage. Begin with 0 Action Rerolls."},
 "bugh":{"name":"Warden Soul","hp":6,"blanks":3,"text":"6 HP · minimum 3 Blanks per die. Keep up to 2 Block at own-turn start. Movement abilities travel 1 less, minimum 1."}
}
# Face IDs are projections onto physical Strike sides, never owned bonus designs.
const FACES = {
 73:{"name":"Jab","range":2,"text":"After moving at least 2 spaces this own turn, deal 1 damage to an enemy within 2. Once per own turn; spends this rolled die."},
 74:{"name":"Crack","range":1,"text":"After another Attack this own turn, remove up to 2 Block from an adjacent enemy. No HP damage. Once per own turn; spends this rolled die."},
 81:{"name":"Poke","range":1,"text":"Deal 1 damage to an adjacent enemy after you have dealt actual enemy HP damage this own turn. Once per own turn; spends this rolled die."},
 82:{"name":"Poison Poke","range":1,"text":"Poke for 1 damage. If the target loses HP, apply Poison 1. Requires earlier enemy HP damage this own turn. Once per own turn; spends this rolled die."},
 84:{"name":"Oath Cut","range":1,"text":"Deal 1 damage to an adjacent enemy. Spends this rolled die. Oathblade gives all your Attack faces Pierce 1."},
 83:{"name":"Heavy Poke","range":1,"text":"Poke for 2 damage, then pay 1 HP unless combat ended. Requires earlier enemy HP damage this own turn. Once per own turn; spends this rolled die."}
}
const WEAPONS = {
 "":{"name":"Unarmed","min":0,"max":0,"replacements":[],"modifiers":{},"text":"Attack faces: minimum 0 / maximum 0. Equip a Weapon to use Attack faces."},
 "dagger":{"name":"Dagger","min":2,"max":5,"replacements":[81],"modifiers":{},"text":"Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poke (1 damage after earlier enemy HP damage). All-Attack passive: none."},
 "venom":{"name":"Poison Dagger","min":2,"max":5,"replacements":[82],"modifiers":{},"text":"Attack faces: minimum 2 / maximum 5. Replace 1 basic Strike → Poison Poke (1 damage; HP loss adds Poison 1). All-Attack passive: none."},
 "heavy":{"name":"Heavy Dagger","min":2,"max":6,"replacements":[83],"modifiers":{},"text":"Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Heavy Poke (2 damage, then pay 1 HP). All-Attack passive: none."},
 "oathblade":{"name":"Oathblade","min":3,"max":6,"replacements":[84,84,84],"modifiers":{"pierce":1},"text":"Attack faces: minimum 3 / maximum 6. Replace 3 basic Strikes → Oath Cut (1 adjacent damage each). Passive: ALL your Attack faces gain Pierce 1, including other equipped Attacks. Replacements spend rolled dice."},
 "spear":{"name":"Spear","min":2,"max":6,"replacements":[73],"modifiers":{},"text":"Attack faces: minimum 2 / maximum 6. Replace 1 basic Strike → Jab (range 2; move 2 first). All-Attack passive: none."},
 "hammer":{"name":"Hammer","min":2,"max":8,"replacements":[74],"modifiers":{},"text":"Attack faces: minimum 2 / maximum 8. Replace 1 basic Strike → Crack (remove 2 adjacent Block after another Attack). All-Attack passive: none."}
}
const BLANK_MEMORIES = {
 "first_step":{"name":"Memory of the First Step","mode":"move","distance":1,"text":"Spend one rolled Blank as Move 1, once per own turn. The installed side remains Blank."},
 "wind":{"name":"Memory of Wind","mode":"move","distance":2,"text":"Spend one rolled Blank as Move 2, once per own turn."},
 "hearth":{"name":"Memory of Hearth","mode":"heal","distance":0,"text":"Spend one rolled Blank to heal yourself 1 HP, once per own turn. Cannot revive yourself."},
 "mire":{"name":"Memory of the Mire","mode":"heal","distance":0,"text":"Spend one rolled Blank to heal yourself 1 HP, once per own turn. Cannot revive yourself."},
 "glasswing":{"name":"Glasswing Memory","mode":"blink","distance":2,"text":"Spend one rolled Blank to blink up to 2 orthogonal spaces, once per own turn. Landing must be empty; Rooted prevents this."},
 "ironbound":{"name":"Ironbound Memory","mode":"block","distance":0,"text":"Spend one rolled Blank to gain 2 Block, once per own turn."}
}
static func active(profile: Dictionary) -> bool:return bool(profile.get("equipment.enabled",false))
static func body_key(key: String) -> String:return "broken" if key=="broken_body" else key
static func soul_key(key: String) -> String:return "beginning" if key=="" else key
static func memory_key(key: String) -> String:return key.trim_prefix("memory_")
static func key(profile: Dictionary, slot: String, hero: int) -> String:
 var defaults: Array = ["dagger","dagger","dagger"] if slot=="weapons" else ["broken","broken","broken"] if slot=="bodies" else ["beginning","beginning","beginning"] if slot=="souls" else ["","",""]
 return str(profile.get("equipment."+slot,profile.get("trial."+slot,defaults))[hero])
static func scoped(profile: Dictionary, hero: int) -> Dictionary:
 var result := profile.duplicate(true);result["equipment.hero"] = hero;return result
static func soul_data(profile: Dictionary, hero: int) -> Dictionary:return SOULS.get(key(profile,"souls",hero),SOULS.beginning)
static func configure(profile: Dictionary, bodies: Array, souls: Array, weapons: Array, memories: Array) -> Dictionary:
 var result := profile.duplicate(true);result["equipment.enabled"] = true
 result["equipment.bodies"] = bodies.map(func(v):return body_key(str(v)))
 result["equipment.souls"] = souls.duplicate();result["equipment.weapons"] = weapons.duplicate();result["equipment.memories"] = memories.map(func(v):return memory_key(str(v)))
 for hero in range(3):
  var m: Dictionary = BLANK_MEMORIES.get(memory_key(str(memories[hero])),{})
  result["soul.eligible."+str(hero)] = not m.is_empty()
  result["soul.mode."+str(hero)] = m.get("mode","move");result["soul.distance."+str(hero)] = m.get("distance",1);result["soul.allowance."+str(hero)] = 1
  result["weapon.dagger."+str(hero)] = false
 return result
static func effective(build: Array, weapon: String, raw: int, die: int, side: int, definition: Dictionary = {}) -> int:
 if raw!=1 or die<0 or side<0:return raw
 var replacements: Array = definition.get("replacements",WEAPONS.get(weapon,WEAPONS[""]).replacements)
 var index := 0
 for d in range(build.size()):
  for s in range(build[d].size()):
   if int(build[d][s])!=1:continue
   if d==die and s==side:return int(replacements[index]) if index<replacements.size() else raw
   index += 1
 return raw
static func limits_error(build: Array, totals: Dictionary, profile: Dictionary) -> String:
 var hero: int = int(profile.get("equipment.hero",0))
 var body: Dictionary = BODIES.get(body_key(key(profile,"bodies",hero)),BODIES.broken)
 for category in body.limits:
  var bounds: Array = body.limits[category];var count: int = int(totals.get(category,0))
  if count<int(bounds[0]) or count>int(bounds[1]):return "%s requires %d–%d %s faces across all three dice; this build has %d." % [body.name,bounds[0],bounds[1],category,count]
 var weapon: Dictionary = WEAPONS.get(key(profile,"weapons",hero),WEAPONS[""])
 var attacks: int = int(totals.get("Attack",0))
 if attacks<int(weapon.min) or attacks>int(weapon.max):return "%s requires %d–%d Attack faces across all three dice; this build has %d." % [weapon.name,weapon.min,weapon.max,attacks]
 var strikes := 0
 for die in build:
  for face in die:
   if int(face)==1:strikes += 1
 if strikes<weapon.replacements.size():return "%s replaces %d basic Strikes; keep at least that many Strike sides." % [weapon.name,weapon.replacements.size()]
 return ""

static func repair(build: Array, body: String, soul: String, weapon: String, category: Callable) -> Array:
 # Used for prepared starters and versioned save migration only. Collections are untouched.
 var result: Array = build.map(func(die):return die.map(func(face):return int(face)))
 var blank_min: int = int(SOULS.get(soul,SOULS.beginning).blanks)
 var limits: Dictionary = BODIES.get(body_key(body),BODIES.broken).limits
 var w: Dictionary = WEAPONS.get(weapon,WEAPONS[""])
 for die in result:
  for attack_pass in [false,true]:
   for side in range(5,-1,-1):
    if die.count(0)>=blank_min:break
    if die[side]!=0 and (category.call(int(die[side]))=="Attack")==attack_pass:die[side] = 0
 var counts := {"Defense":0,"Movement":0,"Skill":0,"Attack":0}
 for die in result:
  for side in range(6):
   var cat: String = category.call(int(die[side]))
   if not counts.has(cat):continue
   counts[cat] += 1
   var maximum: int = int(w.max) if cat=="Attack" else int(limits[cat][1])
   if counts[cat]>maximum:die[side] = 0;counts[cat] -= 1
 var strikes := 0
 for die in result:strikes += die.count(1)
 # Turn an existing non-basic Attack into Strike first; preserve the Attack count.
 for die in result:
  for side in range(6):
   if strikes>=w.replacements.size():break
   if category.call(int(die[side]))=="Attack" and int(die[side])!=1:die[side] = 1;strikes += 1
 for die in result:
  for side in range(6):
   if counts.Attack>=int(w.min) and strikes>=w.replacements.size():break
   var cat: String = category.call(int(die[side]))
   if cat=="Attack":continue
   if die[side]==0 and die.count(0)<=blank_min:continue
   if counts.Attack>=int(w.max):continue
   die[side] = 1;counts.Attack += 1;strikes += 1
 return result
