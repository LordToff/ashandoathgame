extends SceneTree
const B = preload("res://prototype/battle.gd")
const E = preload("res://prototype/essence.gd")
const M = preload("res://prototype/event_battle.gd")
const C = preload("res://prototype/catalog.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("ESSENCE FAIL: ",why)
func fresh(face: int = 60, profile: Dictionary = {}):
 var g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],27,false,true,profile)
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.forced_die = -1
 for h in g.heroes:
  h.used = [false,false,false];h.results = [face,1,0];h.rolls = [0,0,0];h.reaction = [];h.bone_count = 0;h.moved_turn = 0
 g.heroes[0].pos = Vector2i(2,3);g.heroes[1].pos = Vector2i(1,3);g.heroes[2].pos = Vector2i(0,3)
 return g
func group(hard: bool = false):
 var g = M.new();g.prototype_pack = true;g.hard = hard;g.start([B.default_build(),B.default_build(),B.default_build()],27)
 g.pending = {};return g
func _initialize():call_deferred("run")
func run():
 check(C.FACE_COUNT == 73 and B.FACES.size() == 73,"original reward IDs retained with four boss faces")
 for id in range(60,69):check(C.name_for(id) == E.FACES[id-60][0] and B.valid_face_number(id),"reward catalog integration")
 check(not B.valid_face_number(73),"invalid next face still rejected")
 var e = E.new();e.bank = {"bone_creature":100,"support_creature":20,"movement_creature":10}
 check(e.reward_name("bone_strike") == "Bone Strike" and e.reward_effect("bone_strike").contains("Adjacent"),"effect and design name inspectable before crafting")
 check(e.craft("bone_strike") == "" and e.owned(61) == 1 and e.bank.bone_creature == 98,"first craft pays two and grants first physical copy")
 check(e.reward_name("bone_strike") == "Bone Strike" and not e.reward_effect("bone_strike").contains("hidden"),"unlock reveals exact effect")
 for i in range(12):check(e.craft("bone_strike") == "","same-cost duplicates have no owned maximum")
 check(e.owned(61) == 13 and e.bank.bone_creature == 74,"duplicate payment quantity")
 check(e.craft("bone_growth") == "" and e.craft("bone_guard") == "","reward unlocks never exclude other entries")
 check(e.craft("memory_loss") == "" and e.bank.support_creature == 16,"Memory costs four")
 check(e.craft("memory_loss") != "" and e.bank.support_creature == 16,"Memory permanent unlock cannot be bought twice")
 check(e.equip_memory(0) and e.equip_memory(2) and e.memories == ["","","memory_loss"],"Memory shared copy can transfer at refitting")
 check(e.equip_memory(-1) and e.memories == ["","",""] and e.unlocked.has("memory_loss"),"Memory can stay unequipped without losing ownership")
 check(e.grant_soul(1,"nugh") and not e.equip_soul(0,"nugh") and e.equip_soul(1,"nugh"),"Soul binds to recipient and cannot trade")
 e = E.new();e.bank.bone_creature = 1;e.bank.support_creature = 10
 check(e.craft("bone_strike") != "" and e.bank.bone_creature == 1 and e.bank.support_creature == 10,"cannot mix Essence types for a purchase")
 var g = group();g.damage(3,99,true)
 check(g.harvest_tokens.size() == 1 and g.harvest_tokens[0].id == 3,"one token belongs to first defeated card")
 g.damage(3,99,true);check(g.harvest_tokens.size() == 1,"repeated corpse damage cannot duplicate token")
 g.damage(4,99,true);check(g.outcome == "victory" and g.harvest_tokens.size() == 2,"two identical individuals yield two tokens")
 check(e.settle(g.harvest_run,true,g.harvest_tokens,g.harvest_deaths,g.encounter_types()) and e.bank.bone_creature == 3,"victory banks all tokens")
 check(not e.settle(g.harvest_run,true,g.harvest_tokens,g.harvest_deaths,g.encounter_types()) and e.bank.bone_creature == 3,"settlement is exactly once")
 g = group();g.damage(3,99,true);g.heroes[0].hp = 0;g.heroes[1].hp = 0;g.heroes[2].hp = 0;g.check_end()
 e.settle(g.harvest_run,false,g.harvest_tokens,g.harvest_deaths,g.encounter_types())
 check(e.bank.bone_creature == 3 and g.outcome == "defeat","defeat discards current tokens, never banked Essence")
 g = group();g.damage(3,99,true);g.damage(4,99,true);e.settle(g.harvest_run,true,g.harvest_tokens,g.harvest_deaths,g.encounter_types())
 check(e.bank.bone_creature == 5,"repeat encounters bank more of same type")
 g = fresh();g.boss.harvest_condition = "no_block";g.boss.block = 1
 check(g.harvest_card(3).contains("HIDDEN") and not g.harvest_card(3).contains("YES"),"hidden boss eligibility does not leak")
 g.harvest_revealed.hollow = true;check(g.harvest_card(3).contains("NO"),"discovered condition exposes current eligibility")
 g.boss.block = 0;check(g.harvest_card(3).contains("YES"),"eligibility changes dynamically")
 g.boss.block = 1;g.damage(3,99,true)
 check(g.harvest_tokens.is_empty(),"an earlier eligible state does not qualify at death")
 e.settle(g.harvest_run,false,g.harvest_tokens,g.harvest_deaths,g.encounter_types());check(e.defeated.has("hollow"),"first defeat reveals permanently even if party later loses")
 g = fresh();g.boss.harvest_condition = "poisoned";g.boss.hp = 1;g.apply_poison(0,3,1);g.tick_poison(3)
 check(g.harvest_tokens.size() == 3,"poison lethal tick checks condition before decay/death cleanup")
 g = fresh();var worm: int = g.spawn_friendly(0,Vector2i(2,2));g.damage(worm,99,true)
 check(g.harvest_tokens.is_empty(),"friendly summon deaths never yield Essence")
 g = fresh();g.damage(3,99,true);e.settle(g.harvest_run,true,g.harvest_tokens,g.harvest_deaths,g.encounter_types())
 check(e.souls.all(func(list):return "hollow" in list),"tutorial Hollow awards Soul to every hero")
 var loaded = E.new();loaded.decode(e.encode())
 check(loaded.bank == e.bank and loaded.souls == e.souls and loaded.settled == e.settled,"ledger reload preserves safe bank, ownership and claims")
 for face in [60,61,62]:
  g = fresh(face);g.heroes[0].results = [60,61,62]
  for die in range(3):g.on_roll(g.heroes[0],die)
  check(g.heroes[0].bone_count == 3,"all three rolled Bone faces count")
  if face == 60:
   check(g.hero_action(0,-1,Vector2i(2,2)) and g.heroes[0].block == 1 and g.heroes[0].pos == Vector2i(2,2),"Bone Growth gains one Block and moves one")
  elif face == 61:
   g.hero_action(0);var hp: int = g.boss.hp;check(g.hero_action(1,3) and g.boss.hp == hp-3,"spent Bone Growth still counts for Bone Strike")
  else:
   g.hero_action(0);check(g.hero_action(2) and g.heroes[0].block == 4,"spent Bone counts for three Block plus Growth Block")
 g = fresh(63);g.heroes[1].hp = 3;g.hero_action(0)
 check(g.pending.is_empty() and g.heroes[1].hp == 3,"full-health self does not trigger ally heal")
 g = fresh(63,{"memory.loss.0":true});g.heroes[0].hp = 2;g.heroes[1].hp = 3;g.hero_action(0)
 check(g.heroes[0].hp == 4 and g.pending.kind == "essence_remedy" and g.face_range(63) == 3,"Memory improves first actual self-heal and eligible range")
 check(g.essence_pick(1) and g.heroes[1].hp == 4,"Remedy ally heals one after actual self-heal")
 g.heroes[0].used[0] = false;g.hero_action(0);check(g.heroes[0].hp == 5,"Memory bonus only once per combat")
 check(g.face_range(7) == 1 and g.face_range(55) == 1,"Self/Adjacent healing exceptions unchanged")
 g = fresh(64);var hp: int = g.heroes[0].hp;g.hero_action(0);g.essence_decline()
 check(g.heroes[0].hp == hp and g.heroes[0].used[0],"declined Offering spends face without paying HP")
 g.heroes[0].used[0] = false;g.hero_action(0);g.essence_pick(1,0)
 check(g.heroes[0].hp == hp-1 and g.heroes[1].block == 2,"Offering pays one unavoidable HP and grants two Block")
 g = fresh(64);g.hero_action(0);g.essence_pick(1,1)
 check(g.heroes[1].offering_boost == 1,"Offering grants next Attack buff")
 g.active = 1;g.heroes[1].pos = Vector2i(2,3);var bhp: int = g.boss.hp;g.strike(1,3,1);g.strike(1,3,1)
 check(g.boss.hp == bhp-3 and g.heroes[1].offering_boost == 0,"buff applies once, not to every subsequent Attack")
 g = fresh(65);g.heroes[0].round_history = [{"die":1,"face":4}];g.heroes[0].used[1] = true
 var cursor: int = g.cursor;var old: Array = g.heroes[1].build.duplicate(true);g.hero_action(0)
 check(g.burden_source(0) and g.burden_ally(1,0),"Shared Burden accepts spent source and ready ally die")
 check(g.active == 1 and g.forced_die == 0 and g.cursor == cursor,"single-action interrupt keeps initiative cursor")
 check(not g.hero_action(1,3),"recipient cannot spend unrelated extra action")
 check(g.hero_action(0) and g.heroes[1].block == 1,"recipient resolves copied Guard")
 check(g.return_from_burden() and g.active == 0 and g.cursor == cursor and g.heroes[1].used[0],"return to original hero with ally die consumed")
 check(g.heroes[1].build == old,"no installed faces changed by Shared Burden")
 g = fresh(66);g.heroes[1].pos = Vector2i(0,7);g.heroes[2].pos = Vector2i(0,8)
 check(g.hero_action(0,-1,Vector2i(0,3)) and g.heroes[0].block == 1 and g.heroes[0].moved_turn == 2,"Retreat moves two, tracks spaces and rewards retreat from all enemies")
 g.heroes[0].used[1] = false;g.heroes[0].results[1] = 67;g.heroes[0].pos = Vector2i(2,3);bhp = g.boss.hp
 check(g.hero_action(1,3) and g.boss.hp == bhp-1,"Momentum after two spaces deals fixed one")
 g = fresh(67);check(not g.hero_action(0,3) and not g.heroes[0].used[0],"Momentum requires actual movement before committing")
 for incoming in [1,2]:
  g = fresh();g.heroes[0].results = [68,0,0];g.heroes[0].used[0] = true;g.heroes[0].reaction = [0]
  g.pending = {"kind":"attack","action":"Test","victims":[0],"reacted":[],"amount":incoming,"source":3,"range":1};g.continue_attack();g.react(true)
  check(g.heroes[0].hp == 6-maxi(0,incoming-1),"Evasive grants one Block before hit")
  check((g.pending.get("kind","") == "essence_evasive") == (incoming == 1),"post-Attack move only if no HP lost")
  if incoming == 1:check(g.evasive_step(Vector2i.UP) and g.heroes[0].pos == Vector2i(2,2),"Evasive Move 1 occurs only after complete Attack")
 g = group(true)
 check(g.living_minions().size() == 2 and g.essence_type(3) == "support_creature" and g.unit_data(4).essence_type == "movement_creature","all three prototype species are playable in event groups")
 # Movement threshold, numeric zero and per-hero Soul equipment.
 g = fresh(67);g.heroes[0].moved_turn = 3;g.forced_die = -1;g.balance["numeric.high_faces"] = 6;g.balance["numeric.high"] = 2;bhp = g.boss.hp
 check(g.hero_action(0,3) and g.boss.hp == bhp-3,"Momentum after three spaces uses Numeric plus one")
 g = fresh(67);g.heroes[0].moved_turn = 3;g.heroes[0].gambler = true;g.heroes[0].stored_num = 0
 # Numeric zero flag has its standard absolute-zero behavior through strike.
 g.heroes[0].numeric_zero = true;bhp = g.boss.hp;g.strike(0,3,1,0,true)
 check(g.boss.hp == bhp,"Gambler absolute zero cannot be rescued by Momentum bonus")
 g = fresh(66);g.heroes[1].pos = Vector2i(0,7);g.heroes[2].pos = Vector2i(0,8)
 g.minions.append({"name":"Other enemy","hp":2,"max_hp":2,"block":0,"dead":false,"pos":Vector2i(0,3),"faction":"enemy"})
 check(g.hero_action(0,-1,Vector2i(1,3)) and g.heroes[0].block == 0,"Retreat must move farther from EVERY enemy")
 g = fresh(63,{"memory.loss.0":true});g.heroes[0].hp = 6;g.hero_action(0)
 check(not g.heroes[0].get("memory_self_used",false),"healing zero HP does not spend Memory's first self-heal")
 g.heroes[0].hp = 3;g.action_owner = 1;g.heal(0,1)
 check(g.heroes[0].hp == 4 and not g.heroes[0].get("memory_self_used",false),"an ally healing the Memory owner is not a self-heal")
 g.action_owner = 0;g.heal(0,1);check(g.heroes[0].hp == 6,"Memory bonus remains for later actual self-heal")
 g = fresh();g.heroes[0].results = [68,68,0];g.heroes[0].used = [true,true,false];g.heroes[0].reaction = [0,1]
 g.pending = {"kind":"attack","action":"Test","victims":[0],"reacted":[],"amount":2,"source":3,"range":1};g.continue_attack();g.react(true);g.react(true)
 check(g.heroes[0].hp == 6 and g.pending.kind == "essence_evasive","two Evasive copies grant two Block")
 g.evasive_step(Vector2i.ZERO);check(g.pending.kind == "essence_evasive","each successful Evasive copy offers its own post-Attack step")
 g.heroes[0].rooted = 1;check(not g.evasive_step(Vector2i.UP) and g.evasive_step(Vector2i.ZERO),"Rooted denies voluntary step but permits staying")
 g = fresh();g.heroes[0].results = [68,0,0];g.heroes[0].used[0] = true;g.heroes[0].reaction = [0]
 g.heroes[1].pos = Vector2i(0,7);g.heroes[2].pos = Vector2i(0,8)
 g.pending = {"kind":"attack","action":"Drive Back","victims":[0],"reacted":[],"amount":1,"source":3,"range":1};g.continue_attack();g.react(true)
 check(g.pending.get("kind","") == "essence_evasive","fully blocked Drive Back offers Evasive movement after forced push")
 g = fresh();g.heroes[0].results = [68,0,0];g.heroes[0].used[0] = true;g.heroes[0].reaction = [0]
 g.pending = {"kind":"attack","action":"Drive Back","victims":[0],"reacted":[],"amount":1,"source":3,"range":1};g.continue_attack();g.react(true)
 if g.pending.get("kind","") == "stun":g.stun_die(1)
 check(g.heroes[0].hp == 5 and g.pending.get("kind","") != "essence_evasive","collision HP loss from the Attack denies Evasive step")
 g = fresh(65);g.heroes[0].round_history = [{"die":1,"face":65},{"die":2,"face":1}];g.hero_action(0)
 check(not g.burden_source(0) and g.burden_source(1),"Shared Burden excludes itself but preserves other rolled results")
 g.heroes[1].used = [true,true,true];check(not g.burden_ally(1,0),"Shared Burden cannot refresh a spent recipient die")
 g.heroes[1].used[0] = false;g.heroes[1].pos = Vector2i(0,8);check(not g.burden_ally(1,0),"Shared Burden ally range is enforced")
 g.heroes[1].pos = Vector2i(1,3);g.heroes[1].moved_turn = 3;g.burden_ally(1,0)
 check(g.heroes[1].moved_turn == 0,"borrowed action does not reuse last normal turn's movement")
 g.decline(0);g.return_from_burden();check(g.heroes[1].moved_turn == 3,"borrowed action restores previous turn scope without giving a new full turn")
 var ledger = preload("res://prototype/expedition.gd").new();ledger.fragments = 3
 check(ledger.unlock_soul(2) and "ashroad" in ledger.camp.souls[2] and "ashroad" not in ledger.camp.souls[0],"event Soul binds only to specified recipient")
 check(not ledger.camp.equip_soul(0,"ashroad"),"event Soul cannot be traded")
 var scoped: Dictionary = ledger.camp.profile({});scoped["soul.eligible.0"] = false;scoped["soul.eligible.1"] = false;scoped["soul.eligible.2"] = true
 g = fresh(0,scoped);check(g.reward and g.soul_remaining(0) == 0 and g.soul_remaining(2) == 1,"equipped Soul grants Blank conversion only to its bound hero")
 g = fresh(65);g.heroes[0].round_history = [{"die":1,"face":4}];g.hero_action(0);g.burden_source(0)
 g.heroes[1].used[0] = true;g.heroes[1].results[0] = 5;g.heroes[1].reaction = [0]
 check(g.burden_ally(1,0) and g.heroes[1].reaction.is_empty() and not g.heroes[1].used[0],"held unspent Reaction may pay Shared Burden; old latch is removed")
 check(g.hero_action(0) and g.return_from_burden(),"copied action resolves after paying a held Reaction")
 g = fresh(11);g.heroes[1].results[1] = 62;g.hero_action(0)
 check(C.can_copy(62) and g.catalog_pick(1,1) and g.face(0,0) == 62,"existing Conjure supports immediate earned faces without allowing Shared Burden loops")
 check(not C.can_copy(65) and not C.can_copy(68),"copy/setup and held-Reaction restrictions remain on Conjure")
 g = fresh(61);g.heroes[0].bone_count = 1;g.heroes[0].offering_boost = 1;g.heroes[0].mods[0] = {"repeat":1};bhp = g.boss.hp
 g.strike(0,3,1);check(g.boss.hp == bhp-3,"Sorrow next-Attack bonus is spent on first hit rather than repeated forever")
 g = fresh(1);g.heroes[1].results[0] = 68;g.heroes[1].used[0] = true;g.heroes[1].reaction = [0]
 check(g.hero_action(0,1) and g.pending.kind == "essence_friendly_evasive" and not g.heroes[0].used[0],"friendly Attack pauses for Evasive before paying/resolving the Attack")
 check(g.friendly_evasive_react(true) and g.heroes[1].hp == 6 and g.heroes[0].used[0],"Evasive Block also mitigates a friendly Attack and consumes the attacking die exactly once")
 check(g.pending.kind == "essence_evasive" and g.evasive_step(Vector2i.UP),"friendly Attack offers the same post-Attack Move 1")
 g = fresh(1);g.heroes[1].results[0] = 68;g.heroes[1].used[0] = true;g.heroes[1].reaction = [0];g.hero_action(0,1)
 check(g.friendly_evasive_react(false) and g.heroes[1].hp == 5 and g.heroes[1].reaction == [0],"holding Evasive against friendly fire preserves the face and takes normal damage")
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.expedition.camp = E.new();app.expedition.camp.bank.bone_creature = 10;app.open_camp()
 check(app.page == "camp" and app.ui.get_node_or_null("Craft_bone_growth") != null,"Camp Forge renders with real crafting control")
 app.ui.get_node("Craft_bone_growth").pressed.emit()
 check(app.expedition.camp.owned(60) == 1 and app.ui.get_node("CampRecipeDetails").text.contains("Move 1"),"craft reveals effect")
 app.camp_tab = 1;app.rebuild()
 check(app.ui.has_node("CampSlot0_0"),"dedicated refit tab exposes die slots")
 app.camp_place(60,0,2,1)
 check(app.builds[0][2][1] == 60,"owned face refits into legal starter slot")
 var before_build: Array = app.builds[1].duplicate(true);app.camp_place(60,1,2,1)
 check(app.builds[1] == before_build,"one party copy cannot be equipped on two heroes")
 app.camp_remove(0,2,1);app.camp_place(60,1,2,1)
 check(app.builds[0][2][1] == 0 and app.builds[1][2][1] == 60 and app.expedition.camp.owned(60) == 1,"Camp unequips/trades the actual shared copy without loss or refund")
 app.page = "battle";app.game = group();app.game.damage(3,99,true);app.game.damage(4,99,true);app.show_enemy_cards = true;app.rebuild()
 check(app.show_enemy_cards,"defeated cards and token text can render after the outcome")
 app.queue_free();await process_frame
 print("ESSENCE V0.27: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
