extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const R = preload("res://prototype/trial_rules.gd")
const C = preload("res://prototype/trial_content.gd")
const T = preload("res://prototype/trial_encounter.gd")
static func act(app, column: Control, text: String, fn: Callable, name: String, color: Color = Color("e6c58c"), disabled: bool = false) -> Button:
 var button := M.btn(app,column,text,fn,color,disabled);button.name = name;return button
static func render(app) -> void:
 var run = app.trials
 if app.trial_view=="guide":guide(app);return
 if app.trial_view=="craft":crafting(app);return
 if app.trial_view=="builds":build_ideas(app);return
 if run.phase=="lobby":lobby(app);return
 if run.phase in ["failed","complete"]:ending(app);return
 var title: String = "Boss gate" if run.stage==5 else "Stop %d / 5" % [run.stage+1]
 var column := P.panel(app,"TRIALS · "+title,"%d Trial Essence · HP carries between fights" % run.essence)
 if run.message!="":M.text(column,run.message,20,app.GOLD)
 if run.wishlist!="":act(app,column,"Wishlist · "+run.wishlist_progress(),func():app.trial_view = "craft";app.rebuild(),"TrialPinned",Color("9acdb6"))
 var party := M.row(column)
 for id in range(3):M.text(party,"%s · %d HP" % [M.NAMES[id],int(run.hp[id])],20,app.COLORS[id])
 match run.phase:
  "route":route(app,column)
  "reward":reward(app,column);return
  "camp":
   M.text(column,"A quiet camp",28,app.GOLD)
   M.text(column,"Rest restores 2 HP to every hero, including fallen heroes. Or gather supplies for +2 Trial Essence. Pick one.")
   act(app,column,"Rest · heal everyone 2",func():run.camp(true);app.rebuild(),"TrialRest")
   act(app,column,"Gather · +2 Trial Essence",func():run.camp(false);app.rebuild(),"TrialGather")
  "event":
   M.text(column,"Buried cache",28,app.GOLD)
   M.text(column,"Take +1 Trial Essence safely. Or search: d6 4–6 grants +5 Essence; 1–3 costs each hero 1 HP. This can fell the party. One roll only.")
   act(app,column,"Take the safe cache · +1",func():run.event(false);app.rebuild(),"TrialCacheSafe")
   act(app,column,"Search deeper · 50% chance",func():run.event(true);app.rebuild(),"TrialCacheRisk",Color("df897f"))
 P.footer(app,["Main menu","Trial Forge","Equipment / help"],[app.go_main,func():app.trial_view = "craft";app.rebuild(),func():app.trial_view = "guide";app.rebuild()])
static func lobby(app) -> void:
 var run = app.trials;var wide: bool = app.get_viewport_rect().size.x>app.get_viewport_rect().size.y
 var subtitle: String = "%s · %d maximum HP · equip each hero" % [M.NAMES[run.hero],run.maximum_hp(run.hero)] if wide else "Test expedition · equip each hero"
 var column := P.panel(app,"TRIALS",subtitle)
 if not wide:M.text(column,"Equip three heroes. Five stops, then a boss. Rewards stay in Trials.",21)
 var tabs := M.row(column)
 for id in range(3):act(app,tabs,M.NAMES[id],func():run.hero = id;app.rebuild(),"TrialHero"+str(id),app.COLORS[id] if run.hero==id else app.MUTED)
 if not wide:M.text(column,"Maximum HP: %d" % run.maximum_hp(run.hero),22,app.COLORS[run.hero])
 var slots := GridContainer.new();slots.columns = 4 if app.get_viewport_rect().size.x>app.get_viewport_rect().size.y else 2;slots.add_theme_constant_override("h_separation",10);slots.add_theme_constant_override("v_separation",10);column.add_child(slots)
 var labels := {"body":R.BODIES[run.bodies[run.hero]].name,"memory":R.MEMORIES[run.memories[run.hero]].name,"soul":R.SOULS[run.souls[run.hero]].name if run.souls[run.hero]!="" else "Beginning Soul","weapon":R.WEAPONS[run.loadout_weapons[run.hero]].name}
 for slot in ["body","memory","soul","weapon"]:
  var pick := act(app,slots,slot.capitalize()+"\n"+labels[slot],func():app.trial_slot = slot;app.rebuild(),"TrialSlot_"+slot,app.GOLD if app.trial_slot==slot else app.MUTED)
  pick.add_theme_font_size_override("font_size",18);pick.custom_minimum_size.y = 84
 match app.trial_slot:
  "body":
   var keys: Array = run.available("body")
   M.choose(app,column,"Body",keys.map(func(key):return R.BODIES[key].name),keys.find(run.bodies[run.hero]),func(index):run.bodies[run.hero] = keys[index];run.save();app.rebuild(),"TrialBody")
   M.text(column,R.BODIES[run.bodies[run.hero]].text,20)
  "memory":
   var keys: Array = run.available("memory")
   M.choose(app,column,"Memory",keys.map(func(key):return R.MEMORIES[key].name),keys.find(run.memories[run.hero]),func(index):run.memories[run.hero] = keys[index];app.rebuild(),"TrialMemory")
   M.text(column,R.MEMORIES[run.memories[run.hero]].text,21)
  "soul":
   var souls: Array = run.available("soul")
   M.choose(app,column,"Soul",souls.map(func(key):return R.SOULS[key].name if key!="" else "Beginning Soul"),maxi(0,souls.find(run.souls[run.hero])),func(index):run.souls[run.hero] = souls[index];app.rebuild(),"TrialSoul")
   M.text(column,R.SOULS[run.souls[run.hero]].text if run.souls[run.hero]!="" else "Spend one rolled Blank as Move 1, once per own turn. Defeat bosses to unlock other Souls.",20)
  "weapon":
   var keys: Array = run.available("weapon")
   M.choose(app,column,"Weapon",keys.map(func(key):return R.WEAPONS[key].name),keys.find(run.loadout_weapons[run.hero]),func(index):run.loadout_weapons[run.hero] = keys[index];run.save();app.rebuild(),"TrialWeapon")
   M.text(column,R.WEAPONS[run.loadout_weapons[run.hero]].text,21)
 M.choose(app,column,"Final boss",run.BOSS_NAMES,run.selected_boss,func(index):run.selected_boss = index;app.rebuild(),"TrialBoss")
 act(app,column,"Equipment & how to play",func():app.trial_view = "guide";app.rebuild(),"TrialPreview",app.MUTED)
 P.footer(app,["Main menu","Forge / builds","Begin Trial"],[app.go_main,func():app.trial_view = "craft";app.rebuild(),func():run.start();app.trial_view = "run";app.rebuild()])
static func route(app, column: Control) -> void:
 var run = app.trials
 M.text(column,"Battle → Camp / battle → Battle → Cache / elite → Camp / elite → Boss",18,app.MUTED)
 var choices: Array = run.options()
 for index in range(choices.size()):
  var choice: Dictionary = choices[index]
  if choice.kind=="fight" and choice.get("objective","")!="":
   var objective: Dictionary = C.OBJECTIVES[choice.objective]
   M.text(column,objective.name,25,Color("a9cbe8"));M.text(column,objective.text,20)
   act(app,column,"Enter objective encounter",func():app.choose_trial_route(index),"TrialRoute"+str(index))
  elif choice.kind=="fight":
   var group: Dictionary = T.GROUPS[choice.group];var elite: bool = choice.elite
   var caption: String = group.title+(" · ELITE" if elite else "")
   var units: Array = group.roles.duplicate()
   if elite:units.append(group.elite)
   var stats: Array = units.map(func(role):return T.ROLES[role].name+" %d HP" % (int(T.ROLES[role].hp)+(1 if elite else 0)))
   M.text(column,caption,25,Color("df897f") if elite else app.GOLD)
   M.text(column," · ".join(stats),19,app.MUTED);M.text(column,group.text+"\nDrops: %d " % (3 if elite else 2)+C.ESSENCE[C.reward_source(choice)].name,20)
   act(app,column,"Fight · +%d Essence, then choose a reward" % (4 if elite else 2),func():app.choose_trial_route(index),"TrialRoute"+str(index))
  elif choice.kind=="camp":
   M.text(column,"Camp",27,app.GOLD);M.text(column,"Heal everyone 2, or gather +2 Trial Essence. No fight.",21)
   act(app,column,"Take the Camp route",func():app.choose_trial_route(index),"TrialRoute"+str(index))
  elif choice.kind=="event":
   M.text(column,"Buried cache",27,app.GOLD);M.text(column,"Safe +1 Essence, or a 50% chance of +5 with a party HP risk.",21)
   act(app,column,"Explore the cache",func():app.choose_trial_route(index),"TrialRoute"+str(index))
  else:
   M.text(column,run.BOSS_NAMES[run.selected_boss],28,app.GOLD)
   M.text(column,"Victory unlocks "+R.SOULS[choice.boss].name+" for future Trials.\n"+R.SOULS[choice.boss].text,21)
   act(app,column,"Enter the final arena",func():app.choose_trial_route(index),"TrialRoute"+str(index))
static func reward(app, column: Control) -> void:
 var run = app.trials
 M.text(column,"Choose one reward",27,app.GOLD)
 var tabs := M.row(column)
 for id in range(3):act(app,tabs,M.NAMES[id],func():run.hero = id;run.reward_face = run.reward_faces(id)[0];app.rebuild(),"TrialRewardHero"+str(id),app.COLORS[id] if id==run.hero else app.MUTED)
 var actions := M.row(column)
 act(app,actions,"New face · 2 Essence",func():run.reward_mode = "face";run.reward_face = run.reward_faces(run.hero)[0];app.rebuild(),"TrialRewardFace",app.GOLD,run.essence<2)
 act(app,actions,"Weapon · 2 Essence",func():run.reward_mode = "weapon";app.rebuild(),"TrialRewardWeapon",app.GOLD,run.essence<2)
 if run.reward_mode=="":M.text(column,"Choose a new dice ability, equip a Weapon, or take +2 Essence. One reward per victory.",21)
 else:
  if run.reward_mode=="face":
   var faces: Array = run.reward_faces(run.hero)
   M.choose(app,column,"New ability",faces.map(func(face):return app.Catalog.name_for(face)),maxi(0,faces.find(run.reward_face)),func(index):run.reward_face = faces[index];app.rebuild(),"TrialRewardChoice")
   M.text(column,app.AbilityCopy.new().face(run.reward_face),20)
   M.text(column,"Choose a side to replace. Keep two Blanks per die and normal category/copy caps. The new physical face belongs to this Trial.",18,app.MUTED)
  else:
   var weapons: Array = ["venom","heavy","spear","hammer"]
   M.choose(app,column,"Weapon",weapons.map(func(key):return R.WEAPONS[key].name),maxi(0,weapons.find(run.reward_weapon)),func(index):run.reward_weapon = weapons[index];app.rebuild(),"TrialWeaponChoice")
   M.text(column,R.WEAPONS[run.reward_weapon].text,21)
   M.text(column,"Replaces this hero’s Weapon. Spear / Hammer replace one Strike side with Jab / Crack; physical dice limits stay the same.",19,app.MUTED)
   act(app,column,"Equip "+R.WEAPONS[run.reward_weapon].name,func():run.equip_weapon(run.reward_weapon);app.rebuild(),"TrialEquipWeapon",app.GOLD,run.weapons[run.hero]==run.reward_weapon)
   P.footer(app,["Main menu","Take +2 Essence"],[app.go_main,func():run.bank_reward();app.rebuild()]);return
  var dice := M.row(column)
  for die in range(3):act(app,dice,"Die "+str(die+1),func():app.trial_die = die;app.rebuild(),"TrialDie"+str(die),app.GOLD if die==app.trial_die else app.MUTED)
  var grid := GridContainer.new();grid.columns = 2;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);column.add_child(grid)
  for side in range(6):
   var face: int = run.builds[run.hero][app.trial_die][side]
   var caption: String = "%d · %s" % [side+1,app.Catalog.name_for(run.display_face(run.hero,face,app.trial_die,side))]
   act(app,grid,caption,func():
    run.add_face(run.reward_face,app.trial_die,side)
    app.rebuild(),"TrialSlot"+str(side),app.color_for_face(face))
 P.footer(app,["Main menu","Take +2 Essence"],[app.go_main,func():run.bank_reward();app.rebuild()])
static func guide(app) -> void:
 var run = app.trials;var column := P.panel(app,"Equipment & arena help","")
 if app.page=="battle":
  if app.game.has_method("objective_summary") and app.game.objective_summary()!="":
   M.text(column,app.game.objective_summary(),26,app.GOLD)
   M.text(column,app.game.rupture_help() if app.game.has_method("rupture_help") else C.OBJECTIVES[app.game.objective_mode].text,21)
  M.text(column,R.guide(app.game),21)
  if app.game.encounter_id=="event":
   for id in [3]+app.game.living_minions():
    var unit: Dictionary = app.game.unit_data(id)
    if not unit.has("trial_role"):continue
    M.text(column,app.game.unit_name(id)+" · %d HP · %d Block" % [unit.hp,unit.block],24,app.GOLD)
    for die in T.ROLES[unit.trial_role].dice:M.text(column," · ".join(die),18)
    if int(unit.get("loot",0))>0:M.text(column,"Carrying %d stolen Trial Essence" % int(unit.loot),20,app.GOLD)
 else:
  M.text(column,"Four equipment slots",27,app.GOLD)
  M.text(column,"Body sets your base HP and dice limits. Memory gives its listed automatic effect. Soul changes what your Blanks can do or adds its listed effect. Weapon supplies its listed action or replaces Strike with a weapon face. Each hero equips one of each.",21)
  var shown_builds: Array = run.starting_builds() if run.phase=="lobby" else run.builds
  for id in range(3):
   M.text(column,M.NAMES[id],25,app.COLORS[id])
   M.text(column,"Body: "+R.BODIES[run.bodies[id]].name+"\n"+R.BODIES[run.bodies[id]].text+"\nMemory: "+R.MEMORIES[run.memories[id]].name+"\n"+R.MEMORIES[run.memories[id]].text,20)
   var soul_key: String = run.souls[id]
   M.text(column,"Soul: "+(R.SOULS[soul_key].name+"\n"+R.SOULS[soul_key].text if soul_key!="" else "Beginning Soul · one Blank as Move 1 per own turn"),20)
   var weapon_key: String = run.loadout_weapons[id] if run.phase=="lobby" else run.weapons[id]
   M.text(column,"Weapon: "+R.WEAPONS[weapon_key].name+"\n"+R.WEAPONS[weapon_key].text,20)
   if shown_builds.size()==3:
    for die in range(3):M.text(column,"Die %d: " % [die+1]+" · ".join(range(6).map(func(side):return app.Catalog.name_for(run.display_face(id,int(shown_builds[id][die][side]),die,side)))),19)
  for group in T.GROUPS:M.text(column,group.title+"\n"+group.text,21,app.GOLD)
  for key in run.BOSSES:
   var card: Button = act(app,column,R.SOULS[key].name+(" · owned" if key in run.completed_bosses else " · locked"),func():app.mobile_info = R.SOULS[key].text;app.rebuild(),"TrialSoulCard_"+key,app.GOLD if key in run.completed_bosses else app.MUTED)
   app.bind_unlock(card,"trial_soul",key,run.hero)
   M.text(column,R.SOULS[key].text+("\nUnlocked" if key in run.completed_bosses else "\nDefeat "+run.BOSS_NAMES[run.BOSSES.find(key)]+" in Trials"),20)
  if app.debug_mode:M.text(column,"Debug: hold a locked Trial Soul to unlock it for testing.",19,app.GOLD)
 P.footer(app,["Back"],[func():app.trial_view = "run";app.show_trial_guide = false;app.rebuild()])
static func outcome(app) -> void:
 var run = app.trials;run.finish(app.game)
 var column := P.panel(app,"Trial victory" if app.game.outcome=="victory" else "Trial ended","")
 M.text(column,run.message,26,app.GOLD)
 if run.last_progress!="":M.text(column,run.last_progress,22,Color("9acdb6"))
 M.text(column,"%d Trial Essence · %d HP remaining across the party" % [run.essence,int(run.hp.reduce(func(a,b):return int(a)+int(b),0))],21)
 if run.phase=="reward":M.text(column,"Choose a dice ability, a Weapon, or +2 Essence before the next stop.",21)
 if int(app.game.trial_state.get("escaped",0))>0:M.text(column,"Escaped thieves kept %d Essence." % int(app.game.trial_state.escaped),20)
 P.footer(app,["Battle log","Continue"],[func():app.show_history = true;app.rebuild(),app.continue_trial])
static func ending(app) -> void:
 var run = app.trials;var column := P.panel(app,"Trial complete" if run.phase=="complete" else "Trial ended","")
 M.text(column,run.message,26,app.GOLD)
 M.text(column,"Trial Souls collected: %d / 4" % run.completed_bosses.size(),22)
 for line in run.history:M.text(column,str(line),18,app.MUTED)
 M.text(column,"Safe route and reward checkpoints can be resumed. Leaving or reloading during a fight ends that Trial without a victory reward. Your normal Camp collection remains separate.",20)
 P.footer(app,["Main menu","Trial Forge","New Trial"],[app.go_main,func():app.trial_view = "craft";app.rebuild(),func():run.phase = "lobby";run.save();app.rebuild()])

static func options(app) -> void:
 var column := P.panel(app,"Trial options","")
 act(app,column,"Sound & volume",func():app.show_soundtrack = true;app.rebuild(),"TrialSound")
 act(app,column,"Action Rerolls: "+("Any time" if app.game.v("hero.reroll_anytime") else "Opening only"),func():app.game.balance["hero.reroll_anytime"] = 0 if app.game.v("hero.reroll_anytime") else 1;app.rebuild(),"TrialRerollOption")
 act(app,column,"Main menu · leave Trial fight",app.go_main,"TrialLeave",app.MUTED)
 P.footer(app,["Back to battle"],[func():app.show_options = false;app.rebuild()])

static func menu(app) -> void:
 var column := P.panel(app,"Trial menu","")
 act(app,column,"Equipment & arena help",func():app.show_menu = false;app.show_trial_guide = true;app.rebuild(),"TrialMenuGuide")
 act(app,column,"Enemy intents",func():app.show_menu = false;app.show_intents = true;app.rebuild(),"TrialMenuIntents")
 act(app,column,"Full battle log",func():app.show_menu = false;app.show_history = true;app.rebuild(),"TrialMenuLog")
 act(app,column,"Sound & volume",func():app.show_menu = false;app.show_soundtrack = true;app.rebuild(),"TrialMenuSound")
 act(app,column,"Options",func():app.show_menu = false;app.show_options = true;app.rebuild(),"TrialMenuOptions")
 P.footer(app,["Return to battle","Main menu · leave Trial"],[func():app.show_menu = false;app.rebuild(),app.go_main])

static func crafting(app) -> void:
 var run = app.trials;var column := P.panel(app,"Trial Forge", "This collection stays in Trials")
 M.text(column,"Craft equipment with Essence from Trial victories. Crafted pieces stay available for future Trials. Equip them in the lobby before beginning a new run. Fight rewards still use carried Trial Essence.",20)
 if run.wishlist!="":M.text(column,"PINNED · "+run.wishlist_progress(),22,Color("9acdb6"))
 var keys: Array = C.RECIPES.keys()
 if app.trial_recipe not in keys:app.trial_recipe = keys[0]
 M.choose(app,column,"Equipment recipe",keys.map(func(key):return C.RECIPES[key].name+" · "+C.RECIPES[key].slot.capitalize()),keys.find(app.trial_recipe),func(index):app.trial_recipe = keys[index];app.rebuild(),"TrialRecipe")
 var key: String = app.trial_recipe;var recipe: Dictionary = C.RECIPES[key]
 M.text(column,recipe.name,27,app.GOLD);M.text(column,run.recipe_effect(key),21)
 for type in recipe.cost:
  M.text(column,"%d / %d %s" % [int(run.ingredients.get(type,0)),int(recipe.cost[type]),C.ESSENCE[type].name],23,Color("9acdb6"))
  M.text(column,"Find it: "+C.ESSENCE[type].source,20)
 var ready: bool = key not in run.crafted and recipe.cost.keys().all(func(type):return int(run.ingredients.get(type,0))>=int(recipe.cost[type]))
 var card := act(app,column,"Already crafted" if key in run.crafted else "Craft "+recipe.name,func():run.craft(key);app.rebuild(),"TrialCraft",app.GOLD,not ready)
 # A separate inspectable card remains enabled for the existing Debug hold gesture.
 if app.debug_mode and key not in run.crafted:
  var unlock := act(app,column,"Debug · hold to unlock "+recipe.name,func():pass,"TrialCraftUnlock",app.MUTED)
  app.bind_unlock(unlock,"trial_recipe",key,0)
 act(app,column,"Unpin wishlist" if run.wishlist==key else "Pin to wishlist",func():run.pin(key);app.rebuild(),"TrialPin",Color("9acdb6"))
 if run.message!="":M.text(column,run.message,20,app.GOLD)
 P.footer(app,["Back","Build ideas"],[func():app.trial_view = "run";app.rebuild(),func():app.trial_view = "builds";app.rebuild()])
static func build_ideas(app) -> void:
 var run = app.trials;var column := P.panel(app,"Equipment combinations","Four slots · no extra upgrade category")
 var tabs := M.row(column)
 for id in range(3):act(app,tabs,M.NAMES[id],func():run.hero = id;app.rebuild(),"TrialBuildHero"+str(id),app.COLORS[id] if run.hero==id else app.MUTED)
 M.text(column,"Suggested combinations explain a turn sequence. Applying one changes this hero’s four slots only, using starter equipment for missing pieces. Your dice layout stays unchanged.",20)
 for key in C.BUILDS:
  var build: Dictionary = C.BUILDS[key]
  M.text(column,build.name,27,app.GOLD);M.text(column,build.text,21)
  var equipment: Array[String] = [R.BODIES[build.body].name,R.MEMORIES[build.memory].name,R.WEAPONS[build.weapon].name,R.SOULS[build.soul].name if build.soul!="" else "Beginning Soul"]
  M.text(column," · ".join(equipment),19,Color("a9cbe8"))
  if run.phase=="lobby":act(app,column,"Apply available pieces to "+M.NAMES[run.hero],func():run.apply_build(key,run.hero);app.rebuild(),"TrialBuild_"+key)
  for recipe_key in C.RECIPES:
   var recipe: Dictionary = C.RECIPES[recipe_key]
   if recipe.item==build.get(recipe.slot,"") and recipe_key not in run.crafted:
    act(app,column,"Inspect / pin "+recipe.name,func():app.trial_recipe = recipe_key;app.trial_view = "craft";app.rebuild(),"TrialBuildRecipe_"+recipe_key,app.MUTED)
 if run.message!="":M.text(column,run.message,20,app.GOLD)
 P.footer(app,["Back","Trial Forge"],[func():app.trial_view = "run";app.rebuild(),func():app.trial_view = "craft";app.rebuild()])
