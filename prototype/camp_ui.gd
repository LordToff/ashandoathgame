extends RefCounted
## Each tab has its own workspace; long descriptions scroll independently.
const ITEM_ART = preload("res://prototype/assets/souls_memory_sheet.png")
const E = preload("res://prototype/essence.gd")
const NAMES = ["Vesper","Rook","Wren"]
const SPECIES = ["bone_creature","support_creature","movement_creature"]

static func detail(app, text: String, rect: Rect2, size_px: int = 18) -> RichTextLabel:
 var node := RichTextLabel.new();node.position = rect.position;node.size = rect.size
 node.text = text;node.add_theme_font_size_override("normal_font_size",size_px)
 node.add_theme_color_override("default_color",Color("c8d3d9"));app.ui.add_child(node)
 return node

static func art(app, texture: Texture2D, rect: Rect2) -> void:
 var image := TextureRect.new();image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 if texture in app.CREATURE_SPRITES.values():
  var frame := AtlasTexture.new();frame.atlas = texture;frame.region = Rect2(0,0,16,16);image.texture = frame
 else:image.texture = texture
 image.position = rect.position;image.size = rect.size
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
  var type: String = SPECIES[i];var y := 270+i*125
  app.button("",Vector2(64,y),Vector2(234,110),func():app.camp_type = type;app.camp_recipe = app.expedition.camp.recipes_for(type)[0];app.rebuild(),app.GOLD if type == app.camp_type else app.MUTED).name = "CampType"+str(i)
  art(app,app.CREATURE_SPRITES[type],Rect2(76,y+22,60,60))
  app.label_at(E.type_name(type).replace(" Creature",""),Vector2(148,y+20),19,app.GOLD if type == app.camp_type else Color("d9e0df"),142,true).mouse_filter = Control.MOUSE_FILTER_IGNORE
  app.label_at("%d Essence" % int(app.expedition.camp.bank.get(type,0)),Vector2(148,y+55),16,app.MUTED,142).mouse_filter = Control.MOUSE_FILTER_IGNORE
 detail(app,"Earn Essence from individual enemies. Win the fight to bank it safely.",Rect2(68,656,226,70),15)
 app.setup_panel(Rect2(334,210,420,534))
 app.label_at("REWARD DESIGNS",Vector2(356,230),13,app.GOLD,372)
 var recipes: Array = app.expedition.camp.recipes_for(app.camp_type)
 for i in range(recipes.size()):
  var key: String = recipes[i];var recipe: Dictionary = E.RECIPES[key];var y := 270+i*110
  var card = app.button(app.expedition.camp.reward_name(key),Vector2(350,y),Vector2(388,92),func():app.camp_recipe = key;app.rebuild(),app.GOLD if key == app.camp_recipe else app.MUTED)
  card.name = "Recipe_"+key;card.alignment = HORIZONTAL_ALIGNMENT_LEFT;card.add_theme_font_size_override("font_size",17)
  for color_name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color","font_hover_pressed_color"]:card.add_theme_color_override(color_name,Color(0,0,0,0))
  app.label_at(app.expedition.camp.reward_name(key),Vector2(368,y+17),17,app.GOLD if key == app.camp_recipe else Color("d5dedf"),350).mouse_filter = Control.MOUSE_FILTER_IGNORE
  var copies: String = "Owned %d" % app.expedition.camp.owned(recipe.face) if recipe.has("face") else ("Owned · permanent" if app.expedition.camp.unlocked.has(key) else "One-time Memory")
  app.label_at("%d Essence  ·  %s" % [recipe.cost,copies],Vector2(368,y+53),14,app.MUTED,350).mouse_filter = Control.MOUSE_FILTER_IGNORE
 app.setup_panel(Rect2(774,210,618,534))
 var selected: Dictionary = E.RECIPES[app.camp_recipe]
 app.label_at("DESIGN DETAILS",Vector2(802,234),13,app.GOLD,550)
 app.label_at(app.expedition.camp.reward_name(app.camp_recipe),Vector2(802,278),28,Color("eee7d8"),562,true,true)
 detail(app,app.expedition.camp.reward_effect(app.camp_recipe),Rect2(802,360,562,160)).name = "CampRecipeDetails"
 app.label_at("COST  /  %d %s Essence" % [selected.cost,E.type_name(app.camp_type)],Vector2(802,552),16,app.GOLD,562)
 detail(app,"Your first craft reveals the design and gives one copy. Further face copies cost the same. Owned rewards stay yours; no dismantling or refunds.",Rect2(802,591,562,60),15)
 var unlocked: bool = app.expedition.camp.unlocked.has(app.camp_recipe)
 var locked: bool = int(app.expedition.camp.bank.get(app.camp_type,0)) < selected.cost or (not selected.has("face") and unlocked)
 app.button("Memory already owned" if not selected.has("face") and unlocked else ("Craft another copy" if unlocked else "Craft & reveal design"),Vector2(802,674),Vector2(562,48),func():app.craft_recipe(app.camp_recipe),app.GOLD,locked).name = "Craft_"+app.camp_recipe

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
 detail(app,app.expedition.camp.reward_effect(app.camp_recipe) if has_face else "Your collection starts empty. Defeat creatures, bank their Essence, then craft a design in the Essence Forge tab.",Rect2(70,350,306,175))
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
    for soul in app.expedition.camp.souls[hero]:picker.add_item(str({"beginning":"Beginning Soul · Move 1","hollow":"Hollow Soul · Move 2","ashroad":"Ash Road Soul · Move 2"}.get(soul,soul)))
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
    "soul":app.expedition.camp.equip_soul(hero,options[index])
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
 var icons := ["beginning","hollow","ashroad","memory_loss"]
 for index in range(4):
  var key: String = icons[index]
  var owned: bool = key in app.expedition.camp.souls[hero] if index < 3 else app.expedition.camp.unlocked.has(key)
  var texture := AtlasTexture.new();texture.atlas = ITEM_ART;texture.region = Rect2(index*543,0,543,724)
  var image := TextureRect.new();image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;image.name = "EquipmentSprite_"+key;image.texture = texture;image.position = Vector2(764+index*148,352);image.size = Vector2(132,134)
  image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;image.mouse_filter = Control.MOUSE_FILTER_IGNORE
  image.modulate = Color.WHITE if owned else Color(0.22,0.26,0.3,0.7);app.ui.add_child(image)
  app.label_at(["Beginning","Hollow","Ash Road","Memory"][index] if owned else "Undiscovered",Vector2(764+index*148,492),14,app.GOLD if owned else app.MUTED,136)
 if not app.expedition.camp.unlocked.has("memory_loss"):descriptions.memory = "Shared Memory\n\nThis reward design is still undiscovered. Craft the Memory using Support Creature Essence in the Essence Forge. Its exact name and effect reveal on first craft. One physical copy can then be equipped or transferred among the party."
 detail(app,descriptions[app.equipment_slot],Rect2(764,540,596,184),18).name = "EquipmentDetails"

static func creatures(app) -> void:
 var descriptions := ["Two Bone Creatures. Each has 3 HP and public dice: Scuttle 2, Bite 1, Guard 1.","One Support Creature (2 HP) with two Movement Creatures (3 HP each). Mend restores 1 HP to a living ally within 2.","Two Movement Creatures. Each has 3 HP. Scuttle travels up to 3 spaces; Bite 1 and Guard 1 round out their dice."]
 var rewards := ["Up to 2 Bone Essence","Up to 1 Support + 2 Movement Essence","Up to 2 Movement Essence"]
 for i in range(3):
  var type: String = SPECIES[i];var x := 48+i*454
  app.setup_panel(Rect2(x,210,436,534))
  app.label_at(["BONE PATROL","MIXED GROUP","SWIFT PACK"][i],Vector2(x+28,236),13,app.GOLD,380)
  art(app,app.CREATURE_SPRITES[type],Rect2(x+118,280,200,160))
  app.label_at(E.type_name(type),Vector2(x+28,459),27,Color("ede8dc"),380,true)
  detail(app,descriptions[i],Rect2(x+28,508,380,100),17)
  app.label_at(rewards[i],Vector2(x+28,631),16,Color("9acfc0"),380)
  app.button("Fight this group →",Vector2(x+28,682),Vector2(380,44),func():app.start_creature_encounter(i),app.GOLD).name = "FightCreature"+str(i)
