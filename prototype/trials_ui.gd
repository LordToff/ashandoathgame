extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const R = preload("res://prototype/trial_rules.gd")
const T = preload("res://prototype/trial_encounter.gd")
static func act(app, column: Control, text: String, fn: Callable, name: String, color: Color = Color("e6c58c"), disabled: bool = false) -> Button:
 var button := M.btn(app,column,text,fn,color,disabled);button.name = name;return button
static func render(app) -> void:
 var run = app.trials
 if app.trial_view=="guide":guide(app);return
 if run.phase=="lobby":lobby(app);return
 if run.phase in ["failed","complete"]:ending(app);return
 var title: String = "Boss gate" if run.stage==5 else "Stop %d / 5" % [run.stage+1]
 var column := P.panel(app,"TRIALS · "+title,"%d Trial Essence · HP carries between fights" % run.essence)
 if run.message!="":M.text(column,run.message,20,app.GOLD)
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
 P.footer(app,["Main menu","Party / rules"],[app.go_main,func():app.trial_view = "guide";app.rebuild()])
static func lobby(app) -> void:
 var run = app.trials;var column := P.panel(app,"TRIALS","Experimental expeditions · separate Trial collection")
 M.text(column,"Five branching stops, then a boss. Build around Poison, counterattacks or movement. HP carries forward; Camp can restore fallen heroes. Rewards and changes belong to Trials.",21)
 var tabs := M.row(column)
 for id in range(3):act(app,tabs,M.NAMES[id],func():run.hero = id;app.rebuild(),"TrialHero"+str(id),app.COLORS[id] if run.hero==id else app.MUTED)
 var keys: Array = R.PATHS.keys()
 M.choose(app,column,"Build path",keys.map(func(key):return R.PATHS[key].name),keys.find(run.paths[run.hero]),func(index):run.paths[run.hero] = keys[index];app.rebuild(),"TrialPath")
 M.text(column,R.PATHS[run.paths[run.hero]].text,21)
 var souls: Array = [""]+run.completed_bosses
 M.choose(app,column,"Trial Soul",souls.map(func(key):return R.SOULS[key].name if key!="" else "Beginning Soul · Blank as Move 1"),maxi(0,souls.find(run.souls[run.hero])),func(index):run.souls[run.hero] = souls[index];app.rebuild(),"TrialSoul")
 if run.souls[run.hero]!="":M.text(column,R.SOULS[run.souls[run.hero]].text,20)
 else:M.text(column,"Defeat each boss in a Trial to unlock its Soul here. All paths keep one rolled Blank as Move 1 per own turn.",19,app.MUTED)
 M.choose(app,column,"Final boss",run.BOSS_NAMES,run.selected_boss,func(index):run.selected_boss = index;app.rebuild(),"TrialBoss")
 act(app,column,"Preview enemies, terrain & builds",func():app.trial_view = "guide";app.rebuild(),"TrialPreview",app.MUTED)
 P.footer(app,["Main menu","Begin Trial"],[app.go_main,func():run.start();app.trial_view = "run";app.rebuild()])
static func route(app, column: Control) -> void:
 var run = app.trials
 M.text(column,"Battle → Camp / battle → Battle → Cache / elite → Camp / elite → Boss",18,app.MUTED)
 var choices: Array = run.options()
 for index in range(choices.size()):
  var choice: Dictionary = choices[index]
  if choice.kind=="fight":
   var group: Dictionary = T.GROUPS[choice.group];var elite: bool = choice.elite
   var caption: String = group.title+(" · ELITE" if elite else "")
   var units: Array = group.roles.duplicate()
   if elite:units.append(group.elite)
   var stats: Array = units.map(func(role):return T.ROLES[role].name+" %d HP" % (int(T.ROLES[role].hp)+(1 if elite else 0)))
   M.text(column,caption,25,Color("df897f") if elite else app.GOLD)
   M.text(column," · ".join(stats),19,app.MUTED);M.text(column,group.text,20)
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
 for id in range(3):act(app,tabs,M.NAMES[id],func():run.hero = id;run.reward_face = R.PATHS[run.paths[id]].faces[0];app.rebuild(),"TrialRewardHero"+str(id),app.COLORS[id] if id==run.hero else app.MUTED)
 var actions := M.row(column)
 act(app,actions,"New face · 2 Essence",func():run.reward_mode = "face";run.reward_face = R.PATHS[run.paths[run.hero]].faces[0];app.rebuild(),"TrialRewardFace",app.GOLD,run.essence<2)
 act(app,actions,"Temper · 2 Essence",func():run.reward_mode = "temper";app.rebuild(),"TrialRewardTemper",app.GOLD,run.essence<2)
 if run.reward_mode=="":M.text(column,"Install a path ability on one legal side, temper an Attack with a tradeoff, or save this reward as +2 Essence. Only one reward per victory.",21)
 else:
  if run.reward_mode=="face":
   var faces: Array = R.PATHS[run.paths[run.hero]].faces
   M.choose(app,column,"New ability",faces.map(func(face):return app.Catalog.name_for(face)),maxi(0,faces.find(run.reward_face)),func(index):run.reward_face = faces[index];app.rebuild(),"TrialRewardChoice")
   M.text(column,app.AbilityCopy.new().face(run.reward_face),20)
   M.text(column,"Choose a side to replace. Keep two Blanks per die and normal category/copy caps. The new physical face belongs to this Trial.",18,app.MUTED)
  else:
   M.choose(app,column,"Attack edge",["Venom edge","Heavy edge"],0 if run.reward_mod=="venom" else 1,func(index):run.reward_mod = "venom" if index==0 else "heavy";app.rebuild(),"TrialEdge")
   M.text(column,"-1 direct damage; HP-damaging hits add Poison 1." if run.reward_mod=="venom" else "+1 damage; pay 1 unavoidable HP after the Attack. A killing victory hit has no further cost.",21)
   M.text(column,"Choose an Attack side. One edge per physical side; it applies only when that side is rolled. Replacing that side removes its edge.",18,app.MUTED)
  var dice := M.row(column)
  for die in range(3):act(app,dice,"Die "+str(die+1),func():app.trial_die = die;app.rebuild(),"TrialDie"+str(die),app.GOLD if die==app.trial_die else app.MUTED)
  var grid := GridContainer.new();grid.columns = 2;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);column.add_child(grid)
  for side in range(6):
   var face: int = run.builds[run.hero][app.trial_die][side]
   var key := "%d:%d:%d" % [run.hero,app.trial_die,side]
   var caption: String = "%d · %s" % [side+1,app.Catalog.name_for(face)]
   if run.mods.has(key):caption += " · "+run.mods[key]+" edge"
   act(app,grid,caption,func():
    if run.reward_mode=="face":run.add_face(run.reward_face,app.trial_die,side)
    else:run.temper(app.trial_die,side,run.reward_mod)
    app.rebuild(),"TrialSlot"+str(side),app.color_for_face(face),run.reward_mode=="temper" and (not app.Catalog.is_attack(face) or run.mods.has(key)))
 P.footer(app,["Main menu","Save reward · +2 Essence"],[app.go_main,func():run.bank_reward();app.rebuild()])
static func guide(app) -> void:
 var run = app.trials;var column := P.panel(app,"Trial field guide","")
 if app.page=="battle":
  M.text(column,R.guide(app.game),21)
  if app.game.encounter_id=="event":
   for id in [3]+app.game.living_minions():
    var unit: Dictionary = app.game.unit_data(id)
    if not unit.has("trial_role"):continue
    M.text(column,app.game.unit_name(id)+" · %d HP · %d Block" % [unit.hp,unit.block],24,app.GOLD)
    for die in T.ROLES[unit.trial_role].dice:M.text(column," · ".join(die),18)
    if int(unit.get("loot",0))>0:M.text(column,"Carrying %d stolen Trial Essence" % int(unit.loot),20,app.GOLD)
 else:
  for key in R.PATHS:M.text(column,R.PATHS[key].name+"\n"+R.PATHS[key].text,21)
  M.text(column,"Normal construction limits apply. Beginning Soul spends one rolled Blank as Move 1 per own turn. Path perks stack with your chosen Trial Soul. Trial gear never changes normal equipment.",20)
  if not run.builds.is_empty():
   for id in range(3):
    M.text(column,M.NAMES[id]+" · "+R.PATHS[run.paths[id]].name,25,app.COLORS[id])
    for die in range(3):
     var entries: Array = []
     for side in range(6):
      var name: String = app.Catalog.name_for(int(run.builds[id][die][side]));var key := "%d:%d:%d" % [id,die,side]
      if run.mods.has(key):name += " ("+run.mods[key]+" edge)"
      entries.append(name)
     M.text(column,"Die %d: " % [die+1]+" · ".join(entries),19)
  for group in T.GROUPS:M.text(column,group.title+"\n"+group.text,21,app.GOLD)
  for key in R.SOULS:
   var card: Button = act(app,column,R.SOULS[key].name+(" · owned" if key in run.completed_bosses else " · locked"),func():app.mobile_info = R.SOULS[key].text;app.rebuild(),"TrialSoulCard_"+key,app.GOLD if key in run.completed_bosses else app.MUTED)
   app.bind_unlock(card,"trial_soul",key,run.hero)
   M.text(column,R.SOULS[key].text+("\nUnlocked" if key in run.completed_bosses else "\nDefeat "+run.BOSS_NAMES[run.BOSSES.find(key)]+" in Trials"),20)
  if app.debug_mode:M.text(column,"Debug: hold a locked Trial Soul to unlock it for testing.",19,app.GOLD)
 P.footer(app,["Back"],[func():app.trial_view = "run";app.show_trial_guide = false;app.rebuild()])
static func outcome(app) -> void:
 var run = app.trials;run.finish(app.game)
 var column := P.panel(app,"Trial victory" if app.game.outcome=="victory" else "Trial ended","")
 M.text(column,run.message,26,app.GOLD)
 M.text(column,"%d Trial Essence · %d HP remaining across the party" % [run.essence,int(run.hp.reduce(func(a,b):return int(a)+int(b),0))],21)
 if run.phase=="reward":M.text(column,"Choose a face, an Attack edge, or extra Essence before the next route.",21)
 if int(app.game.trial_state.get("escaped",0))>0:M.text(column,"Escaped thieves kept %d Essence." % int(app.game.trial_state.escaped),20)
 P.footer(app,["Battle log","Continue"],[func():app.show_history = true;app.rebuild(),app.continue_trial])
static func ending(app) -> void:
 var run = app.trials;var column := P.panel(app,"Trial complete" if run.phase=="complete" else "Trial ended","")
 M.text(column,run.message,26,app.GOLD)
 M.text(column,"Trial Souls collected: %d / 4" % run.completed_bosses.size(),22)
 for line in run.history:M.text(column,str(line),18,app.MUTED)
 M.text(column,"Safe route and reward checkpoints can be resumed. Leaving or reloading during a fight ends that Trial without a victory reward. Your normal Camp collection remains separate.",20)
 P.footer(app,["Main menu","New Trial"],[app.go_main,func():run.phase = "lobby";run.save();app.rebuild()])

static func options(app) -> void:
 var column := P.panel(app,"Trial options","")
 act(app,column,"Sound & volume",func():app.show_soundtrack = true;app.rebuild(),"TrialSound")
 act(app,column,"Action Rerolls: "+("Any time" if app.game.v("hero.reroll_anytime") else "Opening only"),func():app.game.balance["hero.reroll_anytime"] = 0 if app.game.v("hero.reroll_anytime") else 1;app.rebuild(),"TrialRerollOption")
 act(app,column,"Main menu · leave Trial fight",app.go_main,"TrialLeave",app.MUTED)
 P.footer(app,["Back to battle"],[func():app.show_options = false;app.rebuild()])

static func menu(app) -> void:
 var column := P.panel(app,"Trial menu","")
 act(app,column,"Trial field guide",func():app.show_menu = false;app.show_trial_guide = true;app.rebuild(),"TrialMenuGuide")
 act(app,column,"Enemy intents",func():app.show_menu = false;app.show_intents = true;app.rebuild(),"TrialMenuIntents")
 act(app,column,"Full battle log",func():app.show_menu = false;app.show_history = true;app.rebuild(),"TrialMenuLog")
 act(app,column,"Sound & volume",func():app.show_menu = false;app.show_soundtrack = true;app.rebuild(),"TrialMenuSound")
 act(app,column,"Options",func():app.show_menu = false;app.show_options = true;app.rebuild(),"TrialMenuOptions")
 P.footer(app,["Return to battle","Main menu · leave Trial"],[func():app.show_menu = false;app.rebuild(),app.go_main])
