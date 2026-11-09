extends RefCounted
## Trials-only starting kits. All combat effects come from the four equipment slots.
const DEFAULTS = ["skirmisher","vanguard","skirmisher"]
const CLASSES = {
 "skirmisher":{
  "name":"Skirmisher","role":"Move first, then strike from range 2.",
  "body":"fleet","memory":"stride","weapon":"spear",
  "play":"Step moves 2. Move first, then use Jab; Momentum adds +1 to your first eligible Attack.",
  "dice":[[1,34,4,1,0,0],[2,3,5,2,0,0],[67,7,6,4,0,0]],
  "rewards":[67,66,53],
  "hp_text":"4 maximum HP: Fleet Body 5, Memory of Momentum −1.",
  "turn":"Example: roll Step and Jab on different dice. Fleet Body makes Step move 2; move first, then Jab reaches an enemy within 2 and deals 2 damage with Memory of Momentum. That Memory boosts only the first eligible Attack. Jab itself is once per own turn and spends its die.",
  "tradeoff":"Fast but fragile. Beginning Soul still converts one Blank to Move 1; Fleet Body does not increase Blank movement. Keep ordinary Strikes or Strike Numeric for turns without enough movement."
 },
 "vanguard":{
  "name":"Vanguard","role":"Guard the front line and break enemy Block.",
  "body":"stone","memory":"guard","weapon":"hammer",
  "play":"Use another Attack before Crack. Fully block an enemy hit to ready +1 next-Attack damage.",
  "dice":[[1,4,72,1,0,0],[34,1,1,3,0,0],[41,7,8,5,0,0]],
  "rewards":[72,68,51],
  "hp_text":"6 maximum HP: Stone Body 7, Memory of Guard −1.",
  "turn":"Use Guard, Iron Shelter or a held Reaction to block an enemy Attack completely; Memory of Guard readies +1 damage for your next Attack. During your own turn, use another rolled Attack first, then spend a rolled Crack to remove up to 2 Block from an adjacent enemy. Crack deals no HP damage.",
  "tradeoff":"Durable but slower: Stone Body makes Stride travel 2 instead of 3. Beginning Soul still converts one Blank to Move 1. Ordinary Strikes, Strike Numeric and Engrave give you attacks to set up Crack."
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
