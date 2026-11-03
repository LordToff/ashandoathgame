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
 app.label_at("ASH & OATH · MOBILE · v0.31",Vector2(18,58),15,MUTED,size.x-36)
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
  "main":main_menu(app)
  "forge":
   if app.draft_modal:draft(app)
   else:forge(app)
  "camp":camp(app)
  "setup":setup(app)
  "events":events(app)
  "battle":battle(app)
 # A pending choice stays mandatory; optional panels never grant a combat action.
 if not app.combat_notices.is_empty() and app.rolling_time <= 0:modal(app,app.notice_ui);return
 if app.choosing_poke and app.rolling_time <= 0:modal(app,app.poke_ui);return
 if app.show_enemy_cards:modal(app,app.enemy_cards_ui);return
 if app.show_soundtrack:modal(app,app.soundtrack_settings_ui);return
 if app.show_options:options(app);return
 if app.show_history:modal(app,app.history_ui);return
 if app.show_dice:modal(app,app.dice_ui);return
 if app.show_help:modal(app,app.help_ui);return
 if app.show_changes:modal(app,app.changes_ui);return
 if app.show_supplies:modal(app,app.supplies_ui);return
 if app.show_menu:menu(app);return
 if app.page == "battle":
  if app.game.outcome != "":modal(app,app.outcome_ui);return
  if not app.game.pending.is_empty():modal(app,app.pending_ui);return
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
 footer(app,["Camp","Creatures"],[app.open_camp,func():app.camp_tab = 3;app.open_camp()])

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
 for id in range(60,69):
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
 var recipes: Array = app.expedition.camp.recipes_for(app.camp_type)
 if app.camp_recipe not in recipes:app.camp_recipe = recipes[0]
 for key in recipes:btn(app,column,app.expedition.camp.reward_name(key)+" · %d Essence" % E.RECIPES[key].cost,func():app.camp_recipe = key;app.rebuild(),GOLD if app.camp_recipe == key else MUTED)
 var recipe: Dictionary = E.RECIPES[app.camp_recipe]
 text(column,app.expedition.camp.reward_name(app.camp_recipe),26,GOLD);text(column,app.expedition.camp.reward_effect(app.camp_recipe))
 var already: bool = false
 if recipe.has("soul"):
  text(column,"Bind permanently to:",20,GOLD);heroes(app,column,true);already = recipe.soul in app.expedition.camp.souls[app.camp_hero]
 elif not recipe.has("face"):already = app.expedition.camp.unlocked.has(app.camp_recipe)
 else:text(column,"Owned copies: %d" % app.expedition.camp.owned(recipe.face),20)
 var caption: String = "Already owned" if already else ("Bind to "+NAMES[app.camp_hero] if recipe.has("soul") else "Craft & reveal / add copy")
 btn(app,column,caption,func():app.craft_recipe(app.camp_recipe),GOLD,already or int(app.expedition.camp.bank.get(app.camp_type,0)) < recipe.cost)
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
 var memory: bool = app.expedition.camp.unlocked.has("memory_loss")
 choose(app,column,"Memory",["None","Memory of Loss"] if memory else ["No Memory owned"],1 if app.expedition.camp.memories[hero] == "memory_loss" else 0,func(index):
  if index == 1:app.expedition.camp.equip_memory(hero)
  elif app.expedition.camp.memories[hero] != "":app.expedition.camp.equip_memory(-1)
  app.expedition.save();app.rebuild())
 if memory:
  var icon := AtlasTexture.new();icon.atlas = Camp.ITEM_ART;icon.region = Rect2(48,0,16,16);picture(column,icon);text(column,E.RECIPES.memory_loss.effect,20)
 text(column,"Souls bind to their hero. Memory is one shared copy. Refitting saves locally and applies to your next encounter.",19)

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
  var edge: float = minf(size.y-104,size.x*0.52)
  return Rect2(8,98,edge,edge)
 return Rect2(8,174,size.x-16,size.x-16)
static func board_point(app, at: Vector2) -> Vector2:
 var rect := board_rect(app);return SOURCE_RECT.position+(at-rect.position)*(SOURCE_RECT.size.x/rect.size.x)
static func battle(app) -> void:
 var size: Vector2 = app.get_viewport_rect().size;var landscape: bool = size.x > size.y
 var active: int = app.game.active
 app.label_at(app.game.unit_name(active)+" · Round %d" % app.game.round_no,Vector2(12,10),24,GOLD,size.x-24,true)
 for hero in range(3):
  var width: float = (size.x-24)/3
  var h: Dictionary = app.game.heroes[hero]
  var status: Button = app.button(NAMES[hero]+" · %d/%d HP · B%d" % [h.hp,h.max_hp,h.block],Vector2(12+hero*width,49),Vector2(width-4,36),func():app.mobile_info = NAMES[hero]+"\n"+app.game.status_description(hero);app.rebuild(),app.COLORS[hero])
  status.add_theme_font_size_override("font_size",14);status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 if not landscape:
  var intents: String = app.game.boss_name()+" · %d HP\n" % app.enemy_pool("hp")+" · ".join(app.game.boss_rolls)
  app.button(intents,Vector2(12,104),Vector2(size.x-24,64),func():app.show_enemy_cards = true;app.rebuild(),MUTED).add_theme_font_size_override("font_size",17)
 var rect := board_rect(app)
 var controls := ScrollContainer.new();controls.name = "MobileBattleActions";controls.scroll_deadzone = 14
 controls.position = Vector2(rect.end.x+12,98) if landscape else Vector2(12,rect.end.y+10)
 controls.size = Vector2(size.x-controls.position.x-12,size.y-controls.position.y-82);app.ui.add_child(controls)
 var scroll_key := "battle-"+str(active)
 controls.get_v_scroll_bar().value_changed.connect(func(value):app.mobile_scrolls[scroll_key] = int(value))
 controls.set_deferred("scroll_vertical",int(app.mobile_scrolls.get(scroll_key,0)))
 var column := VBoxContainer.new();column.custom_minimum_size.x = controls.size.x-14;column.size_flags_horizontal = Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",10);controls.add_child(column)
 if active < 3:
  var h: Dictionary = app.game.heroes[active]
  var dice := row(column)
  for die in range(3):
   var face: int = app.game.face(active,die)
   var name: String = app.game.soul_label(active) if face == 0 and app.game.reward and app.game.soul_remaining(active)>0 else app.Catalog.name_for(face)
   var caption: String = "Die %s%s\n%s" % [["I","II","III"][die]," · held" if die in h.reaction else " · spent" if h.used[die] else "",name]
   var pick := btn(app,dice,caption,func():app.mobile_die = die;app.select_combat_die(die),GOLD if app.selected == die else app.color_for_face(face),not app.game.pending.is_empty() or app.game.outcome != "" or h.dead or h.hp <= 0);pick.custom_minimum_size.y = 104;pick.add_theme_font_size_override("font_size",18);pick.name = "MobileDie"+str(die)
  if app.selected >= 0 and not h.used[app.selected]:
   var face: int = app.game.face(active,app.selected)
   var immediate: bool = (face == 59 and app.game.owned_worm(active)>=0) or face in [4,9,10,11,13,14,16,17,18,20,21,22,23,24,25,26,27,29,30,31,32,33,42,43,47,49,50,51,52,54,56,60,62,63,64,65] or (face == 0 and (not app.game.reward or app.game.soul_remaining(active)<=0 or app.game.soul_mode(active) in ["heal","block"]))
   var actions := row(column)
   if immediate:btn(app,actions,"Resolve",func():
    if app.game.hero_action(app.selected):app.selected = -1;app.roll_feedback = {}
    app.rebuild(),GOLD,face == 0 and app.game.soul_mode(active) == "heal" and h.hp >= h.max_hp).name = "MobileResolve"
   btn(app,actions,"Decline die",func():app.game.decline(app.selected);app.selected = -1;app.rebuild(),MUTED)
  if app.shove_target >= 0:
   for index in range(4):
    var direction: Vector2i = app.Model.DIRS[index]
    btn(app,column,["Push north","Push east","Push south","Push west"][index],func():
     if app.game.hero_action(app.selected,app.shove_target,direction):app.selected = -1;app.shove_target = -1
     app.rebuild(),GOLD,direction not in app.game.away_dirs(active,app.shove_target))
  var actions := row(column)
  btn(app,actions,"Reroll · %d" % h.rerolls,func():
   if app.selected >= 0 and app.game.reroll_reason(app.selected) == "":app.perform_reroll(app.selected)
   else:app.choosing_reroll = true;app.selected = -1;app.hint = "Tap a ready die or held Reaction to reroll.";app.rebuild(),GOLD,app.game.reroll_window_reason() != "").name = "MobileReroll"
  btn(app,actions,"End hero turn",func():app.game.finish_turn();app.selected = -1;app.rebuild(),GOLD,not app.game.pending.is_empty() or app.game.outcome != "").name = "MobileEndTurn"
  text(column,app.hint if app.selected >= 0 or app.choosing_reroll else "Tap a die, then its highlighted target. Scroll here for more controls.",18)
  btn(app,column,"Ability details",func():app.mobile_info = app.face_help(app.game.face(active,app.mobile_die));app.rebuild(),MUTED).name = "MobileDetails"
  btn(app,column,"Dagger · Poke",func():app.choosing_poke = true;app.rebuild(),GOLD,app.game.poke_targets().is_empty())
  if not app.game.burden_interrupt.is_empty():text(column,"Resolve the copied die, then End hero turn to return to "+app.game.unit_name(app.game.burden_interrupt.owner)+".",20)
 else:
  text(column,app.game.boss_display_action(),26,GOLD);text(column,app.boss_ability_summary(app.game.boss_display_action()),20)
  btn(app,column,app.game.boss_step_label(),func():app.game.boss_step();app.selected = -1;app.rebuild()).name = "MobileEnemyStep"
 var nav_x: float = controls.position.x if landscape else 12
 var nav_w: float = size.x-nav_x-12
 for i in range(3):
  var action: Callable = [func():app.show_enemy_cards = true;app.rebuild(),func():app.show_history = true;app.rebuild(),func():app.show_menu = true;app.rebuild()][i]
  app.button(["Enemies","Full log","Menu"][i],Vector2(nav_x+i*(nav_w+8)/3,size.y-74),Vector2((nav_w-16)/3,62),action,MUTED).add_theme_font_size_override("font_size",20)

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
  app.button("Back",Vector2.ZERO,Vector2(420,68),func():app.mobile_info = "";app.rebuild()))
static func menu(app) -> void:
 modal(app,func():
  app.label_at("Game menu",Vector2.ZERO,28,GOLD)
  app.button("Return to battle",Vector2.ZERO,Vector2(400,68),func():app.show_menu = false;app.rebuild())
  for item in [["Enemy cards","show_enemy_cards"],["Full battle log","show_history"],["View dice","show_dice"],["Supplies","show_supplies"],["Rules","show_help"],["Sound & volume","show_soundtrack"],["Options","show_options"]]:
   app.button(item[0],Vector2.ZERO,Vector2(400,68),func():app.show_menu = false;app.set(item[1],true);app.rebuild())
  app.button("Main menu · leave encounter",Vector2.ZERO,Vector2(400,68),app.go_main))
static func options(app) -> void:
 modal(app,func():
  app.label_at("Options",Vector2.ZERO,28,GOLD)
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
