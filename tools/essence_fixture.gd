extends Node
const B = preload("res://prototype/battle.gd")
const M = preload("res://prototype/event_battle.gd")
const E = preload("res://prototype/essence.gd")
var app
var callback
func _ready():
 app = load("res://prototype/prototype.tscn").instantiate();add_child(app)
 await get_tree().process_frame
 callback = JavaScriptBridge.create_callback(proof);JavaScriptBridge.get_interface("window").essenceProof = callback
func reset_ui():
 app.dice_tray.cancel();app.rolling_time = 0;app.choosing_poke = false;app.creature_fight = false;app.camp_tab = 0;app.show_enemy_cards = false;app.show_menu = false;app.show_options = false;app.show_history = false;app.show_supplies = false;app.show_soundtrack = false;app.draft_modal = false;app.lab = false;app.training = false;app.event_fight = false;app.combat_notices.clear();app.selected = -1
 app.gifts = [[34,47],[34,47],[34,47]];app.builds = [B.bonus_build([34,47]),B.bonus_build([34,47]),B.bonus_build([34,47])]
 app.seen_event = 0;app.seen_roll = 0;app.roll_seen = 0;app.effects.clear();app.snapshots.clear();app.visual_positions.clear()
func setup_reward(face: int):
 app.game = B.new();app.game.start(app.builds,27,false,true,app.camp_battle_profile());app.game.active = 0;app.game.cursor = app.game.order.find(0);app.game.pending = {};app.game.forced_die = -1;app.page = "battle"
 for h in app.game.heroes:h.results = [face,1,0];h.used = [false,false,false];h.reaction = [];h.rolls = [0,0,0]
 app.game.heroes[0].pos = Vector2i(2,3);app.game.heroes[1].pos = Vector2i(1,3);app.game.heroes[2].pos = Vector2i(0,3)
func proof(args):
 var mode: String = str(args[0])
 if mode == "state":
  var data := {"rolling":app.dice_tray.busy,"bank":app.expedition.camp.bank,"copies":app.expedition.camp.copies,"memories":app.expedition.camp.memories,"active":app.game.active,"page":app.page,"builds":app.builds,"weapons":app.expedition.camp.weapons,"souls":app.expedition.camp.souls,"equipped_souls":app.expedition.camp.equipped_souls}
  if app.game.heroes.size() == 3:data.hp = app.game.heroes.map(func(h):return h.hp);data.block = app.game.heroes.map(func(h):return h.block);data.positions = app.game.heroes.map(func(h):return [h.pos.x,h.pos.y]);data.dagger_used = app.game.heroes.map(func(h):return h.get("dagger_used",false));data.used = app.game.heroes.map(func(h):return h.used);data.boss_hp = app.game.boss.hp
  JavaScriptBridge.get_interface("window").essenceState = JSON.stringify(data);return
 reset_ui()
 if mode == "wilds_camp":
  app.expedition.camp = E.new();app.expedition.camp.bank = {"mire_leech":6,"glasswing_moth":6,"iron_husk":6};app.camp_type = "mire_leech";app.camp_recipe = "mire_soul";app.essence_page = 1;app.camp_hero = 0;app.open_camp()
 elif mode in ["soul_heal","soul_block","soul_blink"]:
  app.expedition.camp = E.new()
  var soul: String = {"soul_heal":"mire","soul_block":"iron","soul_blink":"glasswing"}[mode]
  app.expedition.camp.grant_soul(0,soul);app.expedition.camp.equip_soul(0,soul);setup_reward(0);app.game.heroes[0].hp = 3
  for hero in range(3):app.game.heroes[hero].pos = Vector2i(hero,7)
 elif mode == "wilds_cards":
  app.game = M.new();app.game.prototype_pack = true;app.game.creature_types = ["mire_leech","glasswing_moth","iron_husk"];app.game.start(app.builds,29);app.page = "battle";app.show_enemy_cards = true
 elif mode == "equipment_all":
  app.expedition.camp = E.new();app.expedition.camp.bank.support_creature = 10;app.expedition.camp.craft("memory_loss")
  for hero in range(3):app.expedition.camp.grant_soul(hero,"hollow");app.expedition.camp.grant_soul(hero,"ashroad")
  app.camp_tab = 2;app.open_camp()
 elif mode == "poke":
  app.expedition.camp = E.new();setup_reward(1);app.game.heroes[0].pos = Vector2i(3,5);app.game.hero_action(0,3)
 elif mode == "beginning":
  app.expedition.camp = E.new();setup_reward(0)
  for hero in range(3):app.game.heroes[hero].pos = Vector2i(hero*3,7)
 elif mode in ["victory","defeat","mixed"]:
  app.expedition.camp = E.new()
  if mode == "defeat":app.expedition.camp.bank.bone_creature = 7
  app.game = M.new();app.game.prototype_pack = true;app.game.hard = mode == "mixed";app.game.start(app.builds,27);app.page = "battle";app.event_fight = true;app.expedition.selected = 5 if mode == "mixed" else 4;app.expedition.stage = "combat"
  if mode == "mixed":app.show_enemy_cards = true
  else:
   app.game.damage(3,99,true)
   if mode == "victory":app.game.damage(4,99,true)
   else:
    for hero in range(3):app.game.damage(hero,99,true)
 elif mode == "support_camp":
  app.expedition.camp = E.new();app.expedition.camp.bank.support_creature = 10;app.camp_type = "support_creature";app.camp_recipe = "shared_remedy";app.open_camp()
 elif mode == "remedy":
  setup_reward(63);app.game.heroes[0].hp = 2;app.game.heroes[1].hp = 3;app.game.hero_action(0)
 elif mode == "burden":
  setup_reward(65);app.game.heroes[0].round_history = [{"die":1,"face":4}];app.game.heroes[0].used[1] = true;app.game.hero_action(0)
 elif mode == "friendly":
  setup_reward(1);app.game.heroes[1].results[0] = 68;app.game.heroes[1].used[0] = true;app.game.heroes[1].reaction = [0];app.game.hero_action(0,1)
 elif mode == "evasive":
  setup_reward(68);app.game.heroes[0].used[0] = true;app.game.heroes[0].reaction = [0];app.game.pending = {"kind":"attack","action":"Test Attack","victims":[0],"reacted":[],"amount":1,"source":3,"range":1};app.game.continue_attack()
 app.inspect_actor = app.game.active;app.rebuild()
