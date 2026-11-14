extends SceneTree
const B = preload("res://prototype/battle.gd")
const N = preload("res://prototype/nugh.gd")
const T = preload("res://prototype/trials.gd")
const Prep = preload("res://prototype/trial_preparation.gd")
const Helpers = preload("res://prototype/tests/presentation_helpers.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("UX42 FAIL: ",why)
func tap(app, name: String) -> void:
 var b: Button = app.ui.find_child(name,true,false)
 check(b!=null and not b.disabled,"Reachable: "+name)
 if b!=null and not b.disabled:b.pressed.emit()
func attach(app, g) -> void:
 app.game = g;app.page = "battle";app.trial_fight = false;app.show_options = false;app.show_history = false;app.mobile_info = "";app.selected = -1
 app.dice_tray.cancel();app.seen_event = g.event_id;app.roll_seen = g.roll_presentations.size();app.playback.model_id = g.get_instance_id();app.playback.clear(app.CombatPlayback.capture(g));app.effects.clear();app.floaters.clear();app.rebuild()
func _initialize():call_deferred("run")
func run() -> void:
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.set_mobile_mode(false,false);app.draft_modal = false
 var camp_before: Dictionary = app.expedition.camp.encode().duplicate(true);var normal_builds: Array = app.builds.duplicate(true)
 var g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],42,false,true,{"presentation.capture":true})
 g.active = 0;g.pending = {};g.heroes[0].used = [false,false,false];g.heroes[0].reaction = [];g.forced_die = -1
 attach(app,g);app.set_dice_animation(false,false)
 check(g.action_reroll(0),"Real Action Reroll succeeds with animation disabled")
 var rng: int = g.rng.state;var result: int = g.face(0,0);var rolls: int = g.roll_presentations.size();app.rebuild()
 check(not app.dice_tray.busy and not app.playback.busy(),"OFF removes both dice animation and result pause")
 check(app.playback.last_roll!="" and g.roll_presentations.size()==rolls and g.event_log[-1].kind=="roll","OFF retains the result and full battle history")
 app._process(.1);check(g.rng.state==rng and g.face(0,0)==result,"Skipping dice does not reroll or change RNG")
 app.set_dice_animation(true,false);g.heroes[0].rerolls = 1;g.heroes[0].used[0] = false;g.heroes[0].reaction.erase(0);g.forced_die = -1
 check(g.action_reroll(0),"Second real reroll")
 app.rebuild();check(app.dice_tray.busy,"ON retains the readable dice presentation")
 app.set_dice_animation(false,false);check(not app.dice_tray.busy and not app.playback.busy(),"Disabling an active drawer completes it without cancelling combat replay")
 app.set_dice_animation(false);app.set_blank_move_enabled(true)
 var cfg := ConfigFile.new();cfg.load("user://ash-combat-options.cfg")
 check(not cfg.get_value("combat","animate_dice",true) and cfg.get_value("combat","blank_move_one",false),"Both preferences save together")
 app.dice_animation = true;app.blank_move_setting = false;app.load_blank_move_setting()
 check(not app.dice_animation and app.blank_move_setting,"Preferences restore together")
 app.set_blank_move_enabled(false);cfg.load("user://ash-combat-options.cfg");check(not cfg.get_value("combat","animate_dice",true),"Blank toggle never erases dice preference")
 # A lethal enemy hit has a dedicated visible fall and no second model application.
 var n = N.new();n.start([B.default_build(),B.default_build(),B.default_build()],43,false,true,{"presentation.capture":true});n.active = 0;n.pending = {}
 attach(app,n);n.damage(4,999,true,"UX death");var boss_hp: int = n.boss.hp;var rng_death: int = n.rng.state;app.rebuild()
 check(app.playback.current.get("kind","")=="fall" and app.effects.any(func(f):return f.kind=="fall" and f.target==4),"Enemy death visibly collapses at its HP impact")
 check(app.playback.busy() and n.unit_data(4).dead,"Fall pauses presentation while the model stays resolved")
 Helpers.drain(app);check(n.boss.hp==boss_hp and n.rng.state==rng_death,"Death replay cannot repeat Soul Link, rewards or RNG")
 g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],44,false,true,{"presentation.capture":true});g.active = 0;g.pending = {};g.heroes[0].hp = 1
 attach(app,g);g.damage(0,1,true,"Fall test",3);app.rebuild()
 check(g.heroes[0].hp==0 and not g.heroes[0].dead and app.playback.current.kind=="fall" and not app.playback.current.fallen[0].dead,"Downed receives a distinct nonlethal fall")
 Helpers.drain(app);g.heroes[0].protected = false;g.damage(0,1,true,"Slain test",3);app.rebuild()
 check(g.heroes[0].dead and app.playback.current.kind=="fall" and app.playback.current.fallen[0].dead,"A Downed hero slain at zero HP still receives death feedback")
 Helpers.drain(app)
 # The actual wizard controls preserve each hero and never edit normal Camp.
 app.go_main();camp_before = app.expedition.camp.encode().duplicate(true);normal_builds = app.builds.duplicate(true)
 app.trials = T.new(false);app.open_trials();await process_frame
 check(app.trials.prepare_step==0 and app.trials.hero==0,"Preparation begins at the first hero / Class")
 tap(app,"TrialPrepClass_vanguard");await process_frame;await process_frame
 check(app.trials.classes[0]=="vanguard" and app.trials.classes[1]=="vanguard","Class choice belongs to the current hero")
 tap(app,"TrialPrepNext");await process_frame;await process_frame
 tap(app,"TrialPrepSoul_soulcaster");await process_frame;await process_frame
 tap(app,"TrialPrepNext");await process_frame;await process_frame
 tap(app,"TrialPrepBody_broken");await process_frame;await process_frame
 tap(app,"TrialPrepNext");await process_frame;await process_frame
 tap(app,"TrialPrepWeapon_spear");await process_frame;await process_frame
 tap(app,"TrialPrepNext");await process_frame;await process_frame
 check(app.trials.prepare_step==4 and app.trials.memories[0]=="","Memory step correctly starts empty")
 tap(app,"TrialPrepNext");await process_frame;await process_frame
 var faces: Array = app.ui.find_children("TrialPrepDie*","Button",true,false).map(func(b):return b.text)
 check(faces.size()==18 and "Jab" in faces and "Crack" not in faces,"Review shows all 18 actual sides with the selected Weapon projection")
 check("Gather" in Prep.face_help(app,0,0),"Blank preview uses this Trial hero’s Soulcaster, not normal Camp equipment")
 check(app.trials.starting_builds()[0].all(func(die):return die.count(0)>=4),"Soulcaster preview adapts all dice to four Blanks")
 tap(app,"TrialPrepNext");await process_frame;await process_frame
 check(app.trials.hero==1 and app.trials.prepare_step==0 and app.trials.prepared==[true,false,false],"Review advances to the next hero, retaining the first kit")
 for hero in [1,2]:
  for step in range(6):
   check(app.trials.hero==hero and app.trials.prepare_step==step,"Sequential per-hero step")
   tap(app,"TrialPrepNext");await process_frame;await process_frame
 check(app.trials.prepare_step==6 and app.trials.prepared==[true,true,true],"All three reviews lead to the party / boss page")
 var restored = T.new(true)
 check(restored.prepare_step==6 and restored.prepared==[true,true,true] and restored.classes==app.trials.classes and restored.souls[0]=="soulcaster","Reload restores wizard progress and gear")
 check(app.expedition.camp.encode()==camp_before and app.builds==normal_builds,"Preparation never touches normal Camp or dice")
 tap(app,"TrialPrepBegin");await process_frame;await process_frame
 check(app.trials.phase=="route" and app.trials.validate(app.trials.builds)=="" and app.trials.memories==["","",""],"Begin creates the reviewed legal party with empty Memories")
 var soul_before: String = app.trials.souls[0];app.trials.souls[0] = "bugh"
 check("2 spaces" in Prep.face_help(app,0,3),"Warden Soul preview includes its movement penalty")
 app.trials.souls[0] = soul_before
 var preset = T.new(false);preset.ensure_classes();preset.prepared = [true,true,true];preset.prepare_step = 6
 preset.apply_build(preset.C.BUILDS.keys()[0],1)
 check(preset.prepare_step==0 and preset.hero==1 and preset.prepared==[true,false,true],"Applying a Forge build returns its changed hero to preparation review")
 # Fixed headers and their dedicated slots stay apart on each encounter.
 for model in [B.new(),N.new(),preload("res://prototype/cantor.gd").new(),preload("res://prototype/bugh.gd").new()]:
  model.start([B.default_build(),B.default_build(),B.default_build()],45,false,true,{"presentation.capture":true});model.active = 0;model.pending = {}
  attach(app,model);app.set_mobile_mode(false,false);app.rebuild();await process_frame
  var log: Control = app.ui.find_child("BattleLogButton",true,false)
  for name in ["NughBroodStatus","WardenStatus","ResonanceStatus"]:
   var badge: Control = app.ui.find_child(name,true,false)
   if badge:check(not badge.get_global_rect().intersects(log.get_global_rect()),"Boss badge does not overlap log: "+name)
  var phase: Control = app.ui.find_child("BossPhaseSummary",true,false)
  for index in range(3):
   var intent: Control = app.ui.find_child("EnemyIntent"+str(index),true,false)
   check(intent.size.y==44 and not intent.get_global_rect().intersects(phase.get_global_rect()),"Long intent stays in its fixed row")
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);app.show_options = true
  for trial in [false,true]:
   app.trial_fight = trial;app.rebuild();await process_frame
   check(app.ui.find_child("DiceAnimationToggle",true,false)!=null,"Dice setting is present in both modes / layouts")
 app.queue_free();await process_frame
 print("UX v42: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
