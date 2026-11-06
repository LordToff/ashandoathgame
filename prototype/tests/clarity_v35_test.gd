extends SceneTree
const B = preload("res://prototype/battle.gd")
const Group = preload("res://prototype/event_battle.gd")
const Preview = preload("res://prototype/battle_preview.gd")
const Run = preload("res://prototype/trials.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V35 FAIL: ",why)
func fresh():
 var g = Group.new();g.prototype_pack = true;g.start([B.default_build(),B.default_build(),B.default_build()],35,false,true)
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.forced_die = -1
 g.heroes[0].pos = Vector2i(4,4);g.heroes[1].pos = Vector2i(4,7);g.heroes[2].pos = Vector2i(8,8);g.boss.pos = Vector2i(4,2);g.unit_data(4).pos = Vector2i(0,0)
 for h in g.heroes:h.used = [false,false,false];h.reaction = [];h.results = [35,4,0];h.rolls = [0,0,0]
 return g
func text_content(node: Node) -> String:
 var result: String = str(node.text)+"\n" if node is Label or node is Button or node is RichTextLabel else ""
 for child in node.get_children():result += text_content(child)
 return result
func _initialize():call_deferred("run_tests")
func run_tests():
 var g = fresh();var preview: Dictionary = Preview.for_face(g,35)
 check(preview.reach==g.face_range(35) and Vector2i(6,4) in preview.tiles,"ranged shot shows empty tiles at exact range")
 check(Vector2i(7,4) not in preview.tiles and 3 in preview.targets,"range excludes farther tiles and includes legal enemy")
 g.heroes[1].pos = Vector2i(4,3);preview = Preview.for_face(g,35)
 check(Vector2i(4,2) in preview.blocked and 3 not in preview.targets,"unit blocking sight is marked and enemy is not a target")
 g = fresh();preview = Preview.for_face(g,19)
 check(Vector2i(4,7) in preview.tiles and 1 in preview.targets and 0 not in preview.targets,"Restore shows its three-tile ally range and no self-target")
 g.balance["memory.loss.0"] = true;g.heroes[1].pos = Vector2i(4,8);preview = Preview.for_face(g,19)
 check(preview.reach==4 and 1 in preview.targets,"Memory range bonus shown exactly")
 g = fresh();g.heroes[1].pos = Vector2i(5,4);preview = Preview.for_face(g,8)
 check(preview.reach==1 and 1 in preview.targets and Vector2i(4,3) in preview.tiles,"Shove shows adjacent reach including empty tiles")
 preview = Preview.for_face(g,64);check(1 in preview.targets and 3 not in preview.targets,"Offering range highlights allies only")
 preview = Preview.for_face(g,52);check(preview.mode=="area" and 0 not in preview.targets,"area ability previews radius without falsely targeting its owner")
 check(Preview.for_face(g,4).mode=="none","self Block does not invent a targeting radius")
 preview = Preview.for_face(g,2);check(preview.destinations==g.reachable(0,g.move_steps(2),false),"movement preview uses actual reachable cells")
 g.balance["trial.enabled"] = true;g.balance["trial.terrain"] = "crates";g.TrialRules.setup(g);g.trial_state.crates = [Vector2i(4,3)]
 preview = Preview.for_face(g,35);check(Vector2i(4,2) in preview.blocked and not g.sight(0,3,2),"crate sight obstruction matches combat")
 g.trial_state.crates.clear();check(3 in Preview.for_face(g,35).targets,"opening sightline restores target preview")
 g = fresh();var before: int = g.rng.state;var events: int = g.event_id;var builds: Array = g.heroes.map(func(h):return h.build.duplicate(true));var used: Array = g.heroes[0].used.duplicate()
 for face in range(73):
  preview = Preview.for_face(g,face)
  check(preview.tiles.all(func(c):return c.x>=0 and c.y>=0 and c.x<9 and c.y<9),"all face previews stay on the board")
 check(g.rng.state==before and g.event_id==events and g.heroes[0].used==used and g.heroes.map(func(h):return h.build)==builds,"previewing never mutates dice, events, state or RNG")
 var independent = Run.new(false);var starter: Array = independent.starting_builds();independent.memories = ["guard","venom","venom"];check(independent.starting_builds()==starter,"Memory selection does not rewrite dice")
 var run = Run.new(false);run.start(35);run.phase = "reward";run.essence = 5;run.save()
 var legacy = JSON.parse_string(FileAccess.get_file_as_string(Run.SAVE));legacy.erase("equipment_version");legacy.paths = legacy.memories;legacy.erase("memories");legacy.erase("weapons");legacy.mods = {"0:0:0":"venom","1:0:0":"heavy"}
 var file := FileAccess.open(Run.SAVE,FileAccess.WRITE);file.store_string(JSON.stringify(legacy));file.close()
 var restored = Run.new(true)
 check(restored.essence==9 and restored.memories==["venom","guard","stride"] and restored.weapons==["dagger","dagger","dagger"],"old modifiers refunded and old selections migrated to Memory slots")
 restored.save();var twice = Run.new(true);check(twice.essence==9,"migration refund cannot repeat")
 var app=load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.trials = Run.new(false);app.open_trials();await process_frame;var text := text_content(app.ui)
 for slot in ["Body","Memory","Soul","Weapon"]:check(slot in text,"setup explains each existing equipment slot")
 check(not "edge" in text.to_lower() and not "pact" in text.to_lower() and not "passive" in text.to_lower(),"setup has no extra equipment concepts")
 app.trials.start(35);app.trials.phase = "reward";app.trials.reward_mode = "weapon";app.rebuild();await process_frame;text = text_content(app.ui)
 check("Weapon" in text and "Equip Poison Dagger" in text and not "Attack edge" in text,"reward equips one named Weapon")
 app.game = fresh();app.page = "battle";app.seen_event = app.game.event_id;app.roll_seen = app.game.roll_presentations.size();app.dice_tray.cancel();app.rolling_time = 0;app.combat_notices.clear()
 app.game.heroes[0].rerolls = 1;var serial: int = app.game.roll_serial;app.perform_reroll(0)
 check(app.combat_notices.is_empty() and app.game.roll_serial>serial and app.game.heroes[0].rerolls==0,"Action Reroll animates the real roll without a text prompt")
 app.dice_tray.cancel();app.rolling_time = 0;app.game.heroes[0].used = [false,false,false];app.game.heroes[0].results = [6,1,0];app.game.forced_die = -1;app.game.hero_action(0,1);app.sync_presentation()
 check(app.combat_notices.is_empty() and app.game.forced_die==1,"Focus reroll does not create a blocking prompt")
 # A boss Trial also emits ordinary harvest events; these must stay out of Camp.
 app.dice_tray.cancel();app.rolling_time = 0;app.trials = Run.new(false);app.trials.start(35);app.trials.stage = 5;app.trials.choose(0)
 var camp_before: Dictionary = app.expedition.camp.encode().duplicate(true);app.start_trial_battle();app.game.damage(3,999,true);app.sync_presentation()
 check(app.expedition.camp.encode()==camp_before,"Trial boss harvest does not leak discoveries or resources into ordinary Camp")
 app.queue_free();await process_frame
 print("CLARITY v0.35: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
