extends SceneTree
const B = preload("res://prototype/battle.gd")
const T = preload("res://prototype/trials.gd")
const F = preload("res://prototype/trial_encounter.gd")
const H = preload("res://prototype/trial_hollow.gd")
const P = preload("res://prototype/trial_forecast.gd")
const Reach = preload("res://prototype/battle_preview.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("V36 FAIL: ",why)
func ready(g) -> void:
 g.active = 0;g.order = [0,1,2,3];g.cursor = 0;g.pending = {};g.forced_die = -1
 for h in g.heroes:h.used = [false,false,false];h.reaction = [];h.results = [1,34,2];h.rolls = [0,0,0];h.poison = 0
 g.heroes[0].pos = Vector2i(3,5);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 g.trial_state.positions = {}
 for id in range(g.unit_count()):g.trial_state.positions[id] = g.unit_data(id).pos
func fresh(weapon: String = "dagger", objective: String = ""):
 var run = T.new(false);run.loadout_weapons[0] = weapon;run.start(36)
 var g = F.new();g.objective_mode = objective;var profile: Dictionary = run.profile();profile["trial.terrain"] = "none"
 g.start(run.builds,36,true,true,profile);ready(g)
 return g
func signature(g) -> String:
 return JSON.stringify([g.heroes,g.boss,g.minions,g.pending,g.trial_state,g.event_log,g.roll_presentations,g.outcome,g.rng.state,g.forced_die,g.recovery])
func _initialize():call_deferred("run_tests")
func run_tests() -> void:
 var normal = B.new();normal.start([B.default_build(),B.default_build(),B.default_build()],36)
 check(B.Catalog.FACE_COUNT==73 and B.Catalog.extended_ids().size()==48 and not B.valid_face_number(73),"normal catalog and ownership do not admit Trial-only weapon faces")
 normal.heroes[0].results[0] = 1;check(normal.face(0,0)==1,"normal Strike stays Strike")
 var g = fresh("spear");var raw: Array = g.heroes[0].build.duplicate(true)
 check(g.face(0,0)==73 and B.Catalog.name_for(g.face(0,0))=="Jab" and B.Catalog.category(73)=="Attack","Spear transforms rolled Strike into a red Attack face")
 g.heroes[0].results[2] = 1;g.heroes[0].rolls[2] = 0
 check(g.face(0,2)==1,"weapon replaces one Strike side; other normal Attacks remain for setup")
 check(g.heroes[0].build==raw and not g.balance["weapon.dagger.0"] and g.poke_targets().is_empty(),"Spear keeps physical dice/caps and offers no free Poke")
 g.heroes[0].results[2] = 2
 var before := signature(g)
 check(not g.hero_action(0,3) and signature(g)==before,"Jab before movement spends and changes nothing")
 g.heroes[0].moved_turn = 2;g.heroes[0].pos = Vector2i(3,6)
 check(3 in Reach.for_face(g,73).targets and g.face_range(73)==2,"Jab highlights its actual two-tile enemy range")
 var hp: int = g.boss.hp
 check(g.hero_action(0,3) and g.boss.hp==hp-1 and g.heroes[0].used[0],"Jab does one damage within two and consumes its rolled die")
 g.heroes[0].used[0] = false;check(not g.hero_action(0,3),"additional rolled Jab cannot bypass once-per-own-turn limit")
 g.TrialRules.turn_start(g,0);g.heroes[0].moved_turn = 2;check(g.hero_action(0,3),"new own turn refreshes Jab")
 g = fresh("hammer");g.boss.block = 3;before = signature(g)
 check(g.face(0,0)==74 and not g.hero_action(0,3) and signature(g)==before,"Crack replaces Strike but requires an earlier Attack")
 g.heroes[0].stored_num = 1;check(g.hero_action(1,3) and g.heroes[0].trial_attack_used,"a blocked Attack qualifies for Crack")
 hp = g.boss.hp;var remaining: int = g.boss.block
 check(g.hero_action(0,3) and g.boss.block==maxi(0,remaining-2) and g.boss.hp==hp and g.heroes[0].used[0],"Crack removes Block, causes no HP damage and consumes its die")
 g.heroes[0].used[0] = false;check(not g.hero_action(0,3),"Crack cannot repeat in the same own turn")
 g = fresh("hammer");g.unit_data(4).pos = Vector2i(4,5);g.unit_data(4).block = 3;g.heroes[0].trial_attack_used = true
 check(g.hero_action(0,4) and g.unit_data(4).block==1,"Crack works on ordinary creatures as well as source 3")
 g = fresh("dagger","ritual")
 check(g.objective_ids("ritual").size()==3 and g.enemy_intents().size()==6,"ritual has three objects and no object enemy turns")
 var stone: int = g.objective_ids("ritual")[0];g.heroes[0].pos = Vector2i(2,6)
 check(stone in Reach.for_face(g,1).targets,"ritual stone is a real highlighted Attack target")
 g.apply_poison(0,stone,3);check(g.unit_data(stone).poison==0,"ritual objects cannot receive Poison")
 g.heroes[0].results[1] = 8;before = signature(g);check(not g.hero_action(1,stone,Vector2i.UP) and signature(g)==before,"ritual objects cannot be Shoved")
 check(g.hero_action(0,stone) and g.unit_data(stone).hp==1,"ordinary Strike damages the actual stone")
 g.damage(3,99,true)
 for id in g.living_minions():g.damage(id,99,true)
 check(g.outcome=="","killing every creature does not bypass the ritual objective")
 for id in g.objective_ids("ritual"):g.damage(id,99,true)
 check(g.outcome=="victory" and g.objective_ids("ritual").is_empty(),"breaking all stones completes the objective")
 g = fresh("dagger","ritual")
 for id in g.objective_ids("ritual"):g.damage(id,99,true)
 check(g.outcome=="victory" and g.boss.hp>0,"surviving enemies retreat without requiring extra kills")
 g = fresh("dagger","spirit");var spirit: int = g.objective_ids("spirit")[0]
 check(g.friendly(spirit) and spirit not in g.living_minions() and spirit not in g.living_minions("friendly"),"spirit is an ally but never acts as a creature or owned summon")
 g.boss.pos = Vector2i(4,5);var intent_rng: int = g.rng.state
 var intent: Dictionary = g.enemy_intent(3,"Bash",0)
 check(intent.target==spirit and "Spirit" in intent.policy and g.rng.state==intent_rng,"visible intent prefers reachable spirit without consuming RNG")
 check(g.enemy_target(3,g.attack_targets(3,1),"Bash")==spirit,"real target matches spirit intent")
 g.unit_data(spirit).hp = 3;g.heroes[0].pos = Vector2i(3,6);g.heroes[0].results[0] = 7
 check(spirit in Reach.for_face(g,7).targets and g.hero_action(0,spirit) and g.unit_data(spirit).hp==4,"First Aid can target and heal the spirit")
 g.heroes[0].pos = Vector2i(4,7);g.heroes[0].results[1] = 44;g.heroes[0].reaction = [1];g.heroes[0].used[1] = true
 g.pending = {"kind":"attack","action":"Bash","victims":[spirit],"reacted":[],"amount":2,"source":3,"range":1,"needs_sight":false,"area":false};g.continue_attack()
 check(g.pending.get("kind","")=="reaction" and g.pending.get("die",-1)==1,"Shield Wall can react to an attack on the spirit")
 g.react(true);check(g.unit_data(spirit).hp==3,"Shield Wall gives spirit Block before the hit")
 g = fresh("dagger","spirit")
 for turn in range(3):
  g.active = 3;g.cursor = 3;g.pending = {};g.boss_index = 3;g.finish_turn()
  check(g.protected_turns==turn+1 and (g.outcome=="victory" if turn==2 else g.outcome==""),"protection advances only after a completed enemy turn")
 g = fresh("dagger","spirit");spirit = g.objective_ids("spirit")[0];g.damage(spirit,99,true)
 check(g.outcome=="defeat","spirit death fails the objective immediately")
 var run = T.new(false);run.start(36);run.choose(1);g = fresh("dagger","ritual");g.outcome = "victory";run.pin("fleet")
 check(run.finish(g) and run.essence==6 and run.ingredients.get("cinder",0)==2 and "2/3" in run.last_progress,"objective reward banks separate ingredients and shows wishlist progress")
 check(not run.finish(g) and run.ingredients.cinder==2,"victory ingredients settle only once")
 check(not run.craft("fleet") and run.ingredients.cinder==2,"missing ingredient cannot be spent or crafted")
 run.ingredients.cinder = 3;check(run.craft("fleet") and run.ingredients.cinder==0 and "fleet" in run.available("body"),"craft pays exactly and unlocks persistent Body equipment")
 check(not run.craft("fleet") and run.ingredients.cinder==0,"craft cannot duplicate an owned unique equipment item")
 run.phase = "lobby";check(run.apply_build("movement",0) and run.bodies[0]=="fleet" and run.loadout_weapons[0]=="spear" and run.souls[0]=="","build applies owned pieces with Beginning Soul fallback")
 run.ingredients.cinder = 3;check(run.craft("wind_soul"),"Wind Soul has a real paid recipe")
 run.apply_build("movement",0);run.start(36);g = F.new();g.start(run.builds,36,true,true,run.profile());ready(g)
 check(g.heroes[0].max_hp==4 and g.move_steps(2)==2 and g.soul_distance(0)==2,"Movement combination uses Body, Memory, Weapon and Soul together")
 run.phase = "reward";run.ingredients.ward = 3;run.craft("stone");run.phase = "lobby";run.apply_build("protection",1);run.start(36);g = F.new();g.start(run.builds,36,true,true,run.profile());ready(g);g.active = 1
 check(g.heroes[1].max_hp==6 and g.move_steps(3)==2,"Protection combination uses Stone HP and shorter movement")
 run.phase = "reward";run.ingredients.ward = 2;check(run.craft("shelter_memory"),"Memory has its own recipe without an extra upgrade category")
 run.memories[0] = "shelter";run.start(36);g = F.new();g.start(run.builds,36,true,true,run.profile());ready(g);g.heroes[0].results = [4,4,1]
 check(g.hero_action(0) and g.heroes[0].block==2,"crafted Memory adds Block to first own-turn Defense")
 g.hero_action(1);check(g.heroes[0].block==3,"Memory of Shelter does not repeat this own turn")
 run.phase = "reward";run.save();var restored = T.new(true)
 check(restored.crafted==run.crafted and restored.wishlist==run.wishlist and restored.ingredients==run.ingredients and restored.loadout_weapons==run.loadout_weapons,"Trial collection, wishlist and starting weapons survive safe reload")
 var fallen_profile: Dictionary = run.profile();fallen_profile["trial.hp"] = [0,5,5]
 var carried = F.new();carried.start(run.builds,36,true,true,fallen_profile)
 check(carried.heroes[0].dead and carried.face(0,0)==0,"carried fallen heroes have safe inert face inspection before Camp revival")
 # The boss experiment uses the same damage/reaction pipeline as ordinary attacks.
 run = T.new(false);run.start(36);var hollow = H.new();hollow.start(run.builds,36,true,true,run.profile());ready(hollow)
 check(hollow.core_id==4 and hollow.enemy_intents().size()==3 and hollow.unit_data(4).hp==2,"Hollow core is visible but has no extra enemy actions")
 hollow.damage(4,2,true);check(hollow.rupture_cancelled and hollow.harvest_tokens.is_empty(),"breaking core cancels rupture without farming normal Essence")
 hollow.active = 3;hollow.pending = {};hollow.boss_rolls = ["Rupture cancelled","Brace","Brace"];hollow.boss_index = 0;hp = hollow.heroes[0].hp;hollow.boss_step()
 check(hollow.boss_index==1 and hollow.heroes[0].hp==hp and hollow.rupture_resolved,"cancelled rupture spends one boss action and deals no damage")
 hollow = H.new();hollow.start(run.builds,36,true,true,run.profile());ready(hollow);hollow.active = 3;hollow.boss_rolls = ["Soul Rupture","Brace","Brace"];hollow.boss_index = 0;hollow.heroes[0].block = 2;hp = hollow.heroes[0].hp;hollow.boss_step()
 check(hollow.heroes[0].hp==hp-1 and hollow.heroes[1].hp==hollow.heroes[1].max_hp-3 and hollow.rupture_resolved,"uninterrupted rupture deals three at any distance, with real Block")
 # The round-two interrupt keeps priority while preserving a queued phase Roar.
 hollow = H.new();hollow.start(run.builds,36,true,true,run.profile());ready(hollow);hollow.round_no = 1;hollow.roar_queued = true;hollow.new_round()
 check(hollow.boss_rolls[0]=="Soul Rupture" and hollow.roar_queued,"round-two Rupture is visible even with a queued Roar")
 hollow.active = 0;hollow.damage(3,6,true)
 check(hollow.phase_two and hollow.boss_rolls[0]=="Soul Rupture" and hollow.roar_queued,"half-health phase cannot replace the reserved interrupt attack")
 for group in range(3):
  var pure = F.new();pure.group_index = group;pure.start(run.builds,36,true,true,run.profile())
  var old_log: int = pure.event_id;var old_rng: int = pure.rng.state
  for read in range(4):pure.enemy_intents()
  check(pure.event_id==old_log and pure.rng.state==old_rng,"reading every Trial group intent is pure")
 for body in ["broken","fleet","stone"]:
  for face in [0,2,3,53,54,57,60,66]:
   g = fresh();g.balance["trial.bodies"] = [body,"broken","broken"];g.heroes[0].results[0] = face
   var preview: Dictionary = Reach.for_face(g,face)
   check(not preview.destinations.is_empty(),"each Body retains legal movement destinations")
   for cell in preview.destinations:
    var simulated = P.copy_battle(g)
    check(simulated.hero_action(0,-1,cell),"every highlighted movement destination is legal for the equipped Body")
 hollow = H.new();hollow.start(run.builds,36,true,true,run.profile());ready(hollow);hollow.round_no = 1;hollow.boss.binds = [{"owner":0,"die":0,"action":"Soul Rupture"}];hollow.new_round()
 check(hollow.boss_rolls[0]=="Bound" and hollow.rupture_resolved,"Lethargic Bind can suppress the Trial Rupture without it returning next round")
 g = fresh("spear");g.on_roll(g.heroes[0],0)
 check(g.heroes[0].round_history[-1].face==73,"rolled history records the actual Jab face for Shared Burden")
 # Forecast all ordinary face IDs plus two scoped weapon faces; the live state is byte-identical.
 g = fresh();g.heroes[0].results = [1,34,2];g.boss.block = 1;g.balance["face1.damage"] = 3
 before = signature(g);var forecast: Dictionary = P.calculate(g,0,3)
 check(forecast.valid and "2 HP damage" in forecast.text and "1 blocked" in forecast.text and "Poison +1" in forecast.text,"compact fixed preview includes HP loss, Block and status")
 check(signature(g)==before,"forecast never changes live state, event log, dice presentation or RNG")
 g.heroes[0].results[0] = 34;g.boss.block = 0;before = signature(g);forecast = P.calculate(g,0,3)
 check(forecast.valid and forecast.numeric and "0–2 HP damage" in forecast.text,"Numeric forecast shows possible range instead of hidden next roll")
 check(signature(g)==before,"Numeric enumeration does not consume RNG")
 g.heroes[0].stored_num = 1;forecast = P.calculate(g,0,3)
 check(forecast.valid and "1 HP damage" in forecast.text and not "0–2 HP" in forecast.text,"stored Numeric is predicted from its known value")
 g = fresh();before = signature(g)
 for face in range(75):
  g.heroes[0].results[0] = face;var original := signature(g)
  P.calculate(g,0,3);Reach.for_face(g,face)
  check(signature(g)==original,"every face preview is read-only")
 var app=load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.trials = T.new(false);var camp_before: Dictionary = app.expedition.camp.encode().duplicate(true)
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);await process_frame;app.open_trials();app.trial_slot = "weapon";app.rebuild();await process_frame
  check(app.ui.find_child("TrialWeapon",true,false)!=null,"weapon selector is reachable in phone and desktop lobby")
  app.trial_view = "craft";app.rebuild();await process_frame
  check(app.ui.find_child("TrialRecipe",true,false)!=null and app.ui.find_child("TrialPin",true,false)!=null,"wishlist/Forge render on every layout")
 app.trials = T.new(false);app.trials.start(36);app.choose_trial_route(1);app.dice_tray.cancel();app.rolling_time = 0;ready(app.game);app.game.heroes[0].pos = Vector2i(2,6);app.selected = 0;app.inspect_actor = app.game.active;app.seen_event = app.game.event_id;app.roll_seen = app.game.roll_presentations.size()
 stone = app.game.objective_ids("ritual")[0];hp = app.game.unit_data(stone).hp;app.stage_trial_choice(stone)
 check(not app.trial_choice.is_empty() and app.game.unit_data(stone).hp==hp and not app.game.heroes[0].used[0],"actual target tap stages forecast without spending or damaging")
 await process_frame
 var banner: Control = app.ui.find_child("TrialObjective",true,false)
 check(banner!=null and not app.ui.get_children().any(func(node):return node is Label and node.get_global_rect().intersects(banner.get_global_rect())),"desktop objective banner has no overlaid goal text")
 var intents: Control = app.ui.find_child("EnemyIntentsButton",true,false)
 var expand: Button = app.ui.get_children().filter(func(node):return node is Button and node.text=="Expand log")[0]
 check(not intents.get_global_rect().intersects(expand.get_global_rect()),"desktop Trial intents and log buttons do not overlap")
 app.confirm_trial_choice();check(app.trial_choice.is_empty() and app.game.unit_data(stone).hp==hp-1 and app.game.heroes[0].used[0],"Confirm resolves the real action exactly once")
 app.game.heroes[0].used[0] = false;app.stage_trial_choice(stone);app.game.event_id += 1;app.confirm_trial_choice()
 check(app.game.unit_data(stone).hp==hp-1,"stale forecasts cannot resolve after combat state changes")
 app.debug_mode = true;check(app.debug_unlock("trial_recipe","wind_soul",0) and not app.debug_unlock("trial_recipe","wind_soul",0),"Debug hold unlock path is Trial-only and idempotent")
 app.game.damage(3,999,true);app.sync_presentation();check(app.expedition.camp.encode()==camp_before,"all new Trial systems preserve ordinary Camp collection")
 app.queue_free();await process_frame
 print("TRIALS v0.36: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
