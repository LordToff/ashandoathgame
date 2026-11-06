extends SceneTree
const Run = preload("res://prototype/trials.gd")
const Fight = preload("res://prototype/trial_encounter.gd")
const B = preload("res://prototype/battle.gd")
const R = preload("res://prototype/trial_rules.gd")
const E = preload("res://prototype/essence.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("TRIAL FAIL: ",why)
func fresh(group: int = 0, paths: Array = ["venom","guard","stride"], souls: Array = ["","",""]):
 var run = Run.new(false);run.memories = paths;run.souls = souls;run.start(34)
 var profile: Dictionary = run.profile();profile["trial.terrain"] = "none";profile["face1.damage"] = 2 # Fixed hit size isolates Memory arithmetic.
 var g = Fight.new();g.group_index = group;g.start(run.builds,34,true,true,profile)
 g.order = [0,1,2,3];g.cursor = 0;g.active = 0;g.pending = {};g.forced_die = -1;g.boss.hp = 20;g.boss.max_hp = 20
 for h in g.heroes:h.used = [false,false,false];h.reaction = [];h.results = [1,4,2];h.rolls = [0,0,0];h.poison = 0;h.hp = h.max_hp
 g.heroes[0].pos = Vector2i(3,5);g.heroes[1].pos = Vector2i(0,7);g.heroes[2].pos = Vector2i(8,7);g.unit_data(4).pos = Vector2i(7,1)
 g.trial_state.positions = {}
 for id in range(g.unit_count()):g.trial_state.positions[id] = g.unit_data(id).pos
 return g
func reward_run():
 var run = Run.new(false);run.start(34);run.choose(0)
 var g = fresh();g.outcome = "victory";run.finish(g);return run
func button(root: Node, name: String):return root.find_child(name,true,false)
func _initialize():call_deferred("run_tests")
func run_tests():
 for a in R.MEMORIES:
  for b in R.MEMORIES:
   for c in R.MEMORIES:
    var run = Run.new(false);run.memories = [a,b,c];run.start(34)
    check(run.validate(run.builds)=="","all 27 Memory parties obey ordinary construction/copy limits")
 var g = fresh();g.hero_action(0,3)
 check(g.boss.poison==1,"Venom first damaging Attack applies Poison")
 g.heroes[0].used[0] = false;g.hero_action(0,3);check(g.boss.poison==1,"Venom once per own turn")
 g.heroes[0].hp = 3;g.heal(0,2);check(g.heroes[0].hp==4,"Venom healing tradeoff")
 g = fresh();g.active = 1;g.heroes[1].pos = Vector2i(3,5);g.heroes[0].pos = Vector2i(0,7);g.heroes[1].block = 2;g.action_owner = 3
 g.damage(1,2,false,"Bash",3);check(g.heroes[1].hp==5 and g.heroes[1].trial_counter,"Iron vow primes after fully blocked hit")
 var hp_before: int = g.boss.hp;g.hero_action(0,3);check(hp_before-g.boss.hp==3 and not g.heroes[1].trial_counter,"counterattack +1 consumed")
 g.heroes[1].used[0] = false;hp_before = g.boss.hp;g.hero_action(0,3);check(hp_before-g.boss.hp==2,"next Attack returns to normal")
 g = fresh();g.active = 2;g.heroes[2].pos = Vector2i(3,5);g.heroes[0].pos = Vector2i(0,7);g.heroes[2].moved_turn = 2
 hp_before = g.boss.hp;g.hero_action(0,3);check(hp_before-g.boss.hp==3,"Wayfarer move-then-Attack bonus")
 g.heroes[2].used[0] = false;hp_before = g.boss.hp;g.hero_action(0,3);check(hp_before-g.boss.hp==2,"Wayfarer once per own turn")
 g = fresh();g.heroes[0].numeric_zero = true;hp_before = g.boss.hp;g.strike(0,3,0,0,true);check(g.boss.hp==hp_before and int(g.boss.get("poison",0))==0,"absolute Numeric zero retained")
 for index in range(3):
  for elite in [false,true]:
   var run = Run.new(false);run.start(34);g = Fight.new();g.group_index = index;g.elite = elite;g.start(run.builds,34,true,true,run.profile())
   check(g.roles.size()==(3 if elite else 2),"role group size")
   check(g.boss_dice().size()==3 and g.boss_dice().all(func(die):return die.size()==6),"public six-sided role dice")
   var rng_state: int = g.rng.state;var intents: Array = g.enemy_intents();check(intents.size()==g.roles.size()*3 and g.rng.state==rng_state,"role forecasts do not advance RNG")
 g = fresh();g.unit_data(4).pos = Vector2i(4,4);g.special_monster_action(3,"Shield Line")
 check(g.boss.block==2 and g.unit_data(4).block==2,"Shieldbearer protects adjacent ally")
 g.special_monster_action(3,"Shield Line");g.special_monster_action(3,"Shield Line");check(g.boss.block==3 and g.unit_data(4).block==3,"Shield Line caps protection at three")
 g.unit_data(4).block = 2
 g.unit_data(4).pos = Vector2i(7,1);g.special_monster_action(3,"Shield Line");check(g.unit_data(4).block==2,"separating group stops ally shielding")
 g.boss.hp = 15;g.special_monster_action(4,"Restitch");check(g.boss.hp==15,"Mender respects range")
 g.unit_data(4).pos = Vector2i(4,4);g.special_monster_action(4,"Restitch");check(g.boss.hp==17,"Mender heals most wounded nearby ally 2")
 g.special_monster_action(4,"Restitch");check(g.boss.hp==17,"Mender heal once per enemy turn")
 g = fresh(1);g.special_monster_action(3,"Mark Charge");check(g.trial_state.charges.size()==1,"Ram marks charge")
 var lane: Array = g.trial_state.charges[0].tiles.duplicate();g.heroes[2].pos = Vector2i(0,8);g.special_monster_action(3,"Mark Charge")
 check(g.trial_state.charges[0].tiles==lane,"marked charge does not chase a moving target or stack")
 for h in g.heroes:h.pos = Vector2i(0,7)
 g.order = [3,0,1,2];g.cursor = 0;g.activate();check(g.trial_state.charges.is_empty() and g.heroes[0].hp==6,"sidestepping charge avoids damage")
 g = fresh(1);g.trial_state.charges = [{"source":3,"tiles":[Vector2i(3,5)]}];g.order = [3,0,1,2];g.cursor = 0;g.activate()
 check(g.heroes[0].hp==3 and g.pending.is_empty(),"locked charge deals 3 before enemy dice")
 g = fresh(2);g.trial_state.purse = 3;g.special_monster_action(3,"Pilfer")
 check(g.trial_state.purse==2 and g.boss.loot==1,"thief steals carried Trial currency")
 g.damage(3,99,true);check(g.trial_state.purse==3 and g.boss.loot==0,"defeating thief returns its loot once")
 g.damage(3,99,true);check(g.trial_state.purse==3,"corpse cannot duplicate stolen currency")
 g.unit_data(4).loot = 2;g.unit_data(4).pos = Vector2i(0,1);g.special_monster_action(4,"Flee")
 check(g.unit_data(4).dead and g.trial_state.escaped==2 and g.trial_state.purse==3,"escaping removes thief and stolen currency")
 g = fresh();g.trial_state.cover = [g.heroes[0].pos];g.unit_data(4).pos = Vector2i(3,2)
 g.damage(0,2,false,"Needle",4);check(g.heroes[0].hp==5,"cover reduces ranged damage by 1")
 g.damage(0,2,true,"Poison",4);check(g.heroes[0].hp==3,"cover does not reduce Poison/unavoidable damage")
 g = fresh();g.heroes[0].pos = Vector2i(3,6);g.trial_state.crates = [Vector2i(3,5)]
 check(not g.legal(0,Vector2i(3,5)) and not g.sight(0,3,3),"barricade blocks movement and sight")
 check(g.hero_action(0,-1,Vector2i(3,5)) and g.heroes[0].used[0] and g.trial_state.crates.is_empty(),"adjacent Attack spends result to break barricade")
 check(g.legal(0,Vector2i(3,5)) and g.sight(0,3,3),"breaking opens route and sightline")
 g = fresh();g.heroes[0].pos = Vector2i(1,6);g.trial_state.positions[0] = g.heroes[0].pos;g.trial_state.spikes = [Vector2i(2,6)]
 check(g.hero_action(2,-1,Vector2i(2,6)) and g.heroes[0].hp==5,"landing on spikes hurts once")
 g.report_changes();check(g.heroes[0].hp==5,"stationary redraw cannot repeat spike damage")
 g = fresh();g.heroes[0].pos = Vector2i(3,4);g.boss.pos = Vector2i(6,2);g.unit_data(4).pos = Vector2i(4,4);g.unit_data(4).hp = 3;g.heroes[0].results[0] = 8;g.trial_state.positions[4] = Vector2i(4,4);g.trial_state.spikes = [Vector2i(5,4)]
 check(g.hero_action(0,4,Vector2i.RIGHT) and g.unit_data(4).hp==2,"Shove onto spikes damages enemy")
 g = fresh(0,["guard","guard","stride"],["hollow",""," "]);g.heroes[0].trial_cinder_used = false;g.hero_action(0,3)
 check(g.boss.poison==1,"Cinder Soul adds Poison after damaging Attack")
 g = fresh(0,["guard","guard","stride"],["nugh","",""]);g.unit_data(4).pos = Vector2i(4,4);g.apply_poison(0,3,2)
 check(g.heroes[0].max_hp==4 and g.unit_data(4).poison==1,"Brood Soul spreads first Poison and reduces maximum HP")
 g.apply_poison(0,3,1);check(g.unit_data(4).poison==1,"Brood spread once per own turn")
 g = fresh(0,["guard","guard","stride"],["cantor","",""]);g.heroes[0].results[1] = 7;g.heroes[0].hp = 3;g.hero_action(1,0)
 check(g.heroes[0].rerolls==0 and g.heroes[0].trial_echo==1,"Echo Soul starts without reroll and powers next Attack after Skill")
 hp_before = g.boss.hp;g.hero_action(0,3);check(hp_before-g.boss.hp==3 and g.heroes[0].trial_echo==0,"Echo bonus consumed by next Attack")
 g = fresh(0,["guard","guard","stride"],["bugh","",""]);g.heroes[0].block = 5;g.cursor = 0;g.activate()
 check(g.heroes[0].block==2 and g.move_steps(2)==1 and g.move_steps(3)==2,"Warden Soul preserves two Block and shortens movement")
 var run = reward_run();check(run.phase=="reward" and run.essence==5,"victory earns two and offers reward")
 var again = fresh();again.outcome = "victory";check(not run.finish(again) and run.essence==5,"settlement idempotent")
 var saved: Dictionary = run.pool.duplicate();check(not run.add_face(70,0,4) and run.essence==5 and run.pool.get("70")==saved.get("70"),"reward cannot remove required Blank or charge on failure")
 check(run.add_face(69,0,0) and run.stage==1 and run.essence==3 and run.builds[0][0][0]==69,"paid face replaces legal physical side")
 check(not run.add_face(69,0,1),"cannot claim second face reward")
 run = reward_run();check(run.equip_weapon("venom") and run.weapons[0]=="venom" and run.essence==3,"Weapon reward occupies one Weapon slot and pays once")
 check(not run.equip_weapon("heavy"),"second reward cannot be claimed")
 g = fresh(0,["guard","guard","stride"]);g.balance["trial.weapons"] = ["venom","dagger","dagger"];g.heroes[0].damaged_enemy_turn = true;g.poke(3)
 check(g.boss.poison==1,"Poison Dagger Poke applies Poison on HP loss")
 g = fresh(0,["guard","guard","stride"]);g.balance["trial.weapons"] = ["heavy","dagger","dagger"];hp_before = g.boss.hp;g.hero_action(0,3)
 check(hp_before-g.boss.hp==2 and g.heroes[0].hp==5,"Weapon reward does not modify die abilities")
 hp_before = g.boss.hp;g.poke(3);check(hp_before-g.boss.hp==2 and g.heroes[0].hp==4,"Heavy Dagger Poke trades one HP for two damage")
 run = reward_run();check(run.bank_reward() and run.essence==7 and run.stage==1 and not run.bank_reward(),"saving reward trades offer for currency once")
 run.choose(0);run.hp = [0,2,4];check(run.camp(true) and run.hp==[2,4,5] and run.stage==2,"Camp heals and revives without exceeding path maximum")
 run.stage = 3;run.phase = "route";run.choose(0);var bank: int = run.essence;check(run.event(false) and run.essence==bank+1 and not run.event(false),"safe cache reward once")
 for boss_index in range(4):
  run = Run.new(false);run.selected_boss = boss_index;run.start(34)
  for stop in range(5):
   check(run.stage==stop,"five route stages in order");run.choose(0)
   if run.phase=="combat":g = fresh();g.outcome = "victory";run.finish(g);run.bank_reward()
   elif run.phase=="camp":run.camp(true)
   elif run.phase=="event":run.event(false)
  check(run.stage==5 and run.options()[0].kind=="boss","five stops lead to selected boss")
  run.choose(0)
  g = [B,preload("res://prototype/nugh.gd"),preload("res://prototype/cantor.gd"),preload("res://prototype/bugh.gd")][boss_index].new()
  g.start(run.builds,34,true,true,run.profile());g.damage(3,999,true);check(g.outcome=="victory" and run.finish(g),"real boss death completes Trial")
  check(run.phase=="complete" and run.BOSSES[boss_index] in run.completed_bosses,"each boss unlocks its distinct Trial Soul")
  check(not run.finish(g),"boss Soul cannot duplicate through redraw")
 run = reward_run();run.save();var restored = Run.new(true)
 check(restored.phase=="reward" and restored.builds==run.builds and restored.essence==run.essence,"safe reward checkpoint restores")
 run.phase = "combat";run.save();restored = Run.new(true);check(restored.phase=="failed" and restored.completed_bosses.is_empty(),"interrupted fight gives no free clear or Soul")
 g = fresh();g.trial_state.cover = [g.unit_data(4).pos];g.action_owner = 0;hp_before = g.unit_data(4).hp;g.damage(4,2,false,"Shot",0)
 check(hp_before-g.unit_data(4).hp==1,"cover also protects one-cell enemies")
 var normal = B.new();normal.start([B.default_build(),B.default_build(),B.default_build()],34)
 check(normal.trial_state.is_empty() and normal.heroes.all(func(h):return h.max_hp==6),"ordinary combat has no Trial terrain or Memory penalties")
 var app=load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.trials = Run.new(false);var normal_builds: Array = app.builds.duplicate(true);var normal_bank: Dictionary = app.expedition.camp.encode().duplicate(true)
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);await process_frame;await process_frame;app.open_trials();await process_frame
  check(button(app.ui,"TrialMemory")!=null and button(app.ui,"TrialBoss")!=null,"Trial lobby renders on phone and desktop")
 app.trials.start(34);app.choose_trial_route(0);app.dice_tray.cancel();app.rolling_time = 0;app.game.pending = {};app.game.active = 0;app.rebuild();await process_frame
 check(app.trial_fight and app.builds==normal_builds,"Trial uses separate party build")
 app.game.damage(3,999,true)
 for id in app.game.living_minions():app.game.damage(id,999,true)
 app.rebuild();await process_frame;app.settle_essence()
 check(app.trials.phase=="reward" and app.expedition.camp.encode()==normal_bank,"Trial victory never changes ordinary ledger")
 app.continue_trial();check(app.page=="trials" and not app.trial_fight,"outcome returns to Trial rewards")
 app.trials.bank_reward();app.trials.stage = 2;app.trials.phase = "route";app.choose_trial_route(0);app.go_main()
 check(app.trials.phase=="failed" and app.builds==normal_builds and app.expedition.camp.encode()==normal_bank,"leaving Trial fight ends run and preserves main progression")
 app.trials = Run.new(false);app.debug_mode = false;check(not app.debug_unlock("trial_soul","hollow",0),"Trial Soul Debug gated")
 app.debug_mode = true;check(app.debug_unlock("trial_soul","hollow",0) and "hollow" in app.trials.completed_bosses and app.expedition.camp.encode()==normal_bank,"Debug unlock writes only Trial Soul collection")
 check(not app.debug_unlock("trial_soul","hollow",0),"Trial Soul Debug unlock is idempotent")
 app.queue_free();await process_frame
 print("TRIALS v0.34: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
