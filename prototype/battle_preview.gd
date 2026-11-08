extends RefCounted
## Read-only board reach. Never rolls dice or changes the battle.
const MOVEMENT = [2,3,53,54,57,60,66]
const RANGED_SKILLS = [7,8,11,12,15,19,44,45,52,55,58,63,64,65]
const SIGHT = [11,15,19,35,58,70]
static func empty() -> Dictionary:return {"tiles":[],"blocked":[],"targets":[],"destinations":[],"reach":0,"mode":"none"}
static func for_face(g, face: int) -> Dictionary:
 var result := empty()
 if face<0 or g.active not in range(3) or g.heroes.size()!=3:return result
 var actor: int = g.active;var h: Dictionary = g.heroes[actor]
 if h.dead or h.hp<=0:return result
 if face in MOVEMENT or (face==0 and g.reward and g.soul_mode(actor) not in ["heal","block"]):
  result.mode = "move"
  result.destinations = g.leap_cells(actor) if face==53 else g.soul_cells(actor) if face==0 else g.reachable(actor,g.move_steps(face),face==3)
  result.tiles = result.destinations.duplicate();result.reach = g.soul_distance(actor) if face==0 else g.move_steps(face);return result
 if face==59 and g.owned_worm(actor)<0:
  result.mode = "summon";result.destinations = g.summon_cells(actor);result.tiles = result.destinations.duplicate();result.reach = 1;return result
 if not g.Catalog.is_attack(face) and face not in RANGED_SKILLS:return result
 result.mode = "area" if face==52 else "target"
 result.reach = 99 if face==12 else g.face_range(face)
 if face==52:result.reach = g.v("face52.range")
 for y in range(9):
  for x in range(9):
   var cell := Vector2i(x,y)
   if absi(cell.x-h.pos.x)+absi(cell.y-h.pos.y)>result.reach:continue
   if face in SIGHT and not visible_cell(g,actor,cell,result.reach):result.blocked.append(cell)
   else:result.tiles.append(cell)
 for target in range(g.unit_count()):
  var unit: Dictionary = g.unit_data(target)
  if unit.get("dead",false) or g.distance(actor,target)>result.reach:continue
  if face in SIGHT and not g.sight(actor,target,result.reach):continue
  if eligible(g,face,target):result.targets.append(target)
 return result
static func eligible(g, face: int, target: int) -> bool:
 var actor: int = g.active;var unit: Dictionary = g.unit_data(target)
 if face==52:return target!=actor and unit.hp>0
 if g.TrialRules.immobile_object(g,target) and face==8:return false
 if g.Catalog.is_attack(face):
  if face in [73,74]:return g.TrialRules.weapon_reason(g,face,target)==""
  if target==actor:return false
  if face in [61,67,69,70] and (not g.enemies(actor,target) or unit.hp<=0):return false
  if face==67 and int(g.heroes[actor].get("moved_turn",0))<2:return false
  return true
 if face==8:return target!=actor and unit.hp>0
 if g.TrialRules.objective_unit(g,target) and unit.trial_object=="spirit":return face==7 and unit.hp>0
 if target>=3:return false
 if face in [15,19,58,63,64,65,44] and target==actor:return false
 if face in [11,58,64,65,44,45] and unit.hp<=0:return false
 if face==58 and (unit.get("rooted",0)>0 or g.heroes[actor].get("rooted",0)>0):return false
 if face in [12,15] and not unit.build.any(func(die):return 0 in die):return false
 return true
static func visible_cell(g, source: int, cell: Vector2i, reach: int) -> bool:
 var endpoint := -1
 for id in range(g.unit_count()):
  if not g.unit_data(id).get("dead",false) and cell in g.cells(id):endpoint = id;break
 for start in g.cells(source):
  if absi(start.x-cell.x)+absi(start.y-cell.y)>reach:continue
  var dx: int = cell.x-start.x;var dy: int = cell.y-start.y
  var nx := absi(dx);var ny := absi(dy);var ix := 0;var iy := 0
  var at: Vector2i = start;var touched: Array = [];var clear := true
  while ix<nx or iy<ny:
   var decision: int = (1+2*ix)*ny-(1+2*iy)*nx
   if decision==0:
    touched.append(at+Vector2i(signi(dx),0));touched.append(at+Vector2i(0,signi(dy)))
    at += Vector2i(signi(dx),signi(dy));ix += 1;iy += 1
   elif decision<0:at.x += signi(dx);ix += 1
   else:at.y += signi(dy);iy += 1
   touched.append(at)
  for tile in touched:
   if g.TrialRules.blocked_cell(g,tile):clear = false
   for id in range(g.unit_count()):
    if id in [source,endpoint] or g.unit_data(id).get("dead",false):continue
    if tile in g.cells(id):clear = false
  if clear:return true
 return false
