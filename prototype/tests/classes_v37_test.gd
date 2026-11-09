extends SceneTree
const T = preload("res://prototype/trials.gd")
const B = preload("res://prototype/battle.gd")
const F = preload("res://prototype/trial_encounter.gd")
const K = preload("res://prototype/trial_classes.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("CLASS FAIL: ",why)
func new_party():
 var run = T.new(false);run.ensure_classes();return run
func ready(g) -> void:
 g.active = 0;g.order = [0,1,2,3];g.cursor = 0;g.pending = {};g.forced_die = -1
 for h in g.heroes:h.used = [false,false,false];h.reaction = [];h.results = [1,1,1];h.rolls = [0,0,0];h.poison = 0
 g.heroes[0].pos = Vector2i(3,5);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8);g.unit_data(4).pos = Vector2i(7,1)
 g.trial_state.positions = {}
 for id in range(g.unit_count()):g.trial_state.positions[id] = g.unit_data(id).pos
func text_content(node: Node) -> String:
 var result: String = str(node.text)+"\n" if node is Label or node is Button or node is RichTextLabel else ""
 for child in node.get_children():result += text_content(child)
 return result
func _initialize():call_deferred("run_tests")
func run_tests() -> void:
 check(K.CLASSES.size()==2,"exactly two classes are offered")
 for a in K.CLASSES:
  for b in K.CLASSES:
   for c in K.CLASSES:
    var run = new_party()
    for id in range(3):run.choose_class(id,[a,b,c][id])
    var bank: Dictionary = run.ingredients.duplicate();run.start(37)
    check(run.validate(run.builds)=="","all eight class party combinations obey physical/category/Blank limits")
    check(run.ingredients==bank and run.crafted.is_empty(),"starting class equipment costs no ingredients and grants no global recipe unlock")
    var g = F.new();g.start(run.builds,37,true,true,run.profile())
    for id in range(3):
     var kit: Dictionary = K.CLASSES[run.classes[id]]
     check(run.reward_faces(id)==kit.rewards,"reward offers follow the chosen class, not the hero name")
     check(run.weapons[id]==kit.weapon and run.bodies[id]==kit.body and run.memories[id]==kit.memory,"class supplies its declared Weapon, Body and Memory")
     check(g.heroes[id].max_hp==(4 if run.classes[id]=="skirmisher" else 6),"real combat maximum HP matches the class explanation")
     var weapon_faces := 0
     for die in range(3):
      for side in range(6):
       var actual: int = g.TrialRules.effective_face(g,id,g.heroes[id].build[die][side],die,side)
       check(actual==K.face_for(run.classes[id],die,side),"six-side preview and actual equipped weapon face agree")
       if actual in [73,74]:weapon_faces += 1
     check(weapon_faces==1 and not g.balance["weapon.dagger."+str(id)],"weapon attack is one rolled face; no additional free Poke")
     check(g.soul_distance(id)==1 and g.soul_limit(id)==1,"Beginning Soul keeps one Blank to Move 1")
 # Each class works for any of the three named heroes.
 for key in K.CLASSES:
  var run = new_party();var prior: Array = [run.classes.duplicate(),run.memories.duplicate(),run.bodies.duplicate(),run.loadout_weapons.duplicate()]
  run.choose_class(0,key)
  check(run.classes.slice(1)==prior[0].slice(1) and run.memories.slice(1)==prior[1].slice(1) and run.bodies.slice(1)==prior[2].slice(1),"class change affects only the chosen hero")
  var start: Array = run.starting_builds();run.memories[0] = "venom"
  check(run.starting_builds()==start and run.customized(0),"adjusting Memory never rewrites class dice; custom gear is marked")
  run.choose_class(0,key);run.start(37)
  var g = F.new();var profile: Dictionary = run.profile();profile["trial.terrain"] = "none";g.start(run.builds,37,true,true,profile);ready(g)
  var before: int = g.boss.hp
  check(not g.hero_action(0,3) and not g.heroes[0].used[0],"class weapon requirements do not spend failed attempts")
  if key=="skirmisher":
   g.heroes[0].results[1] = 2;g.heroes[0].pos = Vector2i(3,7);g.trial_state.positions[0] = g.heroes[0].pos
   check(g.move_steps(2)==2 and g.hero_action(1,-1,Vector2i(3,5)) and g.heroes[0].moved_turn==2,"real Fleet Step supplies the two spaces needed for Jab")
   check(g.hero_action(0,3) and g.boss.hp==before-2 and g.heroes[0].used[0],"class example really deals Jab 1 plus Momentum 1 and spends its die")
  else:
   g.heroes[0].results[1] = 1;g.heroes[0].rolls[1] = 1;g.boss.block = 3
   check(g.move_steps(3)==2 and g.hero_action(1,3) and g.boss.block==2,"Vanguard retains real normal Strikes to set up Crack")
   check(g.hero_action(0,3) and g.boss.block==0 and g.boss.hp==before,"rolled Crack strips the remaining two Block without hidden damage")
   g.heroes[0].block = 2;g.action_owner = 3;g.damage(0,2,false,"Bash",3)
   check(g.heroes[0].trial_counter and g.heroes[0].hp==6,"Vanguard's Memory actually primes after a perfect block")
  check(not run.choose_class(0,"vanguard" if key=="skirmisher" else "skirmisher"),"class cannot be changed during a run")
 for key in K.CLASSES:
  var reward_run = new_party();reward_run.choose_class(0,key);reward_run.start(37);reward_run.phase = "reward"
  var paid: bool = reward_run.add_face(66,1,0) if key=="skirmisher" else reward_run.add_face(68,2,3)
  check(paid and reward_run.essence==1 and reward_run.stage==1 and reward_run.classes[0]==key,"class reward can be installed legally, pays once and retains the class")
 var run = new_party()
 check("fleet" in run.available("body",0) and "stone" not in run.available("body",0) and "stone" in run.available("body",1) and "fleet" not in run.available("body",1),"a class starting Body is scoped to that hero's class")
 run.ingredients.ward = 3;check(run.craft("stone") and "stone" in run.available("body",0),"crafting still unlocks a Body for the other class")
 run.choose_class(0,"vanguard");run.save();var saved = T.new(true)
 check(saved.classes==run.classes and saved.bodies==run.bodies and saved.crafted==run.crafted,"lobby class choices and free gear survive reload")
 run.start(37);run.choose(0);run.phase = "reward";run.hp = [2,4,3];run.save();saved = T.new(true)
 check(saved.phase=="reward" and saved.classes==run.classes and saved.builds==run.builds and saved.hp==run.hp,"safe classed checkpoints preserve builds and injuries")
 # Old checkpoints keep their gear/dice until the next new Trial.
 var legacy = T.new(false);legacy.start(36);legacy.choose(0);legacy.phase = "reward";legacy.hp = [3,4,2];legacy.save()
 var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(T.SAVE));data.erase("classes");data.equipment_version = 36
 var file := FileAccess.open(T.SAVE,FileAccess.WRITE);file.store_string(JSON.stringify(data));file.close();saved = T.new(true)
 check(saved.phase=="reward" and saved.classes==["","",""] and saved.builds==legacy.builds and saved.hp==legacy.hp,"v0.36 checkpoints migrate without changing existing gear, dice or HP")
 saved.phase = "lobby";saved.ensure_classes();check(saved.classes==K.DEFAULTS and saved.bodies==["fleet","stone","fleet"],"next new Trial offers the two classes after a legacy run")
 check(B.Catalog.FACE_COUNT==73 and B.Catalog.extended_ids().size()==48,"normal catalog remains 73 faces and 48 free designs")
 var app=load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.trials = T.new(false);var normal_bank: Dictionary = app.expedition.camp.encode().duplicate(true);var normal_builds: Array = app.builds.duplicate(true)
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);await process_frame;app.open_trials();await process_frame
  check(app.ui.find_child("TrialClassOverview",true,false)!=null,"class card is reachable in every lobby layout")
  app.trial_view = "classes";app.trial_class_preview = "vanguard";app.trial_class_die = 0;app.rebuild();await process_frame
  var text := text_content(app.ui)
  check("Vanguard" in text and "Stone Body" in text and "Memory of Guard" in text and "Hammer" in text and "Crack" in text,"class page explains gear and shows its weapon face")
  check(app.ui.find_child("TrialClassFace0",true,false).text=="Crack" and app.ui.find_child("TrialClassFace3",true,false).text=="Strike","preview shows both Crack and retained Strike on real sides")
  check(app.TrialUI.class_face_help(app,"skirmisher",2).contains("2 spaces") and app.TrialUI.class_face_help(app,"vanguard",3).contains("2 spaces"),"movement face help includes the starting Body modifier")
 app.trials = T.new(false);app.trials.ensure_classes();app.trials.start(37);app.choose_trial_route(0);app.game.active = 0;app.game.pending = {}
 check(app.face_help(2).contains("2 orthogonal spaces") and app.short_face_help(3).contains("4 spaces"),"Skirmisher combat Details show actual Body-modified Step and Stride")
 app.go_main();app.trials = T.new(false);app.trials.ensure_classes();app.trials.choose_class(0,"vanguard");app.trials.start(37);app.choose_trial_route(0);app.game.active = 0;app.game.pending = {}
 check(app.face_help(3).contains("2 spaces") and app.short_face_help(2).contains("1 orthogonal spaces"),"Vanguard combat Details show actual shorter movement")
 check(app.expedition.camp.encode()==normal_bank and app.builds==normal_builds,"class browsing and setup leave normal Camp and builds untouched")
 app.queue_free();await process_frame
 print("CLASSES v0.37: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
