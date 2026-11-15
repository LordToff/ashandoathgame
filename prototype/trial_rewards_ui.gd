extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const H = preload("res://prototype/menu_helpers.gd")
const R = preload("res://prototype/trial_rules.gd")
static func render(app) -> void:
 var run = app.trials;var context: String = str(run.seed_value)+":"+str(run.stage)
 if app.trial_reward_context!=context:
  app.trial_reward_context = context;app.trial_reward_step = 0 if run.reward_mode=="" else 2;app.trial_replacement = Vector2i(-1,-1)
 var step: int = app.trial_reward_step
 var labels := ["Choose a hero","Choose reward type","Inspect your reward","Choose a side to replace"]
 var column := P.panel(app,"Victory reward","Step %d — %s · %d Run Essence available" % [step+1,labels[step],run.essence])
 if step==0:
  H.note(column,"Who receives this reward?","Choose one hero. You get one upgrade per victory, or can take +2 Run Essence instead.")
  var choices := H.grid(app,column,3)
  for id in range(3):
   var c := H.card(app,choices,M.NAMES[id]+(" · selected" if run.hero==id else ""),"%d / %d HP · %s" % [run.hp[id],run.maximum_hp(id),R.WEAPONS[run.weapons[id]].name],app.COLORS[id])
   H.action(app,c,"Choose "+M.NAMES[id],func():run.hero = id;run.reward_face = run.reward_faces(id)[0];app.trial_replacement = Vector2i(-1,-1);app.rebuild(),"TrialRewardHero"+str(id),app.COLORS[id])
  P.footer(app,["Main menu","Next: reward type"],[app.go_main,func():app.trial_reward_step = 1;app.rebuild()]);return
 H.note(column,"Reward for "+M.NAMES[run.hero],"Run Essence buys this run’s rewards. Permanent Forge materials are a separate balance.",app.COLORS[run.hero])
 if step==1:
  var choices := H.grid(app,column)
  for entry in [["face","Ability face","Replace one legal side on this hero’s dice. Costs 2 Run Essence.","TrialRewardFace"],["memory","Memory","Equip a passive on this hero. Costs 2 Run Essence.","TrialRewardMemory"],["weapon","Weapon","Change this hero’s Attack limits and Strike replacements. Costs 2 Run Essence.","TrialRewardWeapon"]]:
   var c := H.card(app,choices,entry[1],entry[2])
   if run.essence<2:M.text(c,"Need 2 Run Essence; you have %d." % run.essence,18,Color("efb090"))
   H.action(app,c,"Inspect "+entry[1].to_lower(),func():run.reward_mode = entry[0];app.trial_reward_step = 2;app.trial_replacement = Vector2i(-1,-1);app.rebuild(),entry[3],app.GOLD,run.essence<2)
  var bank := H.card(app,choices,"Take currency instead","Gain +2 Run Essence, buy no upgrade, and move to the next stop.",Color("9acfc0"))
  H.action(app,bank,"Take +2 Run Essence",func():run.bank_reward();app.rebuild(),"TrialBankReward",Color("9acfc0"))
  P.footer(app,["Back to hero"],[func():app.trial_reward_step = 0;app.rebuild()]);return
 if run.reward_mode=="memory":
  var keys: Array = run.available("memory").filter(func(key):return key!="")
  if app.trial_reward_memory not in keys:app.trial_reward_memory = keys[0]
  M.choose(app,column,"Memory to inspect",keys.map(func(key):return R.memory_data(key).name),keys.find(app.trial_reward_memory),func(index):app.trial_reward_memory = keys[index];app.rebuild(),"TrialMemoryChoice")
  H.note(column,R.memory_data(app.trial_reward_memory).name,R.memory_data(app.trial_reward_memory).text)
  var same: bool = run.memories[run.hero]==app.trial_reward_memory
  M.text(column,"Already equipped on this hero." if same else "Replaces the Memory slot. After purchase: %d Run Essence." % (run.essence-2),18)
  P.footer(app,["Back to rewards","Equip Memory · 2"],[func():app.trial_reward_step = 1;app.rebuild(),func():run.equip_memory_reward(app.trial_reward_memory);app.rebuild()],[false,same or run.essence<2])
  for b in app.ui.get_children():
   if b is Button and b.text=="Equip Memory · 2":b.name = "TrialMemoryBuy"
  return
 if run.reward_mode=="weapon":
  var keys := ["venom","heavy","spear","hammer"]
  M.choose(app,column,"Weapon to inspect",keys.map(func(key):return R.WEAPONS[key].name),maxi(0,keys.find(run.reward_weapon)),func(index):run.reward_weapon = keys[index];app.rebuild(),"TrialWeaponChoice")
  H.note(column,R.WEAPONS[run.reward_weapon].name,R.WEAPONS[run.reward_weapon].text)
  var error: String = run.weapon_reward_error(run.reward_weapon)
  M.text(column,error if error!="" else "After purchase: %d Run Essence. Only this hero’s Weapon changes." % (run.essence-2),18,Color("efb090") if error!="" else app.MUTED)
  P.footer(app,["Back to rewards","Equip Weapon · 2"],[func():app.trial_reward_step = 1;app.rebuild(),func():run.equip_weapon(run.reward_weapon);app.rebuild()],[false,error!=""])
  for b in app.ui.get_children():
   if b is Button and b.text=="Equip Weapon · 2":b.name = "TrialEquipWeapon"
  return
 if step==2:
  var faces: Array = run.reward_faces(run.hero)
  if run.reward_face not in faces:run.reward_face = faces[0]
  M.choose(app,column,"Ability to inspect",faces.map(func(face):return app.Catalog.name_for(face)),faces.find(run.reward_face),func(index):run.reward_face = faces[index];app.trial_replacement = Vector2i(-1,-1);app.rebuild(),"TrialRewardChoice")
  H.note(column,app.Catalog.name_for(run.reward_face),app.AbilityCopy.new().face(run.reward_face))
  M.text(column,"Costs 2 Run Essence. Next choose the physical side it replaces; no payment while browsing.",18)
  P.footer(app,["Back to rewards","Next: choose die side"],[func():app.trial_reward_step = 1;app.rebuild(),func():app.trial_reward_step = 3;app.rebuild()]);return
 var dice := M.row(column)
 for die in range(3):H.action(app,dice,"Die "+str(die+1),func():app.trial_die = die;app.trial_replacement = Vector2i(-1,-1);app.rebuild(),"TrialDie"+str(die),app.GOLD if die==app.trial_die else app.MUTED)
 M.text(column,"Replace one side with "+app.Catalog.name_for(run.reward_face)+". Tap an unavailable side to see why.",19)
 var grid := GridContainer.new();grid.columns = 3;grid.add_theme_constant_override("h_separation",6);grid.add_theme_constant_override("v_separation",6);column.add_child(grid)
 var width: float = (column.custom_minimum_size.x-12)/3
 for side in range(6):
  var face: int = run.display_face(run.hero,int(run.builds[run.hero][app.trial_die][side]),app.trial_die,side)
  var error: String = run.replacement_error(run.reward_face,app.trial_die,side)
  var b: Button = H.action(app,grid,app.Catalog.name_for(face)+("\nUnavailable" if error!="" else ""),func():app.trial_replacement = Vector2i(app.trial_die,side);app.rebuild(),"TrialSlot"+str(side),app.MUTED if error!="" else app.color_for_face(face))
  M.fit_button(b,Vector2(width,72),16);b.custom_minimum_size = Vector2(width,72)
 var chosen: Vector2i = app.trial_replacement
 var error: String = run.replacement_error(run.reward_face,chosen.x,chosen.y)
 if error=="":M.text(column,"Replace %s → %s on %s. Pay 2 Run Essence; %d remains." % [app.Catalog.name_for(run.display_face(run.hero,int(run.builds[run.hero][chosen.x][chosen.y]),chosen.x,chosen.y)),app.Catalog.name_for(run.reward_face),M.NAMES[run.hero],run.essence-2],20,app.GOLD)
 else:M.text(column,error,18,Color("efb090"))
 P.footer(app,["Back to ability","Buy ability · 2"],[func():app.trial_reward_step = 2;app.rebuild(),func():run.add_face(run.reward_face,chosen.x,chosen.y);app.trial_replacement = Vector2i(-1,-1);app.rebuild()],[false,error!=""])
 for b in app.ui.get_children():
  if b is Button and b.text=="Buy ability · 2":b.name = "TrialRewardBuy"
