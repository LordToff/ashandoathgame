extends SceneTree
const T = preload("res://prototype/trials.gd")
const E = preload("res://prototype/trial_encounter.gd")
const Art = preload("res://prototype/enemy_art.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("DIRECT FAIL: ",why)
func _initialize():call_deferred("run_tests")
func fresh(app) -> void:
 app.game = E.new();app.trials = T.new(false);app.trials.ensure_classes();app.trials.memories[0] = "";app.trials.bodies[0] = "broken";app.trials.loadout_weapons[0] = "dagger";app.trials.start(39)
 var profile: Dictionary = app.trials.profile();profile["trial.terrain"] = "none";app.game.start(app.trials.builds,39,true,true,profile)
 app.page = "battle";app.trial_fight = true;app.game.active = 0;app.game.cursor = app.game.order.find(0);app.game.pending = {};app.game.forced_die = -1;app.selected = -1
 for h in app.game.heroes:h.used = [false,false,false];h.reaction = [];h.results = [1,4,2];h.rolls = [0,0,0]
 app.game.heroes[0].pos = Vector2i(3,5);app.game.heroes[1].pos = Vector2i(2,5);app.game.heroes[2].pos = Vector2i(8,8);app.game.boss.pos = Vector2i(3,4);app.game.boss.block = 0;app.game.boss.hp = 10;app.game.unit_data(4).pos = Vector2i(8,0)
 app.game.trial_state.positions = {}
 for id in range(app.game.unit_count()):app.game.trial_state.positions[id] = app.game.unit_data(id).pos
 app.roll_seen = app.game.roll_presentations.size();app.seen_event = app.game.event_id;app.dice_tray.cancel();app.rolling_time = 0;app.inspect_actor = 0;app.rebuild()
func click(app, cell: Vector2i) -> void:
 var event := InputEventMouseButton.new();event.button_index = MOUSE_BUTTON_LEFT;event.pressed = true;event.position = app.ORIGIN+Vector2(cell)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(event)
func run_tests() -> void:
 var app=load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame;app.set_mobile_mode(false,false)
 fresh(app);app.select_combat_die(0);check(not app.game.heroes[0].used[0] and app.trial_choice.is_empty(),"selecting Attack waits for map target without confirmation stage")
 click(app,Vector2i(3,4));check(app.game.boss.hp==9 and app.game.heroes[0].used[0] and app.trial_choice.is_empty(),"target tap resolves Strike immediately")
 fresh(app);app.select_combat_die(1);check(app.game.heroes[0].block==1 and app.game.heroes[0].used[1] and app.selected==-1,"Guard resolves from one ability tap")
 fresh(app);app.select_combat_die(2);check(app.game.heroes[0].pos==Vector2i(3,5),"movement selection does not move before target")
 click(app,Vector2i(4,5));check(app.game.heroes[0].pos==Vector2i(4,5) and app.game.heroes[0].used[2],"Step moves on destination tap, no Confirm")
 fresh(app);app.select_combat_die(0);var rng_before: int = app.game.rng.state;click(app,Vector2i(8,0));check(not app.game.heroes[0].used[0] and app.game.boss.hp==10 and app.game.rng.state==rng_before,"invalid target spends neither die nor RNG")
 fresh(app);app.game.heroes[0].results[0] = 78;app.game.heroes[0].build[0][0] = 78;app.game.heroes[1].hp = 2;app.select_combat_die(0);click(app,Vector2i(2,5));check(app.game.heroes[1].hp==4 and app.game.heroes[0].used[0] and app.game.heroes[0].build[0][0]==0,"Grave Stitch heals the tapped ally and returns to Blank directly")
 for key in Art.STILLS:
  var first: AtlasTexture = Art.texture(key,0);var next: AtlasTexture = Art.texture(key,.25);var walk: AtlasTexture = Art.texture(key,0,true)
  check(first.region!=next.region and first.region!=walk.region,"licensed sprite has real idle/run frames: "+key)
  check(first.region.size.x<=32 and first.region.size.y<=32,"pixel source bounds stay native: "+key)
 app.queue_free();await process_frame
 print("DIRECT v39: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
