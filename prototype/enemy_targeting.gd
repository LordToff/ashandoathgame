extends RefCounted
## Priorities are shared by the model and its live intent cards.
const RULES = {
 "Advance":"highest_hp","Iron Advance":"highest_hp","Smoking Strike":"lowest_hp","Strike":"lowest_hp",
 "Skirmish":"closest","Ashen Chain":"furthest","Cinder Brand":"damage_last_round","Distort":"buffs",
 "Fracture":"buffs","Drive Back":"most_block","Gnashing Maw":"lowest_hp","Hushed Chime":"buffs",
 "Tuning Fork":"furthest","Shield Bash":"most_block","Driving Blow":"highest_hp",
 "Bite":"lowest_hp","Venom Bite":"debuffs","Needle":"damage_last_round","Bash":"most_block","Scuttle":"closest"
}
const LABELS = {"highest_hp":"Highest HP","lowest_hp":"Lowest HP","most_block":"Most Block","furthest":"Furthest hero","closest":"Closest hero","buffs":"Most active buffs","debuffs":"Most active debuffs","damage_last_round":"Most enemy HP damage last round"}
const SELF = ["Brace","Raise Guard","Guard","Iron Guard","Gathering Note","Crescendo","Seal the Bell","Brood Guard","Burrow"]
const AREA = ["Sweep","Furnace Roar","Toll of Reckoning","Hammerfall","Grave Tithe","Screaming Chorus"]
static func rule(action: String) -> String:return RULES.get(action,"closest")
static func label(action: String) -> String:return LABELS[rule(action)]
static func score(game, source: int, target: int, action: String) -> int:
 var h: Dictionary = game.unit_data(target)
 match rule(action):
  "highest_hp":return h.hp
  "lowest_hp":return -h.hp
  "most_block":return h.block
  "furthest":return game.distance(source,target)
  "closest":return -game.distance(source,target)
  "damage_last_round":return int(h.get("damage_last_round",0))
  "buffs":
   var total := int(h.block > 0)
   for key in ["dr","ward","num_boost","numeric_focus","backstab","debt_buff","defy","gambler","stored_num","offering_boost"]:
    if key == "stored_num":total += int(int(h.get(key,-1)) >= 0)
    elif key == "backstab":total += int(int(h.get(key,0)) >= game.round_no and int(h.get(key,0)) > 0)
    else:total += int(int(h.get(key,0)) > 0)
   total += int(not h.get("channel",{}).is_empty());return total
  "debuffs":return int(h.get("poison",0)>0)+int(h.get("rooted",0)>0)+int(h.get("stun",false))+int(bool(h.get("weak",false)) or bool(h.get("bulwark_weak",false)))+int(h.get("debt_penalty",0)>0)
 return 0
static func pick(game, source: int, legal: Array, action: String, slot: int = -1) -> int:
 if legal.is_empty():return -1
 var everyone: Array = game.attack_targets(source,99)
 var heroes: Array = everyone.filter(func(id):return id < 3)
 if not heroes.is_empty():everyone = heroes
 var best := -2147483647;var preferred: Array = []
 for id in everyone:
  var value := score(game,source,id,action)
  if value > best:best = value;preferred = [id]
  elif value == best:preferred.append(id)
 var candidates: Array = preferred.filter(func(id):return id in legal)
 if candidates.is_empty():
  var closest := 999
  for id in legal:
   var distance: int = game.distance(source,id)
   if distance < closest:closest = distance;candidates = [id]
   elif distance == closest:candidates.append(id)
 # Round seed is rolled by the model. Reading/redrawing never consumes RNG.
 var tie_rng := RandomNumberGenerator.new();tie_rng.seed = hash([game.intent_seed,source,slot,action])
 return candidates[tie_rng.randi_range(0,candidates.size()-1)]
