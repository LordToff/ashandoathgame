extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const R = preload("res://prototype/trial_rules.gd")
const K = preload("res://prototype/trial_classes.gd")
const C = preload("res://prototype/trial_content.gd")
const T = preload("res://prototype/trial_encounter.gd")
static func act(app, column: Control, text: String, fn: Callable, name: String, color: Color = Color("e6c58c"), disabled: bool = false) -> Button:
 var button := M.btn(app,column,text,fn,color,disabled);button.name = name;return button
static func render(app) -> void:
 var run = app.trials
 if app.trial_view=="classes":classes(app);return
 if app.trial_view=="guide":guide(app);return
 if app.trial_view=="craft":crafting(app);return
 if app.trial_view=="builds":build_ideas(app);return
 if run.phase=="lobby":lobby(app);return
 if run.phase in ["failed","complete"]:ending(app);return
 var title: String = "Boss gate" if run.stage==5 else "Stop %d / 5" % [run.stage+1]
 var column := P.panel(app,"TRIALS · "+title,"%d Run Essence · HP carries between fights" % run.essence)
 if run.message!="":M.text(column,run.message,20,app.GOLD)
 if run.wishlist!="":act(app,column,"Wishlist · "+run.wishlist_progress(),func():app.trial_view = "craft";app.rebuild(),"TrialPinned",Color("9acdb6"))
 var party := M.row(column)
 for id in range(3):M.text(party,"%s · %d HP" % [M.NAMES[id],int(run.hp[id])],20,app.COLORS[id])
 match run.phase:
  "route":route(app,column)
  "reward":reward(app,column);return
  "camp":
   M.text(column,"A quiet camp",28,app.GOLD)
   M.text(column,"Rest restores 2 HP to every hero, including fallen heroes. Or gather supplies for +2 Run Essence. Pick one.")
   act(app,column,"Rest · heal everyone 2",func():run.camp(true);app.rebuild(),"TrialRest")
   act(app,column,"Gather · +2 Run Essence",func():run.camp(false);app.rebuild(),"TrialGather")
  "event":
   M.text(column,"Buried cache",28,app.GOLD)
   M.text(column,"Take +1 Run Essence safely. Or search: d6 4–6 grants +5 Essence; 1–3 costs each hero 1 HP. This can fell the party. One roll only.")
   act(app,column,"Take the safe cache · +1",func():run.event(false);app.rebuild(),"TrialCacheSafe")
   act(app,column,"Search deeper · 50% chance",func():run.event(true);app.rebuild(),"TrialCacheRisk",Color("df897f"))
 P.footer(app,["Main menu","Trial Forge","Equipment / help"],[app.go_main,func():app.trial_view = "craft";app.rebuild(),func():app.trial_view = "guide";app.rebuild()])
static func lobby(app) -> void:
 var run = app.trials;run.ensure_classes();var wide: bool = app.get_viewport_rect().size.x>app.get_viewport_rect().size.y
 var subtitle: String = "%s · %s · %d maximum HP" % [M.NAMES[run.hero],run.class_label(run.hero),run.maximum_hp(run.hero)] if wide else "Choose a class for each hero"
 var column := P.panel(app,"TRIALS",subtitle)
 M.text(column,"Choose a hero → tap a gear slot → Begin Trial. Tap Class to compare the two starting kits.",18,app.MUTED)
 var tabs := M.row(column)
 for id in range(3):act(app,tabs,M.NAMES[id],func():run.hero = id;app.rebuild(),"TrialHero"+str(id),app.COLORS[id] if run.hero==id else app.MUTED)
 var class_key: String = run.classes[run.hero]
 var class_card := act(app,column,"Class · "+run.class_label(run.hero)+" · %d HP\nChange class / see starter dice" % run.maximum_hp(run.hero),func():app.trial_class_preview = class_key;app.trial_class_die = 0;app.trial_view = "classes";app.rebuild(),"TrialClassOverview",app.COLORS[run.hero])
 class_card.add_theme_font_size_override("font_size",20)
 var slots := GridContainer.new();slots.columns = 4 if app.get_viewport_rect().size.x>app.get_viewport_rect().size.y else 2;slots.add_theme_constant_override("h_separation",10);slots.add_theme_constant_override("v_separation",10);column.add_child(slots)
 var labels := {"body":R.BODIES[run.bodies[run.hero]].name,"memory":R.MEMORIES[run.memories[run.hero]].name,"soul":R.SOULS[run.souls[run.hero]].name if run.souls[run.hero]!="" else "Beginning Soul","weapon":R.WEAPONS[run.loadout_weapons[run.hero]].name}
 for slot in ["body","memory","soul","weapon"]:
  var pick := act(app,slots,slot.capitalize()+"\n"+labels[slot],func():app.trial_slot = slot;app.rebuild(),"TrialSlot_"+slot,app.GOLD if app.trial_slot==slot else app.MUTED)
  pick.add_theme_font_size_override("font_size",18);pick.custom_minimum_size.y = 68
 M.text(column,{"body":"BODY · base HP and normal movement modifiers", "memory":"MEMORY · an automatic effect; no button to activate it", "soul":"SOUL · what rolled Blanks can do", "weapon":"WEAPON · an attack face, or a separate Poke action"}.get(app.trial_slot,""),18,app.GOLD)
 match app.trial_slot:
  "body":
   var keys: Array = run.available("body")
   M.choose(app,column,"Body",keys.map(func(key):return R.BODIES[key].name),keys.find(run.bodies[run.hero]),func(index):run.bodies[run.hero] = keys[index];run.save();app.rebuild(),"TrialBody")
   M.text(column,R.BODIES[run.bodies[run.hero]].text,20)
   M.text(column,"Your class includes its starting Body free. Crafting unlocks that Body for other classes.",18,app.MUTED)
  "memory":
   var keys: Array = run.available("memory")
   M.choose(app,column,"Memory",keys.map(func(key):return R.MEMORIES[key].name),keys.find(run.memories[run.hero]),func(index):run.memories[run.hero] = keys[index];run.save();app.rebuild(),"TrialMemory")
   M.text(column,R.MEMORIES[run.memories[run.hero]].text,21)
  "soul":
   var souls: Array = run.available("soul")
   M.choose(app,column,"Soul",souls.map(func(key):return R.SOULS[key].name if key!="" else "Beginning Soul"),maxi(0,souls.find(run.souls[run.hero])),func(index):run.choose_soul(run.hero,souls[index]);app.rebuild(),"TrialSoul")
   M.text(column,R.SOULS[run.souls[run.hero]].text if run.souls[run.hero]!="" else "Spend one rolled Blank as Move 1, once per own turn. Defeat bosses to unlock other Souls.",20)
  "weapon":
   var keys: Array = run.available("weapon")
   M.choose(app,column,"Weapon",keys.map(func(key):return R.WEAPONS[key].name),keys.find(run.loadout_weapons[run.hero]),func(index):run.loadout_weapons[run.hero] = keys[index];run.save();app.rebuild(),"TrialWeapon")
   M.text(column,R.WEAPONS[run.loadout_weapons[run.hero]].text,21)
 if run.souls[run.hero]=="soulcaster":act(app,column,"Soulcaster · spellbook & actual starter dice",func():app.trial_help_topic = "My heroes";app.trial_view = "guide";app.rebuild(),"TrialSoulcasterHelp",Color("c5a5e8"))
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
   act(app,column,"Fight · +%d Run Essence, then choose a reward" % (4 if elite else 2),func():app.choose_trial_route(index),"TrialRoute"+str(index))
  elif choice.kind=="camp":
   M.text(column,"Camp",27,app.GOLD);M.text(column,"Heal everyone 2, or gather +2 Run Essence. No fight.",21)
   act(app,column,"Take the Camp route",func():app.choose_trial_route(index),"TrialRoute"+str(index))
  elif choice.kind=="event":
   M.text(column,"Buried cache",27,app.GOLD);M.text(column,"Safe +1 Run Essence, or a 50% chance of +5 with a party HP risk.",21)
   act(app,column,"Explore the cache",func():app.choose_trial_route(index),"TrialRoute"+str(index))
  else:
   M.text(column,run.BOSS_NAMES[run.selected_boss],28,app.GOLD)
   M.text(column,"Victory unlocks "+R.SOULS[choice.boss].name+" for future Trials.\n"+R.SOULS[choice.boss].text,21)
   act(app,column,"Enter the final arena",func():app.choose_trial_route(index),"TrialRoute"+str(index))
static func reward(app, column: Control) -> void:
 var run = app.trials
 M.text(column,"Choose one reward",27,app.GOLD)
 var tabs := M.row(column)
 for id in range(3):act(app,tabs,M.NAMES[id],func():run.hero = id;run.reward_face = run.reward_faces(id)[0];app.trial_replacement = Vector2i(-1,-1);app.rebuild(),"TrialRewardHero"+str(id),app.COLORS[id] if id==run.hero else app.MUTED)
 var actions := M.row(column)
 act(app,actions,"New face · 2 Run Essence",func():run.reward_mode = "face";run.reward_face = run.reward_faces(run.hero)[0];app.rebuild(),"TrialRewardFace",app.GOLD,run.essence<2)
 act(app,actions,"Weapon · 2 Run Essence",func():run.reward_mode = "weapon";app.rebuild(),"TrialRewardWeapon",app.GOLD,run.essence<2)
 if run.reward_mode=="":M.text(column,"Choose a new dice ability, equip a Weapon, or take +2 Run Essence. One reward per victory.",21)
 else:
  if run.reward_mode=="face":
   var faces: Array = run.reward_faces(run.hero)
   M.choose(app,column,"New ability",faces.map(func(face):return app.Catalog.name_for(face)),maxi(0,faces.find(run.reward_face)),func(index):run.reward_face = faces[index];app.trial_replacement = Vector2i(-1,-1);app.rebuild(),"TrialRewardChoice")
   M.text(column,app.AbilityCopy.new().face(run.reward_face),20)
   M.text(column,"Choose a side to replace. Keep four Blanks per Soulcaster die, two for other Souls and normal category/copy caps. The new physical face belongs to this Trial.",18,app.MUTED)
  else:
   var weapons: Array = ["venom","heavy","spear","hammer"]
   M.choose(app,column,"Weapon",weapons.map(func(key):return R.WEAPONS[key].name),maxi(0,weapons.find(run.reward_weapon)),func(index):run.reward_weapon = weapons[index];app.rebuild(),"TrialWeaponChoice")
   M.text(column,R.WEAPONS[run.reward_weapon].text,21)
   M.text(column,"Replaces this hero’s Weapon. Spear / Hammer replace one Strike side with Jab / Crack; physical dice limits stay the same.",19,app.MUTED)
   act(app,column,"Equip "+R.WEAPONS[run.reward_weapon].name,func():run.equip_weapon(run.reward_weapon);app.rebuild(),"TrialEquipWeapon",app.GOLD,run.weapons[run.hero]==run.reward_weapon)
   P.footer(app,["Main menu","Take +2 Run Essence"],[app.go_main,func():run.bank_reward();app.rebuild()]);return
  var dice := M.row(column)
  for die in range(3):act(app,dice,"Die "+str(die+1),func():app.trial_die = die;app.rebuild(),"TrialDie"+str(die),app.GOLD if die==app.trial_die else app.MUTED)
  var grid := GridContainer.new();grid.columns = 2;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);column.add_child(grid)
  for side in range(6):
   var face: int = run.builds[run.hero][app.trial_die][side]
   var error: String = run.replacement_error(run.reward_face,app.trial_die,side)
   var caption: String = app.Catalog.name_for(run.display_face(run.hero,face,app.trial_die,side))+(" · unavailable" if error!="" else " → "+app.Catalog.name_for(run.reward_face))
   act(app,grid,caption,func():
    app.trial_replacement = Vector2i(app.trial_die,side)
    run.message = error if error!="" else "Replace "+app.Catalog.name_for(face)+" with "+app.Catalog.name_for(run.reward_face)+" for 2 Run Essence. This run only."
    app.rebuild(),"TrialSlot"+str(side),app.MUTED if error!="" else app.color_for_face(face))
 var chosen: Vector2i = app.trial_replacement
 var can_buy: bool = run.reward_mode=="face" and run.replacement_error(run.reward_face,chosen.x,chosen.y)==""
 P.footer(app,["Main menu","Take +2 Run Essence","Buy · 2"],[app.go_main,func():app.trial_replacement = Vector2i(-1,-1);run.bank_reward();app.rebuild(),func():run.add_face(run.reward_face,chosen.x,chosen.y);app.trial_replacement = Vector2i(-1,-1);app.rebuild()],[false,false,not can_buy])
static func guide(app) -> void:
 var run = app.trials;var column := P.panel(app,"Trials · help", "Pick a topic for a short explanation")
 var topics := ["How to play","My heroes","Rewards & resources","Arena","Boss Souls","Soulcaster"]
 M.choose(app,column,"Topic",topics,maxi(0,topics.find(app.trial_help_topic)),func(index):app.trial_help_topic = topics[index];app.rebuild(),"TrialHelpTopic")
 match app.trial_help_topic:
  "How to play":
   M.text(column,"One run, three heroes",27,app.GOLD)
   M.text(column,"Choose a class and four pieces of gear for each hero, then start. Each fight rolls three Action Dice per hero. Tap a ready ability, tap its target or destination, and confirm the preview. Use opens abilities that need a choice. Held Reactions respond to attacks. Unused results are optional; End turn advances play.",21)
   M.text(column,"Red = Attack · Blue = Defense · Yellow = Movement · Purple = Skill · Light gray = Blank · Dark gray = spent.",21)
   M.text(column,"HP is life; 0 HP Downs a hero. Healing can revive them. Block absorbs damage before HP and expires at that unit’s next turn. Poison costs HP at turn start, then decreases by 1. Action Rerolls are a separate bank (normally at most 1); they roll a die again and may show the same result.",21)
   M.text(column,"Five stops lead to your selected boss. HP carries between fights. Camp can heal the party. A safe route / reward checkpoint can resume; leaving during a fight ends the run.",21)
  "Rewards & resources":
   M.text(column,"Run Essence · spent this run",27,app.GOLD)
   M.text(column,"The carried number buys one face or Weapon at a victory reward. An upgrade costs 2; taking the reward as currency adds 2 instead. New faces replace a physical side and last for this run. Choose a legal side, review the replacement, then Buy. A new run resets this currency and its purchases.",21)
   M.text(column,"Forge materials · kept between runs",27,app.GOLD)
   M.text(column,"Ward, Cinder, Shade and Hollow Essence are ingredients from Trial victories. The Forge shows your balance, recipe cost and where to find each. Crafting unlocks equipment for future Trials; equip it in the lobby. Your class’s starting kit and Soulcaster are free. Boss victories unlock their Soul. This collection is separate from normal Camp.",21)
   M.text(column,"Soul Charges · only in a fight",27,app.GOLD)
   M.text(column,"Soulcaster gathers these by spending rolled Blanks. Maximum 3; they pay for spells, not rewards or rerolls. They start at 0 each encounter.",21)
  "My heroes":
   M.text(column,"Four slots, one of each per hero",26,app.GOLD)
   M.text(column,"Body sets base HP and normal movement. Memory triggers its listed bonus automatically. Soul changes Blanks or adds its listed effect. Weapon supplies Poke or replaces one Strike with Jab / Crack. Class is a free starting kit; changing class resets that hero’s gear.",21)
   var shown_builds: Array = app.game.heroes.map(func(h):return h.build) if app.page=="battle" else run.starting_builds() if run.phase=="lobby" else run.builds
   var tabs := M.row(column)
   for id in range(3):act(app,tabs,M.NAMES[id],func():run.hero = id;app.rebuild(),"TrialGuideHero"+str(id),app.COLORS[id] if run.hero==id else app.MUTED)
   var id: int = run.hero
   M.text(column,M.NAMES[id]+" · "+run.class_label(id)+" · %d maximum HP" % run.maximum_hp(id),25,app.COLORS[id])
   for slot in ["body","memory","soul","weapon"]:
    var key: String = {"body":run.bodies[id],"memory":run.memories[id],"soul":run.souls[id],"weapon":run.loadout_weapons[id] if run.phase=="lobby" else run.weapons[id]}[slot]
    var data: Dictionary = {"body":R.BODIES,"memory":R.MEMORIES,"soul":R.SOULS,"weapon":R.WEAPONS}[slot].get(key,{"name":"Beginning Soul","text":"Spend one rolled Blank as Move 1 per own turn."})
    M.text(column,slot.capitalize()+" · "+data.name,23,app.GOLD);M.text(column,data.text,20)
   if run.souls[id]=="soulcaster":act(app,column,"Open Soulcaster spellbook",func():app.show_soulcaster_help = true;app.rebuild(),"TrialSpellbook",Color("c5a5e8"))
   if shown_builds.size()==3:
    M.text(column,"Actual starter dice" if run.phase=="lobby" else "Dice for this run",25,app.GOLD)
    for die in range(3):M.text(column,"Die %d: " % [die+1]+" · ".join(range(6).map(func(side):return app.Catalog.name_for(app.game.TrialRules.effective_face(app.game,id,int(shown_builds[id][die][side]),die,side) if app.page=="battle" else run.display_face(id,int(shown_builds[id][die][side]),die,side)))),19)
  "Arena":
   if app.page=="battle":
    if app.game.objective_summary()!="":M.text(column,app.game.objective_summary(),26,app.GOLD);M.text(column,app.game.rupture_help(),21)
    M.text(column,"Tap any enemy intent to see its damage, range and target priority. Highlighted tiles show the selected ability’s reach. Targets outside it cannot be selected.",21)
    for id in [3]+app.game.living_minions():
     var unit: Dictionary = app.game.unit_data(id)
     if not unit.has("trial_role"):continue
     M.text(column,app.game.unit_name(id)+" · %d HP · %d Block" % [unit.hp,unit.block],24,app.GOLD)
     for die in T.ROLES[unit.trial_role].dice:M.text(column," · ".join(die),18)
   else:
    for group in T.GROUPS:M.text(column,group.title,25,app.GOLD);M.text(column,group.text,21)
   M.text(column,"Cover reduces ranged damage. Spikes hurt when entered. Break barricades with an Attack or Shove. Objective encounters explain their win condition before entry and through the arena button.",21)
  "Boss Souls":
   for key in run.BOSSES:
    var card: Button = act(app,column,R.SOULS[key].name+(" · owned" if key in run.completed_bosses else " · locked"),func():app.mobile_info = R.SOULS[key].text;app.rebuild(),"TrialSoulCard_"+key,app.GOLD if key in run.completed_bosses else app.MUTED)
    app.bind_unlock(card,"trial_soul",key,run.hero)
    M.text(column,R.SOULS[key].text+("\nUnlocked" if key in run.completed_bosses else "\nDefeat "+run.BOSS_NAMES[run.BOSSES.find(key)]+" in Trials"),20)
  "Soulcaster":
   M.text(column,R.SOULS.soulcaster.text,21)
   act(app,column,"Open the six-spell guide",func():app.show_soulcaster_help = true;app.rebuild(),"TrialSpellbook",Color("c5a5e8"))
 P.footer(app,["Back"],[func():app.trial_view = "run";app.show_trial_guide = false;app.rebuild()])
static func outcome(app) -> void:
 var run = app.trials;run.finish(app.game)
 var column := P.panel(app,"Trial victory" if app.game.outcome=="victory" else "Trial ended","")
 M.text(column,run.message,26,app.GOLD)
 if run.last_progress!="":M.text(column,run.last_progress,22,Color("9acdb6"))
 M.text(column,"%d Run Essence · %d HP remaining across the party" % [run.essence,int(run.hp.reduce(func(a,b):return int(a)+int(b),0))],21)
 if run.phase=="reward":M.text(column,"Choose a dice ability, a Weapon, or +2 Run Essence before the next stop.",21)
 if int(app.game.trial_state.get("escaped",0))>0:M.text(column,"Escaped thieves kept %d Essence." % int(app.game.trial_state.escaped),20)
 P.footer(app,["Battle log","Continue"],[func():app.show_history = true;app.rebuild(),app.continue_trial])
static func ending(app) -> void:
 var run = app.trials;var column := P.panel(app,"Trial complete" if run.phase=="complete" else "Trial ended","")
 M.text(column,run.message,26,app.GOLD)
 M.text(column,"Trial Souls collected: %d / 4" % run.completed_bosses.size(),22)
 for line in run.history:M.text(column,str(line),18,app.MUTED)
 M.text(column,"Safe route and reward checkpoints can be resumed. Leaving or reloading during a fight ends that Trial without a victory reward. Your normal Camp collection remains separate.",20)
 P.footer(app,["Main menu","Trial Forge","New Trial"],[app.go_main,func():app.trial_view = "craft";app.rebuild(),func():run.phase = "lobby";run.ensure_classes();run.save();app.rebuild()])

static func options(app) -> void:
 var column := P.panel(app,"Trial options","")
 var display: Button = app.fullscreen_button(Vector2.ZERO,Vector2(420,68));display.reparent(column);display.custom_minimum_size = Vector2(0,68);display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 act(app,column,"Sound & volume",func():app.show_soundtrack = true;app.rebuild(),"TrialSound")
 act(app,column,"Action Rerolls: "+("Any time" if app.game.v("hero.reroll_anytime") else "Opening only"),func():app.game.balance["hero.reroll_anytime"] = 0 if app.game.v("hero.reroll_anytime") else 1;app.rebuild(),"TrialRerollOption")
 act(app,column,"Main menu · leave Trial fight",app.go_main,"TrialLeave",app.MUTED)
 P.footer(app,["Back to battle"],[func():app.show_options = false;app.rebuild()])

static func menu(app) -> void:
 var column := P.panel(app,"Trial menu","")
 if app.game.active in range(3) and app.game.heroes[app.game.active].get("omen_ready",false):act(app,column,"Save with Hoarded Omen",func():app.show_menu = false;app.Model.Soulcaster.open_omen(app.game);app.rebuild(),"TrialMenuOmen")
 act(app,column,"Equipment & arena help",func():app.show_menu = false;app.show_trial_guide = true;app.rebuild(),"TrialMenuGuide")
 act(app,column,"Enemy intents",func():app.show_menu = false;app.show_intents = true;app.rebuild(),"TrialMenuIntents")
 act(app,column,"Full battle log",func():app.show_menu = false;app.show_history = true;app.rebuild(),"TrialMenuLog")
 act(app,column,"Sound & volume",func():app.show_menu = false;app.show_soundtrack = true;app.rebuild(),"TrialMenuSound")
 act(app,column,"Options",func():app.show_menu = false;app.show_options = true;app.rebuild(),"TrialMenuOptions")
 P.footer(app,["Return to battle","Main menu · leave Trial"],[func():app.show_menu = false;app.rebuild(),app.go_main])

static func crafting(app) -> void:
 var run = app.trials;var column := P.panel(app,"Trial Forge", "This collection stays in Trials")
 M.text(column,"Your class already includes its starting gear free. Craft Body designs to use them with the other class. Craft equipment with permanent Forge materials from Trial victories. Crafted pieces stay available for future Trials. Equip them in the lobby before beginning a new run. Fight rewards still use carried Run Essence.",20)
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

static func classes(app) -> void:
 var run = app.trials
 if not K.valid(app.trial_class_preview):app.trial_class_preview = run.classes[run.hero] if K.valid(run.classes[run.hero]) else "skirmisher"
 var key: String = app.trial_class_preview;var kit: Dictionary = K.CLASSES[key]
 var column := P.panel(app,"Choose a class",M.NAMES[run.hero]+" · class supplies starting gear and dice")
 var heroes := M.row(column)
 for id in range(3):
  act(app,heroes,M.NAMES[id],func():run.hero = id;app.trial_class_preview = run.classes[id] if K.valid(run.classes[id]) else "skirmisher";app.trial_class_die = 0;app.rebuild(),"TrialClassHero"+str(id),app.COLORS[id] if run.hero==id else app.MUTED)
 var choices := M.row(column)
 for choice in K.CLASSES:
  act(app,choices,K.CLASSES[choice].name,func():app.trial_class_preview = choice;app.trial_class_die = 0;app.rebuild(),"TrialClass_"+choice,app.GOLD if key==choice else app.MUTED)
 M.text(column,kit.name+" · "+kit.role,25,app.GOLD)
 M.text(column,kit.hp_text,21,app.COLORS[run.hero])
 M.text(column,"Body · "+R.BODIES[kit.body].name+"\nMemory · "+R.MEMORIES[kit.memory].name+"\nWeapon · "+R.WEAPONS[kit.weapon].name+"\nSoul · Beginning Soul",21)
 M.text(column,kit.play,20)
 M.text(column,"Starter dice · tap a face to read it",23,app.GOLD)
 var dice := M.row(column)
 for die in range(3):act(app,dice,"Die "+str(die+1),func():app.trial_class_die = die;app.rebuild(),"TrialClassDie"+str(die),app.GOLD if app.trial_class_die==die else app.MUTED)
 var faces := GridContainer.new();faces.columns = 3;faces.add_theme_constant_override("h_separation",8);faces.add_theme_constant_override("v_separation",8);column.add_child(faces)
 for side in range(6):
  var face: int = K.face_for(key,app.trial_class_die,side)
  var pick := act(app,faces,app.Catalog.name_for(face),func():app.mobile_info = class_face_help(app,key,face);app.rebuild(),"TrialClassFace"+str(side),app.color_for_face(face))
  pick.add_theme_font_size_override("font_size",16);pick.custom_minimum_size.y = 62
 act(app,column,"How to play "+kit.name,func():app.mobile_info = kit.turn+"\n\n"+kit.tradeoff;app.rebuild(),"TrialClassExample",app.MUTED)
 M.text(column,"Each die keeps 2 Blanks. Red = Attack, blue = Defense, yellow = Movement, purple = Skill. A weapon face must be rolled before use; it spends that die. Class bonuses come from the listed equipment.",18,app.MUTED)
 M.text(column,"Use applies this starting gear and dice only to "+M.NAMES[run.hero]+", at no Essence cost. You can adjust equipment before starting a run.",19)
 P.footer(app,["Back to setup","Use "+kit.name],[func():app.trial_view = "run";app.rebuild(),func():run.choose_class(run.hero,key);app.trial_view = "run";app.rebuild()],[false,run.phase!="lobby"])
static func class_face_help(app, key: String, face: int) -> String:
 var kit: Dictionary = K.CLASSES[key]
 if face==0:return "Beginning Soul: spend one rolled Blank as Move 1, once per own turn. The installed side remains Blank. The Body’s movement bonus or penalty does not change this distance."
 if face in [2,3]:
  var spaces: int = maxi(1,(1 if face==2 else 3)+(1 if kit.body=="fleet" else -1))
  return ("Step: move up to %d spaces, turning allowed." if face==2 else "Stride: move up to %d spaces in a straight line.") % spaces+" This includes the starting Body’s movement modifier."
 return app.Catalog.name_for(face)+"\n\n"+app.AbilityCopy.new().face(face)
