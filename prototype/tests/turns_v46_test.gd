extends SceneTree
const B = preload("res://prototype/battle.gd")
const T = preload("res://prototype/trials.gd")
const Field = preload("res://prototype/battlefield_art.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("TURNS46 FAIL: ",why)
func fresh(refill: bool = true, cap: int = 1):
 var g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],46,false,true,{"hero.reroll_each_turn":int(refill),"hero.reroll_cap":cap,"hero.rerolls":0})
 g.order = [0,1,2,3];g.initiative_base = [0,1,2,3];g.cursor = 0;g.active = 0;g.pending = {};g.replaced = [];g.forced_die = -1
 for h in g.heroes:h.rerolls = 0;h.results = [1,4,0];h.used = [false,false,false];h.reaction = []
 g.activate();return g
func attach(app,g) -> void:
 app.game = g;app.page = "battle";app.trial_fight = false;app.lab = false;app.training = false;app.selected = -1;app.show_options = false
 app.dice_tray.cancel();app.seen_event = g.event_id;app.roll_seen = g.roll_presentations.size();app.playback.model_id = g.get_instance_id();app.playback.clear(app.CombatPlayback.capture(g));app.combat_notices.clear();app.rebuild()
func node(app,name: String):return app.ui.find_child(name,true,false)
func _initialize():call_deferred("run")
func run() -> void:
 var off = fresh(false);check(off.heroes[0].rerolls==0,"Default bank behavior has no automatic refill")
 var g = fresh();check(g.heroes[0].rerolls==1 and g.heroes[1].rerolls==0,"Only the hero whose own turn starts gets a refill")
 check(g.action_reroll(0) and g.heroes[0].rerolls==0,"A real reroll consumes the refreshed charge")
 var rng: int = g.rng.state;var events: int = g.event_id
 check(g.reroll_window_reason().contains("next own turn"),"Empty bank explains the next refill")
 check(g.rng.state==rng and g.event_id==events,"Reading refill availability is pure")
 g.finish_turn();check(g.active==1 and g.heroes[1].rerolls==1 and g.heroes[0].rerolls==0,"Next hero refills without changing the previous bank")
 g.finish_turn();g.finish_turn();check(g.active==3 and g.heroes[0].rerolls==0,"Enemy turn never refills hero banks")
 g.finish_turn();check(g.active==0 and g.heroes[0].rerolls==1,"A spent bank refills on the following actual own turn")
 g.finish_turn();check(g.heroes[1].rerolls==1,"Unused turn refills do not stack")
 g = fresh(true,3);g.heroes[0].rerolls = 2;rng = g.rng.state;g.refill_turn_reroll(0)
 check(g.heroes[0].rerolls==2 and g.rng.state==rng,"Earned extra charges are preserved without another RNG roll")
 g = fresh(true,0);check(g.heroes[0].rerolls==0,"A custom zero bank cap is respected")
 g = fresh();g.heroes[0].hp = 0;g.heroes[0].rerolls = 0;g.activate();check(g.heroes[0].rerolls==0,"Downed heroes do not receive unusable refills")
 g = fresh();g.heroes[1].hp = 0;g.heroes[1].rerolls = 0;g.heal(1,1);g.finish_turn()
 check(g.active==1 and g.recovery_active and g.heroes[1].rerolls==1,"A real immediate recovery turn gets its own refill")
 g = fresh();g.heroes[1].rerolls = 0;g.pending = {"kind":"essence_burden_ally","die":2,"copy":4}
 check(g.burden_ally(1,0) and g.active==1 and g.heroes[1].rerolls==0,"Shared Burden is one borrowed action and never refills the recipient")
 var run = T.new();run.phase = "lobby";run.ensure_classes();var profile: Dictionary = run.profile();profile["hero.reroll_each_turn"] = 1;profile["hero.rerolls"] = 0
 g = B.new();g.start(run.starting_builds(),46,false,true,profile);g.order = [0,1,2,3];g.initiative_base = [0,1,2,3];g.cursor = 0;g.pending = {};g.heroes[0].rerolls = 0;g.activate()
 check(g.heroes[0].rerolls==1,"Trials uses the same refill rule")
 var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://prototype/assets/vendor/crawl_party_arena/SELECTIONS.json"))
 for filename in source.files:
  check(FileAccess.get_sha256("res://prototype/assets/vendor/crawl_party_arena/"+filename)==source.files[filename].sha256,"Unchanged original artist tile: "+filename)
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.set_dice_animation(false,false);g = fresh(false);attach(app,g)
 app.set_turn_reroll(true,false);app.set_turn_reroll(false,false);app.set_turn_reroll(true,false)
 check(g.heroes[0].rerolls==0,"Toggling during a turn cannot farm refills")
 check(app.camp_battle_profile()["hero.reroll_each_turn"]==1 and app.blank_move_profile(run.profile())["hero.reroll_each_turn"]==1,"Preference reaches future normal and Trial battles")
 app.set_turn_reroll(true);app.set_blank_move_enabled(true);app.set_dice_animation(false)
 var config := ConfigFile.new();config.load("user://ash-combat-options.cfg")
 check(config.get_value("combat","reroll_each_turn",false) and config.get_value("combat","blank_move_one",false) and not config.get_value("combat","animate_dice",true),"All three settings save together")
 app.reroll_each_turn = false;app.blank_move_setting = false;app.dice_animation = true;app.load_blank_move_setting()
 check(app.reroll_each_turn and app.blank_move_setting and not app.dice_animation,"Preferences restore without erasing older settings")
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1000,false);g = fresh();attach(app,g);await process_frame
  app.toggle_reroll_selection();check(app.choosing_reroll,"Reroll enters selection mode "+str(size))
  check(node(app,"MobileReroll" if app.mobile_mode else "ActionRerollButton").text.contains("Cancel reroll"),"Selection mode has an explicit cancel "+str(size))
  app.toggle_reroll_selection();check(not app.choosing_reroll and g.heroes[0].rerolls==1,"Cancel spends nothing "+str(size))
  app.toggle_reroll_selection();g.finish_turn();app.rebuild();check(not app.choosing_reroll and app.selected==-1,"Changing turns clears stale reroll and target state "+str(size))
  app.show_options = true;app.rebuild();await process_frame
  var toggle: Button = node(app,"TurnRerollToggle")
  check(toggle!=null and toggle.size.x<=app.get_viewport_rect().size.x,"Normal options contain the fitted toggle "+str(size))
  app.trial_fight = true;app.rebuild();await process_frame
  check(node(app,"TurnRerollToggle")!=null,"Trial options contain the same toggle "+str(size))
  app.trial_fight = false;app.show_options = false
 root.size = Vector2i(390,844);app.set_mobile_mode(true,false)
 profile["hero.reroll_each_turn"] = 1;g = B.new();g.start(run.starting_builds(),47,false,true,profile);g.active = 0;g.pending = {};g.forced_die = -1
 g.heroes[0].results[0] = 1;g.heroes[0].used[0] = true;g.heroes[0].omen_held = {"die":0,"face":1,"round":g.round_no+1};attach(app,g);await process_frame
 var card = node(app,"MobileDie0").find_child("DiceCardArtwork",true,false)
 check(card.title.text=="Strike" and not card.spent and "Held" in node(app,"MobileDie0").text,"Saved Omen shows the ability name and held marker without looking spent")
 for hero in range(3):check(app.HeroArt.texture(hero).get_size()==Vector2(32,32),"New party knight has native 32px art: "+str(hero))
 for y in range(8):
  var center: Vector2 = app.ORIGIN+Vector2(3,y)*app.CELL+Vector2.ONE*app.CELL
  var footprint := Rect2(app.ORIGIN+Vector2(3,y)*app.CELL,Vector2.ONE*app.CELL*2)
  check(footprint.encloses(Field.boss_bar(center)),"Boss health bar stays inside its own footprint at row "+str(y))
 app.queue_free();await process_frame
 print("TURNS v46: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
