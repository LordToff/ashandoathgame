extends SceneTree
const B = preload("res://prototype/battle.gd")
const E = preload("res://prototype/equipment.gd")
const T = preload("res://prototype/trials.gd")
const F = preload("res://prototype/essence.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("EQUIPMENT FAIL: ",why)
func _initialize():call_deferred("run")
func profile(body: String = "broken", soul: String = "beginning", weapon: String = "dagger", memory: String = "") -> Dictionary:
 return E.configure({},[body,body,body],[soul,soul,soul],[weapon,weapon,weapon],[memory,memory,memory])
func ready(g, build: Array, p: Dictionary) -> void:
 g.start([build,build,build],40,false,true,p);g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.forced_die = -1
 for h in g.heroes:h.used = [false,false,false];h.results = [1,1,1];h.rolls = [0,0,0];h.reaction = [];h.poison = 0
 g.heroes[0].pos = Vector2i(2,3);g.boss.pos = Vector2i(3,3);g.boss.block = 0;g.boss.hp = 30;g.boss.max_hp = 30
func run() -> void:
 var six: Array = [[1,1,34,37,0,0],[1,1,0,0,0,0],[0,0,0,0,0,0]]
 for body in E.BODIES:
  check(not E.BODIES[body].limits.has("Attack"),"Body never owns Attack limits: "+body)
  check(B.validate(six,[34,37],profile(body,"beginning","spear"))=="","Weapon permits six Attacks on every Body: "+body)
  check(B.validate(six,[34,37],profile(body)).contains("Dagger requires 2–5 Attack"),"Dagger caps Attacks independently of Body")
 var too_few: Array = [[1,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
 check(B.validate(too_few,[],profile()).contains("requires 2–5 Attack"),"Weapon minimum enforced")
 var no_strike: Array = [[34,37,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
 check(B.validate(no_strike,[34,37],profile()).contains("replaces 1 basic Strikes"),"Weapon needs physical Strike replacement source")
 var defense: Array = [[1,4,5,0,0,0],[1,4,0,0,0,0],[0,0,0,0,0,0]]
 check(B.validate(defense,[],profile("fleet")).contains("0–2 Defense"),"Fleet Defense max enforced")
 check(B.validate(defense,[],profile("stone"))=="","Stone permits that Defense build")
 check(B.validate(B.default_build(),[],profile("broken","hollow")).contains("3 Blanks"),"Soul owns minimum Blanks")
 var build: Array = [[1,4,0,0,0,0],[1,3,0,0,0,0],[1,34,0,0,0,0]]
 for count in range(1,4):
  var shown: Array = []
  for die in range(3):shown.append(E.effective(build,"dagger",1,die,0,{"replacements":[81,82,83].slice(0,count)}))
  check(shown.slice(0,count)==[81,82,83].slice(0,count) and shown.slice(count).all(func(f):return f==1),"Exact one/two/three replacements, other Strikes preserved")
 var g = B.new()
 for body in E.BODIES:
  ready(g,build,profile(body));check(g.heroes[0].max_hp==6,"Soul HP independent of Body")
  check(g.move_steps(2)==1 and g.move_steps(3)==3,"Body never alters movement distances")
  check(g.soul_remaining(0)==0,"No Blank conversion without Memory")
 ready(g,build,profile());check(g.face(0,0)==81,"Dagger Poke is an actual rolled face")
 check(not g.hero_action(0,3) and not g.heroes[0].used[0],"Poke requires earlier enemy HP damage and invalid attempts spend nothing")
 # The second Strike remains ordinary; only the first physical side is replaced.
 check(g.face(0,1)==1 and g.hero_action(1,3),"Ordinary Strike remains usable before Poke")
 var hp: int = g.boss.hp
 check(g.hero_action(0,3) and g.heroes[0].used[0] and g.boss.hp==hp-1,"Poke spends rolled die after earlier damage")
 check(not g.poke(3),"No free extra Poke")
 ready(g,build,profile("broken","beginning","oathblade"));g.boss.block = 1
 check([g.face(0,0),g.face(0,1),g.face(0,2)]==[84,84,84],"Oathblade projects three physical Strikes")
 for die in range(3):check(g.hero_action(die,3),"Each Oath Cut is a separate rolled Attack")
 check(g.boss.hp==27 and g.boss.block==1,"Pierce passive applies to all three projected attacks")
 ready(g,build,profile("broken","beginning","oathblade"));g.boss.block = 1;g.heroes[0].results[1] = 34
 g.rng.seed = 4;hp = g.boss.hp;g.hero_action(1,3)
 check(g.boss.hp<hp and g.boss.block==1,"Weapon passive also applies to another equipped Attack face")
 ready(g,build,profile());g.heroes[0].hp = 2;g.damage(0,5,false,"Enemy hit",3)
 check(g.heroes[0].hp==1 and g.heroes[0].last_ember_used,"Beginning Soul strong effect saves from lethal enemy damage")
 g.damage(0,2,false,"Enemy hit",3);check(g.heroes[0].hp==0,"Last Ember only once per encounter")
 ready(g,build,profile());g.heroes[0].hp = 1;g.damage(0,1,true,"Voluntary HP cost",0)
 check(g.heroes[0].hp==0 and not g.heroes[0].get("last_ember_used",false),"Soul never cancels voluntary HP costs")
 ready(g,build,profile("broken","beginning","dagger","first_step"));g.heroes[0].results[0] = 0
 check(g.soul_remaining(0)==1 and g.hero_action(0,-1,Vector2i(2,4)),"First Step Memory spends a rolled Blank to move")
 check(g.soul_remaining(0)==0 and g.heroes[0].build[0][2]==0,"Memory allowance spent without changing installed Blank")
 for cls in ["skirmisher","vanguard"]:
  for soul in ["","soulcaster","hollow","nugh","cantor","bugh"]:
   var t = T.new(false);t.ensure_classes();t.choose_class(0,cls);t.souls[0] = soul;t.start(40)
   check(t.phase=="route" and t.validate(t.builds)=="","Legal starter for "+cls+" / "+soul)
   check(t.memories==["","",""] and t.maximum_hp(0)==int(E.SOULS.get(soul,E.SOULS.beginning).hp),"Empty starting Memories; Soul HP")
 var t = T.new(false);t.ensure_classes();t.start(40);t.phase = "reward";t.essence = 3
 check(t.equip_memory_reward("first_step") and t.memories[0]=="first_step" and t.essence==1,"Memory can be earned after first victory")
 var camp = F.new();check(camp.memories==["","",""] and E.active(camp.profile({})),"Normal mode uses shared equipment with empty starting Memory")
 camp.decode({"souls":[["beginning","mire"],["beginning","mire"],["beginning","iron"]],"equipped_souls":["mire","mire","iron"],"memories":["","",""]})
 check(camp.memory_copies.mire_soul==2 and camp.memories==["mire_soul","mire_soul","iron_soul"],"Save conversion retains each owned Memory copy and equipped effect")
 var saved := camp.encode();var restored = F.new();restored.decode(saved)
 check(restored.memory_copies==camp.memory_copies and restored.memories==camp.memories,"Migration round trip is idempotent")
 var p: Dictionary = restored.profile({})
 check(p["soul.mode.0"]=="heal" and p["soul.mode.2"]=="block","Converted Memories drive Blank effects")
 check(restored.souls.all(func(owned):return "beginning" in owned) and restored.equipped_souls==["beginning","beginning","beginning"],"Converted Soul slots retain a valid Beginning Soul")
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.expedition.camp = F.new();app.gifts = [[],[],[]];app.builds = [B.default_build(),B.default_build(),B.default_build()]
 var before: Array = app.builds.duplicate(true)
 app.camp_remove(0,0,0)
 check(app.builds==before and app.expedition.camp.owned(81)==0,"Returning crafted faces never removes a projected Poke / physical Strike")
 app.camp_equip("body",0,"fleet")
 check(E.body_key(app.expedition.camp.bodies[0])=="broken" and app.builds==before and app.camp_message.contains("Defense"),"Incompatible Body equip is atomic and explains its range")
 app.builds[0][2][3] = 0;app.camp_equip("body",0,"fleet")
 check(app.expedition.camp.bodies[0]=="fleet","Compatible Body equip succeeds")
 app.camp_equip("weapon",0,"spear")
 check(app.expedition.camp.weapons[0]=="spear" and app.camp_display_face(0,0,0)==73,"Normal equipped Weapon preview uses Jab")
 app.builds[0] = [[1,69,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]];app.expedition.camp.copies["69"] = 1
 app.camp_remove(0,0,1)
 check(app.builds[0][0][1]==69 and app.camp_message.contains("Attack faces") and app.expedition.camp.owned(69)==1,"Crafted face removal cannot violate Weapon minimum or consume ownership")
 app.expedition.camp.unlocked.memory_iron = true;app.expedition.camp.equip_memory(0,"memory_iron")
 check(not app.camp_battle_profile()["soul.eligible.0"],"Boss Memory of Iron remains its Defense passive, distinct from Ironbound Blank conversion")
 app.queue_free();await process_frame
 print("EQUIPMENT v40: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
