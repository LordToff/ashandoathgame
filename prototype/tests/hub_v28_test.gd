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
 check(e.equip_weapon(1,"spear") and not e.equip_weapon(1,"invented"),"valid starter weapon choices")
 var restored = E.new();restored.decode(e.encode())
 check(restored.weapons == ["dagger","spear","dagger"],"weapon equipment persists")
 check(not e.equip_body(0,"") and e.equip_body(0,"stone"),"Body category choices are mandatory")
 check("beginning" in e.souls[0] and e.memories==["","",""],"Beginning Soul owned; first Memory empty")
 var g = fresh();g.heroes[0].results = [81,1,0]
 check(not g.hero_action(0,3) and not g.heroes[0].used[0],"Poke locked before actual enemy HP damage")
 g.boss.block = 2;g.hero_action(1,3)
 check(not g.heroes[0].get("damaged_enemy_turn",false),"fully blocked hit does not unlock Poke")
 g = fresh();g.heroes[0].results = [81,1,0];check(g.hero_action(1,3),"another rolled Strike deals enemy damage")
 var hp: int = g.boss.hp
 check(g.hero_action(0,3) and g.boss.hp==hp-1 and g.heroes[0].used[0],"Poke spends its rolled die for 1 damage")
 check(not g.poke(3) and not g.hero_action(0,3),"no free extra Poke or reuse")
 g = fresh(W);g.heroes[0].results = [81,1,0];g.guard_broken = true;g.hero_action(1,3);g.guard_broken = false;hp = g.boss.hp
 check(g.hero_action(0,3) and g.boss.hp==hp,"Warden armor applies to rolled Poke")
 g = fresh(C);g.heroes[0].results = [81,1,0];g.hero_action(1,3);var resonance: int = g.resonance
 check(g.hero_action(0,3) and g.resonance==resonance+g.v("cantor.attack_charge"),"rolled Poke charges Veyl as an Attack")
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
 check(sg.soul_remaining(0)==0 and not sg.hero_action(0,-1,Vector2i(0,6)),"Beginning Soul grants no implicit Blank movement")
 app.expedition.camp.unlocked.memory_first_step = true;app.expedition.camp.equip_memory(0,"memory_first_step")
 scoped = app.camp_battle_profile()
 check(scoped["soul.eligible.0"] and not scoped["soul.eligible.1"],"First Step Memory conversion is specific to its equipped hero")
 for tab in range(4):
  app.camp_tab = tab;app.rebuild();check(app.ui.has_node("CampTab"+str(tab)),"Camp tab renders")
 app.camp_tab = 2;app.rebuild()
 for slot in ["body","weapon","soul","memory"]:check(app.ui.has_node("Equipment_"+slot),"equipment slot "+slot)
 app.ui.get_node("Equipment_weapon").item_selected.emit(1)
 check(app.expedition.camp.weapons[app.camp_hero] == "spear","UI equips Spear on a legal build")
 app.ui.get_node("Equipment_weapon").item_selected.emit(0)
 check(app.expedition.camp.weapons[app.camp_hero] == "dagger","UI restores Dagger")
 check(app.ui.get_node("EquipmentSprite_beginning").size == Vector2(132,134),"sprite stays within its equipment cell")
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
