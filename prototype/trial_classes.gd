extends RefCounted
## Trials-only starting kits. All combat effects come from the four equipment slots.
const DEFAULTS = ["skirmisher","vanguard","skirmisher"]
const CLASSES = {
 "skirmisher":{
  "name":"Skirmisher","role":"Move first, then strike from range 2.",
  "body":"fleet","memory":"","weapon":"spear",
  "play":"Move at least 2 spaces with Stride or two Steps, then use Jab. Memory starts empty.",
  "dice":[[1,34,4,1,0,0],[2,3,5,2,0,0],[67,7,6,0,0,0]],
  "rewards":[67,66,53],
  "hp_text":"6 maximum HP from Beginning Soul. Fleet Body sets category limits; Memory starts empty.",
  "turn":"Example: roll Stride and Jab on different dice. Move at least 2 spaces with Stride, then Jab deals 1 damage within 2. Each ability spends its rolled die. Step moves its printed 1 space.",
  "tradeoff":"Fleet Body allows up to 4 Movement faces but only 2 Defense faces. Spear allows 2–6 Attack faces. Beginning Soul requires 2 Blanks per die and supplies Last Ember. Earn a Memory later for a passive."
 },
 "vanguard":{
  "name":"Vanguard","role":"Guard the front line and break enemy Block.",
  "body":"stone","memory":"","weapon":"hammer",
  "play":"Use another Attack before Crack. Build Block with rolled Defense abilities; Memory starts empty.",
  "dice":[[1,4,72,1,0,0],[34,1,1,3,0,0],[41,7,8,5,0,0]],
  "rewards":[72,68,51],
  "hp_text":"6 maximum HP from Beginning Soul. Stone Body sets category limits; Memory starts empty.",
  "turn":"Use Guard, Iron Shelter or a held Reaction for Block. During your own turn, use another rolled Attack first, then spend a rolled Crack to remove up to 2 Block from an adjacent enemy. Crack deals no HP damage.",
  "tradeoff":"Stone Body allows up to 4 Defense faces but only 2 Movement faces. Hammer allows 2–8 Attack faces. Stride keeps its printed Move 3. Beginning Soul requires 2 Blanks per die and supplies Last Ember."
 }
}
static func valid(key: String) -> bool:return CLASSES.has(key)
static func name_for(key: String) -> String:return CLASSES[key].name if valid(key) else "Previous setup"
static func face_for(key: String, die: int, side: int) -> int:
 var data: Dictionary = CLASSES[key];var face: int = data.dice[die][side]
 if face!=1:return face
 for d in range(3):
  for s in range(6):
   if data.dice[d][s]==1:return (73 if data.weapon=="spear" else 74) if Vector2i(d,s)==Vector2i(die,side) else face
 return face
