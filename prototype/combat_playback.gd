extends RefCounted
## Read-only visual replay. Combat and RNG resolve once in the model.
const WINDUP = 0.72
const IMPACT = 0.32
const STATUS = 0.72
const FALL = 1.15
var animate_dice := true
var model_id := 0
var queue: Array = []
var current: Dictionary = {}
var elapsed := 0.0
var units: Dictionary = {}
var last_roll := ""
static func capture(g) -> Dictionary:
 var state := {}
 for id in range(g.unit_count()):
  var u: Dictionary = g.unit_data(id)
  state[id] = {"hp":u.hp,"max_hp":u.max_hp,"block":u.block,"poison":int(u.get("poison",0)),"dead":bool(u.get("dead",false)),"pos":u.pos,"stun":bool(u.get("stun",false)),"broken":bool(u.get("broken",false)),"protected":bool(u.get("protected",false))}
 return state
func busy() -> bool:return not current.is_empty() or not queue.is_empty()
func clear(state: Dictionary = {}) -> void:
 queue.clear();current.clear();elapsed = 0;units = state.duplicate(true)
func enqueue(events: Array, rolls: Array, from_roll: int, final_state: Dictionary) -> void:
 var cursor: int = from_roll
 var previous: Dictionary = queue[-1].get("state",units).duplicate(true) if not queue.is_empty() else units.duplicate(true)
 for event in events:
  var end: int = mini(int(event.get("roll_cursor",cursor)),rolls.size())
  cursor = append_rolls(rolls,cursor,end,event.get("visual_state",{}))
  var kind: String = "roll_note" if event.kind=="roll" else str(event.kind)
  var duration := 0.0
  if kind=="attack":duration = WINDUP
  elif kind in ["damage","block"]:duration = IMPACT
  elif kind in ["poison","poison_tick","heal","phase","summon"]:duration = STATUS
  elif kind=="minion_action" and ("rolled 0" in event.text or "misses" in event.text):kind = "miss";duration = .6
  if duration>0 or event.has("visual_state") or kind in ["engrave","focus","buff","debuff","block_gain","resonance","core","fire","fire_arm","stun"]:
   queue.append({"kind":kind,"event":event.duplicate(true),"duration":duration,"state":event.get("visual_state",{}).duplicate(true)})
  if event.has("visual_state"):
   var next: Dictionary = event.visual_state
   var fallen: Array = []
   for id in next:
    if not previous.has(id):continue
    var was: Dictionary = previous[id];var now: Dictionary = next[id]
    var drops: bool = int(was.hp)>0 and int(now.hp)<=0
    var slain: bool = int(id)<3 and not bool(was.dead) and bool(now.dead)
    if drops or slain:fallen.append({"id":int(id),"dead":int(id)>=3 or bool(now.dead),"pos":now.pos})
   if not fallen.is_empty():
    # The impact and collapse begin in the same frame; the fall owns the pause.
    if not queue.is_empty() and kind in ["damage","block"]:queue[-1].duration = 0.0
    queue.append({"kind":"fall","fallen":fallen,"duration":FALL,"state":next.duplicate(true)})
   previous = next.duplicate(true)
 append_rolls(rolls,cursor,rolls.size(),{})
 queue.append({"kind":"state","duration":0.0,"state":final_state.duplicate(true)})
func append_rolls(rolls: Array, first: int, end: int, state: Dictionary) -> int:
 var rows: Array = []
 for i in range(first,end):
  var roll: Dictionary = rolls[i]
  if str(roll.kind).begins_with("Numeric"):
   if not rows.is_empty():queue.append({"kind":"roll","roll":{"rows":rows.duplicate(true)},"duration":0.0,"state":state});rows.clear()
   queue.append({"kind":"roll","roll":roll.duplicate(true),"duration":0.0,"state":state})
  else:rows.append(roll.duplicate(true))
 if not rows.is_empty():queue.append({"kind":"roll","roll":{"rows":rows},"duration":0.0,"state":state})
 return end
func tick(delta: float, dice_busy: bool) -> Array:
 var started: Array = []
 if not current.is_empty():
  if current.kind=="roll" and dice_busy:return started
  elapsed += delta
  if current.kind!="roll" and elapsed<float(current.duration):return started
  current = {}
 while current.is_empty() and not queue.is_empty():
  current = queue.pop_front();elapsed = 0
  current.before = units.duplicate(true)
  if not current.get("state",{}).is_empty():units = current.state.duplicate(true)
  if current.kind=="roll":
   var roll: Dictionary = current.roll
   if roll.has("rows"):
    last_roll = (str(roll.rows[0].actor)+": "+", ".join(roll.rows[0].results)) if roll.rows.size()==1 else "Shared roll · %d units · View dice for all faces" % roll.rows.size()
   else:last_roll = str(roll.actor)+": "+", ".join(roll.results)
   if not animate_dice:
    current = {};continue
  started.append(current.duplicate(true))
  if current.kind=="roll" or float(current.duration)>0:break
  current = {}
 return started
