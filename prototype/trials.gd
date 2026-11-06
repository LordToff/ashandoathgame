extends RefCounted
## Separate experimental run/collection. Never writes Expedition or ordinary builds.
const B = preload("res://prototype/battle.gd")
const R = preload("res://prototype/trial_rules.gd")
const STARTER_FACES = [[70,59,69],[72,68,51],[67,66,53]]
const SAVE = "user://ash-trials-v34.json"
const BOSSES = ["hollow","nugh","cantor","bugh"]
const BOSS_NAMES = ["The Hollow","Nu’gh","Veyl, Brass Cantor","Bu’gh, Iron Warden"]
var phase := "lobby"
var memories: Array = ["venom","guard","stride"]
var souls: Array = ["","",""]
var selected_boss := 0
var hero := 0
var stage := 0
var seed_value := 0
var essence := 3
var hp: Array = []
var builds: Array = []
var pool: Dictionary = {}
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
 if restore:load_save()
func start(seed_number: int = 0) -> void:
 seed_value = seed_number if seed_number!=0 else int(Time.get_ticks_usec())
 weapons = ["dagger","dagger","dagger"]
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
 phase = "route";save()
func options() -> Array:
 var offset := absi(seed_value)%3;var group := (stage+offset)%3
 match stage:
  0:return [{"kind":"fight","group":group,"elite":false},{"kind":"fight","group":(group+1)%3,"elite":true}]
  1:return [{"kind":"camp"},{"kind":"fight","group":group,"elite":false}]
  2:return [{"kind":"fight","group":group,"elite":false},{"kind":"fight","group":(group+2)%3,"elite":true}]
  3:return [{"kind":"event"},{"kind":"fight","group":group,"elite":true}]
  4:return [{"kind":"camp"},{"kind":"fight","group":group,"elite":true}]
 return [{"kind":"boss","boss":BOSSES[selected_boss]}]
func choose(index: int) -> bool:
 if phase!="route" or index not in range(options().size()):return false
 current = options()[index].duplicate(true);settled = false;reward_mode = ""
 phase = "combat" if current.kind in ["fight","boss"] else current.kind
 history.append("Stop %d: %s" % [stage+1,current.kind]);save();return true
func profile() -> Dictionary:
 var result := {"trial.enabled":true,"trial.memories":memories.duplicate(),"trial.souls":souls.duplicate(),"trial.hp":hp.duplicate(),"trial.weapons":weapons.duplicate(),"trial.bodies":bodies.duplicate(),"trial.purse":essence,"trial.terrain":"cover"}
 for id in range(3):
  result["soul.eligible."+str(id)] = true;result["soul.mode."+str(id)] = "move";result["soul.distance."+str(id)] = 1;result["soul.allowance."+str(id)] = 1;result["weapon.dagger."+str(id)] = true
 for key in pool:result["earned."+key] = int(pool[key])
 return result
func validate(candidate: Array) -> String:
 for id in range(3):
  var error: String = B.validate(candidate[id],range(9,60),profile())
  if error!="":return error
 for face in range(60,73):
  var count := 0
  for build in candidate:
   for die in build:count += die.count(face)
  if count>int(pool.get(str(face),0)):return "No free physical copy of "+B.FACES[face]+"."
 return ""
func finish(g) -> bool:
 if phase!="combat" or settled or g.outcome=="":return false
 settled = true;essence = int(g.trial_state.get("purse",essence));hp = g.heroes.map(func(h):return int(h.hp))
 if g.outcome!="victory":fail("The party fell. Start another Trial; your Trial Soul collection remains.");return true
 if current.kind=="boss":
  var boss: String = current.boss
  if boss not in completed_bosses:completed_bosses.append(boss)
  phase = "complete";message = "Trial complete! "+R.SOULS[boss].name+" is available for future Trials."
  essence += 6;history.append("Boss victory: "+BOSS_NAMES[selected_boss]);save();return true
 var earned := 4 if current.get("elite",false) else 2
 essence += earned;message = "Victory · +%d Trial Essence. Choose a reward." % earned;phase = "reward";reward_mode = "";save();return true
func bank_reward() -> bool:
 if phase!="reward":return false
 essence += 2;message = "Saved the reward as +2 Trial Essence.";advance();return true
func add_face(face: int, die: int, side: int) -> bool:
 if phase!="reward" or essence<2 or die not in range(3) or side not in range(6) or face not in reward_faces(hero):return false
 var old: int = builds[hero][die][side]
 if old==face:return false
 var candidate := builds.duplicate(true);candidate[hero][die][side] = face
 var old_count: int = int(pool.get(str(face),0))
 if face>=60:pool[str(face)] = old_count+1
 var error := validate(candidate)
 if error!="":
  if face>=60:pool[str(face)] = old_count
  message = error;return false
 builds = candidate;essence -= 2;message = "Installed "+B.FACES[face]+" for this Trial.";advance();return true
func equip_weapon(key: String) -> bool:
 if phase!="reward" or essence<2 or not R.WEAPONS.has(key) or weapons[hero]==key:return false
 weapons[hero] = key;essence -= 2;message = R.WEAPONS[key].name+" equipped in "+["Vesper","Rook","Wren"][hero]+"’s Weapon slot.";advance();return true
func maximum_hp(id: int) -> int:return (6 if memories[id]=="venom" else 5)-(1 if souls[id]=="nugh" else 0)
func reward_faces(id: int) -> Array:return STARTER_FACES[id]
func starting_builds() -> Array:
 var result: Array = []
 for key in ["venom","guard","stride"]:
  var build: Array = B.default_build()
  match key:
   "venom":build[1][0] = 70;build[2][2] = 59
   "guard":build[0][2] = 72;build[2][0] = 41
   "stride":build[0][0] = 67;build[1][1] = 66;build[2][0] = 8
  result.append(build)
 return result
func camp(rest: bool) -> bool:
 if phase!="camp":return false
 if rest:
  for id in range(3):hp[id] = mini(maximum_hp(id),int(hp[id])+2)
  message = "Camp restores 2 HP to every hero, including fallen heroes."
 else:essence += 2;message = "Gathered 2 Trial Essence instead of resting."
 advance();return true
func event(risk: bool) -> bool:
 if phase!="event":return false
 if not risk:essence += 1;message = "Took the safe cache: +1 Trial Essence."
 else:
  var rng := RandomNumberGenerator.new();rng.seed = hash([seed_value,stage,"buried-cache"])
  var roll := rng.randi_range(1,6)
  if roll>=4:essence += 5;message = "Cache d6 → %d: +5 Trial Essence." % roll
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
 var data := {"equipment_version":35}
 for key in ["phase","memories","weapons","bodies","souls","selected_boss","stage","seed_value","essence","hp","builds","pool","completed_bosses","history","message","current","settled"]:data[key] = get(key)
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
 if data.get("completed_bosses") is Array:completed_bosses = data.completed_bosses.filter(func(key):return key in BOSSES)
 if not data.has("memories") and data.get("paths") is Array:data.memories = data.paths
 for key in ["memories","souls","weapons","bodies"]:
  if data.get(key) is Array and data[key].size()==3:set(key,data[key])
 for id in range(3):
  if not R.MEMORIES.has(memories[id]):memories[id] = R.MEMORIES.keys()[id]
  if not R.WEAPONS.has(weapons[id]):weapons[id] = "dagger"
  bodies[id] = "broken"
  if souls[id] not in completed_bosses:souls[id] = ""
 selected_boss = clampi(int(data.get("selected_boss",0)),0,3)
 var loaded_phase: String = str(data.get("phase","lobby"))
 if loaded_phase=="combat":phase = "failed";message = "A Trial fight was interrupted. No victory reward was granted; collected Trial Souls remain.";return
 if loaded_phase not in ["route","reward","camp","event","complete","failed"]:return
 var saved_builds = data.get("builds",[])
 if not saved_builds is Array or saved_builds.size()!=3:return
 for key in ["stage","seed_value","essence"]:set(key,maxi(0,int(data.get(key,0))))
 if stage>5:stage = 5
 if int(data.get("equipment_version",34))<35 and data.get("mods") is Dictionary:
  essence += data.mods.size()*2;data.message = "Old dice upgrades refunded as %d Essence. Rewards now offer Weapons." % (data.mods.size()*2)
 for key in ["pool","current"]:
  if data.get(key) is Dictionary:set(key,data[key])
 if data.get("hp") is Array and data.hp.size()==3:hp = data.hp.map(func(value):return clampi(int(value),0,6))
 else:return
 if validate(saved_builds)!="":return
 builds = saved_builds.map(func(build):return build.map(func(die):return die.map(func(face):return int(face))));phase = loaded_phase;message = str(data.get("message",""));settled = bool(data.get("settled",false))
 if data.get("history") is Array:history = data.history
