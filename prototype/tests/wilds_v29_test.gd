extends SceneTree
const B = preload("res://prototype/battle.gd")
const E = preload("res://prototype/essence.gd")
const M = preload("res://prototype/event_battle.gd")
const W = preload("res://prototype/wilds.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("WILDS FAIL: ",why)
func fresh(mode: String):
 var profile := {"soul.eligible.0":true,"soul.mode.0":mode,"soul.distance.0":2 if mode == "blink" else 0,"soul.allowance.0":1}
 var g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],29,false,true,profile)
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.forced_die = -1
 g.heroes[0].pos = Vector2i(0,7);g.heroes[1].pos = Vector2i(1,7);g.heroes[2].pos = Vector2i(6,7)
 g.heroes[0].results = [0,0,0];g.heroes[0].used = [false,false,false];g.heroes[0].reaction = [];return g
func monster(type: String):
 var g = M.new();g.prototype_pack = true;g.creature_types = [type];g.start([B.default_build(),B.default_build(),B.default_build()],29)
 g.active = 3;g.pending = {};g.boss.pos = Vector2i(3,4)
 for h in g.heroes:h.reaction = [];h.pos = Vector2i(0,0)
 g.heroes[0].pos = Vector2i(3,5);return g
func action(g, name: String):
 g.queued_actions = [{"id":3,"action":name}];g.continue_monsters()
func _initialize():call_deferred("run")
func run():
 check(W.GROUPS.size() == 6 and W.MEMORIES.size() == 3,"three new groups and Souls")
 var e = E.new();e.bank = {"mire_leech":9,"glasswing_moth":3,"iron_husk":3}
 check(e.reward_name("mire_soul") == "Memory of the Mire" and not e.reward_effect("mire_soul").contains("hidden"),"Memory name/effect readable before crafting")
 check(e.craft("mire_soul") == "" and e.bank.mire_leech==6,"craft pays three matching Essence")
 check(e.equip_memory(1,"mire_soul") and not e.equip_soul(1,"mire"),"Blank conversion is in Memory, not Soul")
 check(e.craft("mire_soul") != "" and e.bank.mire_leech==6,"owned permanent Memory cannot be bought twice")
 check(e.equip_memory(0,"mire_soul") and e.memories[1]=="","one shared Memory copy transfers")
 check(e.craft("glasswing_soul") == "" and e.craft("iron_soul") == "","other enemy Essence buys independent Memories")
 var reload = E.new();reload.decode(e.encode());check(reload.memories==e.memories and reload.bank==e.bank,"Memory/Essence save roundtrip")
 e = E.new();e.bank = {"mire_leech":2,"iron_husk":99};check(e.craft("mire_soul") != "" and e.bank.iron_husk==99,"cannot mix Essence types")
 var g = fresh("heal");check(not g.hero_action(0) and not g.heroes[0].used[0] and g.soul_remaining(0) == 1,"full HP rejects Mire without spending")
 g.heroes[0].hp = 3;check(g.hero_action(0) and g.heroes[0].hp == 4 and g.heroes[0].used[0],"Mire heals one and spends Blank")
 check(g.hero_action(1) and g.heroes[0].hp == 4,"Mire cannot heal twice in turn")
 g.cursor = g.order.find(0);g.activate();g.heroes[0].used[1] = false;check(g.hero_action(1) and g.heroes[0].hp == 5,"Mire refreshes on own activation")
 g = fresh("heal");g.heroes[0].hp = 3;g.balance["memory.loss.0"] = true;g.hero_action(0)
 check(g.heroes[0].hp == 5 and g.heroes[0].memory_self_used,"Mire actual self-heal supports Memory once per combat")
 check(g.event_log.any(func(event):return event.kind == "soul" and event.value == 2),"Mire log reports actual Memory-enhanced healing")
 g = fresh("heal");g.heroes[0].hp = 0;check(not g.hero_action(0),"Mire cannot revive its Downed owner")
 g = fresh("block");check(g.hero_action(0) and g.heroes[0].block == 2 and g.soul_remaining(0) == 0,"Ironbound grants two Block once")
 check(g.hero_action(1) and g.heroes[0].block == 2,"Ironbound second Blank is inert")
 g.cursor = g.order.find(0);g.activate();check(g.heroes[0].block == 0 and g.soul_remaining(0) == 1,"Ironbound old Block expires and allowance refreshes")
 g.heroes[0].rooted = 1;check(g.hero_action(2),"Rooted does not prevent stationary Ironbound defense")
 g = fresh("block");g.heroes[0].debt_buff = 1;g.hero_action(0)
 check(g.heroes[0].block == 3 and g.event_log.any(func(event):return event.kind == "soul" and event.value == 3),"Ironbound modifiers and actual gain log agree")
 g = fresh("blink");check(Vector2i(2,7) in g.soul_cells(0),"Glasswing can cross occupied intermediate cell")
 check(not (Vector2i(1,7) in g.soul_cells(0)) and not g.hero_action(0,-1,Vector2i(1,7)),"Glasswing cannot land on occupied cell")
 check(not g.hero_action(0,-1,Vector2i(3,7)) and g.soul_remaining(0) == 1,"Glasswing range restriction preserves unused allowance")
 check(g.hero_action(0,-1,Vector2i(2,7)) and g.heroes[0].pos == Vector2i(2,7),"Glasswing actual blink resolves")
 check(not g.hero_action(1,-1,Vector2i(4,7)),"Glasswing once per own turn")
 g = fresh("blink");g.heroes[0].rooted = 1;check(g.soul_cells(0).is_empty() and not g.hero_action(0,-1,Vector2i(0,6)),"Rooted prevents blink")
 for mode in ["heal","block","blink"]:
  g = fresh(mode);g.heroes[0].hp = 3;g.burden_interrupt = {"owner":1,"die":0}
  check(g.soul_remaining(0) == 0 and not g.hero_action(0,-1,Vector2i(0,6)),"new Soul unavailable in Shared Burden interrupt")
 for type in ["mire_leech","glasswing_moth","iron_husk"]:
  g = monster(type);check(g.boss.hp == E.TYPES[type].hp,"enemy HP for "+type)
  check(g.boss_dice().size() == 3 and g.boss_dice().all(func(die):return die.size() == 6),"three public six-sided dice for "+type)
  g.damage(3,99,true);check(g.outcome == "victory" and g.harvest_tokens.size() == 1 and g.harvest_tokens[0].type == type,"individual Essence for "+type)
  var ledger = E.new();ledger.settle(g.harvest_run,true,g.harvest_tokens,g.harvest_deaths,g.encounter_types());ledger.settle(g.harvest_run,true,g.harvest_tokens,g.harvest_deaths,g.encounter_types())
  check(ledger.bank[type] == 1,"idempotent new Essence banking")
 g = monster("mire_leech");action(g,"Venom Bite");check(g.heroes[0].hp == 5 and g.heroes[0].poison == 1,"Venom Bite adds Poison after actual HP loss")
 g = monster("mire_leech");g.heroes[0].block = 1;action(g,"Venom Bite");check(g.heroes[0].hp == 6 and g.heroes[0].get("poison",0) == 0,"blocked Venom Bite does not Poison")
 g = monster("mire_leech");g.heroes[0].results = [5,0,0];g.heroes[0].reaction = [0];action(g,"Venom Bite")
 check(g.pending.get("kind","") == "reaction","Venom Bite offers normal Reactions")
 g.react(true);check(g.heroes[0].hp == 6 and g.heroes[0].get("poison",0) == 0,"Reaction Block prevents Poison")
 g = monster("glasswing_moth");g.heroes[0].pos = Vector2i(3,7);action(g,"Needle");check(g.heroes[0].hp == 5,"Needle hits at range three")
 g = monster("glasswing_moth");g.heroes[0].pos = Vector2i(3,8);action(g,"Needle");check(g.heroes[0].hp == 6,"Needle does not exceed range")
 g = monster("glasswing_moth");g.heroes[0].pos = Vector2i(3,7);g.heroes[1].pos = Vector2i(3,6);g.heroes[1].hp = 0;action(g,"Needle")
 check(g.heroes[0].hp == 6,"occupied line blocks Needle")
 g = monster("iron_husk");action(g,"Iron Guard");check(g.boss.block == 2,"Husk Iron Guard grants two")
 g = monster("iron_husk");action(g,"Bash");check(g.heroes[0].hp == 4,"Husk Bash deals two adjacent damage")
 g = monster("iron_husk");g.boss.weak = true;g.boss.weak_amount = 1;action(g,"Bash")
 check(g.heroes[0].hp == 5,"lead Husk Weakness is subtracted exactly once")
 g = monster("mire_leech");g.boss.weak = true;g.boss.weak_amount = 1;action(g,"Venom Bite")
 check(g.heroes[0].hp == 6 and g.heroes[0].get("poison",0) == 0,"weakened lead Leech deals zero and cannot Poison")
 check(g.creature_move("iron_husk") == 1 and g.creature_move("mire_leech") == 2,"distinct movement budgets")
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.expedition.camp = E.new()
 app.camp_tab = 3;app.creature_page = 1;app.open_camp()
 for i in range(3,6):check(app.ui.has_node("FightCreature"+str(i)),"new encounter card "+str(i))
 app.camp_tab = 0;app.essence_page = 1;app.camp_type = "mire_leech";app.camp_recipe = "mire_soul";app.expedition.camp.bank.mire_leech = 3;app.camp_hero = 1;app.rebuild()
 check(not app.ui.has_node("SoulRecipient1") and not app.ui.get_node("Craft_mire_soul").disabled,"Soul recipient and affordable binding UI")
 app.ui.get_node("Craft_mire_soul").pressed.emit();check(app.expedition.camp.unlocked.has("mire_soul") and app.expedition.camp.bank.mire_leech == 0,"real binding control grants paid recipient Soul")
 app.expedition.camp.equip_memory(1,"mire_soul");var profile: Dictionary = app.camp_battle_profile()
 check(profile["soul.mode.1"] == "heal" and not profile["soul.eligible.0"],"new Soul affects only equipped hero")
 app.camp_tab = 2;app.soul_gallery_page = 1;app.rebuild();check(app.ui.has_node("EquipmentSprite_mire"),"new Soul art renders")
 app.gifts = [[34,47],[34,47],[34,47]];app.builds = [B.bonus_build([34,47]),B.bonus_build([34,47]),B.bonus_build([34,47])]
 for i in range(3,6):
  app.start_creature_encounter(i);app.dice_tray.cancel();app.rolling_time = 0
  check(app.game.essence_type(3) == W.GROUPS[i].enemy,"new direct fight launches correct enemy")
 app.go_main();app.queue_free();await process_frame
 print("WILDS V0.29: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
