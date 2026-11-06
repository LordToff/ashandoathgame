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
func mobile_controls(node: Node, list: Array):
 if node is Control and (node is BaseButton or node is ScrollContainer):
  var rect: Rect2 = node.get_global_rect()
  var clip := Rect2(Vector2.ZERO,app.get_viewport_rect().size)
  var ancestor: Node = node.get_parent()
  while ancestor != null:
   if ancestor is ScrollContainer:clip = clip.intersection(ancestor.get_global_rect())
   ancestor = ancestor.get_parent()
  list.append({"clip":[clip.position.x,clip.position.y,clip.size.x,clip.size.y],"name":str(node.name),"text":node.text if node is Button else "", "x":rect.position.x,"y":rect.position.y,"w":rect.size.x,"h":rect.size.y,"disabled":node.disabled if node is BaseButton else false})
 for child in node.get_children():mobile_controls(child,list)
func reset_ui():
 app.trial_fight = false;app.show_trial_guide = false;app.trial_view = "run"
 app.show_collection = false;app.mobile_more = false;app.debug_hold.clear();app.show_intents = false;app.choice_preview = Vector2i(-1,-1);app.status_sounds.clear();app.status_cooldown = 0;app.choosing_reroll = false;app.mobile_info = "";app.mobile_scrolls.clear()
 app.dice_tray.cancel();app.rolling_time = 0;app.choosing_poke = false;app.creature_fight = false;app.camp_tab = 0;app.show_enemy_cards = false;app.show_menu = false;app.show_options = false;app.show_history = false;app.show_supplies = false;app.show_soundtrack = false;app.draft_modal = false;app.lab = false;app.training = false;app.event_fight = false;app.combat_notices.clear();app.selected = -1
 app.gifts = [[34,47],[34,47],[34,47]];app.builds = [B.bonus_build([34,47]),B.bonus_build([34,47]),B.bonus_build([34,47])]
 app.seen_event = 0;app.seen_roll = 0;app.roll_seen = 0;app.effects.clear();app.snapshots.clear();app.visual_positions.clear()
func setup_reward(face: int):
 app.game = B.new();app.game.start(app.builds,27,false,true,app.camp_battle_profile());app.game.active = 0;app.game.cursor = app.game.order.find(0);app.game.pending = {};app.game.forced_die = -1;app.page = "battle"
 for h in app.game.heroes:h.results = [face,1,0];h.used = [false,false,false];h.reaction = [];h.rolls = [0,0,0]
 app.game.heroes[0].pos = Vector2i(2,3);app.game.heroes[1].pos = Vector2i(1,3);app.game.heroes[2].pos = Vector2i(0,3)
func setup_clarity(face: int):
 setup_reward(face);app.roll_seen = app.game.roll_presentations.size();app.seen_event = app.game.event_id
func proof(args):
 var mode: String = str(args[0])
 if mode == "state":
  var data := {"rolling":app.dice_tray.busy,"bank":app.expedition.camp.bank,"copies":app.expedition.camp.copies,"memories":app.expedition.camp.memories,"active":app.game.active,"page":app.page,"builds":app.builds,"weapons":app.expedition.camp.weapons,"souls":app.expedition.camp.souls,"equipped_souls":app.expedition.camp.equipped_souls}
  var controls: Array = [];mobile_controls(app.ui,controls);data.controls = controls;data.viewport = [app.get_viewport_rect().size.x,app.get_viewport_rect().size.y];data.mobile = app.mobile_mode;data.board = [app.MobileUI.board_rect(app).position.x,app.MobileUI.board_rect(app).position.y,app.MobileUI.board_rect(app).size.x,app.MobileUI.board_rect(app).size.y];data.debug = app.debug_mode;data.unlocked = app.expedition.camp.unlocked;data.collection = app.show_collection;data.enemy_block = app.game.boss.get("block",0) if app.game.heroes.size()==3 else 0;data.intents = app.game.enemy_intents() if app.game.heroes.size()==3 else [];data.sfx = app.status_sounds;data.effects = app.effects.map(func(f):return f.kind);data.notices = app.combat_notices;data.selected = app.selected;data.pending = app.game.pending;data.feedback_playing = app.feedback_audio.playing;data.feedback_kind = app.feedback_streams.find_key(app.feedback_audio.stream);data.live_builds = app.game.heroes.map(func(h):return h.build);data.results = app.game.heroes.map(func(h):return h.results)
  if app.game.heroes.size() == 3:data.hp = app.game.heroes.map(func(h):return h.hp);data.block = app.game.heroes.map(func(h):return h.block);data.positions = app.game.heroes.map(func(h):return [h.pos.x,h.pos.y]);data.dagger_used = app.game.heroes.map(func(h):return h.get("dagger_used",false));data.used = app.game.heroes.map(func(h):return h.used);data.boss_hp = app.game.boss.hp
  data.trial = {"phase":app.trials.phase,"stage":app.trials.stage,"essence":app.trials.essence,"paths":app.trials.paths,"souls":app.trials.souls,"completed":app.trials.completed_bosses,"builds":app.trials.builds,"hp":app.trials.hp,"mods":app.trials.mods,"view":app.trial_view,"fight":app.trial_fight}
  data.terrain = app.game.trial_state
  data.popups = []
  for control in app.ui.find_children("*","OptionButton",true,false):
   var popup: PopupMenu = control.get_popup()
   if popup.visible:
    var panel: StyleBox = popup.get_theme_stylebox("panel")
    data.popups.append({"control":str(control.name),"x":popup.position.x,"y":popup.position.y,"w":popup.size.x,"h":popup.size.y,"top":panel.get_margin(SIDE_TOP),"bottom":panel.get_margin(SIDE_BOTTOM),"items":range(popup.item_count).map(func(index):return popup.get_item_text(index))})
  JavaScriptBridge.get_interface("window").essenceState = JSON.stringify(data);return
 reset_ui()
 if mode=="trials_main":
  app.trials = app.Trials.new(false);app.go_main()
 elif mode=="trials_debug":
  app.trials = app.Trials.new(false);app.debug_mode = true;app.page = "trials";app.trial_view = "guide"
 elif mode=="trials_reward":
  app.trials = app.Trials.new(false);app.trials.start(34);app.trials.choose(0);app.trials.phase = "reward";app.trials.essence = 7;app.trials.message = "Choose a reward";app.page = "trials"
 elif mode=="trials_crates":
  app.trials = app.Trials.new(false);app.trials.start(34);app.trials.choose(0);app.start_trial_battle();app.game.pending = {};app.game.active = 0;app.game.cursor = app.game.order.find(0);app.game.heroes[0].pos = Vector2i(2,6);app.game.heroes[0].results = [1,4,2];app.game.heroes[0].used = [false,false,false];app.game.heroes[0].reaction = [];app.game.trial_state.crates = [Vector2i(2,5),Vector2i(6,5)];app.game.trial_state.cover = [];app.game.trial_state.spikes = [];app.seen_event = app.game.event_id;app.roll_seen = app.game.roll_presentations.size()
 elif mode=="trials_charge":
  app.trials = app.Trials.new(false);app.trials.start(34);app.trials.choose(0);app.start_trial_battle();app.game.pending = {};app.game.active = 0;app.game.heroes[0].pos = Vector2i(3,6);app.game.trial_state.charges = [{"source":3,"tiles":[Vector2i(3,5),Vector2i(3,6),Vector2i(3,7)]}];app.seen_event = app.game.event_id;app.roll_seen = app.game.roll_presentations.size()
 elif mode=="trials_win":
  app.trials = app.Trials.new(false);app.trials.start(34);app.trials.choose(0);app.start_trial_battle();app.game.pending = {}
  for id in range(3,app.game.unit_count()):
   if not app.game.friendly(id):app.game.damage(id,999,true)
 elif mode=="trials_boss_win":
  app.trials = app.Trials.new(false);app.trials.start(34);app.trials.stage = 5;app.trials.choose(0);app.start_trial_battle();app.game.damage(3,999,true)
 elif mode == "flow_player":
  setup_clarity(2)
  for hero in range(3):app.game.heroes[hero].pos=Vector2i(hero*3,7)
  app.game.boss.block=4
 elif mode == "flow_enemy":
  setup_clarity(2);app.game.active=3;app.game.order=[3,0,1,2];app.game.cursor=0;app.game.boss_index=0;app.game.boss_rolls=["Brace","Brace","Brace"];app.game.boss.block=4
 elif mode == "flow_debug":
  app.expedition.camp=E.new();app.debug_mode=false;app.camp_hero=0;app.camp_tab=2;app.open_camp();app.show_collection=true
 elif mode == "flow_boss_forge":
  app.expedition.camp=E.new();app.camp_type="hollow";app.camp_recipe="ember_cut";app.essence_page=2;app.camp_tab=0;app.open_camp()
 elif mode == "flow_boss_win":
  app.expedition.camp=E.new();setup_clarity(1);app.game.damage(3,999,true)
 elif mode == "clarity_borrow":
  setup_clarity(16);app.game.heroes[1].results = [4,1,6];app.game.heroes[1].used = [true,false,false];app.game.heroes[2].results=[7,2,0];app.game.hero_action(0)
 elif mode == "clarity_engrave":
  setup_clarity(41);app.game.heroes[0].pos = Vector2i(3,5);app.game.heroes[0].build[0] = [41,1,0,0,0,0];app.game.heroes[0].stored_num = 1;app.game.hero_action(0,3)
 elif mode == "clarity_poison":
  setup_clarity(1);app.game.heroes[0].poison=2;app.game.tick_poison(0)
 elif mode == "clarity_heal":
  setup_clarity(1);app.game.heroes[0].hp=2;app.game.heal(0,2)
 elif mode == "clarity_stun":
  setup_clarity(1);app.game.heroes[0].stun=true
 elif mode == "clarity_intents":
  setup_clarity(1);app.game.boss_rolls=["Smoking Strike","Ashen Chain","Cinder Brand"];app.game.heroes[0].hp=2;app.game.heroes[1].block=4;app.game.heroes[2].damage_last_round=7;app.show_intents=true
 elif mode == "mobile_main":
  app.gifts = [[],[],[]];app.builds = [B.default_build(),B.default_build(),B.default_build()];app.go_main()
 elif mode == "mobile_move":
  app.expedition.camp = E.new();setup_reward(2)
  for hero in range(3):app.game.heroes[hero].pos = Vector2i(hero*3,7)
 elif mode == "wilds_camp":
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
