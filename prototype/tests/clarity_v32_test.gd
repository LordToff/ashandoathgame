extends SceneTree
const B = preload("res://prototype/battle.gd")
const T = preload("res://prototype/enemy_targeting.gd")
const E = preload("res://prototype/essence.gd")
const M = preload("res://prototype/event_battle.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("CLARITY FAIL: ",why)
func fresh():
 var game = B.new();game.start([B.default_build(),B.default_build(),B.default_build()],32)
 game.active = 0;game.pending = {};game.outcome = "";game.forced_die = -1
 for h in game.heroes:h.hp=6;h.dead=false;h.used=[false,false,false];h.reaction=[];h.results=[41,4,0];h.rolls=[0,0,0];h.pos=Vector2i(0,7)
 game.heroes[0].pos=Vector2i(3,5);game.heroes[1].pos=Vector2i(5,5);game.heroes[2].pos=Vector2i(0,7);return game
func _initialize():call_deferred("run")
func run():
 var g = fresh();g.heroes[0].hp=2;g.heroes[1].hp=5;g.heroes[2].hp=6
 check(T.pick(g,3,[0,1],"Smoking Strike",0)==0,"lowest HP in reach")
 check(T.pick(g,3,[0,1],"Driving Blow",0) in [0,1],"unreachable highest-HP hero falls back to closest legal")
 g.heroes[1].block=5
 check(T.pick(g,3,[0,1],"Shield Bash",0)==1,"highest Block")
 g.heroes[0].poison=2;check(T.pick(g,3,[0,1],"Venom Bite",0)==0,"debuff hunter")
 g.heroes[0].dr=1;g.heroes[0].ward=true;g.heroes[0].num_boost=1
 check(T.pick(g,3,[0,1],"Distort",0)==0,"buff hunter")
 g.heroes[1].damage_last_round=8;check(T.pick(g,3,[0,1],"Cinder Brand",0)==1,"previous-round threat")
 g.heroes[1].pos=Vector2i(5,4)
 var choices: Array = []
 for seed_value in range(40):
  g.intent_seed = seed_value;var tied := T.pick(g,3,[0,1],"Skirmish",0)
  if tied not in choices:choices.append(tied)
 check(choices.size()==2,"tied targets vary with round seed, not hero index")
 var rng_before: int = g.rng.state;var target := T.pick(g,3,[0,1],"Skirmish",0)
 for read in range(30):check(T.pick(g,3,[0,1],"Skirmish",0)==target,"tie stays stable while reading")
 g.enemy_intents();check(g.rng.state==rng_before,"intent reading never advances RNG")
 check(g.enemy_intent(3,"Ashen Chain",0).policy=="Furthest hero","chain preference readable")
 check(g.enemy_intent(3,"Brace",0).target_text==g.boss_name(),"self-target explicit")
 check(g.enemy_intent(3,"Sweep",0).policy.begins_with("All heroes"),"area target explicit")
 g.heroes[0].build[0]=[41,1,0,0,0,0];g.heroes[0].stored_num=1;g.action_owner=0;g.action_label="Engrave"
 check(g.hero_action(0,3),"Engrave resolves")
 check(g.heroes[0].build[0].count(41)==2,"Engrave actually installs another side")
 check(g.event_log.any(func(e):return e.kind=="engrave" and e.value==1 and e.has("faces")),"growth supplies updated die preview")
 check(g.heroes[0].results[2]==0,"growth does not rewrite recorded Blank results")
 g=fresh();g.heroes[0].build[0]=[41,1,0,0,0,0];g.boss.block=9;g.heroes[0].stored_num=1;g.hero_action(0,3)
 check(g.heroes[0].build[0].count(41)==1,"fully blocked hit cannot grow")
 check(g.event_log.any(func(e):return e.kind=="engrave" and e.value==0),"failed growth explains why")
 g=fresh();g.heroes[0].hp=2;g.heroes[1].hp=5;g.heroes[1].pos=Vector2i(5,4);g.active=3;g.boss_index=0;g.boss_rolls=["Smoking Strike","Brace","Brace"]
 var preview: Dictionary = g.enemy_intent(3,"Smoking Strike",0);g.boss_step()
 check(preview.target==0 and g.last_targets==[0],"real boss resolution matches named intent")
 g=fresh();g.action_owner=0;g.damage(3,1,true);g.shared_roll()
 check(g.heroes[0].damage_last_round==1 and g.heroes[0].damage_this_round==0,"actual HP damage tracked across rounds")
 var clean=fresh();clean.round_no=3;clean.heroes[0].backstab=2
 check(T.score(clean,3,0,"Distort")==0,"expired Weak Point is not an active buff")
 clean.heroes[0].weak=true;clean.heroes[0].bulwark_weak=true
 check(T.score(clean,3,0,"Venom Bite")==1,"two Weakness sources count as one active debuff")
 var e=E.new();check(e.reward_name("bone_strike")=="Bone Strike" and "Adjacent" in e.reward_effect("bone_strike"),"recipes readable before paying")
 check(e.recipe_progress("bone_strike").contains("2 more"),"Essence deficit explicit")
 var app=load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.page="battle";app.game=fresh();app.game.heroes[0].poison=2;app.game.tick_poison(0);app.seen_event=0;app.sync_presentation()
 check("poison_tick" in app.status_sounds,"poison damage queues sound")
 check(app.effects.any(func(f):return f.kind=="poison_tick"),"poison damage has its own visual")
 app.status_sounds.clear();app.game.heroes[0].hp=2;app.game.heal(0,1);app.sync_presentation();check("heal" in app.status_sounds,"positive healing queues sound")
 app.status_sounds.clear();app.game.heroes[0].stun=true;app.sync_presentation();check("stun" in app.status_sounds,"Stun transition queues sound")
 var event_count: int = app.status_sounds.size();app.sync_presentation();check(app.status_sounds.size()==event_count,"redrawing does not replay feedback")
 check(app.feedback_streams.heal.data!=app.feedback_streams.stun.data and app.feedback_streams.heal.data!=app.feedback_streams.poison_tick.data,"three distinct synthesized sounds")
 check(app.color_for_face(0)==Color("c3c9d2") and app.color_for_face(2)==Color("e7cc75"),"Blank grey and movement yellow")
 app.dice_tray.cancel();app.rolling_time=0;app.combat_notices.clear();app.game.pending={"kind":"catalog_choice","face":16,"hero":0,"die":0,"stage":0};app.game.heroes[0].results=[16,1,0];app.rebuild();await process_frame
 check(app.ui.find_children("RolledChoice*","Button",true,false).size()==9,"picker contains nine face-up dice, no installed sides")
 app.game.pending={};app.show_intents=true;app.rebuild();await process_frame
 check(app.ui.find_children("BattlePanelScroll","ScrollContainer",true,false).size()==1,"dedicated scrollable intent panel")
 app.queue_free();await process_frame;print("CLARITY v0.32: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
