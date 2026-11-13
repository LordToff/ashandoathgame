extends RefCounted
## Separate experimental run/collection. Never writes Expedition or ordinary builds.
const Equipment = preload("res://prototype/equipment.gd")
const Classes = preload("res://prototype/trial_classes.gd")
const C = preload("res://prototype/trial_content.gd")
const B = preload("res://prototype/battle.gd")
const R = preload("res://prototype/trial_rules.gd")
const STARTER_FACES = [[70,59,69],[72,68,51],[67,66,53]]
const SAVE = "user://ash-trials-v34.json"
const BOSSES = ["hollow","nugh","cantor","bugh"]
const BOSS_NAMES = ["The Hollow","Nu’gh","Veyl, Brass Cantor","Bu’gh, Iron Warden"]
var phase := "lobby"
# Empty keys identify pre-class checkpoints and isolated legacy regression fixtures.
var classes: Array = ["","",""]
var memories: Array = ["","",""]
var bound_souls: Array = [["","soulcaster"],["","soulcaster"],["","soulcaster"]]
var legacy_builds: Array = []
var souls: Array = ["","",""]
var selected_boss := 0
var hero := 0
var stage := 0
var seed_value := 0
var essence := 3
var hp: Array = []
var builds: Array = []
var pool: Dictionary = {}
var loadout_weapons: Array = ["dagger","dagger","dagger"]
var ingredients: Dictionary = {"ward":0,"cinder":0,"shade":0,"hollow":0}
var crafted: Array = []
var wishlist := ""
var craft_hero := 0
var last_progress := ""
var weapons: Array = ["dagger","dagger","dagger"]
var bodies: Array = ["broken","broken","broken"]
var completed_bosses: Array = []
var history: Array = []
var message := ""
var current: Dictionary = {}
var reward_mode := ""
var reward_face := 70
var reward_weapon := "venom"
var settled := false
func _init(restore: bool = true):
 if restore:
  load_save()
  if phase=="lobby":ensure_classes()
func start(seed_number: int = 0) -> void:
 memories = ["","",""]
 seed_value = seed_number if seed_number!=0 else int(Time.get_ticks_usec())
 weapons = loadout_weapons.duplicate()
 last_progress = ""
 stage = 0;essence = 3;hp = [];builds = [];pool = {};history = [];current = {};settled = false;reward_mode = "";message = "Choose your first route. HP carries between encounters."
 var starting: Array = starting_builds()
 for id in range(3):
  var build: Array = starting[id]
  builds.append(build)
  var maximum: int = maximum_hp(id)
  hp.append(maximum)
  for die in build:
   for face in die:
    if face>=60:pool[str(face)] = int(pool.get(str(face),0))+1
 var error := validate(builds)
 if error!="":phase = "lobby";message = error;return
 phase = "route";save()
func options() -> Array:
 var offset := absi(seed_value)%3;var group := (stage+offset)%3
 match stage:
  0:return [{"kind":"fight","group":group,"elite":false},{"kind":"fight","group":1,"elite":false,"objective":"ritual"}]
  1:return [{"kind":"camp"},{"kind":"fight","group":group,"elite":false}]
  2:return [{"kind":"fight","group":0,"elite":false,"objective":"spirit"},{"kind":"fight","group":(group+2)%3,"elite":true}]
  3:return [{"kind":"event"},{"kind":"fight","group":group,"elite":true}]
  4:return [{"kind":"camp"},{"kind":"fight","group":group,"elite":true}]
 return [{"kind":"boss","boss":BOSSES[selected_boss]}]
func choose(index: int) -> bool:
 if phase!="route" or index not in range(options().size()):return false
 current = options()[index].duplicate(true);settled = false;reward_mode = ""
 phase = "combat" if current.kind in ["fight","boss"] else current.kind
 history.append("Stop %d: %s" % [stage+1,current.kind]);save();return true
func profile() -> Dictionary:
 var result := {"trial.enabled":true,"trial.classes":classes.duplicate(),"trial.memories":memories.duplicate(),"trial.souls":souls.duplicate(),"trial.hp":hp.duplicate(),"trial.weapons":weapons.duplicate(),"trial.bodies":bodies.duplicate(),"trial.purse":essence,"trial.terrain":"cover"}
 for id in range(3):
  result["soul.eligible."+str(id)] = true;result["soul.mode."+str(id)] = "heal" if souls[id]=="hearth" else "move";result["soul.distance."+str(id)] = 2 if souls[id]=="wind" else 1;result["soul.allowance."+str(id)] = 1;result["weapon.dagger."+str(id)] = weapons[id] not in ["spear","hammer"]
 for key in pool:result["earned."+key] = int(pool[key])
 return Equipment.configure(result,bodies,souls.map(func(s):return Equipment.soul_key(str(s))),weapons,memories)
func validate(candidate: Array, extra_face: int = -1) -> String:
 var checked_profile := profile()
 if extra_face>=60:checked_profile["earned."+str(extra_face)] = int(pool.get(str(extra_face),0))+1
 for id in range(3):
  var error: String = B.validate(candidate[id],range(9,60),Equipment.scoped(checked_profile,id))
  if error!="":return error
 for face in range(60,73):
  var count := 0
  for build in candidate:
   for die in build:count += die.count(face)
  if count>int(pool.get(str(face),0))+(1 if face==extra_face else 0):return "No free physical copy of "+B.FACES[face]+"."
 return ""
func finish(g) -> bool:
 if phase!="combat" or settled or g.outcome=="":return false
 settled = true;essence = int(g.trial_state.get("purse",essence));hp = g.heroes.map(func(h):return int(h.hp))
 if g.outcome!="victory":fail("The party fell. Start another Trial; your Trial Soul collection remains.");return true
 var source: String = C.reward_source(current)
 var old_progress := wishlist_progress()
 if source!="":ingredients[source] = int(ingredients.get(source,0))+(3 if current.kind=="boss" or current.get("elite",false) else 2)
 last_progress = ""
 if wishlist!="" and old_progress!=wishlist_progress():last_progress = "Wishlist · "+wishlist_progress()
 if current.kind=="boss":
  var boss: String = current.boss
  if boss not in completed_bosses:completed_bosses.append(boss)
  for id in range(3):
   if boss not in bound_souls[id]:bound_souls[id].append(boss)
  phase = "complete";message = "Trial complete! "+R.SOULS[boss].name+" is available for future Trials."
  essence += 6;history.append("Boss victory: "+BOSS_NAMES[selected_boss]);save();return true
 var earned := 3 if current.get("objective","")!="" else 4 if current.get("elite",false) else 2
 essence += earned;message = "Victory · +%d Run Essence. Choose a reward." % earned;phase = "reward";reward_mode = "";save();return true
func bank_reward() -> bool:
 if phase!="reward":return false
 essence += 2;message = "Saved the reward as +2 Run Essence.";advance();return true
func replacement_error(face: int, die: int, side: int) -> String:
 if phase!="reward" or face not in reward_faces(hero):return "Choose a reward face first."
 if essence<2:return "Need 2 Run Essence."
 if die not in range(3) or side not in range(6):return "Select a side to replace."
 if int(builds[hero][die][side])==face:return "This side already has that ability."
 var candidate := builds.duplicate(true);candidate[hero][die][side] = face
 return validate(candidate,face)
func add_face(face: int, die: int, side: int) -> bool:
 var error := replacement_error(face,die,side)
 if error!="":message = error;return false
 builds[hero][die][side] = face
 if face>=60:pool[str(face)] = int(pool.get(str(face),0))+1
 essence -= 2;message = "Installed "+B.FACES[face]+" for this Trial.";advance();return true
func equip_weapon(key: String) -> bool:
 if phase!="reward" or essence<2 or not R.WEAPONS.has(key) or weapons[hero]==key:return false
 var old: String = weapons[hero];weapons[hero] = key
 var error := validate(builds)
 if error!="":weapons[hero] = old;message = error;return false
 essence -= 2;message = R.WEAPONS[key].name+" equipped in "+["Vesper","Rook","Wren"][hero]+"’s Weapon slot.";advance();return true
func maximum_hp(id: int) -> int:return int(R.SOULS.get(souls[id],R.SOULS.beginning).hp)
func reward_faces(id: int) -> Array:return Classes.CLASSES[classes[id]].rewards.duplicate() if Classes.valid(classes[id]) else STARTER_FACES[id]
func starting_builds() -> Array:
 var result: Array = []
 for id in range(3):
  if souls[id]=="soulcaster":result.append(repair_build(R.Soulcaster.STARTER_DICE.duplicate(true),id));continue
  if Classes.valid(classes[id]):result.append(repair_build(Classes.CLASSES[classes[id]].dice.duplicate(true),id));continue
  # Old safe checkpoints retain their original hero-specific loadouts.
  var build: Array = B.default_build()
  match id:
   0:build[1][0] = 70;build[2][2] = 59
   1:build[0][2] = 72;build[2][0] = 41
   2:build[0][0] = 67;build[1][1] = 66;build[2][0] = 8
  result.append(repair_build(build,id))
 return result
func camp(rest: bool) -> bool:
 if phase!="camp":return false
 if rest:
  for id in range(3):hp[id] = mini(maximum_hp(id),int(hp[id])+2)
  message = "Camp restores 2 HP to every hero, including fallen heroes."
 else:essence += 2;message = "Gathered 2 Run Essence instead of resting."
 advance();return true
func event(risk: bool) -> bool:
 if phase!="event":return false
 if not risk:essence += 1;message = "Took the safe cache: +1 Run Essence."
 else:
  var rng := RandomNumberGenerator.new();rng.seed = hash([seed_value,stage,"buried-cache"])
  var roll := rng.randi_range(1,6)
  if roll>=4:essence += 5;message = "Cache d6 → %d: +5 Run Essence." % roll
  else:
   for id in range(3):hp[id] = maxi(0,int(hp[id])-1)
   message = "Cache d6 → %d: each hero loses 1 HP." % roll
 if hp.all(func(value):return int(value)<=0):fail("The cache trap felled the party.")
 else:advance()
 return true
func advance() -> void:
 stage += 1;phase = "route";reward_mode = "";current = {};save()
func fail(reason: String) -> void:
 phase = "failed";message = reason;reward_mode = "";save()
func save() -> void:
 var data := {"equipment_version":40}
 for key in ["phase","classes","memories","weapons","bodies","souls","selected_boss","stage","seed_value","essence","hp","builds","pool","completed_bosses","history","message","current","settled","loadout_weapons","ingredients","crafted","wishlist","last_progress","bound_souls","legacy_builds"]:data[key] = get(key)
 var file := FileAccess.open(SAVE,FileAccess.WRITE)
 if file:file.store_string(JSON.stringify(data))
 if OS.has_feature("web"):JavaScriptBridge.eval("try{localStorage.setItem('ash-and-oath-trials',"+JSON.stringify(JSON.stringify(data))+")}catch(e){}",true)
func load_save() -> void:
 var text := FileAccess.get_file_as_string(SAVE) if FileAccess.file_exists(SAVE) else ""
 if OS.has_feature("web"):
  var stored = JavaScriptBridge.eval("(()=>{try{return localStorage.getItem('ash-and-oath-trials')}catch(e){return null}})()",true)
  if stored is String:text = stored
 if text.is_empty():return
 var parser := JSON.new()
 if parser.parse(text)!=OK:return
 var data = parser.data
 if not data is Dictionary:return
 if data.get("classes") is Array and data.classes.size()==3:
  for id in range(3):classes[id] = str(data.classes[id]) if Classes.valid(str(data.classes[id])) else ""
 if data.get("ingredients") is Dictionary:
  for key in C.ESSENCE:ingredients[key] = maxi(0,int(data.ingredients.get(key,0)))
 if data.get("crafted") is Array:crafted = data.crafted.filter(func(key):return C.RECIPES.has(key))
 if C.RECIPES.has(str(data.get("wishlist",""))):wishlist = str(data.wishlist)
 last_progress = str(data.get("last_progress",""))
 if data.get("loadout_weapons") is Array and data.loadout_weapons.size()==3:
  for id in range(3):
   if data.loadout_weapons[id] in available("weapon",id):loadout_weapons[id] = data.loadout_weapons[id]
 if data.get("completed_bosses") is Array:completed_bosses = data.completed_bosses.filter(func(key):return key in BOSSES)
 if data.get("bound_souls") is Array and data.bound_souls.size()==3:bound_souls = data.bound_souls
 elif int(data.get("equipment_version",0))<40:
  for id in range(3):bound_souls[id].append_array(completed_bosses)
 if data.get("legacy_builds") is Array:legacy_builds = data.legacy_builds
 if not data.has("memories") and data.get("paths") is Array:data.memories = data.paths
 for key in ["memories","souls","weapons","bodies"]:
  if data.get(key) is Array and data[key].size()==3:set(key,data[key])
 for id in range(3):
  if souls[id] in ["wind","hearth"]:
   var old: String = souls[id];souls[id] = ""
   var recipe: String = old+"_soul"
   if recipe not in crafted:crafted.append(recipe)
   if memories[id]=="":memories[id] = old
  if memories[id] not in available("memory",id):memories[id] = ""
  if not R.WEAPONS.has(weapons[id]):weapons[id] = "dagger"
  if bodies[id] not in available("body",id):bodies[id] = "broken"
  if souls[id] not in available("soul",id):souls[id] = ""
 selected_boss = clampi(int(data.get("selected_boss",0)),0,3)
 var loaded_phase: String = str(data.get("phase","lobby"))
 if loaded_phase=="combat":phase = "failed";message = "A Trial fight was interrupted. No victory reward was granted; collected Trial Souls remain.";return
 if loaded_phase not in ["route","reward","camp","event","complete","failed"]:return
 var saved_builds = data.get("builds",[])
 if not saved_builds is Array or saved_builds.size()!=3:return
 for build in saved_builds:
  if not build is Array or build.size()!=3:return
  for die in build:
   if not die is Array or die.size()!=6 or not die.all(func(face):return B.valid_face_number(face)):return
 saved_builds = saved_builds.map(func(build):return build.map(func(die):return die.map(func(face):return int(face))))
 for key in ["stage","seed_value","essence"]:set(key,maxi(0,int(data.get(key,0))))
 if stage>5:stage = 5
 if int(data.get("equipment_version",34))<35 and data.get("mods") is Dictionary:
  essence += data.mods.size()*2;data.message = "Old dice upgrades refunded as %d Essence. Rewards now offer Weapons." % (data.mods.size()*2)
 for key in ["pool","current"]:
  if data.get(key) is Dictionary:set(key,data[key])
 if data.get("hp") is Array and data.hp.size()==3:hp = range(3).map(func(id):return clampi(int(data.hp[id]),0,maximum_hp(id)))
 else:return
 if int(data.get("equipment_version",0))<40:
  legacy_builds = saved_builds.duplicate(true)
  for id in range(3):saved_builds[id] = repair_build(saved_builds[id],id)
  data.message = "Equipment rules updated. Dice repaired for Soul Blanks, Body categories and Weapon Attack limits; original dice and all owned copies are retained. First-encounter Memories are empty."
  if stage==0:memories = ["","",""]
 if validate(saved_builds)!="":
  phase = "failed";message = "This saved Trial needs new equipment preparation. Collected items and original dice are retained; begin a new Trial.";legacy_builds = saved_builds.duplicate(true);return
 builds = saved_builds.map(func(build):return build.map(func(die):return die.map(func(face):return int(face))));phase = loaded_phase;message = str(data.get("message",""));settled = bool(data.get("settled",false))
 if data.get("history") is Array:history = data.history

func available(slot: String, id: int = -1) -> Array:
 if id<0:id = hero
 var items: Array = {"memory":["venom","guard","stride","first_step",""],"body":["broken"],"weapon":["dagger","spear","hammer"],"soul":bound_souls[id]}.get(slot,[]).duplicate()
 if slot=="body" and Classes.valid(classes[id]):
  var starting: String = Classes.CLASSES[classes[id]].body
  if starting not in items:items.append(starting)
 for key in crafted:
  if C.RECIPES[key].slot==slot and C.RECIPES[key].item not in items:items.append(C.RECIPES[key].item)
 return items
func recipe_effect(key: String) -> String:
 if not C.RECIPES.has(key):return ""
 var recipe: Dictionary = C.RECIPES[key]
 return R.memory_data(recipe.item).text if recipe.slot=="memory" else {"weapon":R.WEAPONS,"body":R.BODIES,"soul":R.SOULS}[recipe.slot][recipe.item].text
func wishlist_progress(key: String = "") -> String:
 if key=="":key = wishlist
 if not C.RECIPES.has(key):return "Choose an equipment recipe to pin."
 var recipe: Dictionary = C.RECIPES[key];var parts: Array[String] = []
 for type in recipe.cost:parts.append("%d/%d %s" % [int(ingredients.get(type,0)),int(recipe.cost[type]),C.ESSENCE[type].name])
 return recipe.name+" · "+("crafted" if key in crafted else " · ".join(parts))
func craft(key: String) -> bool:
 if phase=="combat" or not C.RECIPES.has(key) or key in crafted:return false
 var recipe: Dictionary = C.RECIPES[key]
 for type in recipe.cost:
  if int(ingredients.get(type,0))<int(recipe.cost[type]):message = "Missing ingredients. "+wishlist_progress(key);return false
 for type in recipe.cost:ingredients[type] -= int(recipe.cost[type])
 crafted.append(key);message = recipe.name+" crafted for the Trial collection. Equip it before a new Trial.";save();return true
func pin(key: String) -> bool:
 if not C.RECIPES.has(key):return false
 wishlist = "" if wishlist==key else key;save();return true
func apply_build(key: String, id: int) -> bool:
 if phase!="lobby" or id not in range(3) or not C.BUILDS.has(key):return false
 var build: Dictionary = C.BUILDS[key]
 memories[id] = ""
 bodies[id] = build.body if build.body in available("body",id) else "broken"
 loadout_weapons[id] = build.weapon if build.weapon in available("weapon",id) else "dagger"
 souls[id] = build.soul if build.soul in available("soul",id) else ""
 var missing: Array[String] = []
 for key_name in ["body","weapon","soul"]:
  if build[key_name] not in available(key_name,id):
   for recipe_key in C.RECIPES:
    if C.RECIPES[recipe_key].slot==key_name and C.RECIPES[recipe_key].item==build[key_name]:missing.append(C.RECIPES[recipe_key].name)
   if key_name=="soul" and build.soul in BOSSES:missing.append(R.SOULS[build.soul].name+" (defeat its Trial boss)")
 message = build.name+" equipped for "+["Vesper","Rook","Wren"][id]+(". Missing: "+", ".join(missing)+". Available starter equipment fills those slots." if not missing.is_empty() else ". All pieces available.")
 save();return true
func display_face(id: int, face: int, die: int, side: int) -> int:
 var key: String = loadout_weapons[id] if phase=="lobby" else weapons[id]
 var shown: Array = starting_builds()[id] if phase=="lobby" else builds[id]
 return Equipment.effective(shown,key,face,die,side)

func ensure_classes() -> void:
 if phase!="lobby":return
 var changed := false
 for id in range(3):
  if Classes.valid(classes[id]):continue
  set_class_kit(id,Classes.DEFAULTS[id]);changed = true
 if changed:message = "Choose a class for each hero. Starting equipment is included; tap the class card to inspect its dice.";save()
func set_class_kit(id: int, key: String) -> void:
 var kit: Dictionary = Classes.CLASSES[key]
 classes[id] = key;memories[id] = kit.memory;bodies[id] = kit.body;loadout_weapons[id] = kit.weapon;souls[id] = ""
func choose_class(id: int, key: String) -> bool:
 if phase!="lobby" or id not in range(3) or not Classes.valid(key):return false
 set_class_kit(id,key)
 message = ["Vesper","Rook","Wren"][id]+" is a "+Classes.name_for(key)+". Starting gear and dice reset for this hero; no Essence spent."
 save();return true
func customized(id: int) -> bool:
 if not Classes.valid(classes[id]):return false
 var kit: Dictionary = Classes.CLASSES[classes[id]]
 var equipped: String = loadout_weapons[id] if phase=="lobby" else weapons[id]
 return bodies[id]!=kit.body or memories[id]!=kit.memory or equipped!=kit.weapon or souls[id]!=""
func class_label(id: int) -> String:
 return Classes.name_for(classes[id])+(" · adjusted gear" if customized(id) else "")

func choose_soul(id: int, key: String) -> bool:
 if phase!="lobby" or id not in range(3) or key not in available("soul",id):return false
 souls[id] = key
 message = ("Soulcaster equipped: starter dice adapt to four Blanks each. 6 maximum HP from Soulcaster. Tap Spellbook for the six spells." if key=="soulcaster" else "Soul equipped; starter dice and maximum HP update automatically.")
 save();return true

func repair_build(build: Array, id: int) -> Array:
 var weapon: String = loadout_weapons[id] if phase=="lobby" else weapons[id]
 return Equipment.repair(build,bodies[id],souls[id],weapon,func(face):return B.Catalog.category(face))

func equip_memory_reward(key: String) -> bool:
 if phase!="reward" or essence<2 or key=="" or key not in available("memory",hero):return false
 memories[hero] = key;essence -= 2;message = R.memory_data(key).name+" equipped after the first encounter.";advance();return true
