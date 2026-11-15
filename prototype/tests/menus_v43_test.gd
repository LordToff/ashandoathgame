extends SceneTree
const B = preload("res://prototype/battle.gd")
const E = preload("res://prototype/essence.gd")
const T = preload("res://prototype/trials.gd")
const N = preload("res://prototype/navigation_ui.gd")
const C = preload("res://prototype/camp_menu.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("MENUS43 FAIL: ",why)
func texts(node: Node) -> String:
 var result: String = node.text if node is Label or node is Button else ""
 for child in node.get_children():result += "\n"+texts(child)
 return result
func named(app, key: String):return app.ui.find_child(key,true,false)
func tap(app, key: String) -> void:
 var control = named(app,key);check(control!=null and not control.disabled,"Reachable "+key)
 if control and not control.disabled:control.pressed.emit()
func _initialize():call_deferred("run")
func run() -> void:
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.set_mobile_mode(false,false);app.expedition.camp = E.new();app.gifts = [[],[],[]];app.open_normal()
 var bank: Dictionary = app.expedition.camp.encode().duplicate(true)
 N.prepare(app)
 check(app.party_build_error()=="","Normal suggestions prepare a legal party")
 check(app.gifts==N.SUGGESTIONS,"Different readable suggestions for the three heroes")
 check(app.expedition.camp.encode()==bank,"Preparation does not change equipment, ownership or bank")
 var builds: Array = app.builds.duplicate(true);var gifts: Array = app.gifts.duplicate(true)
 N.prepare(app);check(app.builds==builds and app.gifts==gifts,"Prepare remaining preserves ready heroes")
 for hero in range(3):
  for body in ["broken","fleet","stone"]:
   app.expedition.camp.bodies[hero] = body
   var result: Dictionary = N.suggestion(app,hero)
   check(result.error=="" and B.validate(result.build,result.gifts,app.camp_build_profile(hero))=="","Suggestions honor each current Body")
 app.expedition.camp = E.new();app.builds = builds;app.gifts = gifts
 var rng: int = app.game.rng.state;var events: int = app.game.event_id
 app.open_player_guide("Resources");await process_frame
 var search: LineEdit = named(app,"GuideSearch");search.text = "Salve";search.text_changed.emit("Salve");await process_frame
 check("Salve and Reroll Seal" in texts(named(app,"GuideResults")),"Search explains supplies")
 check(not "Body sets" in texts(named(app,"GuideResults")),"Search filters unrelated definitions")
 tap(app,"GuideClose");await process_frame;await process_frame
 check(app.page=="normal" and not app.show_player_guide and app.builds==builds and app.expedition.camp.encode()==bank,"Guide returns to same menu without edits")
 check(app.game.rng.state==rng and app.game.event_id==events,"Help cannot roll RNG or append battle events")
 app.open_player_guide();var escape := InputEventAction.new();escape.action = "ui_cancel";escape.pressed = true;app._unhandled_key_input(escape)
 check(not app.show_player_guide and app.page=="normal","Escape closes only the guide")
 app.camp_tab = 2;app.open_camp();app.equipment_slot = "weapon";app.rebuild()
 var preview: Dictionary = C.gear_plan(app,"weapon",0,"spear")
 check(preview.error=="" and app.expedition.camp.encode()==bank and app.builds==builds,"Gear validation is read-only")
 app.camp_gear_candidate = "spear";C.equip(app)
 check(app.expedition.camp.weapons==["spear","dagger","dagger"] and app.builds==builds,"Explicit gear apply changes only the selected hero slot")
 var equipped: Dictionary = app.expedition.camp.encode().duplicate(true)
 check(C.gear_plan(app,"weapon",0,"oathblade").error!="" and app.expedition.camp.encode()==equipped,"Unowned weapon preview fails atomically")
 app.expedition.camp = E.new();app.expedition.camp.bank.bone_creature = 3
 check(C.craft_block(app,"bone_growth")=="","Craft preview recognizes enough matching Essence")
 check(app.expedition.camp.craft("bone_growth",0)=="" and app.expedition.camp.owned(60)==1 and app.expedition.camp.bank.bone_creature==2,"Craft spends exactly its printed cost for one owned copy")
 app.camp_tab = 1;app.camp_recipe = "bone_growth";app.camp_hero = 0;app.camp_remove_mode = false;app.rebuild()
 var chosen := Vector2i(-1,-1)
 for die in range(3):
  for side in range(6):
   if C.refit_error(app,60,0,Vector2i(die,side))=="":chosen = Vector2i(die,side);break
  if chosen.x>=0:break
 check(chosen.x>=0,"Owned ability has a legal replacement")
 app.camp_slot = chosen;app.rebuild();check(app.builds==builds,"Selecting a replacement remains a preview")
 tap(app,"CampRefitApply");await process_frame;await process_frame
 check(app.builds[0][chosen.x][chosen.y]==60 and app.expedition.camp.allocated(app.builds,60)==1 and app.expedition.camp.bank.bone_creature==2,"Install uses one owned copy without another payment")
 var installed: Array = app.builds.duplicate(true)
 var blocked_copies := false
 for die in range(3):
  for side in range(6):
   var error: String = C.refit_error(app,60,1,Vector2i(die,side))
   if "owns only" in error:blocked_copies = true
 check(blocked_copies and app.builds==installed,"Second installation cannot duplicate the physical copy")
 app.camp_remove(0,chosen.x,chosen.y)
 check(app.expedition.camp.owned(60)==1 and app.expedition.camp.allocated(app.builds,60)==0,"Return retains ownership while freeing allocation")
 check(C.refit_error(app,60,0,Vector2i(0,0),true)!="","Starter/Weapon faces cannot be returned as crafted copies")
 app.go_main();app.trials = T.new(false);app.trials.start(43);app.trials.phase = "reward";app.trials.essence = 5;app.trials.reward_mode = "";app.page = "trials";app.trial_view = "run";app.trial_reward_context = "";app.rebuild()
 check(named(app,"TrialRewardHero0")!=null and named(app,"TrialRewardMemory")==null,"Victory starts at recipient choice")
 app.trial_reward_step = 1;app.rebuild();tap(app,"TrialRewardMemory");await process_frame;await process_frame
 check(named(app,"TrialMemoryChoice")!=null and named(app,"TrialDie0")==null and named(app,"TrialSlot0")==null,"Memory preview never shows an unrelated dice grid")
 var currency: int = app.trials.essence;var phase: String = app.trials.phase;var trial_builds: Array = app.trials.builds.duplicate(true)
 app.open_player_guide("Trials");tap(app,"GuideClose");await process_frame;await process_frame
 check(app.trial_reward_step==2 and app.trials.essence==currency and app.trials.phase==phase and app.trials.builds==trial_builds,"Help preserves a partially selected reward")
 var weapons: Array = app.trials.weapons.duplicate()
 for key in ["venom","heavy","spear","hammer"]:app.trials.weapon_reward_error(key)
 check(app.trials.weapons==weapons and app.trials.essence==currency and app.trials.builds==trial_builds,"Weapon reward previews are read-only")
 var memory: String = app.trial_reward_memory
 tap(app,"TrialMemoryBuy");await process_frame;await process_frame
 check(app.trials.memories[app.trials.hero]==memory and app.trials.essence==currency-2 and app.trials.stage==1,"Memory purchase applies once for 2 Run Essence")
 check(not app.trials.equip_memory_reward(memory) and app.trials.essence==currency-2,"Stale reward purchase cannot pay twice")
 check(app.expedition.camp.bank.bone_creature==2 and app.expedition.camp.owned(60)==1,"Trial reward leaves normal collection alone")
 # The other two reward branches use the same visible sequence and commit only once.
 app.trials.phase = "reward";app.trials.essence = 5;app.trials.reward_mode = "";app.trial_reward_context = "";app.rebuild();app.trial_reward_step = 1;app.rebuild()
 tap(app,"TrialRewardFace");await process_frame;await process_frame
 check(named(app,"TrialRewardChoice")!=null and named(app,"TrialSlot0")==null,"Ability reward is inspected before choosing a side")
 app.trial_reward_step = 3;app.rebuild()
 var reward_slot := Vector2i(-1,-1)
 for die in range(3):
  for side in range(6):
   if app.trials.replacement_error(app.trials.reward_face,die,side)=="":reward_slot = Vector2i(die,side);break
  if reward_slot.x>=0:break
 check(reward_slot.x>=0,"Offered Trial face has a legal physical replacement")
 app.trial_die = reward_slot.x;app.trial_replacement = reward_slot;app.rebuild()
 var stage: int = app.trials.stage;var reward_face: int = app.trials.reward_face
 tap(app,"TrialRewardBuy");await process_frame;await process_frame
 check(app.trials.essence==3 and app.trials.stage==stage+1 and app.trials.builds[app.trials.hero][reward_slot.x][reward_slot.y]==reward_face,"Ability purchase replaces its selected side for the printed cost")
 app.trials.phase = "reward";app.trials.essence = 5;app.trials.reward_mode = "weapon";app.trial_reward_context = "";app.rebuild()
 var valid_weapon := ""
 for key in ["venom","heavy","spear","hammer"]:
  if app.trials.weapon_reward_error(key)=="":valid_weapon = key;break
 check(valid_weapon!="","Existing Trial build can use an offered alternate Weapon")
 app.trials.reward_weapon = valid_weapon;app.rebuild();stage = app.trials.stage
 tap(app,"TrialEquipWeapon");await process_frame;await process_frame
 check(app.trials.weapons[app.trials.hero]==valid_weapon and app.trials.stage==stage+1 and app.trials.essence==3,"Explicit Weapon reward applies once")
 app.trials.phase = "reward";app.trials.essence = 5;app.trials.reward_mode = "";app.trial_reward_context = "";app.rebuild();app.trial_reward_step = 1;app.rebuild();stage = app.trials.stage
 var reward_builds: Array = app.trials.builds.duplicate(true)
 tap(app,"TrialBankReward");await process_frame;await process_frame
 check(app.trials.essence==7 and app.trials.stage==stage+1 and app.trials.builds==reward_builds,"Take currency advances without editing equipment or dice")
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false)
  for page in ["main","normal","setup","events","camp","trials"]:
   app.page = page;app.camp_tab = -1;app.rebuild();await process_frame;await process_frame
   var scroll: Control = named(app,"BattlePanelScroll");var title: Control = named(app,"MenuTitle");var sub: Control = named(app,"MenuSubtitle");var help: Control = named(app,"ContextHelp")
   check(named(app,"SoundtrackCaption")==null,"Audio controls do not cover shared menu footers")
   check(scroll!=null and title!=null and sub!=null and help!=null,"Shared readable menu at "+str(size)+page)
   if scroll:
    check(scroll.position.y>=sub.position.y and scroll.get_global_rect().end.y<=app.get_viewport_rect().size.y-70,"Content stays above fixed footer "+str(size)+page)
    check(title.size.y>0 and not title.get_global_rect().intersects(help.get_global_rect()),"Title reserves Help space "+str(size)+page)
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);app.page = "camp"
  for task in range(4):
   app.camp_tab = task;app.rebuild();await process_frame;await process_frame
   var scroll: ScrollContainer = named(app,"BattlePanelScroll")
   if task==0:check(named(app,"CampMaterialPicker").action_mode==BaseButton.ACTION_MODE_BUTTON_RELEASE,"Scrolling over a selector does not open it on press")
   check(scroll.get_child(0).size.x<=scroll.size.x,"Camp task fits width without sideways scrolling "+str(size)+str(task))
 var pending_game = B.new();pending_game.start([B.default_build(),B.default_build(),B.default_build()],43,false,true,{})
 pending_game.active = 0;pending_game.pending = {"kind":"catalog_choice","face":11,"stage":0,"die":0}
 app.game = pending_game;app.page = "battle";app.selected = 0;app.playback.clear(app.CombatPlayback.capture(pending_game));app.seen_event = pending_game.event_id;app.roll_seen = pending_game.roll_presentations.size()
 app.rebuild();app.selected = 0
 var pending: Dictionary = pending_game.pending.duplicate(true);var pending_rng: int = pending_game.rng.state
 app.open_player_guide("Combat");tap(app,"GuideClose");await process_frame;await process_frame
 check(pending_game.pending==pending and pending_game.rng.state==pending_rng and app.selected==0,"Guide returns to mandatory combat choice without rerolling or cancelling it")
 app.queue_free();await process_frame
 print("MENUS v43: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
