extends SceneTree
const B = preload("res://prototype/battle.gd")
const N = preload("res://prototype/nugh.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V26 FAIL: ",why)
func fresh():
 var g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],26)
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.forced_die = -1
 for h in g.heroes:h.used = [false,false,false];h.results = [16,1,0];h.rolls = [0,0,0];h.reaction = []
 return g
func _initialize():call_deferred("run")
func run():
 var g = fresh();g.apply_poison(3,0,1);g.apply_poison(3,0,1)
 check(g.heroes[0].poison == 2,"Poison 1 + 1 = 2")
 g.heroes[0].block = 5;g.tick_poison(0)
 check(g.heroes[0].hp == 4 and g.heroes[0].block == 5 and g.heroes[0].poison == 1,"Poison 2 damages HP and decrements to 1")
 var tick: Dictionary = g.event_log[-1]
 check(tick.kind == "poison_tick" and tick.hp_before == 6 and tick.hp_after == 4 and tick.poison_after == 1,"tick notice has exact result snapshot")
 g.tick_poison(0);g.tick_poison(0)
 check(g.heroes[0].hp == 3 and g.heroes[0].poison == 0,"second tick deals one then stops")
 g.heroes[0].hp = 1;g.apply_poison(3,0,4);g.tick_poison(0)
 check(g.heroes[0].hp == 0 and g.heroes[0].poison == 0,"Downing still clears Poison")
 for who in [3,4]:
  g = fresh();g.spawn_friendly(0,Vector2i(2,6))
  g.apply_poison(0,who,1);g.apply_poison(0,who,1)
  check(g.unit_data(who).poison == 2,"Poison stacks on bosses and summons")
 for hero in range(3):
  for die in range(3):
   g = fresh();g.heroes[hero].results[die] = 4;g.heroes[hero].used[die] = true
   if hero == 0 and die == 0:continue
   g.hero_action(0)
   check(g.catalog_pick(hero,die),"Borrow Shape selects any hero's spent face-up die")
   check(g.face(0,0) == 4 and g.forced_die == 0 and not g.heroes[0].used[0],"copy remains available on the Borrow die")
   check(g.hero_action(0) and g.heroes[0].block == 1,"copied Guard actually resolves")
   check(g.heroes[hero].used[die] and g.face(hero,die) == 4,"source die unchanged")
 g = fresh();g.heroes[1].results[1] = 5;g.heroes[1].used[1] = true;g.heroes[1].reaction = [1];g.hero_action(0);g.catalog_pick(1,1)
 check(g.heroes[0].reaction == [0] and g.forced_die == -1,"Borrow Shape can hold copied Reaction")
 check(not g.borrow_eligible(2,-1),"invalid Borrow index rejected")
 g.heroes[2].results = [16,56,0]
 check(not g.borrow_eligible(2,0) and not g.borrow_eligible(2,1) and g.borrow_eligible(2,2),"Borrow excludes loops/Red Tile but allows Blank")
 g = fresh();g.heroes[0].opening = false;g.heroes[0].results[1] = 5;g.heroes[0].used[1] = true;g.heroes[0].reaction = [1]
 check(g.action_reroll(1) and g.heroes[0].rerolls == 0,"Action Reroll works after acting and on held Reaction")
 check(g.heroes[0].reaction.count(1) <= 1,"reroll never duplicates Reaction latch")
 g = fresh();g.heroes[0].opening = false;g.balance["hero.reroll_anytime"] = 0
 check(not g.action_reroll(1) and g.heroes[0].rerolls == 1,"opening-only toggle remains testable")
 g = fresh();g.heroes[0].used[1] = true
 check(not g.action_reroll(1),"spent dice cannot be refreshed")
 g = fresh();g.heroes[0].results = [6,5,0];g.heroes[0].used[1] = true;g.heroes[0].reaction = [1]
 check(g.hero_action(0,1),"Focus can reroll a held Reaction")
 check(g.event_log.any(func(e):return e.kind == "focus" and e.has("old_side")),"Focus records both old and new result")
 for amount in [1,2,3]:
  g = fresh();g.heroes[0].results = [5,0,0];g.heroes[0].used[0] = true;g.heroes[0].reaction = [0]
  g.heroes[0].pos = Vector2i(2,3);g.pending = {"kind":"attack","action":"Test hit","victims":[0],"reacted":[],"amount":amount,"source":3,"range":1};g.continue_attack();g.react(true)
  check(g.heroes[0].hp == 6-maxi(0,amount-2),"Reaction really prevents two damage")
  check(g.heroes[0].block == maxi(0,2-amount),"remaining Block reflects consumption")
  check(g.event_log.any(func(e):return e.kind == "reaction" and e.value == 2),"Reaction grant is logged before consumption")
 g = fresh()
 for i in range(2100):g.note("Full detail %d" % i)
 check(g.event_log.size() > 2100 and g.log_lines.size() == g.event_log.size(),"full log retains entire encounter")
 var scene = load("res://prototype/prototype.tscn").instantiate();root.add_child(scene);await process_frame
 scene.draft_modal = false;scene.start_expedition()
 check(scene.page == "events","boss entry routes through events")
 scene.expedition.next_sortie();scene.enter_boss()
 check(scene.page == "events","unresolved event cannot enter boss")
 scene.expedition.stage = "resolved";scene.expedition.selected = 1;scene.gifts = [[34,47],[34,47],[34,47]];scene.builds = [B.bonus_build([34,47]),B.bonus_build([34,47]),B.bonus_build([34,47])];scene.enter_boss()
 check(scene.page == "battle" and scene.expedition.stage == "boss","resolved event permits boss and is consumed")
 scene.start_expedition();check(scene.page == "events" and scene.expedition.stage == "idle","next boss needs a new event")
 scene.begin();scene.game.active = 0;scene.game.pending = {};scene.game.apply_poison(3,0,1);scene.game.tick_poison(0);scene.rebuild();scene.dice_tray.finish();scene.rebuild()
 check(scene.ui.get_node_or_null("AcknowledgeCombatNotice") == null,"Poison damage does not open acknowledgement window")
 var count: int = scene.combat_notices.size();scene.rebuild();check(scene.combat_notices.size() == count,"redraw does not duplicate notices")
 check(scene.combat_notices.is_empty(),"Poison never blocks combat")
 scene.game.note("Full log includes this detail");scene.ui.get_node("LogExtensiveTab").pressed.emit()
 check(not scene.compact_log and scene.ui.get_node("SideChronicle").text.contains("Full log includes this detail"),"Extensive tab shows unfiltered details")
 scene.game.heroes[0].results = [6,5,0];scene.game.heroes[0].used = [false,true,false];scene.game.heroes[0].reaction = [1];scene.selected = 0;scene.select_combat_die(1)
 var focused: Dictionary = scene.game.heroes[0]
 check(scene.combat_notices.is_empty() and (scene.game.forced_die==1 or (scene.game.forced_die<0 and focused.used[1] and 1 in focused.reaction and B.Catalog.is_reaction(scene.game.face(0,1)))),"Focus shows its new roll or holds its Reaction without an acknowledgement")
 scene.restart_to_menu()
 check(scene.page == "main" and scene.draft_modal and scene.gifts == [[],[],[]],"restart opens actual main menu and clears party choices")
 check(not scene.show_options and scene.combat_notices.is_empty(),"restart clears combat overlays")
 scene.queue_free();await process_frame
 print("V0.26 usability: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
