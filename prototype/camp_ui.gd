extends RefCounted
const E = preload("res://prototype/essence.gd")
static func render(app) -> void:
 app.chamber_background()
 app.label_at("CAMP · THE ESSENCE FORGE",Vector2(48,32),32,app.GOLD,1320,true)
 app.label_at("Banked Essence is safe. Crafting is voluntary; each payment uses one enemy type. No dismantling or refunds.",Vector2(50,88),16,app.MUTED,1340)
 var species: Array = ["bone_creature","support_creature","movement_creature"]
 for i in range(3):
  var type: String = species[i]
  var tab = app.button(E.type_name(type)+" · %d Essence" % int(app.expedition.camp.bank.get(type,0)),Vector2(50+i*450,135),Vector2(433,48),func():app.camp_type = type;app.camp_recipe = E.RECIPES.keys().filter(func(key):return E.RECIPES[key].enemy == type)[0];app.rebuild(),app.GOLD if type == app.camp_type else app.MUTED)
  tab.name = "CampType"+str(i)
 app.setup_panel(Rect2(48,200,710,480));app.setup_panel(Rect2(780,200,610,590))
 var recipes: Array = app.expedition.camp.recipes_for(app.camp_type)
 for i in range(recipes.size()):
  var key: String = recipes[i];var recipe: Dictionary = E.RECIPES[key];var y: int = 217+i*106
  app.button(app.expedition.camp.reward_name(key)+" · %d Essence" % recipe.cost,Vector2(65,y),Vector2(430,44),func():app.camp_recipe = key;app.rebuild(),app.GOLD if key == app.camp_recipe else app.MUTED)
  var copies: String = " · owned %d" % app.expedition.camp.owned(recipe.face) if recipe.has("face") else " · one-time unlock"
  app.label_at(recipe.category+copies,Vector2(68,y+54),14,app.MUTED,440)
  var label := "Craft copy" if recipe.has("face") and app.expedition.camp.unlocked.has(key) else "Craft & reveal"
  var locked: bool = int(app.expedition.camp.bank.get(app.camp_type,0)) < recipe.cost or (not recipe.has("face") and app.expedition.camp.unlocked.has(key))
  var craft = app.button(label,Vector2(515,y),Vector2(221,48),func():app.craft_recipe(key),app.GOLD,locked);craft.name = "Craft_"+key
 var selected: Dictionary = E.RECIPES[app.camp_recipe]
 app.label_at(app.expedition.camp.reward_name(app.camp_recipe),Vector2(802,218),24,app.GOLD,560,true)
 app.label_at(app.expedition.camp.reward_effect(app.camp_recipe),Vector2(803,265),18,app.MUTED,550,false,true)
 for hero in range(3):
  app.button(["Vesper","Rook","Wren"][hero],Vector2(805+hero*187,391),Vector2(175,40),func():app.camp_hero = hero;app.rebuild(),app.COLORS[hero] if app.camp_hero == hero else app.MUTED)
 if selected.has("face") and app.expedition.camp.unlocked.has(app.camp_recipe):
  app.label_at("REFIT · choose a die square",Vector2(803,448),15,app.GOLD,380)
  app.button("Unequip mode: "+("ON" if app.camp_remove_mode else "OFF"),Vector2(1195,439),Vector2(166,34),func():app.camp_remove_mode = not app.camp_remove_mode;app.rebuild(),app.GOLD if app.camp_remove_mode else app.MUTED).add_theme_font_size_override("font_size",12)
  for die in range(3):
   for side in range(6):
    var face: int = app.builds[app.camp_hero][die][side]
    var square = app.button("%s%d\n%s" % [["I","II","III"][die],side+1,app.Catalog.name_for(face)],Vector2(804+side*94,485+die*72),Vector2(87,65),func():
     if app.camp_remove_mode:app.camp_remove(app.camp_hero,die,side)
     else:app.camp_place(selected.face,app.camp_hero,die,side),app.color_for_face(face))
    square.tooltip_text = app.Catalog.display_name(face)+"\n"+app.Catalog.text(face)
    square.add_theme_font_size_override("font_size",11);square.name = "CampSlot%d_%d" % [die,side]
  app.label_at("Body/category limits and 2+ Blanks per die still apply.\nCopies are shared across all three heroes; unequipped copies stay owned.",Vector2(803,712),14,app.MUTED,555,false,true)
 elif not selected.has("face") and app.expedition.camp.unlocked.has(app.camp_recipe):
  app.button(("Unequip Memory from " if app.expedition.camp.memories[app.camp_hero] == "memory_loss" else "Equip Memory on ")+["Vesper","Rook","Wren"][app.camp_hero],Vector2(804,488),Vector2(555,48),func():app.expedition.camp.equip_memory(-1 if app.expedition.camp.memories[app.camp_hero] == "memory_loss" else app.camp_hero);app.expedition.save();app.camp_message = "Memory refitted. It remains permanently owned in the shared collection.";app.rebuild())
  app.label_at("One physical Memory of Loss is shared. Equipping it here removes it from its previous holder. This is a Camp refit, not a combat swap.",Vector2(805,558),17,app.MUTED,550,false,true)
 var other: Array[String] = []
 for type in app.expedition.camp.bank:
  if type not in species:other.append("%d %s" % [int(app.expedition.camp.bank[type]),E.type_name(type)])
 app.label_at("Other banked Essence: "+(", ".join(other) if not other.is_empty() else "none yet"),Vector2(65,642),14,app.MUTED,670,false,true)
 app.label_at("SOULS · bound to each recipient; never traded",Vector2(52,706),16,app.GOLD,700)
 for hero in range(3):
  var available: Array = app.expedition.camp.souls[hero]
  var current: String = app.expedition.camp.equipped_souls[hero]
  var next_soul: String = available[0] if current == "" and not available.is_empty() else (available[available.find(current)+1] if available.find(current)+1 < available.size() else "")
  var caption: String = ["Vesper","Rook","Wren"][hero]+" · "+({"hollow":"Hollow","ashroad":"Ash Road"}.get(current,"OFF"))
  app.button(caption,Vector2(50+hero*235,748),Vector2(220,39),func():app.expedition.camp.equip_soul(hero,next_soul);app.expedition.save();app.rebuild(),app.COLORS[hero],available.is_empty())
 app.label_at(app.camp_message,Vector2(50,805),15,app.GOLD,1310,false,true)
 app.button("← Faces / dice",Vector2(48,842),Vector2(280,40),func():app.page = "forge";app.rebuild(),app.MUTED)
 app.button("Services · not yet defined",Vector2(350,842),Vector2(340,40),func():app.camp_message = "Cleansing, Reforging, Restoration, Transmutation and Empowerment are candidates only; effects, costs and unlock milestones are not finalized.";app.rebuild(),app.MUTED)
 app.button("Enter selected boss →" if app.expedition.stage == "resolved" else "Boss & next expedition →",Vector2(1000,842),Vector2(390,40),func():
  if app.expedition.stage == "resolved":app.enter_boss()
  else:app.open_setup())
