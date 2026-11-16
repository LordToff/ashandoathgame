extends RefCounted
## One hero, one equipment decision at a time. No extra character layers.
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const R = preload("res://prototype/trial_rules.gd")
const K = preload("res://prototype/trial_classes.gd")
const STEPS = ["Class","Soul","Body","Weapon","Memory","Dice"]
static func move(app, step: int, hero: int = -1) -> void:
 if app.trials.phase!="lobby":return
 app.trials.prepare_step = clampi(step,0,6)
 if hero in range(3):app.trials.hero = hero
 app.trials.save();app.rebuild()
static func next(app) -> void:
 var run = app.trials
 if run.phase!="lobby" or run.prepare_step not in range(6):return
 if run.prepare_step<5:move(app,run.prepare_step+1);return
 run.prepared[run.hero] = true
 var missing: int = run.prepared.find(false)
 move(app,0,missing) if missing>=0 else move(app,6)
static func back(app) -> void:
 var run = app.trials
 if run.phase!="lobby":return
 if run.prepare_step==6:move(app,5,2)
 elif run.prepare_step>0:move(app,run.prepare_step-1)
 elif run.hero>0:move(app,5,run.hero-1)
static func change(app, slot: String, key: String) -> void:
 var run = app.trials;var id: int = run.hero
 if run.phase!="lobby":return
 match slot:
  "class":
   if run.classes[id]!=key:run.choose_class(id,key)
  "soul":run.choose_soul(id,key)
  "body":run.bodies[id] = key
  "weapon":run.loadout_weapons[id] = key
 run.prepared[id] = false;run.save();app.rebuild()
static func choice(app, parent: Control, name: String, caption: String, key: String, selected: bool, callback: Callable, tint: Color) -> Button:
 var b: Button = P.button(app,parent,("✓  " if selected else "")+caption,callback,tint)
 b.name = name+key;b.custom_minimum_size.y = 64;b.add_theme_font_size_override("font_size",18)
 if selected:
  var box: StyleBoxFlat = app.Polish.box(Color("293331"),tint,1);box.border_width_left = 4;b.add_theme_stylebox_override("normal",box)
 return b
static func heading(parent: Control, text: String, tint: Color) -> void:M.text(parent,text,19,tint)
static func render(app) -> void:
 var run = app.trials;run.ensure_classes()
 if run.prepare_step==6:party(app);return
 var id: int = run.hero;var step: int = run.prepare_step;var tint: Color = app.COLORS[id]
 var column := P.panel(app,"Prepare "+M.NAMES[id],"Hero %d / 3  ·  Step %d / 6 — %s" % [id+1,step+1,STEPS[step]])
 var tabs := M.row(column)
 for hero in range(3):
  var b: Button = P.button(app,tabs,M.NAMES[hero]+(" ✓" if run.prepared[hero] else ""),func():move(app,0,hero),app.COLORS[hero] if id==hero else app.MUTED)
  b.name = "TrialHero"+str(hero);b.custom_minimum_size.y = 44;b.add_theme_font_size_override("font_size",16)
 heading(column,"%02d / %s" % [step+1,STEPS[step].to_upper()],tint)
 column = work_area(app,column,id)
 match step:
  0:classes(app,column)
  1:souls(app,column)
  2:bodies(app,column)
  3:weapons(app,column)
  4:
   M.text(column,"Your Memory slot starts empty.",27,app.GOLD)
   M.text(column,"After the first victory, earn a Memory to add a passive effect. Some Memories let you spend a rolled Blank for movement, healing or Block.",21)
   M.text(column,"Nothing to equip yet. Your class, Soul, Body and Weapon already provide a complete starting kit.",19)
  5:dice(app,column,id)
 var next_text: String = "Next: "+STEPS[step+1] if step<5 else "Prepare next hero" if run.prepared.count(true)<2 and not run.prepared[id] else "Review party"
 P.footer(app,["Exit","Back",next_text],[app.go_main,func():
  if run.prepare_step==step and run.hero==id:back(app),func():
  if run.prepare_step==step and run.hero==id:next(app)],[false,step==0 and id==0,false])
 # Stable names make the actual visible wizard navigation discoverable.
 var buttons: Array = app.ui.get_children().filter(func(n):return n is Button)
 for b in buttons:
  if b.text==next_text:b.name = "TrialPrepNext"
  elif b.text=="Back":b.name = "TrialPrepBack"
static func classes(app, column: Control) -> void:
 var run = app.trials;var id: int = run.hero
 M.text(column,"Choose a starting kit. You can adjust its four equipment slots in the next steps.",20)
 for key in K.CLASSES:
  var kit: Dictionary = K.CLASSES[key]
  choice(app,column,"TrialPrepClass_",kit.name+"\n"+kit.role,key,run.classes[id]==key,func():change(app,"class",key),app.COLORS[id])
 var selected: Dictionary = K.CLASSES[run.classes[id]]
 M.text(column,selected.play,20,app.GOLD)
 var example: Button = P.button(app,column,"Example turn",func():app.mobile_info = selected.name+"\n\n"+selected.turn+"\n\n"+selected.tradeoff;app.rebuild(),app.MUTED);example.custom_minimum_size.y = 44;example.add_theme_font_size_override("font_size",16)
 M.text(column,"Included: "+R.BODIES[selected.body].name+" · "+R.WEAPONS[selected.weapon].name+" · Beginning Soul. Memory starts empty.",19)
static func souls(app, column: Control) -> void:
 var run = app.trials;var id: int = run.hero
 M.text(column,"Your Soul sets maximum HP, minimum Blanks on every die and one strong effect.",20)
 for key in run.available("soul",id):
  var info: Dictionary = R.SOULS.beginning if key=="" else R.SOULS[key]
  choice(app,column,"TrialPrepSoul_",info.name+"\n%d HP · %d Blanks per die" % [info.hp,info.blanks],"beginning" if key=="" else key,run.souls[id]==key,func():change(app,"soul",key),Color("c6a8df"))
 var selected: Dictionary = R.SOULS.beginning if run.souls[id]=="" else R.SOULS[run.souls[id]]
 M.text(column,selected.text,20,app.GOLD)
 if run.souls[id]=="soulcaster":
  M.text(column,"Start with 0 Soul Charges. In combat, tap a Blank: Gather adds 1 charge, or Manifest creates a spell for charges + 1 HP. A new spell must roll on a later turn before use.",20)
  var help: Button = P.button(app,column,"Read the six spells",func():app.trial_help_topic = "Soulcaster";app.trial_view = "guide";app.rebuild(),app.MUTED);help.name = "TrialSoulcasterHelp"
static func bodies(app, column: Control) -> void:
 var run = app.trials;var id: int = run.hero
 M.text(column,"Your Body limits Defense, Movement and Skill faces. Your Weapon sets Attack limits.",20)
 for key in run.available("body",id):
  var info: Dictionary = R.BODIES[key]
  choice(app,column,"TrialPrepBody_",info.name,key,run.bodies[id]==key,func():change(app,"body",key),Color("a8c4df"))
 M.text(column,R.BODIES[run.bodies[id]].text,21,app.GOLD)
 M.text(column,"Legal starting dice adapt to your choices. Movement abilities keep their printed distance.",19)
static func weapons(app, column: Control) -> void:
 var run = app.trials;var id: int = run.hero
 M.text(column,"Your Weapon sets Attack minimum / maximum and replaces basic Strikes with its own rolled attacks.",20)
 for key in run.available("weapon",id):
  var info: Dictionary = R.WEAPONS[key]
  choice(app,column,"TrialPrepWeapon_",info.name+"\n%d–%d Attack faces · %d Strike replacement%s" % [info.min,info.max,info.replacements.size(),"s" if info.replacements.size()!=1 else ""],key,run.loadout_weapons[id]==key,func():change(app,"weapon",key),Color("df9b83"))
 M.text(column,R.WEAPONS[run.loadout_weapons[id]].text,20,app.GOLD)
static func dice(app, column: Control, id: int) -> void:
 var run = app.trials;var build: Array = run.starting_builds()[id]
 M.text(column,"Your starting dice",27,app.GOLD)
 M.text(column,"%d maximum HP · %s · %s" % [run.maximum_hp(id),R.BODIES[run.bodies[id]].name,R.WEAPONS[run.loadout_weapons[id]].name],20)
 M.text(column,"Tap a face to read it. The Weapon’s attacks below occupy real Strike sides and must roll before use.",19)
 var cols: int = 3 if app.mobile_mode and app.get_viewport_rect().size.x<app.get_viewport_rect().size.y else 6
 var width: float = (column.custom_minimum_size.x-(cols-1)*6)/cols
 for die in range(3):
  heading(column,"DIE "+["I","II","III"][die],app.COLORS[id])
  var grid := GridContainer.new();grid.columns = cols;grid.add_theme_constant_override("h_separation",6);grid.add_theme_constant_override("v_separation",6);column.add_child(grid)
  for side in range(6):
   var face: int = run.display_face(id,int(build[die][side]),die,side)
   var b: Button = P.button(app,grid,app.Catalog.name_for(face),func():app.mobile_info = face_help(app,id,face);app.rebuild(),app.color_for_face(face))
   b.name = "TrialPrepDie%dSide%d" % [die,side];b.custom_minimum_size = Vector2(width,54);M.fit_button(b,Vector2(width,54),16);b.custom_minimum_size = Vector2(width,54)
static func party(app) -> void:
 var run = app.trials;var column := P.panel(app,"Your party","Three heroes prepared · choose the final boss")
 for id in range(3):
  M.text(column,M.NAMES[id]+" · "+K.name_for(run.classes[id])+" · %d HP" % run.maximum_hp(id),23,app.COLORS[id])
  var soul: String = "Beginning Soul" if run.souls[id]=="" else R.SOULS[run.souls[id]].name
  M.text(column,R.BODIES[run.bodies[id]].name+" · "+soul+" · "+R.WEAPONS[run.loadout_weapons[id]].name+" · No Memory",18)
  var edit: Button = P.button(app,column,"Edit "+M.NAMES[id],func():move(app,0,id),app.MUTED);edit.name = "TrialPrepEdit"+str(id);edit.custom_minimum_size.y = 42;edit.add_theme_font_size_override("font_size",16)
 M.choose(app,column,"Final boss",run.BOSS_NAMES,run.selected_boss,func(index):run.selected_boss = index;run.save();app.rebuild(),"TrialBoss")
 var tools := M.row(column)
 P.button(app,tools,"Trial Forge",func():app.trial_view = "craft";app.rebuild(),app.MUTED)
 P.button(app,tools,"Equipment guide",func():app.trial_view = "guide";app.rebuild(),app.MUTED)
 P.footer(app,["Back","Begin Trial"],[func():back(app),func():run.start();app.trial_view = "run";app.rebuild()],[false,not run.prepared.all(func(v):return v)])
 for b in app.ui.get_children():
  if b is Button and b.text=="Begin Trial":b.name = "TrialPrepBegin"

static func work_area(app, column: VBoxContainer, id: int) -> VBoxContainer:
 if app.mobile_mode or app.get_viewport_rect().size.x<1000:return column
 var row := HBoxContainer.new();row.add_theme_constant_override("separation",24);column.add_child(row)
 var side := VBoxContainer.new();side.custom_minimum_size.x = 180;side.add_theme_constant_override("separation",16);row.add_child(side)
 M.picture(side,app.HeroArt.texture(id))
 M.text(side,M.NAMES[id],27,app.COLORS[id]);M.text(side,K.name_for(app.trials.classes[id])+" · %d HP" % app.trials.maximum_hp(id),18)
 for entry in [["BODY",R.BODIES[app.trials.bodies[id]].name],["SOUL","Beginning Soul" if app.trials.souls[id]=="" else R.SOULS[app.trials.souls[id]].name],["WEAPON",R.WEAPONS[app.trials.loadout_weapons[id]].name],["MEMORY","Empty at the start"]]:
  M.text(side,entry[0],12,app.COLORS[id]);M.text(side,entry[1],17)
 var panel := PanelContainer.new();panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 var box: StyleBoxFlat = app.Polish.box(Color("192224"),Color("485654"),1);box.set_content_margin_all(16);box.shadow_size = 0;panel.add_theme_stylebox_override("panel",box);row.add_child(panel)
 var work := VBoxContainer.new();work.custom_minimum_size.x = column.custom_minimum_size.x-236;work.add_theme_constant_override("separation",14);panel.add_child(work);return work

static func face_help(app, id: int, face: int) -> String:
 if face==0:
  var text := "Blank: no starting action. Earn a Memory after the first victory to give Blanks another use."
  if app.trials.souls[id]=="soulcaster":text = "Soulcaster Blank: Gather +1 Soul Charge (maximum 3), or Manifest a spell for charges + 1 HP. A new spell must roll on a later turn. Up to four spells; all return to Blank after the encounter."
  if app.blank_move_setting:text += "\n\nYour Settings also enable one rolled Blank as Move 1 per hero turn. This spends the Blank; toggling never refills the allowance."
  return text
 if face in [2,3]:
  var spaces: int = 1 if face==2 else 3
  if app.trials.souls[id]=="bugh":spaces = maxi(1,spaces-1)
  return ("Step: move up to %d orthogonal spaces, turning allowed." if face==2 else "Stride: move up to %d spaces in one straight orthogonal line; no turning.") % spaces
 return app.Catalog.name_for(face)+"\n\n"+app.AbilityCopy.new().face(face)
