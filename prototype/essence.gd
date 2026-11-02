extends RefCounted
## PDF v1: fixed prototype reward effects/costs; combat values below are provisional.
const FACE_FIRST = 60
const FACE_COUNT = 69
const FACES = [
 ["Bone Growth","Skill","Bone. Gain 1 Block and optionally Move 1."],
 ["Bone Strike","Attack","Bone. Adjacent enemy: deal 1 damage per Bone result rolled this turn, spent results count; this face counts if rolled."],
 ["Bone Guard","Defense","Bone. Gain 1 Block per Bone result rolled this turn, spent results count; this face counts if rolled."],
 ["Shared Remedy","Skill","Healing. Heal yourself 1. Only if HP was actually restored, choose an ally within 2 to heal 1."],
 ["Sorrow’s Offering","Skill","Optionally lose 1 HP, then choose an ally within 2: +2 Block or +1 damage on their next Attack. Decline spends the face without effect."],
 ["Shared Burden","Skill","Choose another of your results rolled this round, spent or ready. An ally within 2 spends a ready die to resolve a copy immediately as a single-action interrupt. Their other dice and normal turn are unchanged. No Shared Burden copy loops."],
 ["Retreat","Movement","Move up to 2. If you end farther from every living enemy than at the start, gain 1 Block."],
 ["Momentum Strike","Attack","After moving 2 spaces this turn: adjacent enemy takes 1 damage. After 3+ spaces: Numeric +1 damage instead."],
 ["Evasive Counter","Defense","Reaction when targeted: +1 Block before the Attack. If it removes no HP, optionally Move 1 after the entire Attack resolves."]
]
const TYPES = {
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
var memories: Array = ["","",""]
var souls: Array = [["beginning"],["beginning"],["beginning"]]
var equipped_souls: Array = ["beginning","beginning","beginning"]
var weapons: Array = ["dagger","dagger","dagger"]
var bodies: Array = ["broken_body","broken_body","broken_body"]
func encode() -> Dictionary:
 return {"bank":bank,"unlocked":unlocked,"copies":copies,"seen":seen,"defeated":defeated,"settled":settled,"memories":memories,"souls":souls,"equipped_souls":equipped_souls,"weapons":weapons,"bodies":bodies}
func decode(data: Dictionary):
 for key in ["bank","unlocked","copies","seen","defeated","settled"]:
  if data.get(key) is Dictionary:set(key,data[key].duplicate(true))
 for key in ["memories","souls","equipped_souls"]:
  if data.get(key) is Array and data[key].size() == 3:set(key,data[key].duplicate(true))
 for hero in range(3):
  if "beginning" not in souls[hero]:souls[hero].push_front("beginning")
  if data.get("weapons") is Array and data.weapons.size() == 3 and data.weapons[hero] in ["","dagger"]:weapons[hero] = data.weapons[hero]
  if data.get("bodies") is Array and data.bodies.size() == 3 and data.bodies[hero] == "broken_body":bodies[hero] = "broken_body"
func discovered(type: String) -> bool:return TYPES.get(type,{}).get("rank","normal") == "normal" or defeated.has(type)
func recipes_for(type: String) -> Array:
 var result: Array = []
 if not discovered(type):return result
 for key in RECIPES:
  if RECIPES[key].enemy == type:result.append(key)
 return result
func owned(face: int) -> int:return maxi(0,int(copies.get(str(face),0)))
func craft(key: String) -> String:
 if not RECIPES.has(key):return "Unknown reward."
 var recipe: Dictionary = RECIPES[key]
 if not discovered(recipe.enemy):return "Defeat this enemy first to reveal its rewards."
 if not recipe.has("face") and unlocked.has(key):return "Already permanently unlocked; this reward cannot be bought twice."
 if int(bank.get(recipe.enemy,0)) < recipe.cost:return "Need %d %s Essence. Types cannot be mixed." % [recipe.cost,type_name(recipe.enemy)]
 bank[recipe.enemy] = int(bank.get(recipe.enemy,0))-recipe.cost;unlocked[key] = true
 if recipe.has("face"):copies[str(recipe.face)] = owned(recipe.face)+1
 return ""
func reward_name(key: String) -> String:
 var recipe: Dictionary = RECIPES[key]
 if not unlocked.has(key):return recipe.category
 return FACES[recipe.face-60][0] if recipe.has("face") else recipe.name
func reward_effect(key: String) -> String:
 if not unlocked.has(key):return "Exact effect is hidden until crafted."
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
 for face in range(60,69):result["earned."+str(face)] = owned(face)
 for hero in range(3):
  result["memory.loss."+str(hero)] = memories[hero] == "memory_loss"
  result["weapon.dagger."+str(hero)] = weapons[hero] == "dagger"
 return result
func equip_memory(hero: int) -> bool:
 if hero not in [-1,0,1,2] or not unlocked.has("memory_loss"):return false
 for i in range(3):memories[i] = ""
 if hero >= 0:memories[hero] = "memory_loss"
 return true
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
 if hero not in range(3) or soul == "" or soul in souls[hero]:return false
 souls[hero].append(soul);return true

func equip_weapon(hero: int, weapon: String) -> bool:
 if hero not in range(3) or weapon not in ["","dagger"]:return false
 weapons[hero] = weapon;return true
func equip_body(hero: int, body: String) -> bool:
 if hero not in range(3) or body != "broken_body":return false
 bodies[hero] = body;return true
