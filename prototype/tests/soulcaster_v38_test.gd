extends SceneTree
const B = preload("res://prototype/battle.gd")
const T = preload("res://prototype/trials.gd")
const E = preload("res://prototype/trial_encounter.gd")
const S = preload("res://prototype/soulcaster.gd")
const Preview = preload("res://prototype/battle_preview.gd")
const Forecast = preload("res://prototype/trial_forecast.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("SOULCASTER FAIL: ",why)
func party():
 var t = T.new(false);t.ensure_classes();t.choose_soul(0,"soulcaster");t.memories[0] = "";t.loadout_weapons[0] = "dagger";t.start(38);return t
func fresh(objective: String = ""):
 var t = party();var g = E.new();g.objective_mode = objective;var profile: Dictionary = t.profile();profile["trial.terrain"] = "none";g.start(t.builds,38,true,true,profile)
 g.active = 0;g.order = [0,1,2,3];g.cursor = 0;g.pending = {};g.forced_die = -1;g.trial_state.fate_queue = [];g.trial_state.fate_resume = ""
 for h in g.heroes:h.results = [0,0,0];h.rolls = [2,2,2];h.used = [false,false,false];h.reaction = [];h.poison = 0
 g.heroes[0].pos = Vector2i(2,5);g.heroes[1].pos = Vector2i(3,5);g.heroes[2].pos = Vector2i(8,8);g.boss.pos = Vector2i(3,4);g.unit_data(4).pos = Vector2i(8,0)
 g.trial_state.positions = {}
 for id in range(g.unit_count()):g.trial_state.positions[id] = g.unit_data(id).pos
 return g
func face(g, f: int, die: int = 0) -> void:
 g.heroes[0].results[die] = f;g.heroes[0].build[die][g.heroes[0].rolls[die]] = f;g.heroes[0].used[die] = false
func signature(g) -> String:return JSON.stringify([g.heroes,g.boss,g.minions,g.pending,g.trial_state,g.event_log,g.roll_presentations,g.outcome,g.rng.state,g.forced_die])
func _initialize():call_deferred("run_tests")
func run_tests() -> void:
 var t = party();check(t.validate(t.builds)=="" and t.maximum_hp(0)==6,"legal adapted starting dice and 6 HP without Memory")
 for key in t.Classes.CLASSES:
  for id in range(3):
   var p = T.new(false);p.ensure_classes();p.choose_class(id,key);check(p.choose_soul(id,"soulcaster"),"starter Soul free on either class and every hero")
   p.start(38);check(p.validate(p.builds)=="" and p.maximum_hp(id)==5,"Memory -1 applies to base 6")
   var model = E.new();model.start(p.builds,38,true,true,p.profile());check(model.heroes[id].max_hp==p.maximum_hp(id),"UI HP equals live battle")
   for d in p.builds[id]:check(d.count(0)==4,"four starting Blanks per die")
 var candidate: Array = t.builds.duplicate(true);candidate[0][0][2] = 3;check("4 Blanks" in t.validate(candidate),"construction enforces required Blanks")
 check(B.Catalog.FACE_COUNT==73 and B.Catalog.extended_ids().size()==48 and not B.valid_face_number(75),"spells stay out of normal ownership and free pool")
 var normal = B.new();normal.start([B.default_build(),B.default_build(),B.default_build()],38,true);check(not S.equipped(normal,0) and not normal.heroes[0].has("soul_charges"),"normal encounters keep original state")
 var g = fresh();check(g.heroes[0].hp==6 and S.charges(g,0)==0,"encounter resources initialize")
 var rng_state: int = g.rng.state;check(Preview.for_face(g,0).mode=="none" and g.rng.state==rng_state,"caster Blank has no misleading movement preview")
 check(g.hero_action(0) and g.pending.kind=="soul_blank" and not g.heroes[0].used[0],"Use opens casting without spending")
 check(not S.manifest(g,76) and g.pending.kind=="soul_blank","cannot create without charges")
 check(S.gather(g) and S.charges(g,0)==1 and g.heroes[0].used[0],"Gather spends one result for one charge")
 g.heroes[0].used[0] = false;S.blank(g,0);check(S.manifest(g,76),"Manifest pays legal costs")
 check(S.charges(g,0)==0 and g.heroes[0].hp==5 and g.heroes[0].build[0][2]==76 and g.face(0,0)==0 and g.heroes[0].used[0],"new spell installed physically but not usable on creation turn")
 check(not g.hero_action(0,3),"creation-turn activation rejected")
 for spell in [76,77,80]:
  g = fresh();g.heroes[0].soul_charges = 3;S.blank(g,0);S.manifest(g,spell)
  g.heroes[0].results[0] = spell;g.heroes[0].used[0] = false;g.heroes[0].reaction = [0] if spell==77 else [];g.heroes[0].rerolls = 0;g.on_roll(g.heroes[0],0)
  check(g.heroes[0].used[0] and not 0 in g.heroes[0].reaction and g.trial_state.fate_queue.is_empty() and g.heroes[0].rerolls==0,"later reroll on creation turn cannot activate any spell, Reaction or Fatebreaker")
  g.round_no += 1;g.heroes[0].used[0] = false;g.on_roll(g.heroes[0],0)
  check(not S.created_this_turn(g,0,0) and (spell!=80 or not g.trial_state.fate_queue.is_empty()),"spell activates on a later shared roll before turn-start counter advances")
 g = fresh();g.heroes[0].soul_charges = 3;S.blank(g,0);check(not S.gather(g),"charge cap disables Gather without spending")
 for f in range(75,81):
  g = fresh();g.heroes[0].soul_charges = 3;S.blank(g,0);var hp: int = g.heroes[0].hp
  check(S.manifest(g,f) and g.heroes[0].hp==hp-1 and S.charges(g,0)==3-int(S.SPELLS[f].cost),"all six spell creation costs match PDF")
 g = fresh();g.heroes[0].build[1] = [75,76,77,78,0,0];g.heroes[0].soul_charges = 3;S.blank(g,0);check(not S.manifest(g,79) and "4 manifested" in S.manifest_reason(g,0,79),"per-caster four-spell cap")
 g = fresh();g.heroes[0].soul_charges = 1;g.heroes[0].hp = 1;S.blank(g,0);check(S.manifest(g,76) and g.heroes[0].hp==0 and g.heroes[0].build[0][2]==76,"HP creation cost can Down, installed spell persists")
 g = fresh();face(g,75);var first: Vector2i = g.heroes[0].pos;var second: Vector2i = g.heroes[1].pos
 check(g.hero_action(0,1) and g.pending.kind=="soul_steps" and g.heroes[0].pos==second and g.heroes[1].pos==first,"Wraith swaps allied heroes")
 check(S.optional_step(g,Vector2i(1,0)) and g.heroes[0].pos==second+Vector2i(1,0),"caster optional step exactly one despite Body")
 check(S.optional_step(g,Vector2i.ZERO) and g.pending.is_empty(),"ally may stay; choice finishes")
 g = fresh();face(g,75);g.heroes[1].rooted = 1;check(not g.hero_action(0,1),"Rooted prevents swap")
 g = fresh();face(g,76);g.heroes[0].soul_charges = 0;check(not g.hero_action(0,3) and not g.heroes[0].used[0],"Harvester requires activation charge")
 g.heroes[0].soul_charges = 3;g.boss.hp = 1;g.boss.block = 0
 var before := signature(g);var prediction: Dictionary = Forecast.calculate(g,0,3);check(prediction.valid and signature(g)==before,"spell forecasts never mutate or consume live RNG")
 check(g.hero_action(0,3) and g.boss.hp==0 and S.charges(g,0)==3,"Harvester spends one then kill refunds two capped at 3")
 g = fresh("ritual");face(g,76);g.heroes[0].soul_charges = 1;var stone: int = g.objective_ids("ritual")[0];g.unit_data(stone).hp = 1
 check(g.hero_action(0,stone) and S.charges(g,0)==0,"objective objects do not refund enemy kill charges")
 g = fresh();face(g,78);g.heroes[1].hp = 0;check(g.hero_action(0,1) and g.heroes[1].hp==2 and g.heroes[1].broken and g.heroes[0].build[0][2]==0,"Grave Stitch revives for 2 and returns physical side Blank")
 g = fresh("spirit");face(g,78);var spirit: int = g.objective_ids("spirit")[0];g.unit_data(spirit).hp = 1;g.unit_data(spirit).pos = Vector2i(2,6)
 check(g.hero_action(0,spirit) and g.unit_data(spirit).hp==3,"Grave Stitch heals living objective ally")
 g = fresh();face(g,77);g.heroes[0].reaction = [0];g.heroes[0].used[0] = true;g.heroes[1].pos = Vector2i(3,5);var hp: int = g.boss.hp
 g.pending = {"kind":"attack","action":"Bash","source":3,"range":1,"area":false,"victims":[1],"reacted":[],"amount":2};g.continue_attack()
 check(g.pending.kind=="reaction" and g.pending.hero==0,"Mirror protects an ally in range")
 g.react(true);check(g.heroes[1].hp==g.heroes[1].max_hp and g.boss.hp==hp-1 and g.pending.is_empty(),"Mirror blocks 2 then reflects 1 after no HP loss")
 g = fresh();face(g,77);g.heroes[0].reaction = [0];g.heroes[0].used[0] = true;hp = g.boss.hp
 g.pending = {"kind":"attack","action":"Bash","source":3,"range":1,"area":false,"victims":[1],"reacted":[],"amount":3};g.continue_attack();g.react(true)
 check(g.heroes[1].hp==g.heroes[1].max_hp-1 and g.boss.hp==hp,"Mirror does not reflect an Attack with HP loss")
 # Mirror waits for the entire Attack, including forced collision and its Stun choice.
 g = fresh();face(g,77);g.heroes[0].reaction = [0];g.heroes[0].used[0] = true;g.heroes[0].pos = Vector2i(2,8);g.heroes[1].pos = Vector2i(3,8);g.boss.pos = Vector2i(3,7);hp = g.boss.hp
 g.pending = {"kind":"attack","action":"Drive Back","source":3,"range":1,"area":false,"victims":[1],"reacted":[],"amount":1};g.continue_attack();g.react(true)
 check(g.pending.get("kind","")=="stun" and g.boss.hp==hp,"collision choice delays Mirror completion")
 g.stun_die(0);check(g.boss.hp==hp and g.trial_state.mirrors.is_empty(),"unavoidable collision HP loss prevents reflection after full Attack")
 g = fresh();face(g,77);g.heroes[0].reaction = [0];g.heroes[0].used[0] = true;g.heroes[2].pos = Vector2i(4,5);g.active = 1;g.heroes[1].results[0] = 1
 hp = g.heroes[1].hp
 check(g.hero_action(0,2) and g.pending.kind=="soul_friendly_mirror","Mirror can protect from friendly Attack")
 check(S.friendly_mirror(g,true) and g.heroes[2].hp==g.heroes[2].max_hp and g.heroes[1].hp==hp-1,"friendly Mirror consumes held Reaction, blocks and reflects")
 g = fresh("spirit");face(g,77);g.heroes[0].reaction = [0];g.heroes[0].used[0] = true;var spirit_mirror: int = g.objective_ids("spirit")[0];g.unit_data(spirit_mirror).pos = Vector2i(2,4);hp = g.boss.hp
 g.pending = {"kind":"attack","action":"Bash","source":3,"range":1,"area":false,"victims":[spirit_mirror],"reacted":[],"amount":2};g.continue_attack();g.react(true)
 check(g.unit_data(spirit_mirror).hp==5 and g.boss.hp==hp-1,"Mirror protects and reflects for the living Spirit")
 g = fresh();face(g,79);check(g.hero_action(0,1) and int(g.heroes[1].omen_offer)==int(g.heroes[1].spell_turn)+1,"Omen applies for target's next turn, not immediately")
 g.active = 1;g.heroes[1].results = [4,5,31];g.heroes[1].rolls = [0,0,0];g.heroes[1].used = [false,false,false];S.turn_start(g,1);check(S.offer_omen(g),"next turn offers storage")
 check(not S.can_store(g,1,1) and not S.can_store(g,1,2) and S.can_store(g,1,0),"storage excludes Reactions and Channels")
 check(S.store(g,0) and S.held(g,1,0) and g.heroes[1].used[0],"store reserves original die without spending ability")
 g.round_no += 1;g.roll_hero(g.heroes[1]);check(g.heroes[1].used[0] and g.face(1,0)==4 and g.heroes[1].rolls[0]==0,"held die skips next shared roll and keeps exact face")
 g.pending = {"kind":"preroll_stun","hero":1};g.stun_die(0);check(g.pending.get("kind","")=="preroll_stun" and g.heroes[1].setaside==-1,"stun cannot take the held original die");g.pending = {}
 S.turn_start(g,1);check(not S.held(g,1,0) and not g.heroes[1].used[0] and g.face(1,0)==4,"saved ability releases next own turn; three dice total")
 g = fresh();g.heroes[0].omen_ready = true;face(g,1);S.store(g,0);g.mutate(0,0,2,0);check(not S.held(g,0,0),"physical mutation breaks held Omen")
 g = fresh();face(g,80);g.heroes[0].rerolls = 0;g.on_roll(g.heroes[0],0);check(g.heroes[0].used[0] and g.heroes[0].rerolls==1 and S.open_fate(g),"Fate triggers when rolled and grants normal reroll cap")
 var options: Array = S.fate_options(g);check(options.size()==6,"Fate includes actual unresolved dice from both Trial enemies")
 check(S.choose_fate(g,4,0) and S.fate_options(g).size()==5,"secondary creature die rerolls once")
 S.mark_enemy_result(g,3,1);check(not S.fate_options(g).any(func(e):return e.source==3 and e.slot==1),"resolved enemy die ineligible even between hero activations")
 for source in [3,4]:
  for slot in range(3):S.mark_enemy_result(g,source,slot)
 g.trial_state.fate_queue.append({"hero":0,"die":0});S.open_fate(g);check(S.no_fate(g) and g.pending.is_empty(),"no eligible results safely continues")
 # Initial Fate rolls run before activation, and sequential choices never reactivate twice.
 g = fresh()
 for d in range(3):g.heroes[0].build[d] = [80,80,80,80,80,80]
 g.order = [0,1,2,3];g.cursor = 0;var old_turn: int = g.heroes[0].spell_turn
 S.round_prepare(g);g.shared_roll()
 check(g.pending.kind=="soul_fate" and g.heroes[0].spell_turn==old_turn,"initial Fate window precedes first activation")
 for repeat in range(3):
  var choice: Dictionary = S.fate_options(g)[0];S.choose_fate(g,choice.source,choice.slot)
 check(g.pending.is_empty() and g.heroes[0].spell_turn==old_turn+1 and g.heroes[0].rerolls==g.v("hero.reroll_cap"),"multiple Fates respect cap and resume activation exactly once")
 # A Focus result which becomes Fatebreaker must not leave a forced spent die.
 g = fresh();face(g,6,0);g.heroes[0].build[1] = [80,80,80,80,80,80];g.heroes[0].results[1] = 1
 check(g.hero_action(0,1) and g.pending.kind=="soul_fate" and g.forced_die==-1 and g.heroes[0].used[1],"Focus opens Fate without a forced-die deadlock")
 var target_fate: Dictionary = S.fate_options(g)[0];S.choose_fate(g,target_fate.source,target_fate.slot)
 check(g.pending.is_empty() and g.forced_die==-1,"Fate choice returns to the same Focus turn")
 g = fresh()
 for d in range(3):g.heroes[0].build[d] = [80,80,80,80,80,80]
 for action in g.boss_dice()[0]:g.boss.binds.append({"die":0,"action":action,"owner":1})
 hp = g.heroes[1].hp;S.round_prepare(g);g.shared_roll()
 check(g.heroes[1].hp==hp and g.trial_state.fate_defer_binds,"initial Lethargic Bind waits for Fate choices")
 for repeat in range(3):
  var choice: Dictionary = S.fate_options(g)[0];S.choose_fate(g,choice.source,choice.slot)
 check(g.heroes[1].hp==hp-g.v("face18.backlash") and g.boss_rolls[0]=="Bound","Bind applies only once to final result")
 g = fresh();g.active = 1;g.cursor = 1;g.heroes[0].hp = 2;g.heroes[0].broken = true;g.recovery = [0]
 for d in range(3):g.heroes[0].build[d] = [80,80,80,80,80,80]
 g.finish_turn();check(g.pending.kind=="soul_fate" and g.recovery_active and g.active==0,"recovery rerolls offer Fate before recovery effects")
 for repeat in range(3):
  var choice: Dictionary = S.fate_options(g)[0];S.choose_fate(g,choice.source,choice.slot)
 check(g.pending.is_empty() and g.recovery_active and g.active==0,"Fate resumes recovery without restarting activation")
 for script in [B,preload("res://prototype/nugh.gd"),preload("res://prototype/cantor.gd"),preload("res://prototype/bugh.gd")]:
  t = party();var boss_model = script.new();boss_model.start(t.builds,38,true,true,t.profile());boss_model.pending = {};boss_model.forced_die = -1;boss_model.active = 0
  boss_model.heroes[0].results[0] = 80;boss_model.on_roll(boss_model.heroes[0],0)
  check(S.open_fate(boss_model) and S.fate_options(boss_model).size()>=3,"Fate opens on all four existing boss models")
  var boss_choice: Dictionary = S.fate_options(boss_model)[0]
  check(S.choose_fate(boss_model,boss_choice.source,boss_choice.slot) and boss_model.pending.is_empty(),"Fate returns safely from each boss die")
 t = party();var hollow = preload("res://prototype/trial_hollow.gd").new();hollow.start(t.builds,38,true,true,t.profile());hollow.pending = {};hollow.round_no = 2;hollow.order = [0,1,2,3];hollow.cursor = 0
 for d in range(3):hollow.heroes[0].build[d] = [80,80,80,80,80,80]
 hollow.boss.binds = [{"die":0,"action":"Soul Rupture","owner":1}];S.round_prepare(hollow);hollow.shared_roll()
 for repeat in range(3):
  var choice: Dictionary = S.fate_options(hollow)[0];S.choose_fate(hollow,choice.source,choice.slot)
 check(hollow.boss_rolls[0]=="Bound" and hollow.rupture_resolved,"deferred Bind consumes Hollow's one-off Rupture instead of repeating next round")
 t = party();t.phase = "reward";var old_pool: Dictionary = t.pool.duplicate();var old_builds: Array = t.builds.duplicate(true);var old_essence: int = t.essence
 for die in range(3):
  for side in range(6):t.replacement_error(t.reward_faces(0)[0],die,side)
 check(t.pool==old_pool and t.builds==old_builds and t.essence==old_essence,"reward preview is read-only including shared physical-copy pool")
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.trials = party();app.trial_fight = true;app.page = "battle"
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);app.game = fresh();app.game.heroes[0].soul_charges = 2;app.roll_seen = app.game.roll_presentations.size();app.seen_event = app.game.event_id;app.rolling_time = 0;app.dice_tray.cancel();S.blank(app.game,0);app.rebuild();await process_frame
  for f in range(75,81):check(app.ui.find_child("SoulSpell"+str(f),true,false)!=null,"all spell choices render in each layout")
  var button: Button = app.ui.find_child("SoulSpell76",true,false)
  check(button!=null and not button.disabled and button.get_global_rect().end.y<=app.get_viewport_rect().size.y,"direct spell creation button stays reachable in each viewport")
  app.game.pending = {};app.game.heroes[0].build[0] = [3,3,3,3,3,3];app.game.heroes[0].results[0] = 0;app.game.heroes[0].rerolls = 1;app.game.heroes[0].opening = true;app.selected = 0;app.hint = "OLD HINT";app.perform_reroll(0)
  check(app.hint!="OLD HINT" and not "Gather" in app.hint and app.combat_notices.is_empty(),"reroll replaces stale hint without an acknowledgement prompt")
 app.queue_free();await process_frame
 print("SOULCASTER v38: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
