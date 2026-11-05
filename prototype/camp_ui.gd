extends RefCounted
## Each tab has its own workspace; long descriptions scroll independently.
const ITEM_ART = preload("res://prototype/assets/souls_memory_sheet.png")
const W = preload("res://prototype/wilds.gd")
const NEW_SOUL_ART = {"mire":preload("res://prototype/assets/mire_soul.tres"),"glasswing":preload("res://prototype/assets/glasswing_soul.tres"),"iron":preload("res://prototype/assets/iron_soul.tres")}
const E = preload("res://prototype/essence.gd")
const NAMES = ["Vesper","Rook","Wren"]
const SPECIES = ["bone_creature","support_creature","movement_creature","mire_leech","glasswing_moth","iron_husk"]

static func detail(app, text: String, rect: Rect2, size_px: int = 18) -> RichTextLabel:
 var node := RichTextLabel.new();node.position = rect.position;node.size = rect.size
 node.text = text;node.add_theme_font_size_override("normal_font_size",size_px)
 node.add_theme_color_override("default_color",Color("c8d3d9"));app.ui.add_child(node)
 return node

static func art(app, texture: Texture2D, rect: Rect2) -> void:
 var image := TextureRect.new();image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 if not texture is AtlasTexture and texture in app.CREATURE_SPRITES.values():
  var frame := AtlasTexture.new();frame.atlas = texture;frame.region = Rect2(0,0,16,16);image.texture = frame
 else:image.texture = texture
 var native: Vector2 = image.texture.get_size()
 var zoom: int = maxi(1,int(minf(rect.size.x/native.x,rect.size.y/native.y)))
 image.size = native*zoom;image.position = (rect.position+(rect.size-image.size)/2).round()
 image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;image.mouse_filter = Control.MOUSE_FILTER_IGNORE;app.ui.add_child(image)

static func render(app) -> void:
 app.chamber_background()
 app.label_at("CAMP",Vector2(48,30),36,app.GOLD,1080,true)
 app.label_at("Rest. Refit. Choose your next fight.",Vector2(50,86),18,app.MUTED,1000)
 app.button("Main menu",Vector2(1210,40),Vector2(182,44),app.go_main,app.MUTED).name = "CampMainMenu"
 var tabs := ["Essence Forge","Refit dice","Equipment","Creature encounters"]
 for i in range(tabs.size()):
  app.button(tabs[i],Vector2(48+i*340,136),Vector2(324,48),func():app.camp_tab = i;app.rebuild(),app.GOLD if app.camp_tab == i else app.MUTED).name = "CampTab"+str(i)
 match app.camp_tab:
  0:crafting(app)
  1:refit(app)
  2:inheritance(app)
  3:creatures(app)
 app.setup_panel(Rect2(48,762,1344,54))
 detail(app,app.camp_message,Rect2(66,775,1308,32),15).name = "CampFeedback"
 app.button("← Party & starter dice",Vector2(48,831),Vector2(300,44),func():app.open_forge(false),app.MUTED)
 app.button("Boss expedition →",Vector2(1092,831),Vector2(300,44),app.open_setup).name = "CampBossExpedition"

static func crafting(app) -> void:
 app.setup_panel(Rect2(48,210,266,534))
 app.label_at("ESSENCE SOURCES",Vector2(68,230),13,app.GOLD,226)
 for i in range(3):
  var index: int = i+app.essence_page*3
  var type: String = SPECIES[index];var y := 270+i*125
  app.button("",Vector2(64,y),Vector2(234,110),func():app.camp_type = type;app.camp_recipe = app.expedition.camp.recipes_for(type)[0];app.rebuild(),app.GOLD if type == app.camp_type else app.MUTED).name = "CampType"+str(index)
  art(app,app.CREATURE_SPRITES[type],Rect2(76,y+22,64,64))
  app.label_at(E.type_name(type).replace(" Creature","").replace(" Moth",""),Vector2(148,y+20),19,app.GOLD if type == app.camp_type else Color("d9e0df"),142,true).mouse_filter = Control.MOUSE_FILTER_IGNORE
  app.label_at("%d Essence" % int(app.expedition.camp.bank.get(type,0)),Vector2(148,y+55),16,app.MUTED,142).mouse_filter = Control.MOUSE_FILTER_IGNORE
 app.button("←" if app.essence_page else "1 / 2",Vector2(68,656),Vector2(102,34),func():app.essence_page = 0;app.camp_type = SPECIES[0];app.camp_recipe = app.expedition.camp.recipes_for(app.camp_type)[0];app.rebuild(),app.MUTED).name = "EssencePreviousPage"
 app.button("More →" if app.essence_page == 0 else "2 / 2",Vector2(182,656),Vector2(112,34),func():app.essence_page = 1;app.camp_type = SPECIES[3];app.camp_recipe = app.expedition.camp.recipes_for(app.camp_type)[0];app.rebuild(),app.GOLD).name = "EssenceNextPage"
 detail(app,"Victory banks earned Essence.",Rect2(68,706,226,32),13)
 app.setup_panel(Rect2(334,210,420,534))
 app.label_at("REWARD DESIGNS",Vector2(356,230),13,app.GOLD,372)
 var recipes: Array = app.expedition.camp.recipes_for(app.camp_type)
 for i in range(recipes.size()):
  var key: String = recipes[i];var recipe: Dictionary = E.RECIPES[key];var y := 270+i*110
  var card = app.button(app.expedition.camp.reward_name(key),Vector2(350,y),Vector2(388,92),func():app.camp_recipe = key;app.rebuild(),app.GOLD if key == app.camp_recipe else app.MUTED)
  card.name = "Recipe_"+key;card.alignment = HORIZONTAL_ALIGNMENT_LEFT;card.add_theme_font_size_override("font_size",17)
  for color_name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color","font_hover_pressed_color"]:card.add_theme_color_override(color_name,Color(0,0,0,0))
  app.label_at(app.expedition.camp.reward_name(key),Vector2(368,y+17),17,app.GOLD if key == app.camp_recipe else Color("d5dedf"),350).mouse_filter = Control.MOUSE_FILTER_IGNORE
  var copies: String = "Owned %d" % app.expedition.camp.owned(recipe.face) if recipe.has("face") else ("Bound to %d / 3 heroes" % app.expedition.camp.souls.filter(func(list):return recipe.soul in list).size() if recipe.has("soul") else "Owned · permanent" if app.expedition.camp.unlocked.has(key) else "One-time Memory")
  app.label_at("%d Essence  ·  %s" % [recipe.cost,copies],Vector2(368,y+53),14,app.MUTED,350).mouse_filter = Control.MOUSE_FILTER_IGNORE
 app.setup_panel(Rect2(774,210,618,534))
 var selected: Dictionary = E.RECIPES[app.camp_recipe]
 app.label_at("DESIGN DETAILS",Vector2(802,234),13,app.GOLD,550)
 app.label_at(app.expedition.camp.reward_name(app.camp_recipe),Vector2(802,278),28,Color("eee7d8"),562,true,true)
 detail(app,app.expedition.camp.reward_effect(app.camp_recipe)+"\n\n"+app.expedition.camp.recipe_progress(app.camp_recipe),Rect2(802,360,562,160)).name = "CampRecipeDetails"
 app.label_at("COST  /  %d %s Essence" % [selected.cost,E.type_name(app.camp_type)],Vector2(802,552),16,app.GOLD,562)
 var unlocked: bool = app.expedition.camp.unlocked.has(app.camp_recipe)
 var bound: bool = selected.has("soul")
 var already: bool = selected.soul in app.expedition.camp.souls[app.camp_hero] if bound else not selected.has("face") and unlocked
 if bound:
  app.label_at("BIND TO A HERO · permanent, cannot trade",Vector2(802,592),14,app.GOLD,562)
  for hero in range(3):app.button(NAMES[hero],Vector2(802+hero*190,623),Vector2(182,36),func():app.camp_hero = hero;app.rebuild(),app.COLORS[hero] if app.camp_hero == hero else app.MUTED).name = "SoulRecipient"+str(hero)
 else:detail(app,"Inspect designs freely. Each craft gives one physical party copy; further copies cost the same. Refit to equip. Owned rewards stay yours.",Rect2(802,591,562,60),15)
 var locked: bool = int(app.expedition.camp.bank.get(app.camp_type,0)) < selected.cost or already
 var caption: String = (NAMES[app.camp_hero]+" already owns this Soul" if already else "Bind Soul to "+NAMES[app.camp_hero]) if bound else "Memory already owned" if already else "Craft another copy" if unlocked else "Craft first copy"
 app.button(caption,Vector2(802,674),Vector2(562,48),func():app.craft_recipe(app.camp_recipe),app.GOLD,locked).name = "Craft_"+app.camp_recipe

static func refit(app) -> void:
 app.setup_panel(Rect2(48,210,350,534));app.setup_panel(Rect2(418,210,974,534))
 app.label_at("SHARED FACE COLLECTION",Vector2(70,232),14,app.GOLD,306)
 var choices := OptionButton.new();choices.name = "CampFacePicker";choices.position = Vector2(70,275);choices.size = Vector2(306,48)
 var keys: Array = []
 for key in E.RECIPES:
  var recipe: Dictionary = E.RECIPES[key]
  if recipe.has("face") and app.expedition.camp.unlocked.has(key):
   keys.append(key);choices.add_item("%s ×%d" % [app.Catalog.name_for(recipe.face),app.expedition.camp.owned(recipe.face)])
 if not keys.is_empty():
  if not app.camp_recipe in keys:app.camp_recipe = keys[0]
  choices.select(keys.find(app.camp_recipe))
 else:choices.add_item("Craft a face to begin");choices.disabled = true
 choices.item_selected.connect(func(index):app.camp_recipe = keys[index];app.rebuild());app.ui.add_child(choices)
 var has_face: bool = not keys.is_empty()
 var recipe: Dictionary = E.RECIPES[app.camp_recipe]
 detail(app,("Owned %d · Equipped %d · Free %d\n\n" % [app.expedition.camp.owned(recipe.face),app.expedition.camp.allocated(app.builds,recipe.face),maxi(0,app.expedition.camp.owned(recipe.face)-app.expedition.camp.allocated(app.builds,recipe.face))] + app.expedition.camp.reward_effect(app.camp_recipe)) if has_face else "Your collection starts empty. Defeat creatures, bank their Essence, then craft a design in the Essence Forge tab.",Rect2(70,350,306,175))
 app.button("Mode: return crafted face" if app.camp_remove_mode else "Mode: place selected face",Vector2(70,555),Vector2(306,48),func():app.camp_remove_mode = not app.camp_remove_mode;app.rebuild(),app.GOLD).name = "CampUnequipMode"
 detail(app,"Choose a hero, then a square. Keep 2+ Blanks on every die and respect body limits. Copies are shared by the whole party. Returning a crafted face keeps it owned.",Rect2(70,628,306,96),15)
 for hero in range(3):app.button(NAMES[hero],Vector2(442+hero*310,234),Vector2(292,46),func():app.camp_hero = hero;app.rebuild(),app.COLORS[hero] if app.camp_hero == hero else app.MUTED)
 app.label_at("Choose a square to "+("return its crafted face." if app.camp_remove_mode else "place the selected face."),Vector2(444,301),16,app.MUTED,920)
 for die in range(3):
  var y := 353+die*119
  app.label_at("DIE "+["I","II","III"][die],Vector2(444,y-14),12,app.GOLD,90)
  for side in range(6):
   var face: int = app.builds[app.camp_hero][die][side]
   var square = app.button(app.Catalog.name_for(face),Vector2(444+side*154,y+12),Vector2(144,80),func():
    if app.camp_remove_mode:app.camp_remove(app.camp_hero,die,side)
    elif has_face:app.camp_place(recipe.face,app.camp_hero,die,side),app.color_for_face(face),not app.camp_remove_mode and not has_face)
   square.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;square.add_theme_font_size_override("font_size",15);square.tooltip_text = app.Catalog.text(face);square.name = "CampSlot%d_%d" % [die,side]

static func inheritance(app) -> void:
 app.setup_panel(Rect2(48,210,664,534));app.setup_panel(Rect2(732,210,660,534))
 for hero in range(3):
  app.button(NAMES[hero],Vector2(70+hero*210,234),Vector2(194,46),func():app.camp_hero = hero;app.rebuild(),app.COLORS[hero] if app.camp_hero == hero else app.MUTED).name = "EquipmentHero"+str(hero)
 var hero: int = app.camp_hero
 var slots := ["body","weapon","soul","memory"]
 for i in range(slots.size()):
  var slot: String = slots[i];var y := 324+i*98
  app.button(slot.to_upper(),Vector2(70,y),Vector2(174,48),func():app.equipment_slot = slot;app.rebuild(),app.GOLD if app.equipment_slot == slot else app.MUTED)
  var picker := OptionButton.new();picker.name = "Equipment_"+slot;picker.position = Vector2(264,y);picker.size = Vector2(420,48)
  var options: Array = []
  match slot:
   "body":
    options = ["broken_body"];picker.add_item("Broken Body · equipped");picker.select(0)
   "weapon":
    options = ["","dagger"];picker.add_item("None equipped");picker.add_item("Dagger · Poke");picker.select(maxi(0,options.find(app.expedition.camp.weapons[hero])))
   "soul":
    options = [""]+app.expedition.camp.souls[hero];picker.add_item("None equipped")
    for soul in app.expedition.camp.souls[hero]:picker.add_item(W.soul_name(soul))
    picker.select(maxi(0,options.find(app.expedition.camp.equipped_souls[hero])))
   "memory":
    options = [""];picker.add_item("None equipped")
    if app.expedition.camp.unlocked.has("memory_loss"):options.append("memory_loss");picker.add_item("Memory of Loss · shared copy")
    picker.select(maxi(0,options.find(app.expedition.camp.memories[hero])))
  picker.item_selected.connect(func(index):
   app.equipment_slot = slot
   match slot:
    "body":app.expedition.camp.equip_body(hero,options[index])
    "weapon":app.expedition.camp.equip_weapon(hero,options[index])
    "soul":
     app.expedition.camp.equip_soul(hero,options[index])
     app.soul_gallery_page = 1 if options[index] in W.SOULS else 0
    "memory":
     if options[index] != "":app.expedition.camp.equip_memory(hero)
     elif app.expedition.camp.memories[hero] != "":app.expedition.camp.equip_memory(-1)
   app.expedition.save();app.camp_message = NAMES[hero]+"’s "+slot+" equipment saved.";app.rebuild())
  app.ui.add_child(picker)
  picker.focus_entered.connect(func():app.equipment_slot = slot)
 app.portrait_at(hero,Vector2(764,240),Vector2(84,84))
 app.label_at(NAMES[hero]+"’s equipment",Vector2(872,249),30,app.COLORS[hero],480,true)
 app.label_at("CAMP REFITTING",Vector2(872,296),13,app.MUTED,480)
 var descriptions := {
  "body":"Broken Body\n\nThe party’s current starter body. %d HP, at least %d Blanks on each die, and category limits of %d Movement, %d Defense and %d Skill across a hero’s dice.\n\nNo additional bodies have been unlocked yet. Body equipment is mandatory." % [app.balance_number("hero.hp"),app.balance_number("body.blanks"),app.balance_number("body.Movement"),app.balance_number("body.Defense"),app.balance_number("body.Skill")],
  "weapon":"Dagger · Poke\n\nBase damage 1 to one adjacent enemy, only after this hero has dealt actual HP damage to an enemy during this same turn.\n\nOnce per own turn. No Action Die or reroll spent. Normal Attack modifiers, Block and armor apply. Blocked hits and friendly fire do not unlock it; Shared Burden interrupts do not count as an own turn.\n\nEach hero owns one starter Dagger. Equip or unequip it here.",
  "soul":"Bound Souls\n\nA Soul belongs to its recipient and cannot be traded. Choose among this hero’s owned Souls or unequip it.\n\nBeginning Soul: spend one rolled Blank as Move 1, once per own turn. Current construction requires 2+ Blanks per die, a legal Broken Body build and owned face copies. It grants no free movement and never changes an installed side.\n\nThe Hollow’s tutorial reward grants a Soul to every hero. The Ash Road Fragment reward binds to the hero you choose. Souls allow limited Blank movement; the sandbox override is a separate option.",
  "memory":"Shared Memories\n\nCraft Memory of Loss using 4 Support Creature Essence. It is one permanent shared copy; equipping it transfers it from its previous holder.\n\nHealing abilities gain +1 range except Self/Adjacent. The first actual self-heal per combat restores 1 extra HP, up to maximum.\n\nUnequipping a Memory never destroys it."
 }
 var icons: Array = ["beginning","hollow","ashroad","memory_loss"] if app.soul_gallery_page == 0 else ["mire","glasswing","iron"]
 for index in range(icons.size()):
  var key: String = icons[index]
  var owned: bool = app.expedition.camp.unlocked.has(key) if key == "memory_loss" else key in app.expedition.camp.souls[hero]
  var texture: Texture2D
  if NEW_SOUL_ART.has(key):texture = NEW_SOUL_ART[key]
  else:
   var region := AtlasTexture.new();region.atlas = ITEM_ART;region.region = Rect2(index*16,0,16,16);texture = region
  var image := Control.new();image.name = "EquipmentSprite_"+key;image.position = Vector2(764+index*148,352);image.size = Vector2(132,134);image.mouse_filter = Control.MOUSE_FILTER_IGNORE
  var pixels := TextureRect.new();pixels.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;pixels.texture = texture;pixels.position = Vector2(2,3);pixels.size = Vector2(128,128);pixels.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;pixels.mouse_filter = Control.MOUSE_FILTER_IGNORE;image.add_child(pixels)
  image.modulate = Color.WHITE if owned else Color(0.22,0.26,0.3,0.7);app.ui.add_child(image)
  app.label_at((["Beginning","Hollow","Ash Road","Memory"][index] if app.soul_gallery_page == 0 else ["Mire","Glasswing","Ironbound"][index]) if owned else "Undiscovered",Vector2(764+index*148,492),14,app.GOLD if owned else app.MUTED,136)
 if not app.expedition.camp.unlocked.has("memory_loss"):descriptions.memory = "Shared Memory\n\nThis reward design is still undiscovered. Craft the Memory using Support Creature Essence in the Essence Forge. Its exact name and effect reveal on first craft. One physical copy can then be equipped or transferred among the party."
 app.button("More Souls →" if app.soul_gallery_page == 0 else "← Starter & rewards",Vector2(1210,512),Vector2(150,25),func():app.soul_gallery_page = 1-app.soul_gallery_page;app.rebuild(),app.MUTED).add_theme_font_size_override("font_size",11)
 var current_soul: String = app.expedition.camp.equipped_souls[hero]
 if W.SOULS.has(current_soul):descriptions.soul = W.soul_name(current_soul)+"\n\n"+W.SOULS[current_soul].effect+"\n\nBound to "+NAMES[hero]+". Uses a rolled Blank, not a free action. Next own/recovery turn refreshes the allowance; rerolls and toggles do not."
 detail(app,descriptions[app.equipment_slot],Rect2(764,552,596,172),18).name = "EquipmentDetails"

static func creatures(app) -> void:
 for i in range(3):
  var index: int = i+app.creature_page*3
  var group: Dictionary = W.GROUPS[index];var type: String = group.enemy;var x := 48+i*454
  app.setup_panel(Rect2(x,210,436,534))
  app.label_at(group.title,Vector2(x+28,236),13,app.GOLD,380)
  art(app,app.CREATURE_SPRITES[type],Rect2(x+118,280,200,160))
  app.label_at(E.type_name(type),Vector2(x+28,459),27,Color("ede8dc"),380,true)
  detail(app,group.description,Rect2(x+28,508,380,110),17)
  app.label_at(group.reward,Vector2(x+28,638),16,Color("9acfc0"),380)
  app.button("Fight this group →",Vector2(x+28,682),Vector2(380,44),func():app.start_creature_encounter(index),app.GOLD).name = "FightCreature"+str(index)
 app.button("← Familiar creatures" if app.creature_page else "Creatures 1 / 2",Vector2(367,831),Vector2(265,44),func():app.creature_page = 0;app.rebuild(),app.MUTED).name = "CreaturePreviousPage"
 app.button("Wilds creatures →" if app.creature_page == 0 else "Creatures 2 / 2",Vector2(650,831),Vector2(265,44),func():app.creature_page = 1;app.rebuild(),app.GOLD).name = "CreatureNextPage"
