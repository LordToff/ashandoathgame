extends RefCounted
## Resolve isolated copies, across all Numeric sides, never the live model/RNG.
const TARGETED = [0,1,2,3,7,8,15,19,34,35,36,37,38,39,40,41,53,54,55,57,58,59,60,61,66,67,69,70,73,74,75,76,78,79,81,82,83,84]
const IMMEDIATE = [4,14,20,21,22,27,29,42,43,47,50,51,54,56,60,62,71,72]
static func copy_battle(g):
 var model = g.get_script().new()
 for property in g.get_property_list():
  var key: String = property.name
  if not (int(property.usage)&PROPERTY_USAGE_SCRIPT_VARIABLE) or key=="rng":continue
  var value = g.get(key)
  model.set(key,value.duplicate(true) if value is Array or value is Dictionary else value)
 model.rng = RandomNumberGenerator.new();model.rng.state = g.rng.state
 return model
static func snapshot(g) -> Array:
 var result: Array = []
 for id in range(g.unit_count()):
  var u: Dictionary = g.unit_data(id)
  result.append({"hp":u.hp,"block":u.block,"pos":u.pos,"poison":int(u.get("poison",0)),"rooted":int(u.get("rooted",0)),"dead":bool(u.get("dead",false))})
 return result
static func between(values: Array) -> String:
 var low: int = values.min();var high: int = values.max()
 return str(low) if low==high else "%d–%d" % [low,high]
static func calculate(g, die: int, target: int = -1, destination: Vector2i = Vector2i(-99,-99)) -> Dictionary:
 var result := {"valid":false,"text":"Choose a target.","lines":[],"numeric":false,"target":target,"destination":destination}
 if not g.TrialRules.enabled(g) or g.active not in range(3) or die not in range(3) or not g.pending.is_empty() or g.outcome!="":return result
 var face: int = g.face(g.active,die)
 if face not in TARGETED and face not in IMMEDIATE:
  result.text = "Use opens this ability’s choices; no result is predicted yet."
  return result
 if g.Equipment.FACES.has(face):
  var reason: String = g.TrialRules.weapon_reason(g,face,target)
  if reason!="":result.text = reason;return result
 var before := snapshot(g);var samples: Array = [];var choices := false
 for side in range(6):
  var model = copy_battle(g);model.preview_numeric_side = side
  if not model.hero_action(die,target,destination):
   result.text = "No legal effect here; the die stays available."
   return result
  samples.append(snapshot(model))
  if model.roll_presentations.slice(g.roll_presentations.size()).any(func(display):return str(display.kind).begins_with("Numeric") and not "Stored value" in str(display.kind)):result.numeric = true
  if not model.pending.is_empty():choices = true
 if face==79:
  result.valid = true;result.text = g.unit_name(target)+" may save a ready result next turn. Its original die stays aside until their following turn.";return result
 if choices:
  result.valid = true;result.text = "Swap places, then each hero may Move 1." if face==75 else "Confirm to open the required choice. Effects depend on that choice.";return result
 var lines: Array[String] = []
 for id in range(before.size()):
  var damage: Array = [];var healing: Array = [];var block_lost: Array = [];var block_gained: Array = [];var poison: Array = [];var rooted: Array = [];var positions: Array = []
  for after in samples:
   if id>=after.size():continue
   damage.append(maxi(0,before[id].hp-after[id].hp));healing.append(maxi(0,after[id].hp-before[id].hp))
   block_lost.append(maxi(0,before[id].block-after[id].block));block_gained.append(maxi(0,after[id].block-before[id].block))
   poison.append(maxi(0,after[id].poison-before[id].poison));rooted.append(maxi(0,after[id].rooted-before[id].rooted));positions.append(after[id].pos)
  var effects: Array[String] = []
  if damage.max()>0:effects.append(between(damage)+" HP damage")
  if healing.max()>0:effects.append("heal "+between(healing))
  if block_lost.max()>0:effects.append(between(block_lost)+(" Block removed" if face==74 else " blocked"))
  if block_gained.max()>0:effects.append("+"+between(block_gained)+" Block")
  if poison.max()>0:effects.append("Poison +"+between(poison))
  if rooted.max()>0:effects.append("Rooted +"+between(rooted))
  if not positions.is_empty() and positions[0]!=before[id].pos:effects.append("move → "+g.cell_name(positions[0]))
  if not effects.is_empty():lines.append(g.unit_name(id)+": "+" · ".join(effects))
 if g.TrialRules.blocked_cell(g,destination):lines.append("Barricade breaks; the selected die is spent.")
 if face==59 and target<0 and g.owned_worm(g.active)<0:lines.append("Summon Nu’gh → "+g.cell_name(destination))
 if face==78:lines.append("This physical spell side returns to Blank.")
 if face==76:lines.append("Spend 1 Soul Charge; a creature / boss kill grants 2 (cap 3).")
 if lines.is_empty():lines.append("No immediate HP, Block or status change.")
 if result.numeric:lines.append("Numeric range shown; the result is rolled after confirmation.")
 if target>=0 and g.friendly(target) and target!=g.active and g.Catalog.is_attack(face):lines.push_front("FRIENDLY FIRE")
 result.valid = true;result.lines = lines;result.text = "\n".join(lines)
 return result
