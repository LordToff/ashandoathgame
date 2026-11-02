extends SceneTree
const B = preload("res://prototype/battle.gd")
const M = preload("res://prototype/event_battle.gd")
const E = preload("res://prototype/essence.gd")
const W = preload("res://prototype/bugh.gd")
const C = preload("res://prototype/cantor.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("HUB FAIL: ",why)
func fresh(model = B):
 var g = model.new();g.start([B.default_build(),B.default_build(),B.default_build()],28,false,true,E.new().profile({}))
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.forced_die = -1;g.heroes[0].pos = Vector2i(3,5)
 for h in g.heroes:h.results = [1,4,0];h.rolls = [0,0,0];h.used = [false,false,false];h.reaction = [];h.weak = false
 g.boss.block = 0;return g
func _initialize():call_deferred("run")
func run():
 var e = E.new();check(e.weapons == ["dagger","dagger","dagger"],"three starter Daggers")
 check(e.equip_weapon(1,"") and not e.equip_weapon(1,"invented"),"only valid weapon choices")
 var restored = E.new();restored.decode(e.encode())
 check(restored.weapons == ["dagger","","dagger"] and not restored.profile({})["weapon.dagger.1"],"weapon equipment persists")
 restored.decode({});check(restored.bodies == ["broken_body","broken_body","broken_body"],"legacy saves retain starter bodies")
 check(not e.equip_body(0,"") and e.equip_body(0,"broken_body"),"body mandatory and only owned type")
 check("beginning" in e.souls[0],"Beginning Soul is owned from the start")
 var legacy = E.new();legacy.decode({"souls":[[],["hollow"],[]],"equipped_souls":["","hollow",""]})
 check(legacy.souls[1] == ["beginning","hollow"] and legacy.equipped_souls[1] == "hollow","migration preserves earned/equipped Soul and adds Beginning ownership")
 var g = fresh();check(g.poke_reason().contains("actual HP"),"Poke starts locked")
 check(not g.poke(3),"cannot Poke before enemy damage")
 g.boss.block = 2;g.hero_action(0,3)
 check(not g.heroes[0].get("damaged_enemy_turn",false) and not g.poke(3),"fully blocked hit does not unlock Poke")
 g = fresh();g.heroes[1].pos = Vector2i(2,5);g.hero_action(0,1)
 check(not g.heroes[0].get("damaged_enemy_turn",false),"friendly fire does not unlock Poke")
 g = fresh();g.hero_action(0,3)
 check(g.poke_reason() == "" and g.poke_targets() == [3],"actual enemy HP damage unlocks adjacent Poke")
 var used: Array = g.heroes[0].used.duplicate();var rerolls: int = g.heroes[0].rerolls;var hp: int = g.boss.hp
 check(g.poke(3) and g.boss.hp == hp-1,"Poke deals one normal damage")
 check(g.heroes[0].used == used and g.heroes[0].rerolls == rerolls,"Poke spends neither dice nor rerolls")
 check(not g.poke(3) and g.poke_reason().contains("already"),"Poke cannot repeat this turn")
 g.active = 0;g.cursor = g.order.find(0);g.activate()
 check(not g.heroes[0].damaged_enemy_turn and not g.heroes[0].dagger_used,"own turn refreshes limit and prerequisite")
 g = fresh();g.hero_action(0,3);g.heroes[0].pos = Vector2i(0,0)
 check(g.poke_targets().is_empty() and not g.poke(3),"Poke requires orthogonal adjacency")
 g = fresh();g.hero_action(0,3);g.balance["weapon.dagger.0"] = false
 check(not g.poke(3) and g.poke_reason().contains("Equip"),"unequipped Dagger unavailable")
 g = fresh();g.hero_action(0,3);g.pending = {"kind":"channel"}
 check(not g.poke(3),"pending choice blocks Poke")
 g.pending = {};g.forced_die = 2;check(not g.poke(3),"forced next result blocks Poke")
 g.forced_die = -1;g.burden_interrupt = {"owner":1};check(not g.poke(3),"no weapon bonus inside Shared Burden")
 g = fresh();g.hero_action(0,3);g.heroes[0].weak = true;hp = g.boss.hp
 check(g.poke(3) and g.boss.hp == hp,"Weakness applies and still consumes Poke")
 g = fresh();g.hero_action(0,3);g.boss.block = 1;hp = g.boss.hp
 check(g.poke(3) and g.boss.hp == hp and g.boss.block == 0,"Poke is absorbed by Block")
 g = fresh(W);g.guard_broken = true;g.hero_action(0,3);g.guard_broken = false;hp = g.boss.hp
 check(g.poke(3) and g.boss.hp == hp,"Warden armor applies")
 g = fresh(C);g.hero_action(0,3);var resonance: int = g.resonance
 check(g.poke(3) and g.resonance == resonance+g.v("cantor.attack_charge"),"Poke charges Veyl as an Attack")
 g = fresh();g.action_owner = 1;g.damage(3,1,true)
 check(not g.heroes[0].get("damaged_enemy_turn",false),"another hero’s damage does not qualify active hero")
 g = fresh();g.heroes[0].hp = 0;g.heroes[0].damaged_enemy_turn = true
 check(not g.poke(3),"Downed heroes cannot Poke")
 g = M.new();g.prototype_pack = true;g.creature_types = ["movement_creature","movement_creature"];g.start([B.default_build(),B.default_build(),B.default_build()],28,false,true,E.new().profile({}))
 g.active = 0;g.pending = {};g.forced_die = -1;g.heroes[0].pos = Vector2i(4,4);g.action_owner = 0;g.damage(4,1,true)
 check(g.heroes[0].damaged_enemy_turn and 3 in g.poke_targets(),"enemy minion HP damage qualifies")
 check(g.essence_type(3) == "movement_creature" and g.essence_type(4) == "movement_creature","direct Swift Pack has correct types")
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app)
 await process_frame
 check(app.page == "main" and app.ui.has_node("MainPlay") and app.ui.has_node("MainCreatures"),"main menu on launch")
 app.ui.get_node("MainCreatures").pressed.emit()
 check(app.page == "camp" and app.camp_tab == 3 and app.ui.has_node("FightCreature2"),"main menu reaches all creature groups")
 app.start_creature_encounter(2)
 check(app.page == "forge" and app.queued_creature == 2,"incomplete party routed to bonus selection")
 for hero in range(3):
  app.build_hero = hero;app.choose_gift(34);app.choose_gift(47)
 app.finish_party_selection()
 check(app.page == "battle" and app.creature_fight and app.game.essence_type(3) == "movement_creature","party preparation returns to chosen fight")
 app.dice_tray.cancel();app.rolling_time = 0
 app.go_main();check(app.page == "main" and not app.creature_fight,"main menu abandons without banking")
 app.open_camp()
 app.expedition.camp = E.new()
 var scoped: Dictionary = app.camp_battle_profile()
 var sg = B.new();sg.start([B.default_build(),B.default_build(),B.default_build()],28,false,true,scoped)
 sg.active = 0;sg.cursor = sg.order.find(0);sg.pending = {};sg.forced_die = -1;sg.heroes[0].pos = Vector2i(0,7);sg.heroes[0].results = [0,0,1];sg.heroes[0].used = [false,false,false]
 check(sg.soul_distance(0) == 1 and sg.soul_limit(0) == 1,"Beginning grants Move 1 once per own turn")
 check(not sg.hero_action(0,-1,Vector2i(0,5)) and sg.hero_action(0,-1,Vector2i(0,6)),"Beginning rejects Move 2 and spends Blank for Move 1")
 check(not sg.hero_action(1,-1,Vector2i(0,5)),"second Beginning Blank cannot move again")
 sg.cursor = sg.order.find(0);sg.activate();sg.pending = {};sg.heroes[0].used[1] = false
 check(sg.hero_action(1,-1,Vector2i(0,5)),"Beginning refreshes at next own turn")
 app.expedition.camp.grant_soul(1,"hollow");app.expedition.camp.equip_soul(1,"hollow")
 scoped = app.camp_battle_profile()
 check(scoped["soul.distance.0"] == 1 and scoped["soul.distance.1"] == 2,"earned Move 2 remains specific to equipped hero")
 for tab in range(4):
  app.camp_tab = tab;app.rebuild();check(app.ui.has_node("CampTab"+str(tab)),"Camp tab renders")
 app.camp_tab = 2;app.rebuild()
 for slot in ["body","weapon","soul","memory"]:check(app.ui.has_node("Equipment_"+slot),"equipment slot "+slot)
 app.ui.get_node("Equipment_weapon").item_selected.emit(0)
 check(app.expedition.camp.weapons[app.camp_hero] == "","UI unequips Dagger")
 app.ui.get_node("Equipment_weapon").item_selected.emit(1)
 check(app.expedition.camp.weapons[app.camp_hero] == "dagger","UI equips Dagger")
 check(app.ui.has_node("EquipmentSprite_beginning") and app.ui.has_node("EquipmentSprite_memory_loss"),"soul and Memory sprite regions render")
 app.open_forge(false);check(app.ui.has_node("ForgeFacePicker") and app.ui.has_node("ForgeDie2Side5"),"roomy forge editor renders all dice")
 var before: Array = app.builds.duplicate(true);app.forge_die = 0;app.forge_side = 4;app.forge_replace(1)
 check(app.builds == before,"invalid Blank/copy edit rejected atomically")
 app.start_creature_encounter(0);app.dice_tray.cancel();app.rolling_time = 0
 app.game.damage(3,99,true);app.game.damage(4,99,true);app.rebuild()
 check(app.expedition.camp.bank.get("bone_creature",0) >= 2,"direct fight banks normal Essence on victory")
 var gold: int = app.expedition.gold;var bank: int = app.expedition.camp.bank.bone_creature;app.rebuild()
 check(app.expedition.gold == gold and app.expedition.camp.bank.bone_creature == bank,"direct outcome redraw does not duplicate rewards")
 app.queue_free();await process_frame
 print("HUB V0.28: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
