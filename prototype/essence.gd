extends RefCounted
const Equipment = preload("res://prototype/equipment.gd")
## PDF v1 creature rewards plus original v0.33 boss rewards; balance is provisional.
const Wilds = preload("res://prototype/wilds.gd")
const FACE_FIRST = 60
const FACE_COUNT = 73
const FACES = [
 ["Bone Growth","Skill","Bone. Gain 1 Block and optionally Move 1."],
 ["Bone Strike","Attack","Bone. Adjacent enemy: deal 1 damage per Bone result rolled this turn, spent results count; this face counts if rolled."],
 ["Bone Guard","Defense","Bone. Gain 1 Block per Bone result rolled this turn, spent results count; this face counts if rolled."],
 ["Shared Remedy","Skill","Healing. Heal yourself 1. Only if HP was actually restored, choose an ally within 2 to heal 1."],
 ["Sorrow’s Offering","Skill","Optionally lose 1 HP, then choose an ally within 2: +2 Block or +1 damage on their next Attack. Decline spends the face without effect."],
 ["Shared Burden","Skill","Choose another of your results rolled this round, spent or ready. An ally within 2 spends a ready die to resolve a copy immediately as a single-action interrupt. Their other dice and normal turn are unchanged. No Shared Burden copy loops."],
 ["Retreat","Movement","Move up to 2. If you end farther from every living enemy than at the start, gain 1 Block."],
 ["Momentum Strike","Attack","After moving 2 spaces this turn: adjacent enemy takes 1 damage. After 3+ spaces: Numeric +1 damage instead."],
 ["Evasive Counter","Defense","Reaction when targeted: +1 Block before the Attack. If it removes no HP, optionally Move 1 after the entire Attack resolves."],
 ["Ember Cut","Attack","Adjacent enemy: deal 2 damage. If HP is lost, gain 1 Block."],
 ["Brood Needle","Attack","Enemy in clear sight within 2: deal 1 damage. If HP is lost, apply Poison 1."],
 ["Quiet Note","Skill","Heal yourself 1 HP and clear your Weakness."],
 ["Iron Shelter","Defense","Gain 2 Block, or 3 Block if you already have Block."]
]
const TYPES = {
 "mire_leech":{"name":"Mire Leech","rank":"normal","condition":"regular","hp":4,"faces":[]},
 "glasswing_moth":{"name":"Glasswing Moth","rank":"normal","condition":"regular","hp":3,"faces":[]},
 "iron_husk":{"name":"Iron Husk","rank":"normal","condition":"regular","hp":5,"faces":[]},
 "bone_creature":{"name":"Bone Creature","rank":"normal","condition":"regular","hp":3,"faces":[60,61,62]},
 "support_creature":{"name":"Support Creature","rank":"normal","condition":"regular","hp":2,"faces":[63,64,65]},
 "movement_creature":{"name":"Movement Creature","rank":"normal","condition":"regular","hp":3,"faces":[66,67,68]},
 "hollow":{"name":"The Hollow","rank":"boss","condition":"regular","faces":[]},
 "nugh":{"name":"Nu’gh","rank":"boss","condition":"regular","faces":[]},
 "cantor":{"name":"Veyl, the Brass Cantor","rank":"boss","condition":"regular","faces":[]},
 "bugh":{"name":"Bu’gh, the Iron Warden","rank":"boss","condition":"regular","faces":[]},
 "nugh_worm":{"name":"Screaming Worm","rank":"normal","condition":"regular","faces":[]},
 "scavenger":{"name":"Ash Scavenger","rank":"normal","condition":"regular","faces":[]},
 "cinder_mite":{"name":"Cinder Mite","rank":"normal","condition":"regular","faces":[]}
}
const RECIPES = {
 "weapon_oathblade":{"enemy":"bugh","category":"Weapon","cost":4,"weapon":"oathblade","name":"Oathblade","effect":Equipment.WEAPONS.oathblade.text},
 "memory_first_step":{"enemy":"movement_creature","category":"Memory","cost":1,"memory":"first_step","name":"Memory of the First Step","effect":Equipment.BLANK_MEMORIES.first_step.text},
 "ember_cut":{"enemy":"hollow","category":"Attack Face","cost":2,"face":69},
 "brood_needle":{"enemy":"nugh","category":"Attack Face","cost":2,"face":70},
 "quiet_note":{"enemy":"cantor","category":"Skill Face","cost":2,"face":71},
 "iron_shelter":{"enemy":"bugh","category":"Defense Face","cost":2,"face":72},
 "memory_embers":{"enemy":"hollow","category":"Memory","cost":3,"name":"Memory of Embers","effect":"Your first actual enemy HP damage each own turn grants 1 Block."},
 "memory_brood":{"enemy":"nugh","category":"Memory","cost":3,"name":"Memory of the Brood","effect":"Your first Poison application each own turn adds 1 extra Poison. Your friendly Nu’gh counts."},
 "memory_silence":{"enemy":"cantor","category":"Memory","cost":3,"name":"Memory of Silence","effect":"The first Skill you resolve each own turn grants 1 Block."},
 "memory_iron":{"enemy":"bugh","category":"Memory","cost":3,"name":"Memory of Iron","effect":"The first Defense you resolve each own turn grants 1 extra Block."},
 "mire_soul":{"enemy":"mire_leech","category":"Memory","cost":3,"memory":"mire","name":"Memory of the Mire","effect":Equipment.BLANK_MEMORIES.mire.text},
 "glasswing_soul":{"enemy":"glasswing_moth","category":"Memory","cost":3,"memory":"glasswing","name":"Glasswing Memory","effect":Equipment.BLANK_MEMORIES.glasswing.text},
 "iron_soul":{"enemy":"iron_husk","category":"Memory","cost":3,"memory":"ironbound","name":"Ironbound Memory","effect":Equipment.BLANK_MEMORIES.ironbound.text},
 "bone_growth":{"enemy":"bone_creature","category":"Skill Face · Bone","cost":1,"face":60},
 "bone_strike":{"enemy":"bone_creature","category":"Attack Face · Bone","cost":2,"face":61},
 "bone_guard":{"enemy":"bone_creature","category":"Defense Face · Bone","cost":3,"face":62},
 "shared_remedy":{"enemy":"support_creature","category":"Skill Face · Healing","cost":1,"face":63},
 "sorrow":{"enemy":"support_creature","category":"Skill Face","cost":2,"face":64},
 "shared_burden":{"enemy":"support_creature","category":"Skill Face · Copy","cost":3,"face":65},
 "memory_loss":{"enemy":"support_creature","category":"Memory","cost":4,"name":"Memory of Loss","effect":"Healing abilities gain +1 range except Self/Adjacent. The first actual self-heal each combat restores 1 extra HP."},
 "retreat":{"enemy":"movement_creature","category":"Movement Face","cost":1,"face":66},
 "momentum":{"enemy":"movement_creature","category":"Attack Face","cost":2,"face":67},
 "evasive":{"enemy":"movement_creature","category":"Defense Face · Reaction","cost":3,"face":68}
}
var bank: Dictionary = {}
var unlocked: Dictionary = {}
var copies: Dictionary = {}
var seen: Dictionary = {}
var defeated: Dictionary = {}
var settled: Dictionary = {}
var memory_copies: Dictionary = {}
var migration_message := ""
var memories: Array = ["","",""]
var souls: Array = [["beginning"],["beginning"],["beginning"]]
var equipped_souls: Array = ["beginning","beginning","beginning"]
var weapons: Array = ["dagger","dagger","dagger"]
var bodies: Array = ["broken_body","broken_body","broken_body"]
func encode() -> Dictionary:
 return {"equipment_version":40,"memory_copies":memory_copies,"migration_message":migration_message,"bank":bank,"unlocked":unlocked,"copies":copies,"seen":seen,"defeated":defeated,"settled":settled,"memories":memories,"souls":souls,"equipped_souls":equipped_souls,"weapons":weapons,"bodies":bodies}
func decode(data: Dictionary):
 for key in ["bank","unlocked","copies","seen","defeated","settled","memory_copies"]:
  if data.get(key) is Dictionary:set(key,data[key].duplicate(true))
 for key in ["memories","souls","equipped_souls"]:
  if data.get(key) is Array and data[key].size() == 3:set(key,data[key].duplicate(true))
 for hero in range(3):
  if "beginning" not in souls[hero]:souls[hero].push_front("beginning")
  if data.get("weapons") is Array and data.weapons.size() == 3 and Equipment.WEAPONS.has(str(data.weapons[hero])):weapons[hero] = data.weapons[hero]
  if data.get("bodies") is Array and data.bodies.size() == 3 and Equipment.BODIES.has(Equipment.body_key(str(data.bodies[hero]))):bodies[hero] = Equipment.body_key(str(data.bodies[hero]))
 if int(data.get("equipment_version",0))<40:
  for hero in range(3):
   for old in ["mire","glasswing","iron"]:
    if old not in souls[hero]:continue
    var recipe: String = {"mire":"mire_soul","glasswing":"glasswing_soul","iron":"iron_soul"}[old]
    memory_copies[recipe] = int(memory_copies.get(recipe,0))+1;unlocked[recipe] = true;souls[hero].erase(old)
    if equipped_souls[hero]==old:
     equipped_souls[hero] = "beginning"
     if memories[hero]=="":memories[hero] = recipe
  migration_message = "Equipment updated: Souls now set HP / Blanks; Weapons set Attack limits and replace Strikes. Existing Blank-conversion Souls were kept as Memory copies. Check your dice before fighting."
 else:migration_message = str(data.get("migration_message",""))
func discovered(type: String) -> bool:return TYPES.get(type,{}).get("rank","normal") == "normal" or defeated.has(type)
func recipes_for(type: String) -> Array:
 var result: Array = []
 for key in RECIPES:
  if RECIPES[key].enemy == type:result.append(key)
 return result
func owned(face: int) -> int:return maxi(0,int(copies.get(str(face),0)))
func craft(key: String, recipient: int = -1) -> String:
 if not RECIPES.has(key):return "Unknown reward."
 var recipe: Dictionary = RECIPES[key]
 if not discovered(recipe.enemy):return "Defeat this enemy first to reveal its rewards."
 if recipe.has("soul"):
  if recipient not in range(3):return "Choose the hero who will own this bound Soul."
  if recipe.soul in souls[recipient]:return "This hero already owns that Soul. Choose another recipient."
 if not recipe.has("face") and not recipe.has("soul") and unlocked.has(key):return "Already permanently unlocked; this reward cannot be bought twice."
 if int(bank.get(recipe.enemy,0)) < recipe.cost:return "Need %d %s Essence. Types cannot be mixed." % [recipe.cost,type_name(recipe.enemy)]
 bank[recipe.enemy] = int(bank.get(recipe.enemy,0))-recipe.cost;unlocked[key] = true
 if recipe.has("face"):copies[str(recipe.face)] = owned(recipe.face)+1
 if recipe.has("soul"):grant_soul(recipient,recipe.soul)
 return ""
func reward_name(key: String) -> String:
 var recipe: Dictionary = RECIPES[key]
 return FACES[recipe.face-60][0] if recipe.has("face") else recipe.name
func reward_effect(key: String) -> String:
 var recipe: Dictionary = RECIPES[key]
 return FACES[recipe.face-60][2] if recipe.has("face") else recipe.effect
func settle(run_id: String, victory: bool, tokens: Array, deaths: Array, encounters: Array) -> bool:
 if settled.has(run_id):return false
 settled[run_id] = true
 for type in encounters:seen[type] = true
 for type in deaths:defeated[type] = true
 if victory:
  for token in tokens:bank[token.type] = int(bank.get(token.type,0))+1
  if "hollow" in deaths:
   for hero in range(3):
    grant_soul(hero,"hollow")
 return true
func profile(base: Dictionary) -> Dictionary:
 var result := base.duplicate(true)
 for face in range(60,FACE_COUNT):result["earned."+str(face)] = owned(face)
 for hero in range(3):
  for key in memory_keys():result["memory."+key.trim_prefix("memory_")+"."+str(hero)] = memories[hero] == key
  result["weapon.dagger."+str(hero)] = weapons[hero] == "dagger"
 return Equipment.configure(result,bodies,equipped_souls,weapons,memories.map(func(m):return str(RECIPES.get(m,{}).get("memory",Equipment.memory_key(str(m))))))
func memory_keys() -> Array:
 return RECIPES.keys().filter(func(key):return RECIPES[key].category == "Memory")
func equip_memory(hero: int, memory: String = "memory_loss") -> bool:
 if hero not in [-1,0,1,2] or memory not in memory_keys() or not unlocked.has(memory):return false
 if hero<0:
  for i in range(3):
   if memories[i]==memory:memories[i] = ""
  return true
 if memories[hero]==memory:return true
 if memories.count(memory)>=int(memory_copies.get(memory,1)):
  memories[memories.find(memory)] = ""
 memories[hero] = memory
 return true
func debug_unlock(key: String, recipient: int) -> bool:
 if not RECIPES.has(key):return false
 var recipe: Dictionary = RECIPES[key]
 if recipe.has("soul"):return grant_soul(recipient,recipe.soul)
 if recipe.has("face"):
  if owned(recipe.face)>0:return false
  copies[str(recipe.face)] = 1
 elif unlocked.has(key):return false
 unlocked[key] = true;return true

func equip_soul(hero: int, soul: String) -> bool:
 if hero not in range(3) or (soul != "" and soul not in souls[hero]):return false
 equipped_souls[hero] = soul;return true
static func type_name(type: String) -> String:return TYPES.get(type,{}).get("name",type.capitalize())
static func condition_text(condition: String) -> String:
 return {"regular":"Regular: defeat this individual enemy.","no_block":"Enemy has zero Block at death.","poisoned":"Enemy is Poisoned at death.","rooted":"Enemy is Rooted at death."}.get(condition,"Unspecified condition: cannot harvest yet.")
static func eligible(unit: Dictionary, condition: String) -> bool:
 match condition:
  "regular":return true
  "no_block":return int(unit.get("block",0)) == 0
  "poisoned":return int(unit.get("poison",0)) > 0
  "rooted":return int(unit.get("rooted",0)) > 0
 return false

func grant_soul(hero: int, soul: String) -> bool:
 if hero not in range(3) or soul == "" or not Equipment.SOULS.has(soul) or soul in souls[hero]:return false
 souls[hero].append(soul);return true

func available_weapons() -> Array:
 return ["dagger","spear","hammer"]+(["oathblade"] if unlocked.has("weapon_oathblade") else [])
func equip_weapon(hero: int, weapon: String) -> bool:
 if hero not in range(3) or weapon not in available_weapons():return false
 weapons[hero] = weapon;return true
func equip_body(hero: int, body: String) -> bool:
 if hero not in range(3) or not Equipment.BODIES.has(Equipment.body_key(body)):return false
 bodies[hero] = body;return true

func recipe_progress(key: String) -> String:
 var recipe: Dictionary = RECIPES[key];var available := int(bank.get(recipe.enemy,0));var need := maxi(0,int(recipe.cost)-available)
 return "%d / %d %s Essence · %s" % [available,recipe.cost,type_name(recipe.enemy),"Ready to craft" if need == 0 else "%d more needed" % need]
func allocated(builds: Array, face: int) -> int:
 var count := 0
 for hero in builds:
  for die in hero:count += die.count(face)
 return count
