extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const H = preload("res://prototype/menu_helpers.gd")
const E = preload("res://prototype/essence.gd")
const G = preload("res://prototype/equipment.gd")
const TASKS = ["Craft upgrades","Install abilities","Equip gear","Fight creatures"]
const ROLES = {"body":"Limits Defense, Movement and Skill faces.","soul":"Sets maximum HP, minimum Blanks per die and a strong effect.","memory":"Adds one passive modifier; new parties start empty.","weapon":"Sets Attack limits and replaces basic Strikes with rolled weapon attacks."}
static func open_task(app, task: int) -> void:
 app.camp_tab = task;app.camp_slot = Vector2i(-1,-1);app.camp_message = "";app.camp_gear_context = "";app.rebuild()
static func heroes(app, column: Control) -> void:
 M.text(column,"Changing equipment / dice for:",16,app.MUTED)
 var row := M.row(column)
 for hero in range(3):
  var b: Button = H.action(app,row,M.NAMES[hero],func():app.camp_hero = hero;app.camp_slot = Vector2i(-1,-1);app.camp_gear_context = "";app.rebuild(),"EquipmentHero"+str(hero),app.COLORS[hero] if app.camp_hero==hero else app.MUTED)
  b.custom_minimum_size.y = 44;b.add_theme_font_size_override("font_size",16)
static func render(app) -> void:
 var task: int = app.camp_tab
 var column := P.panel(app,"Camp" if task<0 else TASKS[task],"Choose a task. Banked materials and owned rewards stay in your collection.")
 if app.camp_message!="":M.text(column,app.camp_message,18,app.GOLD).name = "CampFeedback"
 if task<0:
  var grid := H.grid(app,column)
  var explanations := ["Spend matching creature Essence to add an owned ability, Memory or Weapon, or bind a Soul.","Put an owned crafted ability on a die, or return it to the collection. This does not spend Essence.","Choose one hero, then a Body, Soul, Memory or Weapon. Read the effect before equipping.","Earn matching creature Essence. Direct fights do not replace your required road event."]
  for index in range(4):
   var c := H.card(app,grid,TASKS[index],explanations[index],app.GOLD if index==0 else Color("9acfc0"))
   H.action(app,c,"Open "+TASKS[index].to_lower(),func():open_task(app,index),"CampTab"+str(index))
  H.action(app,column,"My collection — owned items and discoveries",func():app.show_collection = true;app.rebuild(),"CampCollection",app.MUTED)
  P.footer(app,["Main menu","Prepare / continue adventure"],[app.go_main,app.open_normal]);return
 match task:
  0:craft(app,column)
  1:refit(app,column)
  2:equipment(app,column)
  3:creatures(app,column)
static func craft_block(app, key: String) -> String:
 var bank = app.expedition.camp;var r: Dictionary = E.RECIPES[key]
 if not bank.discovered(r.enemy):return "Defeat "+E.type_name(r.enemy)+" first to unlock this recipe. You can inspect it now."
 if r.has("soul") and r.soul in bank.souls[app.camp_hero]:return M.NAMES[app.camp_hero]+" already owns this Soul. Choose another recipient."
 if not r.has("face") and not r.has("soul") and bank.unlocked.has(key):return "Already owned. Go to Equip gear to use it."
 var held: int = int(bank.bank.get(r.enemy,0))
 if held<int(r.cost):return "Need %d more %s Essence (you have %d / %d)." % [int(r.cost)-held,E.type_name(r.enemy),held,int(r.cost)]
 return ""
static func craft(app, column: Control) -> void:
 if app.camp_after_craft==app.camp_recipe and app.camp_after_craft in E.RECIPES:
  var completed: String = app.camp_after_craft
  H.action(app,column,"Next: install this ability" if E.RECIPES[completed].has("face") else "Next: equip this reward",func():equip_crafted(app,completed),"CampUseCrafted",Color("9acfc0"))
 M.text(column,"Crafting adds an owned item. Equipping it is a separate next step.",20)
 M.choose(app,column,"1. Choose the material you want to spend",app.CampUI.SPECIES.map(func(type):return E.type_name(type)+" — %d held" % int(app.expedition.camp.bank.get(type,0))),app.CampUI.SPECIES.find(app.camp_type),func(index):app.camp_type = app.CampUI.SPECIES[index];app.camp_recipe = app.expedition.camp.recipes_for(app.camp_type)[0];app.camp_after_craft = "";app.rebuild(),"CampMaterialPicker")
 var keys: Array = app.expedition.camp.recipes_for(app.camp_type)
 if app.camp_recipe not in keys:app.camp_recipe = keys[0]
 M.text(column,"2. Choose a reward to inspect",19,app.GOLD)
 var options := H.grid(app,column)
 for key in keys:
  var r: Dictionary = E.RECIPES[key]
  var b: Button = H.action(app,options,("✓ " if key==app.camp_recipe else "")+app.expedition.camp.reward_name(key)+"\n%d %s Essence" % [r.cost,E.type_name(r.enemy)],func():app.camp_recipe = key;app.camp_after_craft = "";app.rebuild(),"Recipe_"+key,app.GOLD if key==app.camp_recipe else app.MUTED)
  app.bind_unlock(b,"recipe",key,app.camp_hero)
 var key: String = app.camp_recipe;var r: Dictionary = E.RECIPES[key]
 var c := H.card(app,column,app.expedition.camp.reward_name(key),app.expedition.camp.reward_effect(key))
 M.text(c,app.expedition.camp.recipe_progress(key),18,app.GOLD)
 if r.has("soul"):
  M.text(c,"This Soul will belong permanently to one hero. It cannot be traded.",18)
  heroes(app,c)
 elif r.has("face"):
  M.text(c,"Owned %d · On dice %d · Available %d" % [app.expedition.camp.owned(r.face),app.expedition.camp.allocated(app.builds,r.face),maxi(0,app.expedition.camp.owned(r.face)-app.expedition.camp.allocated(app.builds,r.face))],18)
 var reason: String = craft_block(app,key)
 M.text(column,"3. "+("Ready to craft. This spends %d matching Essence." % r.cost if reason=="" else reason),18,app.GOLD if reason=="" else Color("efb090"))
 P.footer(app,["Back to Camp","Bind Soul · %d" % r.cost if r.has("soul") else "Craft · %d Essence" % r.cost],[func():open_task(app,-1),func():
  if craft_block(app,key)!="":return
  app.craft_recipe(key);app.camp_after_craft = key;app.rebuild()],[false,reason!=""])
static func equip_crafted(app, key: String) -> void:
 var r: Dictionary = E.RECIPES[key]
 app.camp_slot = Vector2i(-1,-1);app.camp_message = "Choose where to use "+app.expedition.camp.reward_name(key)+". No further crafting payment is needed."
 if r.has("face"):app.camp_tab = 1;app.camp_recipe = key;app.camp_remove_mode = false
 else:
  app.camp_tab = 2;app.equipment_slot = "soul" if r.has("soul") else "weapon" if r.has("weapon") else "memory"
  app.camp_gear_context = str(app.camp_hero)+app.equipment_slot;app.camp_gear_candidate = str(r.soul) if r.has("soul") else str(r.weapon) if r.has("weapon") else key
 app.rebuild()
static func current(app, slot: String, hero: int) -> String:
 var bank = app.expedition.camp
 return G.body_key(str(bank.bodies[hero])) if slot=="body" else str(bank.equipped_souls[hero]) if slot=="soul" else str(bank.memories[hero]) if slot=="memory" else str(bank.weapons[hero])
static func options(app, slot: String, hero: int) -> Array:
 if slot=="body":return ["broken","fleet","stone"]
 if slot=="weapon":return app.expedition.camp.available_weapons()
 if slot=="soul":return app.expedition.camp.souls[hero]
 return [""]+app.expedition.camp.memory_keys().filter(func(key):return app.expedition.camp.unlocked.has(key))
static func item_name(app, slot: String, key: String) -> String:
 if slot=="memory":return "Empty" if key=="" else app.expedition.camp.reward_name(key)
 return {"body":G.BODIES,"soul":G.SOULS,"weapon":G.WEAPONS}[slot][key].name
static func item_text(app, slot: String, key: String) -> String:
 if slot=="memory":return "No passive is equipped. Craft and equip a Memory to add one." if key=="" else app.expedition.camp.reward_effect(key)
 return {"body":G.BODIES,"soul":G.SOULS,"weapon":G.WEAPONS}[slot][key].text
static func gear_plan(app, slot: String, hero: int, key: String, starter: bool = false) -> Dictionary:
 if key not in options(app,slot,hero):return {"error":"This item is not owned by this hero."}
 var preview = E.new();preview.decode(app.expedition.camp.encode().duplicate(true))
 var ok: bool
 match slot:
  "body":ok = preview.equip_body(hero,key)
  "weapon":ok = preview.equip_weapon(hero,key)
  "soul":ok = preview.equip_soul(hero,key)
  "memory":
   if key=="":preview.memories[hero] = "";ok = true
   else:ok = preview.equip_memory(hero,key)
 if not ok:return {"error":"This copy is already equipped elsewhere, or is not available for this hero."}
 var gifts: Array = app.gifts[hero].duplicate()
 var build: Array = app.builds[hero].duplicate(true)
 var profile: Dictionary = app.Model.Equipment.scoped(preview.profile(app.balance_values),hero)
 if starter:
  if gifts.size()!=2:gifts = app.NavigationUI.SUGGESTIONS[hero].duplicate()
  build = app.Model.bonus_build(gifts,profile)
  if build.is_empty():return {"error":"The current bonus pair cannot fit this equipment. Choose other bonuses first."}
 var error: String = app.Model.validate(build,gifts,profile)
 if error!="":return {"error":error}
 var candidate: Array = app.builds.duplicate(true);candidate[hero] = build
 error = app.camp_allocation_error(candidate)
 if error!="":return {"error":error}
 if not gifts.all(func(id):return build.any(func(die):return id in die)):return {"error":"Keep both chosen bonus abilities on the dice."}
 return {"error":"","camp":preview.encode().duplicate(true),"build":build,"gifts":gifts}
static func equip(app, starter: bool = false) -> void:
 var result := gear_plan(app,app.equipment_slot,app.camp_hero,app.camp_gear_candidate,starter)
 if result.error!="":app.camp_message = result.error;app.rebuild();return
 var bank = app.expedition.camp;var hero: int = app.camp_hero;var key: String = app.camp_gear_candidate
 match app.equipment_slot:
  "body":bank.equip_body(hero,key)
  "weapon":bank.equip_weapon(hero,key)
  "soul":bank.equip_soul(hero,key)
  "memory":
   if key=="":bank.memories[hero] = ""
   else:bank.equip_memory(hero,key)
 app.builds[hero] = result.build;app.gifts[hero] = result.gifts;app.expedition.save()
 app.camp_message = item_name(app,app.equipment_slot,app.camp_gear_candidate)+" equipped on "+M.NAMES[app.camp_hero]+(". Starter dice rebuilt; owned crafted copies are kept." if starter else ".");app.rebuild()
static func equipment(app, column: Control) -> void:
 heroes(app,column);var hero: int = app.camp_hero
 var slots := GridContainer.new();slots.columns = 4 if app.get_viewport_rect().size.x>=1000 else 2;slots.add_theme_constant_override("h_separation",8);slots.add_theme_constant_override("v_separation",8);column.add_child(slots)
 for slot in ["body","soul","memory","weapon"]:
  H.action(app,slots,slot.capitalize()+"\n"+item_name(app,slot,current(app,slot,hero)),func():app.equipment_slot = slot;app.camp_gear_context = "";app.rebuild(),"CampSlot_"+slot,app.GOLD if app.equipment_slot==slot else app.MUTED)
 var slot: String = app.equipment_slot;var available: Array = options(app,slot,hero);var context: String = str(hero)+slot
 if app.camp_gear_context!=context or app.camp_gear_candidate not in available:app.camp_gear_context = context;app.camp_gear_candidate = current(app,slot,hero)
 H.note(column,slot.capitalize()+" — what it controls",ROLES[slot])
 M.choose(app,column,"Choose an owned "+slot+" to preview",available.map(func(key):return item_name(app,slot,key)),available.find(app.camp_gear_candidate),func(index):app.camp_gear_candidate = available[index];app.rebuild(),"Mobile"+slot.capitalize()+"Picker" if app.mobile_mode else "Equipment_"+slot)
 if slot in ["soul","memory"]:
  var key: String = app.camp_gear_candidate
  var texture: Texture2D
  var frames := {"beginning":0,"hollow":1,"ashroad":2,"memory_loss":3}
  var wilds := {"mire_soul":"mire","glasswing_soul":"glasswing","iron_soul":"iron"}
  if key in frames:
   var region := AtlasTexture.new();region.atlas = app.CampUI.ITEM_ART;region.region = Rect2(frames[key]*16,0,16,16);texture = region
  elif key in wilds:texture = app.CampUI.NEW_SOUL_ART[wilds[key]]
  if texture:
   var image := TextureRect.new();image.name = "EquipmentSelectedSprite";image.texture = texture;image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;image.custom_minimum_size = Vector2(64,64);image.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN;image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;column.add_child(image)
 M.text(column,item_text(app,slot,app.camp_gear_candidate),20,app.GOLD).name = "EquipmentDetails"
 var plan := gear_plan(app,slot,hero,app.camp_gear_candidate)
 var unchanged: bool = app.camp_gear_candidate==current(app,slot,hero)
 if plan.error!="":
  M.text(column,"Your current dice do not fit: "+plan.error,18,Color("efb090"))
  var repaired := gear_plan(app,slot,hero,app.camp_gear_candidate,true)
  if repaired.error=="":
   H.note(column,"Option: use compatible starter dice","This changes only this hero’s dice. Your two bonuses are retained when possible; owned crafted abilities stay in the collection.")
   H.action(app,column,"Equip and rebuild starter dice",func():equip(app,true),"CampEquipStarter")
 else:M.text(column,"Already equipped." if unchanged else "Preview only. Press Equip to apply it; looking here spends nothing.",18)
 P.footer(app,["Back to Camp","Equip on "+M.NAMES[hero]],[func():open_task(app,-1),func():equip(app)],[false,plan.error!="" or unchanged])
 for b in app.ui.get_children():
  if b is Button and b.text=="Equip on "+M.NAMES[hero]:b.name = "CampEquipApply"
static func refit_error(app, face: int, hero: int, slot: Vector2i, remove: bool = false) -> String:
 if slot.x not in range(3) or slot.y not in range(6):return "Choose a side on the die."
 var raw: int = app.builds[hero][slot.x][slot.y]
 if remove and raw<60:return "This is a starter / bonus / Weapon side. Edit starter dice to change it."
 if not remove and raw==face:return "That ability is already on this side."
 var candidate: Array = app.builds.duplicate(true);candidate[hero][slot.x][slot.y] = 0 if remove else face
 var error: String = app.Model.validate(candidate[hero],app.gifts[hero],app.camp_build_profile(hero))
 if error=="":error = app.camp_allocation_error(candidate)
 if error=="" and not app.gifts[hero].all(func(id):return candidate[hero].any(func(die):return id in die)):error = "Keep both chosen bonuses on the dice."
 return error
static func refit(app, column: Control) -> void:
 heroes(app,column)
 var modes := M.row(column)
 H.action(app,modes,"Install an owned ability",func():app.camp_remove_mode = false;app.camp_slot = Vector2i(-1,-1);app.rebuild(),"CampInstallMode",app.GOLD if not app.camp_remove_mode else app.MUTED)
 H.action(app,modes,"Return a crafted ability",func():app.camp_remove_mode = true;app.camp_slot = Vector2i(-1,-1);app.rebuild(),"CampReturnMode",app.GOLD if app.camp_remove_mode else app.MUTED)
 var keys: Array = E.RECIPES.keys().filter(func(key):return E.RECIPES[key].has("face") and app.expedition.camp.unlocked.has(key))
 if keys.is_empty() and not app.camp_remove_mode:
  H.note(column,"No crafted abilities yet","First defeat creatures, then craft an ability using their matching Essence. Starter and bonus faces can be changed in the dice editor.")
  H.action(app,column,"Go to Craft upgrades",func():open_task(app,0),"CampStartCrafting")
  H.action(app,column,"Edit starter / bonus dice",func():app.build_hero = app.camp_hero;app.open_forge(false),"CampEditStarter",app.MUTED)
  P.footer(app,["Back to Camp"],[func():open_task(app,-1)]);return
 if app.camp_recipe not in keys and not keys.is_empty():app.camp_recipe = keys[0]
 var face: int = int(E.RECIPES[app.camp_recipe].get("face",-1)) if not keys.is_empty() else -1
 if not app.camp_remove_mode:
  M.choose(app,column,"1. Choose an owned ability",keys.map(func(key):return app.expedition.camp.reward_name(key)),keys.find(app.camp_recipe),func(index):app.camp_recipe = keys[index];app.camp_slot = Vector2i(-1,-1);app.rebuild(),"CampFacePicker")
  M.text(column,app.expedition.camp.reward_effect(app.camp_recipe),19)
  M.text(column,"Owned %d · On dice %d · Available %d" % [app.expedition.camp.owned(face),app.expedition.camp.allocated(app.builds,face),maxi(0,app.expedition.camp.owned(face)-app.expedition.camp.allocated(app.builds,face))],18,app.GOLD)
 M.text(column,"Choose the die, then the side to change. Nothing changes until you press the bottom button.",18)
 var dice := M.row(column)
 for die in range(3):H.action(app,dice,"Die "+str(die+1),func():app.forge_die = die;app.camp_slot = Vector2i(-1,-1);app.rebuild(),"CampDie"+str(die),app.GOLD if die==app.forge_die else app.MUTED)
 var grid := GridContainer.new();grid.columns = 3;grid.add_theme_constant_override("h_separation",6);grid.add_theme_constant_override("v_separation",6);column.add_child(grid)
 var width: float = (column.custom_minimum_size.x-12)/3
 for side in range(6):
  var shown: int = app.camp_display_face(app.camp_hero,app.forge_die,side)
  var b: Button = H.action(app,grid,app.Catalog.name_for(shown),func():app.camp_slot = Vector2i(app.forge_die,side);app.rebuild(),"CampSlot%d_%d" % [app.forge_die,side],app.color_for_face(shown))
  M.fit_button(b,Vector2(width,64),17);b.custom_minimum_size = Vector2(width,64)
 var error: String = refit_error(app,face,app.camp_hero,app.camp_slot,app.camp_remove_mode)
 if app.camp_slot.x>=0:
  var shown: int = app.camp_display_face(app.camp_hero,app.camp_slot.x,app.camp_slot.y)
  M.text(column,("Return "+app.Catalog.name_for(shown)+" to the collection. It remains owned." if app.camp_remove_mode else "Replace "+app.Catalog.name_for(shown)+" with "+app.Catalog.name_for(face)+". No Essence cost."),20,app.GOLD)
 M.text(column,error if error!="" else "Ready. This changes only the selected side.",18,Color("efb090") if error!="" else app.MUTED)
 P.footer(app,["Back to Camp","Return to collection" if app.camp_remove_mode else "Install ability"],[func():open_task(app,-1),func():
  if refit_error(app,face,app.camp_hero,app.camp_slot,app.camp_remove_mode)!="":return
  if app.camp_remove_mode:app.camp_remove(app.camp_hero,app.camp_slot.x,app.camp_slot.y)
  else:app.camp_place(face,app.camp_hero,app.camp_slot.x,app.camp_slot.y)],[false,error!=""])
 for b in app.ui.get_children():
  if b is Button and b.text in ["Install ability","Return to collection"]:b.name = "CampRefitApply"
static func creatures(app, column: Control) -> void:
 M.text(column,"Win the whole fight to bank matching Essence. These optional fights do not advance your road event.",19)
 var groups := H.grid(app,column)
 for index in range(app.Wilds.GROUPS.size()):
  var group: Dictionary = app.Wilds.GROUPS[index]
  var c := H.card(app,groups,group.title,group.description)
  M.text(c,group.reward,18,Color("9acfc0"))
  H.action(app,c,"Fight this group",func():app.start_creature_encounter(index),"MobileFight"+str(index) if app.mobile_mode else "FightCreature"+str(index))
 P.footer(app,["Back to Camp","Prepare party first"],[func():open_task(app,-1),app.open_normal])
