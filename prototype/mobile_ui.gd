extends RefCounted
## Touch presentation for the same model; no separate battle/reward rules.
const Camp = preload("res://prototype/camp_ui.gd")
const E = preload("res://prototype/essence.gd")
const W = preload("res://prototype/wilds.gd")
const NAMES = ["Vesper","Rook","Wren"]
const GOLD = Color("e6c58c")
const MUTED = Color("a8b4bf")
const SOURCE_RECT = Rect2(24,128,716,716)

static func text(parent: Control, words: String, font_size: int = 22, tint: Color = MUTED) -> Label:
 var label := Label.new();label.text = words;label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 label.add_theme_font_size_override("font_size",font_size);label.add_theme_color_override("font_color",tint);label.size_flags_horizontal = Control.SIZE_EXPAND_FILL;parent.add_child(label);return label
static func btn(app, parent: Control, words: String, action: Callable, tint: Color = GOLD, disabled: bool = false) -> Button:
 var button: Button = app.button(words,Vector2.ZERO,Vector2(100,68),action,tint,disabled)
 button.mouse_filter = Control.MOUSE_FILTER_PASS;button.reparent(parent);button.position = Vector2.ZERO;button.custom_minimum_size = Vector2(0,68);button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;button.add_theme_font_size_override("font_size",22);return button
static func row(parent: Control) -> HBoxContainer:
 var line := HBoxContainer.new();line.add_theme_constant_override("separation",10);parent.add_child(line);return line
static func choose(app, parent: Control, caption: String, values: Array, index: int, action: Callable, node_name: String = "") -> OptionButton:
 text(parent,caption,18,GOLD)
 var pick := OptionButton.new();pick.mouse_filter = Control.MOUSE_FILTER_PASS;pick.custom_minimum_size = Vector2(0,68);pick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 if node_name != "":pick.name = node_name
 pick.add_theme_font_size_override("font_size",22)
 for value in values:pick.add_item(str(value))
 pick.select(maxi(0,index));pick.item_selected.connect(action,Object.CONNECT_DEFERRED);parent.add_child(pick)
 pick.get_popup().add_theme_font_size_override("font_size",22);pick.get_popup().add_theme_constant_override("v_separation",16);return pick
static func picture(parent: Control, texture: Texture2D) -> void:
 var icon := TextureRect.new();icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;icon.texture = texture;icon.custom_minimum_size = Vector2(96,96)
 icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;icon.mouse_filter = Control.MOUSE_FILTER_IGNORE;parent.add_child(icon)
static func footer(app, labels: Array, actions: Array, disabled: Array = []) -> void:
 var size: Vector2 = app.get_viewport_rect().size
 for i in range(labels.size()):
  var width := (size.x-24-(labels.size()-1)*8)/labels.size()
  var button: Button = app.button(str(labels[i]),Vector2(12+i*(width+8),size.y-76),Vector2(width,64),actions[i],GOLD,bool(disabled[i]) if i < disabled.size() else false)
  button.add_theme_font_size_override("font_size",20);button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
static func screen(app, heading: String, key: String) -> VBoxContainer:
 var size: Vector2 = app.get_viewport_rect().size
 var shade := ColorRect.new();shade.color = Color("101923");shade.size = size;shade.mouse_filter = Control.MOUSE_FILTER_IGNORE;app.ui.add_child(shade)
 app.label_at(heading,Vector2(16,12),32,GOLD,size.x-32,true,true)
 app.label_at("ASH & OATH · MOBILE · v0.36",Vector2(18,58),15,MUTED,size.x-36)
 var width: float = minf(720,size.x-24)
 var scroll := ScrollContainer.new();scroll.name = "MobileScroll";scroll.position = Vector2((size.x-width)/2,92);scroll.size = Vector2(width,size.y-180);scroll.follow_focus = true;scroll.scroll_deadzone = 14;app.ui.add_child(scroll)
 var column := VBoxContainer.new();column.name = "MobileContent";column.custom_minimum_size.x = width-16;column.size_flags_horizontal = Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",14);scroll.add_child(column)
 scroll.get_v_scroll_bar().value_changed.connect(func(value):app.mobile_scrolls[key] = int(value))
 scroll.set_deferred("scroll_vertical",int(app.mobile_scrolls.get(key,0)))
 return column
static func heroes(app, parent: Control, camp: bool) -> void:
 var tabs := row(parent)
 for hero in range(3):
  btn(app,tabs,NAMES[hero],func():
   if camp:app.camp_hero = hero
   else:app.build_hero = hero
   app.rebuild(),app.COLORS[hero] if (app.camp_hero if camp else app.build_hero) == hero else MUTED)
static func render(app) -> void:
 match app.page:
  "trials":app.TrialUI.render(app)
  "main":main_menu(app)
  "forge":
   if app.draft_modal:draft(app)
   else:forge(app)
  "camp":camp(app)
  "setup":setup(app)
  "events":events(app)
  "battle":battle(app)
 # A pending choice stays mandatory; optional panels never grant a combat action.
 if not app.combat_notices.is_empty() and app.rolling_time <= 0:
  if app.combat_notices[0].has("faces"):app.BattlePanels.engrave(app)
  else:modal(app,app.notice_ui)
  return
 if app.show_trial_guide:app.TrialUI.guide(app);return
 if app.show_collection:app.BattlePanels.collection(app);return
 if app.show_intents:app.BattlePanels.intents(app);return
 if app.mobile_more:more(app);return
 if app.shove_target>=0:shove(app);return
 if app.choosing_poke and app.rolling_time <= 0:modal(app,app.poke_ui);return
 if app.show_enemy_cards:
  if app.trial_fight:app.show_enemy_cards = false;app.show_trial_guide = true;app.TrialUI.guide(app)
  else:modal(app,app.enemy_cards_ui)
  return
 if app.show_soundtrack:modal(app,app.soundtrack_settings_ui);return
 if app.show_options:options(app);return
 if app.show_history:modal(app,app.history_ui);return
 if app.show_dice:modal(app,app.dice_ui);return
 if app.show_help:modal(app,app.help_ui);return
 if app.show_changes:modal(app,app.changes_ui);return
 if app.show_supplies:modal(app,app.supplies_ui);return
 if app.show_menu:menu(app);return
 if app.page == "battle":
  if app.game.outcome != "":
   if app.trial_fight:app.TrialUI.outcome(app)
   else:modal(app,app.outcome_ui)
   return
  if not app.game.pending.is_empty():
   if app.rolled_choice_pending():app.BattlePanels.picker(app)
   else:modal(app,app.pending_ui)
   return
 if app.mobile_info != "":info(app)

static func main_menu(app) -> void:
 var column := screen(app,"ASH & OATH","main")
 text(column,"Play on your phone",30,GOLD)
 text(column,"Tap a die, then tap its target. Menus scroll, and Details explains each ability without hovering.")
 btn(app,column,"Build your party",func():app.open_forge(app.gifts.any(func(list):return list.size() != 2))).name = "MobilePlay"
 btn(app,column,"Camp & Essence Forge",func():app.camp_tab = 0;app.open_camp()).name = "MobileCamp"
 btn(app,column,"Fight creatures",func():app.camp_tab = 3;app.open_camp()).name = "MobileCreatures"
 btn(app,column,"How to play",func():app.show_help = true;app.rebuild(),MUTED)
 btn(app,column,"What changed",func():app.show_changes = true;app.rebuild(),MUTED)
 btn(app,column,"Options",app.open_settings,MUTED)
 btn(app,column,"Desktop mode",func():app.set_mobile_mode(false),MUTED).name = "MobileDesktopMode"
 text(column,"Mobile mode saves on this device. Earned rewards use the same local save.",18)
 btn(app,column,"Trials · experimental expeditions",app.open_trials).name = "MobileTrials"
 footer(app,["Camp","Trials"],[app.open_camp,app.open_trials])

static func draft(app) -> void:
 var column := screen(app,"Choose bonus faces","draft-"+str(app.build_hero)+app.draft_category)
 heroes(app,column,false)
 text(column,"%s · %d / 2 chosen" % [NAMES[app.build_hero],app.gifts[app.build_hero].size()],25,GOLD)
 text(column,"Tap two different designs. They fit onto your dice automatically; you can edit individual sides afterwards.",20)
 var categories := ["All","Attack","Defense","Movement","Skill"]
 choose(app,column,"Show designs",categories,categories.find(app.draft_category),func(index):app.draft_category = categories[index];app.rebuild())
 for id in app.gifts[app.build_hero]:
  btn(app,column,"Remove · "+app.Catalog.name_for(id),func():app.choose_gift(id),app.color_for_face(id))
 if app.draft_error != "":text(column,app.draft_error,20,Color("efa898"))
 for id in app.Catalog.extended_ids():
  if app.draft_category != "All" and app.Catalog.category(id) != app.draft_category:continue
  if id in app.gifts[app.build_hero]:continue
  btn(app,column,app.Catalog.name_for(id)+"\n"+app.Catalog.classification(id),func():app.choose_gift(id),app.color_for_face(id),app.gifts[app.build_hero].size() >= 2).name = "MobileGift"+str(id)
  text(column,app.short_face_help(id),19)
 var complete: bool = app.gifts.all(func(list):return list.size() == 2)
 footer(app,["Menu","Edit dice","Fight / review" if complete else "Next hero"],[app.go_main,func():app.open_forge(false),func():app.finish_party_selection() if complete else app.confirm_gifts()],[false,false,app.gifts[app.build_hero].size() != 2])
static func forge(app) -> void:
 var column := screen(app,"Edit your dice","forge-"+str(app.build_hero)+str(app.forge_die));heroes(app,column,false)
 btn(app,column,"Choose bonus faces",func():app.draft_modal = true;app.rebuild())
 var dice := row(column)
 for die in range(3):btn(app,dice,"Die "+str(die+1),func():app.forge_die = die;app.rebuild(),GOLD if app.forge_die == die else MUTED)
 text(column,app.hint,20)
 var ids: Array = range(9)
 for id in range(60,E.FACE_COUNT):
  if app.expedition.camp.owned(id)>0:ids.append(id)
 ids.append_array(app.gifts[app.build_hero])
 for side in range(6):
  var face: int = app.builds[app.build_hero][app.forge_die][side]
  choose(app,column,"Side "+str(side+1),ids.map(func(id):return app.Catalog.display_name(id)),ids.find(face),func(index):app.forge_side = side;app.forge_replace(ids[index]))
  text(column,app.face_help(face),19)
 text(column,app.party_build_error(),20,Color("efa898"))
 btn(app,column,"Restore this hero’s starter dice",app.restore_hero_build,MUTED)
 btn(app,column,"Save build preset",app.save_preset,MUTED);btn(app,column,"Load build preset",app.load_preset,MUTED)
 footer(app,["Menu","Camp","Boss review"],[app.go_main,app.open_camp,app.open_setup])

static func camp(app) -> void:
 var column := screen(app,"Camp","camp-"+str(app.camp_tab)+app.camp_type+str(app.camp_hero))
 touch(app,"Collection",Vector2(app.get_viewport_rect().size.x-160,6),Vector2(148,48),func():app.show_collection = true;app.rebuild(),MUTED,false,"MobileCollection")
 var tabs := GridContainer.new();tabs.columns = 2;tabs.add_theme_constant_override("h_separation",10);tabs.add_theme_constant_override("v_separation",10);column.add_child(tabs)
 for i in range(4):btn(app,tabs,["Essence Forge","Refit dice","Equipment","Creatures"][i],func():app.camp_tab = i;app.rebuild(),GOLD if app.camp_tab == i else MUTED)
 text(column,app.camp_message,20,GOLD)
 match app.camp_tab:
  0:crafting(app,column)
  1:refit(app,column)
  2:equipment(app,column)
  3:
   for index in range(W.GROUPS.size()):
    var group: Dictionary = W.GROUPS[index]
    picture(column,app.CREATURE_SPRITES[group.enemy]);text(column,group.title,25,GOLD);text(column,group.description)
    text(column,group.reward,20,Color("9acfc0"));btn(app,column,"Fight this group",func():app.start_creature_encounter(index)).name = "MobileFight"+str(index)
 footer(app,["Menu","Party","Boss review"],[app.go_main,func():app.open_forge(false),app.open_setup])
static func crafting(app, column: Control) -> void:
 var types: Array = Camp.SPECIES
 choose(app,column,"Essence source",types.map(func(type):return E.type_name(type)+" · %d Essence" % int(app.expedition.camp.bank.get(type,0))),types.find(app.camp_type),func(index):app.camp_type = types[index];app.camp_recipe = app.expedition.camp.recipes_for(app.camp_type)[0];app.rebuild())
 if app.debug_mode:text(column,"Hold a locked design to unlock",18,GOLD)
 var recipes: Array = app.expedition.camp.recipes_for(app.camp_type)
 if app.camp_recipe not in recipes:app.camp_recipe = recipes[0]
 for key in recipes:
  var pick: Button = btn(app,column,app.expedition.camp.reward_name(key),func():app.camp_recipe = key;app.rebuild(),GOLD if app.camp_recipe == key else MUTED)
  pick.name = "MobileRecipe_"+key;app.bind_unlock(pick,"recipe",key,app.camp_hero)
 var recipe: Dictionary = E.RECIPES[app.camp_recipe]
 text(column,app.expedition.camp.reward_name(app.camp_recipe),26,GOLD);text(column,app.expedition.camp.reward_effect(app.camp_recipe));text(column,app.expedition.camp.recipe_progress(app.camp_recipe),20,GOLD)
 var already: bool = false
 if recipe.has("soul"):
  text(column,"Bind permanently to:",20,GOLD);heroes(app,column,true);already = recipe.soul in app.expedition.camp.souls[app.camp_hero]
 elif not recipe.has("face"):already = app.expedition.camp.unlocked.has(app.camp_recipe)
 else:text(column,"Owned %d · Equipped %d · Free %d" % [app.expedition.camp.owned(recipe.face),app.expedition.camp.allocated(app.builds,recipe.face),maxi(0,app.expedition.camp.owned(recipe.face)-app.expedition.camp.allocated(app.builds,recipe.face))],20)
 var caption: String = "Already owned" if already else ("Bind to "+NAMES[app.camp_hero] if recipe.has("soul") else "Craft / add one party copy")
 btn(app,column,caption,func():app.craft_recipe(app.camp_recipe),GOLD,already or int(app.expedition.camp.bank.get(app.camp_type,0)) < recipe.cost or not app.expedition.camp.discovered(app.camp_type))
static func refit(app, column: Control) -> void:
 heroes(app,column,true)
 var keys: Array = E.RECIPES.keys().filter(func(key):return E.RECIPES[key].has("face") and app.expedition.camp.unlocked.has(key))
 if keys.is_empty():text(column,"Craft a face in the Essence Forge first.");return
 if app.camp_recipe not in keys:app.camp_recipe = keys[0]
 choose(app,column,"Owned face",keys.map(func(key):return app.expedition.camp.reward_name(key)+" ×%d" % app.expedition.camp.owned(E.RECIPES[key].face)),keys.find(app.camp_recipe),func(index):app.camp_recipe = keys[index];app.rebuild())
 text(column,app.expedition.camp.reward_effect(app.camp_recipe),20)
 btn(app,column,"Return crafted faces" if app.camp_remove_mode else "Place selected face",func():app.camp_remove_mode = not app.camp_remove_mode;app.rebuild())
 var dice := row(column)
 for die in range(3):btn(app,dice,"Die "+str(die+1),func():app.forge_die = die;app.rebuild(),GOLD if app.forge_die == die else MUTED)
 for side in range(6):
  var face: int = app.builds[app.camp_hero][app.forge_die][side]
  btn(app,column,"Side %d · %s" % [side+1,app.Catalog.name_for(face)],func():
   if app.camp_remove_mode:app.camp_remove(app.camp_hero,app.forge_die,side)
   else:app.camp_place(E.RECIPES[app.camp_recipe].face,app.camp_hero,app.forge_die,side),app.color_for_face(face))
static func equipment(app, column: Control) -> void:
 heroes(app,column,true);var hero: int = app.camp_hero
 text(column,"Body · Broken Body",25,GOLD)
 text(column,"%d HP · at least %d Blanks per die. Existing category and ownership limits apply." % [app.balance_number("hero.hp"),app.balance_number("body.blanks")],20)
 choose(app,column,"Weapon",["None","Dagger · Poke"],1 if app.expedition.camp.weapons[hero] == "dagger" else 0,func(index):app.expedition.camp.equip_weapon(hero,"dagger" if index == 1 else "");app.expedition.save();app.rebuild())
 var souls: Array = [""]+app.expedition.camp.souls[hero]
 choose(app,column,"Soul",souls.map(func(key):return W.soul_name(key)),souls.find(app.expedition.camp.equipped_souls[hero]),func(index):app.expedition.camp.equip_soul(hero,souls[index]);app.expedition.save();app.rebuild()).name = "MobileSoulPicker"
 var soul: String = app.expedition.camp.equipped_souls[hero]
 if Camp.NEW_SOUL_ART.has(soul):picture(column,Camp.NEW_SOUL_ART[soul])
 elif soul in ["beginning","hollow","ashroad"]:
  var icon := AtlasTexture.new();icon.atlas = Camp.ITEM_ART;icon.region = Rect2(["beginning","hollow","ashroad"].find(soul)*16,0,16,16);picture(column,icon)
 text(column,W.SOULS[soul].effect if W.SOULS.has(soul) else ("Spend one rolled Blank as Move 1, once per own turn." if soul == "beginning" else "Spend one rolled Blank as Move 2, once per own turn." if soul != "" else "No Soul equipped."),20)
 var memories: Array = [""]+app.expedition.camp.memory_keys().filter(func(key):return app.expedition.camp.unlocked.has(key))
 choose(app,column,"Memory",memories.map(func(key):return "None" if key == "" else app.expedition.camp.reward_name(key)),memories.find(app.expedition.camp.memories[hero]),func(index):
  var old: String = app.expedition.camp.memories[hero]
  if index>0:app.expedition.camp.equip_memory(hero,memories[index])
  elif old != "":app.expedition.camp.equip_memory(-1,old)
  app.expedition.save();app.rebuild())
 btn(app,column,"Souls & Memories",func():app.show_collection = true;app.rebuild(),GOLD)

static func setup(app) -> void:
 var column := screen(app,"Boss & rules","setup")
 var keys := ["hollow","nugh","cantor","bugh"];var names := ["The Hollow","Nu’gh · Worm Summoner","Veyl · Brass Cantor","Bu’gh · Iron Warden"]
 for i in range(4):btn(app,column,("Selected · " if app.encounter == keys[i] else "Choose · ")+names[i],func():app.encounter = keys[i];app.rebuild(),GOLD if app.encounter == keys[i] else MUTED)
 choose(app,column,"Numbers",["Tuned","Original"],0 if app.balanced else 1,func(index):app.balanced = index == 0;app.rebuild())
 choose(app,column,"Sandbox Blank movement",["Use equipped Souls","Override · Move 1","Override · Move 2"],int(app.balance_number("soul.move")) if app.reward_soul else 0,func(index):
  app.reward_soul = index > 0
  if index > 0:app.balance_values["soul.move"] = index
  app.rebuild())
 text(column,"An event must be resolved before the boss. Your party starts each encounter with fresh HP and its prepared dice.")
 var error: String = app.party_build_error();text(column,error,20,Color("efa898"))
 footer(app,["Party","Camp","Begin expedition"],[func():app.open_forge(true),app.open_camp,app.start_expedition],[false,false,error != ""])
static func events(app) -> void:
 var column := screen(app,"The Ash Road","events-"+app.expedition.stage)
 text(column,app.expedition.inventory(),20,Color("9acfc0"))
 if app.expedition.stage == "idle":
  text(column,"Roll one event before the boss. Read its costs, chances and rewards before choosing.")
  for i in range(6):text(column,"%d · %s" % [i+1,app.Expedition.TITLES[i]],20)
  btn(app,column,"Roll event · d6",func():app.expedition.roll();app.rebuild()).name = "MobileRollEvent"
 else:
  text(column,"%d · %s" % [app.expedition.selected,app.Expedition.TITLES[app.expedition.selected-1]],26,GOLD)
  text(column,app.Expedition.DETAILS[app.expedition.selected-1] if app.expedition.stage == "choice" else app.expedition.summary)
  if app.expedition.stage == "choice":
   var choices: Array = [["Take 1 Salve","Take 1 Reroll Seal"],["Leave safely","Offer 2 Gold · d6"],["Directions · gain 1 Gold","Help · spend 1 Salve"],["Withdraw safely","Fight 2 Bone Creatures"],["Leave safely","Fight mixed creature group"],["Take 1 Gold","Search deeper · d6"]][app.expedition.selected-1]
   for option in range(2):
    var locked: bool = option == 1 and ((app.expedition.selected == 2 and app.expedition.gold < 2) or (app.expedition.selected == 3 and app.expedition.salves < 1))
    btn(app,column,choices[option],func():app.event_choice(option),GOLD,locked).name = "MobileEventChoice"+str(option)
  else:
   btn(app,column,"Enter selected boss",app.enter_boss).name = "MobileEnterBoss"
   btn(app,column,"New sortie · new event",func():app.expedition.next_sortie();app.rebuild(),MUTED)
 choose(app,column,"Fragment Soul recipient",NAMES,app.event_soul_hero,func(index):app.event_soul_hero = index;app.rebuild())
 btn(app,column,"Spend 3 Fragments · bind Soul",func():app.expedition.unlock_soul(app.event_soul_hero);app.rebuild(),GOLD,app.expedition.fragments < 3 or app.expedition.soul)
 footer(app,["Menu","Camp","Boss review"],[app.go_main,app.open_camp,app.open_setup])

static func board_rect(app) -> Rect2:
 var size: Vector2 = app.get_viewport_rect().size
 if size.x > size.y:
  var edge: float = minf(size.y-102,size.x*0.45)
  return Rect2(8,94,edge,edge)
 var edge: float = minf(size.x-16,size.y-442)
 return Rect2((size.x-edge)/2,208+maxf(0,(size.y-442-edge)/2),edge,edge)
static func board_point(app, at: Vector2) -> Vector2:
 var rect := board_rect(app);return SOURCE_RECT.position+(at-rect.position)*(SOURCE_RECT.size.x/rect.size.x)
static func touch(app, caption: String, at: Vector2, size: Vector2, action: Callable, tint: Color = GOLD, disabled: bool = false, name: String = "") -> Button:
 var pick: Button = app.button(caption,at,size,action,tint,disabled)
 pick.add_theme_font_size_override("font_size",20);pick.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 if name != "":pick.name = name
 return pick
static func battle(app) -> void:
 var size: Vector2 = app.get_viewport_rect().size;var landscape: bool = size.x > size.y
 var board := board_rect(app);var x: float = board.end.x+12 if landscape else 12
 var width: float = size.x-x-12
 var active: int = app.game.active
 var actor: String = "Enemies" if app.trial_fight and active==3 else app.game.unit_name(active)
 var heading: String = actor+" · R"+str(app.game.round_no)
 if app.trial_fight:heading += " · %d Essence" % int(app.game.trial_state.get("purse",0))
 app.label_at(heading,Vector2(12,8),19 if app.trial_fight else 23,GOLD,board.size.x if landscape else size.x-24,true)
 var party_width: float = board.size.x if landscape else size.x-24
 for hero in range(3):
  var h: Dictionary = app.game.heroes[hero];var w: float = (party_width-12)/3
  var b := touch(app,NAMES[hero]+"\n%d HP · %d Block" % [h.hp,h.block],Vector2(12+hero*(w+6),38),Vector2(w,48),func():app.mobile_info = NAMES[hero]+"\n"+app.game.status_description(hero);app.rebuild(),app.COLORS[hero])
  b.add_theme_font_size_override("font_size",13)
 var enemies: Array = app.game.enemy_intents()
 var sources: Array = []
 for entry in enemies:
  if entry.source not in sources:sources.append(entry.source)
 if app.mobile_enemy not in sources:app.mobile_enemy = sources[0] if not sources.is_empty() else 3
 var enemy: Dictionary = app.game.unit_data(app.mobile_enemy)
 var enemy_x: float = x if landscape else 12
 var enemy_y: float = 8 if landscape else 92
 var enemy_width: float = width if landscape else size.x-24
 var stat := touch(app,app.game.unit_name(app.mobile_enemy)+" · %d HP · %d Block" % [enemy.hp,enemy.block],Vector2(enemy_x,enemy_y),Vector2(enemy_width,44),func():app.intent_focus = Vector2i(app.mobile_enemy,maxi(0,mini(2,app.game.boss_visible_index())));app.show_intents = true;app.rebuild(),Color("a9cbe8"),false,"EnemyStatsButton")
 stat.add_theme_font_size_override("font_size",20)
 var intents: Array = enemies.filter(func(entry):return entry.source == app.mobile_enemy)
 for i in range(intents.size()):
  var entry: Dictionary = intents[i];var w: float = (enemy_width-16)/3
  var b := touch(app,entry.action,Vector2(enemy_x+i*(w+8),64 if landscape else 144),Vector2(w,60),func():app.intent_focus = Vector2i(entry.source,entry.slot);app.show_intents = true;app.rebuild(),app.BattlePanels.intent_color(entry.action),false,"EnemyIntent"+str(i))
  b.add_theme_font_size_override("font_size",16)
  if active == 3 and i == app.game.boss_visible_index():b.add_theme_stylebox_override("normal",app.style(Color("303c4b"),GOLD))
 if app.trial_fight:app.trial_objective_button()
 var die_y: float = size.y-228
 if active < 3:
  var h: Dictionary = app.game.heroes[active]
  if app.trial_fight and not app.trial_choice.is_empty():
   app.setup_panel(Rect2(x,die_y,width,82),Color("b7d2ef"))
   var forecast: Label = app.label_at(app.trial_choice.forecast.text,Vector2(x+10,die_y+8),16,Color("e5e8e9"),width-20,false,true)
   forecast.name = "TrialForecast";forecast.max_lines_visible = 3;forecast.clip_text = true;forecast.tooltip_text = app.trial_choice.forecast.text
  else:
   for die in range(3):
    var face: int = app.game.face(active,die);var w: float = (width-16)/3
    var b := touch(app,app.Catalog.name_for(face),Vector2(x+die*(w+8),die_y),Vector2(w,82),func():app.mobile_die = die;app.select_combat_die(die),app.color_for_face(face),not app.game.pending.is_empty() or app.game.outcome != "" or h.dead or h.hp<=0,"MobileDie"+str(die))
    if h.used[die] and die not in h.reaction and (h.channel.is_empty() or h.channel.die != die):app.mark_spent(b)
    elif app.selected == die:b.add_theme_stylebox_override("normal",app.style(Color("293747"),app.color_for_face(face)))
  var action_y: float = size.y-138;var w: float = (width-16)/3
  touch(app,"Cancel" if app.trial_fight and not app.trial_choice.is_empty() else "Details",Vector2(x,action_y),Vector2(w,60),func():
   if app.trial_fight and not app.trial_choice.is_empty():app.trial_choice.clear();app.rebuild()
   else:app.show_mobile_details(),MUTED,false,"MobileDetails")
  touch(app,"Reroll",Vector2(x+w+8,action_y),Vector2(w,60),func():
   app.friendly_confirm = -1
   if app.selected >= 0 and app.game.reroll_reason(app.selected) == "":app.perform_reroll(app.selected)
   else:app.choosing_reroll = true;app.selected = -1;app.rebuild(),GOLD,app.game.reroll_window_reason() != "","MobileReroll")
  var immediate: bool = app.selected >= 0 and not h.used[app.selected] and app.game.face(active,app.selected) in [0,4,9,10,11,13,14,16,17,18,20,21,22,23,24,25,26,27,29,30,31,32,33,42,43,47,49,50,51,52,54,56,60,62,63,64,65,71,72]
  if app.selected >= 0 and app.game.face(active,app.selected) == 0:immediate = not app.game.reward or app.game.soul_remaining(active)<=0 or app.game.soul_mode(active) in ["heal","block"]
  if app.selected >= 0 and app.game.face(active,app.selected) == 59 and app.game.owned_worm(active)>=0:immediate = true
  var trial_ready: bool = app.trial_fight and not app.trial_choice.is_empty()
  touch(app,"Confirm" if trial_ready else "Confirm hit" if app.friendly_confirm>=0 else "Use" if immediate else "Target",Vector2(x+2*(w+8),action_y),Vector2(w,60),func():
   if app.trial_fight and not app.trial_choice.is_empty():app.confirm_trial_choice();return
   var target: int = app.friendly_confirm;app.friendly_confirm = -1
   if app.game.hero_action(app.selected,target):app.selected = -1;app.roll_feedback = {}
   app.rebuild(),GOLD,not trial_ready and not immediate and app.friendly_confirm<0,"MobileResolve")
  if app.trial_fight and app.selected>=0 and app.game.face(active,app.selected) in [73,74] and not trial_ready:
   var reason: String = app.Model.TrialRules.weapon_reason(app.game,app.game.face(active,app.selected))
   if reason!="":
    var note: Label = app.label_at(reason,Vector2(x,die_y-27),14,Color("efba99"),width,false,true)
    note.name = "TrialWeaponRequirement";note.max_lines_visible = 1;note.clip_text = true
  touch(app,"More",Vector2(x,size.y-70),Vector2(width*.32-4,60),func():app.mobile_more = true;app.rebuild(),MUTED,false,"MobileMore")
  touch(app,"End turn",Vector2(x+width*.32+4,size.y-70),Vector2(width*.68-4,60),func():app.friendly_confirm = -1;app.game.finish_turn();app.selected = -1;app.rebuild(),GOLD,not app.game.pending.is_empty() or app.game.outcome != "","MobileEndTurn")
 else:
  var current: String = app.game.boss_display_action()
  var finished: bool = app.game.boss_visible_index()>=3 and not (app.game.encounter_id == "nugh" and bool(app.game.get("command_active")))
  if finished:app.label_at("Turn complete",Vector2(x,die_y+22),25,GOLD,width,true)
  else:touch(app,current,Vector2(x,die_y),Vector2(width,82),func():app.mobile_info = app.game.boss_help("Crushing Sweep" if current.begins_with("Crushing Sweep") else current);app.rebuild(),app.BattlePanels.intent_color(current),false,"CurrentEnemyAbility")
  touch(app,"More",Vector2(x,size.y-70),Vector2(width*.32-4,60),func():app.mobile_more = true;app.rebuild(),MUTED,false,"MobileMore")
  touch(app,"End enemy turn" if finished else "Next action",Vector2(x+width*.32+4,size.y-70),Vector2(width*.68-4,60),func():app.game.boss_step();app.selected = -1;app.rebuild(),GOLD,not app.game.pending.is_empty() or app.game.outcome != "","MobileEnemyStep")
static func more(app) -> void:
 var column: VBoxContainer = app.BattlePanels.panel(app,"Actions","")
 var grid := GridContainer.new();grid.columns = 2;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);column.add_child(grid)
 if app.trial_fight:btn(app,grid,"Equipment & arena help",func():app.mobile_more = false;app.show_trial_guide = true;app.rebuild(),GOLD)
 if app.trial_fight and not app.trial_choice.is_empty():btn(app,grid,"Forecast details",func():app.mobile_info = app.trial_choice.forecast.text;app.mobile_more = false;app.rebuild(),GOLD)
 btn(app,grid,"Poke",func():app.mobile_more = false;app.choosing_poke = true;app.rebuild(),GOLD,app.game.poke_targets().is_empty())
 btn(app,grid,"Skip face",func():app.game.decline(app.selected);app.friendly_confirm = -1;app.selected = -1;app.mobile_more = false;app.rebuild(),MUTED,app.selected<0)
 for item in [["Log","show_history"],["Enemies","show_enemy_cards"],["Supplies","show_supplies"],["Menu","show_menu"]]:
  btn(app,grid,item[0],func():app.mobile_more = false;app.set(item[1],true);app.rebuild(),MUTED)
 footer(app,["Back"],[func():app.mobile_more = false;app.rebuild()])
static func shove(app) -> void:
 var column: VBoxContainer = app.BattlePanels.panel(app,"Push","")
 var grid := GridContainer.new();grid.columns = 2;column.add_child(grid)
 for i in range(4):
  var direction: Vector2i = app.Model.DIRS[i]
  btn(app,grid,["North","East","South","West"][i],func():
   if app.trial_fight:
    var target: int = app.shove_target;app.shove_target = -1;app.stage_trial_choice(target,direction);return
   if app.game.hero_action(app.selected,app.shove_target,direction):app.selected = -1
   app.shove_target = -1;app.rebuild(),GOLD,direction not in app.game.away_dirs(app.game.active,app.shove_target))
 footer(app,["Back"],[func():app.shove_target = -1;app.rebuild()])

static func reflow(node: Control) -> void:
 node.custom_minimum_size.x = 0;node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 if node is BaseButton:
  node.mouse_filter = Control.MOUSE_FILTER_PASS
  # Let touch propagation finish before a choice rebuilds its parent panel.
  var signal_name: StringName = &"item_selected" if node is OptionButton else &"pressed"
  for connection in node.get_signal_connection_list(signal_name):
   if int(connection.flags) & Object.CONNECT_DEFERRED:continue
   node.disconnect(signal_name,connection.callable);node.connect(signal_name,connection.callable,int(connection.flags)|Object.CONNECT_DEFERRED)
  node.custom_minimum_size.y = maxf(68,node.custom_minimum_size.y)
  node.add_theme_font_size_override("font_size",22)
  if node is Button:node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  if node is OptionButton:
   node.get_popup().add_theme_font_size_override("font_size",22);node.get_popup().add_theme_constant_override("v_separation",16)
 elif node is Label:
  node.custom_minimum_size.y = 0;node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;node.clip_text = false;node.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING;node.max_lines_visible = -1;node.add_theme_font_size_override("font_size",22)
 elif node is RichTextLabel:
  node.mouse_filter = Control.MOUSE_FILTER_PASS;node.custom_minimum_size.y = 0;node.fit_content = true;node.scroll_active = false;node.add_theme_font_size_override("normal_font_size",22)
 elif node is ScrollContainer:node.custom_minimum_size.y = 280
 elif node is TextureRect:node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;node.custom_minimum_size.y = 96;node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 elif node is Range:node.custom_minimum_size.y = 64
 if node is GridContainer:node.columns = 1
 for child in node.get_children():
  if child is Control:reflow(child)
static func modal(app, renderer: Callable) -> void:
 var begin: int = app.ui.get_child_count();renderer.call();var nodes: Array = app.ui.get_children().slice(begin)
 var size: Vector2 = app.get_viewport_rect().size
 var shade := ColorRect.new();shade.name = "MobileModalShade";shade.color = Color("101923");shade.size = size;app.ui.add_child(shade)
 var scroll := ScrollContainer.new();scroll.name = "MobileModal";scroll.position = Vector2(12,12);scroll.size = size-Vector2(24,24);scroll.scroll_deadzone = 14;app.ui.add_child(scroll)
 var column := VBoxContainer.new();column.custom_minimum_size.x = size.x-42;column.size_flags_horizontal = Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",16);scroll.add_child(column)
 for node in nodes:
  if node is ColorRect or node is Panel:app.ui.remove_child(node);node.queue_free();continue
  if not node is Control:continue
  node.reparent(column);node.position = Vector2.ZERO;reflow(node)
 # Keep optional-panel exits reachable even while a long document is scrolled.
 for child in column.get_children():
  if child is Button and child.text in ["Back","Back to battle","Back to game","Return to the game","Return to battle","Cancel"]:
   child.reparent(app.ui);child.position = Vector2(12,size.y-80);child.size = Vector2(size.x-24,68);scroll.size.y = size.y-104;break
static func info(app) -> void:
 modal(app,func():
  app.label_at(app.mobile_info,Vector2.ZERO,22,MUTED,420,false,true)
  app.button("Back",Vector2.ZERO,Vector2(420,68),func():app.mobile_info = "";app.show_collection = app.info_return_collection;app.info_return_collection = false;app.rebuild()))
static func menu(app) -> void:
 if app.trial_fight:app.TrialUI.menu(app);return
 modal(app,func():
  app.label_at("Game menu",Vector2.ZERO,28,GOLD)
  app.button("Return to battle",Vector2.ZERO,Vector2(400,68),func():app.show_menu = false;app.rebuild())
  for item in [["Enemy intents","show_intents"],["Enemy cards","show_enemy_cards"],["Full battle log","show_history"],["View dice","show_dice"],["Supplies","show_supplies"],["Rules","show_help"],["Sound & volume","show_soundtrack"],["Options","show_options"]]:
   app.button(item[0],Vector2.ZERO,Vector2(400,68),func():app.show_menu = false;app.set(item[1],true);app.rebuild())
  app.button("Main menu · leave encounter",Vector2.ZERO,Vector2(400,68),app.go_main))
static func options(app) -> void:
 if app.trial_fight:app.TrialUI.options(app);return
 modal(app,func():
  app.label_at("Options",Vector2.ZERO,28,GOLD)
  app.button("Debug unlocks: "+("On" if app.debug_mode else "Off"),Vector2.ZERO,Vector2(420,68),func():app.set_debug_mode(not app.debug_mode))
  app.button("Action Rerolls: "+("Any time" if app.balance_number("hero.reroll_anytime") else "Opening only"),Vector2.ZERO,Vector2(420,68),func():
   var value: int = 0 if app.balance_number("hero.reroll_anytime") else 1
   app.balance_values["hero.reroll_anytime"] = value
   if app.page == "battle":app.game.balance["hero.reroll_anytime"] = value
   app.rebuild())
  app.button("Sandbox Blank movement: "+("On" if app.reward_soul else "Off"),Vector2.ZERO,Vector2(420,68),func():app.set_soul_enabled(not app.reward_soul))
  app.button("Sound & volume",Vector2.ZERO,Vector2(420,68),func():app.show_soundtrack = true;app.rebuild())
  app.button("Desktop mode",Vector2.ZERO,Vector2(420,68),func():app.show_options = false;app.set_mobile_mode(false))
  app.button("Restart party · main menu",Vector2.ZERO,Vector2(420,68),app.restart_to_menu)
  app.button("Back",Vector2.ZERO,Vector2(420,68),func():app.show_options = false;app.rebuild()))
