extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const H = preload("res://prototype/menu_helpers.gd")
const SUGGESTIONS = [[34,47],[19,43],[53,34]]
const BOSSES = ["hollow","nugh","cantor","bugh"]
const BOSS_NAMES = ["The Hollow","Nu’gh","Veyl, Brass Cantor","Bu’gh, Iron Warden"]
const BOSS_HELP = ["Watch fire warnings and prepare for stronger abilities at half HP.","Control the worms. Soul Link connects them to their summoner until phase II.","Attacks charge the bell; Skills and Defenses calm it. Strike during Open Core.","Guard or evade the marked sweep to break Bulwark, then counterattack."]
const EVENT_CHOICES = [
 [["Take a Salve","Gain 1 Salve: heal up to 2 HP during normal combat."],["Take a Reroll Seal","Gain 1 Seal: restore one Action Reroll during normal combat."]],
 [["Leave safely","No cost and no reward."],["Offer 2 Gold","Pay now. Roll d6: 3–6 grants 1 Soul Fragment; 1–2 loses the offering."]],
 [["Take directions","Gain 1 Gold."],["Help the traveller","Spend 1 Salve. Gain 3 Gold and 1 Reroll Seal."]],
 [["Withdraw safely","No battle and no reward."],["Fight two Bone Creatures","Win: 3 Gold, 1 Salve and their matching Essence. Defeat: no reward."]],
 [["Leave safely","No battle and no reward."],["Fight the mixed group","Win: 5 Gold, 1 Soul Fragment, 1 Reroll Seal and matching creature Essence."]],
 [["Take 1 Gold","Safe reward."],["Search instead","Roll d6: 4–6 gives 3 Gold + 1 Soul Fragment; 1–3 loses one held Salve and grants nothing."]]
]
static func main(app) -> void:
 var column := P.panel(app,"ASH & OATH","Choose a mode. Each mode keeps its own rewards.")
 var modes := H.grid(app,column)
 var normal := H.card(app,modes,"Normal adventure","Prepare three heroes, resolve a road event, then fight a boss. Keep crafted rewards.",app.GOLD)
 H.action(app,normal,"Prepare my party",app.open_normal,"MobilePlay" if app.mobile_mode else "MainPlay")
 var trials := H.card(app,modes,"Trials","A five-stop run followed by a boss. HP carries between fights; Trial rewards are separate.",Color("c6a8df"))
 var resume: bool = app.trials.phase in ["route","reward","camp","event"]
 H.action(app,trials,"Continue Trial" if resume else "Prepare a Trial party",app.open_trials,"MobileTrials" if app.mobile_mode else "MainTrials",Color("c6a8df"))
 var extras := H.grid(app,column)
 H.action(app,extras,"Camp — craft and equip upgrades",func():app.camp_tab = -1;app.open_camp(),"MobileCamp" if app.mobile_mode else "MainCamp",Color("9acfc0"))
 H.action(app,extras,"Fight creatures — earn materials",func():app.camp_tab = 3;app.open_camp(),"MobileCreatures" if app.mobile_mode else "MainCreatures",Color("9acfc0"))
 if app.menu_more:
  H.action(app,column,"Guided practice — learn a turn",app.start_training,"MenuPractice",app.MUTED)
  H.action(app,column,"Ability Lab — advanced testing",app.start_lab,"MenuLab",app.MUTED)
  H.action(app,column,"Detailed rules reference",func():app.show_help = true;app.rebuild(),"MenuRulebook",app.MUTED)
  H.action(app,column,"Patch notes",func():app.show_changes = true;app.rebuild(),"MenuChanges",app.MUTED)
  H.action(app,column,"Desktop layout" if app.mobile_mode else "Phone layout",func():app.set_mobile_mode(not app.mobile_mode),"MobileDesktopMode" if app.mobile_mode else "MainMobileMode",app.MUTED)
 M.text(column,"v0.43 · Saves and preferences stay on this browser/device.",13,app.MUTED)
 P.footer(app,["Help","Settings","Less" if app.menu_more else "More"],[func():app.open_player_guide("Start here"),app.open_settings,func():app.menu_more = not app.menu_more;app.rebuild()])
static func hero_error(app, hero: int) -> String:
 if app.gifts[hero].size()!=2:return "Choose two bonus abilities."
 var error: String = app.Model.validate(app.builds[hero],app.gifts[hero],app.camp_build_profile(hero))
 if error=="" and not app.gifts[hero].all(func(face):return app.builds[hero].any(func(die):return face in die)):error = "Both chosen bonuses must be on this hero’s dice."
 return error
static func suggestion(app, hero: int) -> Dictionary:
 var pair: Array = app.gifts[hero].duplicate() if app.gifts[hero].size()==2 else SUGGESTIONS[hero].duplicate()
 var build: Array = app.Model.bonus_build(pair,app.camp_build_profile(hero))
 if build.is_empty():return {"error":"This bonus pair does not fit the equipped gear. Choose another pair or change equipment."}
 return {"error":"","gifts":pair,"build":build}
static func prepare(app, hero: int = -1) -> void:
 var builds: Array = app.builds.duplicate(true);var gifts: Array = app.gifts.duplicate(true)
 for id in range(3):
  if hero>=0 and id!=hero:continue
  if hero<0 and hero_error(app,id)=="":continue
  var result := suggestion(app,id)
  if result.error!="":app.hint = M.NAMES[id]+": "+result.error;app.rebuild();return
  builds[id] = result.build;gifts[id] = result.gifts
 var error: String = app.camp_allocation_error(builds)
 if error!="":app.hint = error;app.rebuild();return
 app.builds = builds;app.gifts = gifts;app.hint = "Starter dice ready. Owned crafted rewards are still in your collection.";app.rebuild()
static func normal(app) -> void:
 var column := P.panel(app,"Prepare your party","1. Prepare heroes → 2. Choose boss → 3. Road event → 4. Boss fight")
 M.text(column,"Each hero needs two bonus abilities. Suggestions build legal starter dice for their current gear; you can customize later.",20)
 var ready: bool = app.party_build_error()==""
 if not ready:H.action(app,column,"Prepare remaining heroes with suggestions",func():prepare(app),"NormalPrepareAll")
 var cards := H.grid(app,column,3)
 for id in range(3):
  var error: String = hero_error(app,id)
  var c := H.card(app,cards,M.NAMES[id]+(" · Ready" if error=="" else " · Needs preparation"),"",app.COLORS[id])
  var gear = app.Model.Equipment
  M.text(c,gear.BODIES[gear.body_key(str(app.expedition.camp.bodies[id]))].name+" · "+gear.WEAPONS[app.expedition.camp.weapons[id]].name,18)
  if app.gifts[id].size()==2:M.text(c,"Bonus abilities: "+", ".join(app.gifts[id].map(func(face):return app.Catalog.name_for(face))),18)
  else:M.text(c,"Suggested: "+", ".join(SUGGESTIONS[id].map(func(face):return app.Catalog.name_for(face))),18)
  var shown: Array = app.gifts[id] if app.gifts[id].size()==2 else SUGGESTIONS[id]
  H.action(app,c,"What do these abilities do?",func():app.mobile_info = "\n\n".join(shown.map(func(face):return app.Catalog.name_for(face)+"\n"+app.AbilityCopy.new().face(face)));app.rebuild(),"NormalBonusHelp"+str(id),app.MUTED)
  if error!="":
   M.text(c,error,17,Color("edb091"))
   H.action(app,c,"Build compatible starter dice" if app.gifts[id].size()==2 else "Use suggested abilities",func():prepare(app,id),"NormalPrepare"+str(id),app.COLORS[id])
  H.action(app,c,"Choose my own bonuses",func():app.build_hero = id;app.open_forge(true),"NormalBonuses"+str(id),app.MUTED)
  H.action(app,c,"Edit individual die sides",func():app.build_hero = id;app.open_forge(false),"NormalEdit"+str(id),app.MUTED)
 if app.hint!="":M.text(column,app.hint,18,app.GOLD)
 H.action(app,column,"Change Body, Soul, Memory or Weapon",func():app.camp_tab = 2;app.open_camp(),"NormalEquipment",Color("9acfc0"))
 P.footer(app,["Main menu","Start selected creature fight" if app.queued_creature>=0 else "Next: choose boss"],[app.go_main,func():
  if app.queued_creature>=0:app.start_creature_encounter(app.queued_creature)
  else:app.open_setup()],[false,not ready])
static func setup(app) -> void:
 var column := P.panel(app,"Choose your boss","Your prepared party will resolve one road event before this fight.")
 var choices := H.grid(app,column)
 for index in range(4):
  var c := H.card(app,choices,BOSS_NAMES[index],BOSS_HELP[index])
  H.action(app,c,"Selected" if app.encounter==BOSSES[index] else "Choose "+BOSS_NAMES[index],func():app.encounter = BOSSES[index];app.rebuild(),["EncounterHollow","EncounterNugh","EncounterCantor","EncounterBugh"][index],app.GOLD if app.encounter==BOSSES[index] else app.MUTED)
 H.action(app,column,"Hide advanced rules" if app.setup_advanced else "Advanced rules — optional",func():app.setup_advanced = not app.setup_advanced;app.rebuild(),"SetupAdvanced",app.MUTED)
 if app.setup_advanced:
  M.choose(app,column,"Balance profile",["Tuned (default)","Original Hollow numbers"],0 if app.balanced else 1,func(index):app.balanced = index==0;app.rebuild(),"SetupBalance")
  M.choose(app,column,"Laboratory Blank override",["Use equipped effects","Move 1 override","Move 2 override"],int(app.balance_number("soul.move")) if app.reward_soul else 0,func(index):app.reward_soul = index>0;app.balance_values["soul.move"] = maxi(1,index);app.rebuild(),"SetupBlankOverride")
  M.text(column,"These optional rules keep their selected values when hidden. Settings also has the separate once-per-turn Blank → Move 1 toggle.",17)
 var error: String = app.party_build_error()
 if error!="":M.text(column,error+" Return to party preparation to fix it.",19,Color("efb090"))
 P.footer(app,["Back to party","Next: road event"],[app.open_normal,app.start_expedition],[false,error!=""])
static func events(app) -> void:
 var e = app.expedition;var column := P.panel(app,"The Ash Road","Resolve this event, then enter the selected boss fight.")
 H.action(app,column,"Supplies & resource meanings",func():app.open_player_guide("Resources"),"EventResourceHelp",app.MUTED)
 M.text(column,e.inventory(),18,Color("9acfc0"))
 if e.stage=="idle":
  H.note(column,"Step 1 — roll your road event","One die chooses the event. You will read its choices before paying or fighting.")
  H.action(app,column,"Roll road event · d6",func():e.roll();app.rebuild(),"MobileRollEvent" if app.mobile_mode else "RollEvent")
 else:
  M.text(column,"%d · %s" % [e.selected,app.Expedition.TITLES[e.selected-1]],25,app.GOLD)
  if e.stage=="choice":
   H.note(column,"Step 2 — choose one outcome","Read the cost and possible reward, then choose. Only that choice is paid / resolved.")
   var options := H.grid(app,column)
   for index in range(2):
    var definition: Array = EVENT_CHOICES[e.selected-1][index]
    var c := H.card(app,options,definition[0],definition[1])
    var blocked: bool = index==1 and ((e.selected==2 and e.gold<2) or (e.selected==3 and e.salves<1))
    if blocked:M.text(c,"Need 2 Gold." if e.selected==2 else "Need 1 Salve.",18,Color("efb090"))
    H.action(app,c,definition[0],func():app.event_choice(index),"MobileEventChoice"+str(index) if app.mobile_mode else "EventChoice"+str(index),app.GOLD,blocked)
  else:
   H.note(column,"Event complete",e.summary)
   var error: String = app.party_build_error()
   if error!="":
    M.text(column,error,18,Color("efb090"));H.action(app,column,"Update party dice for current equipment",app.open_normal,"EventRepairParty")
   H.action(app,column,"Enter "+BOSS_NAMES[BOSSES.find(app.encounter)],app.enter_boss,"MobileEnterBoss" if app.mobile_mode else "EnterBoss",app.GOLD,error!="")
 if e.fragments>=3 and not e.soul:
  var c := H.card(app,column,"Bind the Ash Road Soul","Spend 3 Soul Fragments for one hero. This equips a Soul with 6 HP, 3 Blanks per die and Last Ember; check that hero’s dice afterward.")
  M.choose(app,c,"Recipient",M.NAMES,app.event_soul_hero,func(index):app.event_soul_hero = index;app.rebuild(),"FragmentRecipient")
  H.action(app,c,"Bind Soul · 3 fragments",func():e.unlock_soul(app.event_soul_hero);app.rebuild(),"BindFragmentSoul")
 P.footer(app,["Back to boss choice","Camp"],[app.open_setup,func():app.camp_tab = -1;app.open_camp()])
