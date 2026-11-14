extends SceneTree
const B = preload("res://prototype/battle.gd")
const N = preload("res://prototype/nugh.gd")
const P = preload("res://prototype/combat_playback.gd")
const D = preload("res://prototype/dice_tray.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("PLAYBACK FAIL: ",text)
func _initialize():call_deferred("run")
func advance(app, seconds: float) -> void:
 for step in app.playback.tick(seconds,false):app.present_step(step)
func run() -> void:
 check(D.RESULT_HOLD>=1.2 and D.DURATION>D.SETTLE+1,"Readable settled result hold")
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.blank_move_setting = false;app.set_mobile_mode(false,false);app.draft_modal = false
 var g = N.new();g.start([B.default_build(),B.default_build(),B.default_build()],41,false,true,{"presentation.capture":true})
 g.active = 3;g.pending = {};g.forced_die = -1;g.command_active = true;g.brood_queue = [4]
 for h in g.heroes:h.reaction = [];h.used = [true,true,true];h.poison = 0;h.hp = 6
 g.heroes[0].pos = Vector2i(4,7);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8);g.unit_data(4).pos = Vector2i(4,6)
 var picker := RandomNumberGenerator.new()
 for seed_value in range(1,50):
  picker.seed = seed_value
  if picker.randi_range(0,5)<2:g.rng.seed = seed_value;break
 app.game = g;app.page = "battle";app.seen_event = g.event_id;app.roll_seen = g.roll_presentations.size();app.dice_tray.cancel();app.playback.model_id = g.get_instance_id();app.playback.clear(P.capture(g));app.visual_positions.clear()
 g.activate_worm();var rng_after: int = g.rng.state
 check(g.heroes[0].hp==5 and g.heroes[0].poison==1,"Real worm model rolls once and resolves hit / Poison")
 app.rebuild()
 check(app.dice_tray.busy and app.playback.current.kind=="roll","Worm roll is the first visible step")
 check(app.display_unit(0).hp==6 and app.display_unit(0).poison==0,"Future damage and Poison are hidden during the roll")
 var drawer: Rect2 = app.dice_tray.panel_rect(1,true)
 check(not drawer.intersects(Rect2(app.ORIGIN,Vector2.ONE*app.CELL*9)),"Desktop dice drawer keeps battlefield visible")
 app.dice_tray._process(D.SETTLE+.5)
 check(app.dice_tray.busy and app.display_unit(0).hp==6,"Settled result stays visible before damage")
 app.dice_tray._process(D.RESULT_HOLD)
 check(app.playback.current.kind=="attack" and app.display_unit(0).hp==6,"After the result: wind-up / lunge before damage")
 check(app.effects.any(func(fx):return fx.kind=="boss_attack" and fx.source==4),"Worm has an identifiable source attack animation")
 advance(app,P.WINDUP+.01)
 check(app.playback.current.kind=="damage" and app.display_unit(0).hp==5 and app.display_unit(0).poison==0,"Impact commits visible HP before Poison")
 advance(app,P.IMPACT+.01)
 check(app.playback.current.kind=="poison" and app.display_unit(0).poison==1,"Poison animates as its own following step")
 check(app.effects.any(func(fx):return fx.kind=="poison") and "poison_tick" in app.status_sounds,"Poison application has visible feedback and sound")
 app.muted = false;app.status_cooldown = 0;app._process(.01)
 check(app.playback.busy() and app.feedback_audio.stream==app.feedback_streams.poison_tick,"Poison sound starts during its visual cue, before playback completes")
 advance(app,P.STATUS+.01)
 check(not app.playback.busy() and g.rng.state==rng_after and g.heroes[0].hp==5,"Replay never rerolls or applies damage twice")
 app.dice_tray.cancel();app.rolling_time = 0;app.rebuild()
 check(app.ui.find_child("SideChronicle",true,false)==null and app.ui.find_child("BattleLogButton",true,false)!=null,"Log is a button instead of a permanent combat column")
 app.open_battle_log();check(app.ui.find_child("BattleHistory",true,false)!=null and app.ui.find_child("LogExtensiveTab",true,false)!=null,"Button opens full Summary / Extensive log")
 app.show_history = false;app.set_blank_move_enabled(true,false)
 check(g.balance["soul.distance.0"]==1 and g.balance["soul.allowance.0"]==1,"Settings toggle enables one Move 1 conversion")
 g.active = 0;g.cursor = g.order.find(0);g.heroes[0].results[0] = 0;g.heroes[0].used[0] = false
 check(g.hero_action(0,-1,Vector2i(3,7)) and g.heroes[0].used[0] and g.heroes[0].soul_moves_used==1,"Enabled Blank spends its rolled die for actual Move 1")
 app.set_blank_move_enabled(false,false);app.set_blank_move_enabled(true,false)
 check(g.soul_remaining(0)==0,"Toggle cannot refill a spent allowance")
 app.set_blank_move_enabled(false,false);check(not g.balance.get("blank.move_override",false),"Settings toggle restores original equipped effects")
 g.active = 3;app.dice_tray.cancel();app.rolling_time = 0
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);app.show_options = false;app.show_history = false;app.rolling_time = 0;app.rebuild();await process_frame
  if size.x<1440:
   var board: Rect2 = app.MobileUI.board_rect(app)
   check(board.size.x>240 and (board.end.y<=size.y-180 if size.x<size.y else board.end.y<=size.y),"Readable square board stays above fixed combat controls")
   for name in ["EnemyStatsButton","MobileEnemyStep","MobileLog"]:
    var control: Control = app.ui.find_child(name,true,false)
    check(control!=null and Rect2(Vector2.ZERO,Vector2(size)).encloses(control.get_global_rect()),"Enemy turn controls fit: "+name)
  if size.x<1440:
   g.pending = {"kind":"soul_blank","hero":0,"die":0};app.rebuild();await process_frame
   var heading: Label = app.ui.find_child("SoulcasterResourceSummary",true,false)
   check(heading.get_theme_font("font").get_string_size(heading.text,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x<=heading.size.x,"Soulcaster resource heading fits one line")
   for face in range(75,81):
    var spell: Button = app.ui.find_child("SoulSpell"+str(face),true,false)
    check(spell!=null and spell.size.y<=56,"Soulcaster spell text stays within its card: "+str(face))
   g.pending = {};app.rebuild();await process_frame
  app.show_options = true;app.trial_fight = true;app.rebuild();await process_frame
  check(app.ui.find_child("BlankMoveToggle",true,false)!=null,"Trial settings include Blank → Move 1 in every layout")
  app.trial_fight = false
 app.queue_free();await process_frame
 print("PLAYBACK v41: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
