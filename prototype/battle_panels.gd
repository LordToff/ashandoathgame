extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
static func panel(app, title: String, subtitle: String) -> VBoxContainer:
 var size: Vector2 = app.get_viewport_rect().size
 var shade := ColorRect.new();shade.color = Color("101923");shade.size = size;app.ui.add_child(shade)
 app.label_at(title,Vector2(16,12),26 if app.mobile_mode else 30,app.GOLD,size.x-32,true,true)
 app.label_at(subtitle,Vector2(18,54),17,app.MUTED,size.x-36,false,true)
 var width: float = minf(1180,size.x-24)
 var top: float = 72 if subtitle == "" else 92
 var scroll := ScrollContainer.new();scroll.name = "BattlePanelScroll";scroll.position = Vector2((size.x-width)/2,top);scroll.size = Vector2(width,size.y-top-86);scroll.scroll_deadzone = 14;app.ui.add_child(scroll)
 var column := VBoxContainer.new();column.custom_minimum_size.x = width-16;column.size_flags_horizontal = Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",12);scroll.add_child(column);return column
static func button(app, parent: Control, caption: String, action: Callable, tint: Color, disabled: bool = false) -> Button:
 var pick: Button = M.btn(app,parent,caption,action,tint,disabled)
 for connection in pick.pressed.get_connections():
  if not int(connection.flags)&Object.CONNECT_DEFERRED:
   pick.pressed.disconnect(connection.callable);pick.pressed.connect(connection.callable,int(connection.flags)|Object.CONNECT_DEFERRED)
 return pick
static func footer(app, labels: Array, actions: Array, disabled: Array = []) -> void:
 M.footer(app,labels,actions,disabled)
 # Desktop callbacks also wait until input propagation completes.
 for child in app.ui.get_children():
  if child is Button:
   for connection in child.pressed.get_connections():
    if not int(connection.flags)&Object.CONNECT_DEFERRED:
     child.pressed.disconnect(connection.callable);child.pressed.connect(connection.callable,int(connection.flags)|Object.CONNECT_DEFERRED)
static func intents(app) -> void:
 var entries: Array = app.game.enemy_intents();var sources: Array = []
 for entry in entries:
  if entry.source not in sources:sources.append(entry.source)
 if sources.is_empty():
  var column := panel(app,"No enemy actions","");footer(app,["Back"],[func():app.show_intents = false;app.rebuild()]);return
 if app.intent_focus.x not in sources:app.intent_focus.x = sources[0]
 var source: int = app.intent_focus.x;app.mobile_enemy = source
 var unit: Dictionary = app.game.unit_data(source)
 var column := panel(app,app.game.unit_name(source),"%d HP · %d Block" % [unit.hp,unit.block])
 if sources.size()>1:
  M.choose(app,column,"Enemy",sources.map(func(id):return app.game.unit_name(id)),sources.find(source),func(index):app.intent_focus = Vector2i(sources[index],0);app.rebuild())
 var choices: Array = entries.filter(func(entry):return entry.source == source)
 var tabs := M.row(column)
 for entry in choices:
  var b := button(app,tabs,entry.action,func():app.intent_focus.y = entry.slot;app.rebuild(),intent_color(entry.action))
  b.add_theme_font_size_override("font_size",18);b.custom_minimum_size.y = 62
  if entry.slot==app.intent_focus.y:b.add_theme_stylebox_override("normal",app.style(Color("293747"),app.GOLD))
 var selected: Dictionary = choices[mini(maxi(0,app.intent_focus.y),choices.size()-1)]
 M.text(column,"→ "+selected.target_text,24,app.GOLD)
 M.text(column,selected.detail,22)
 M.text(column,selected.policy,18,app.MUTED)
 footer(app,["Back"],[func():app.show_intents = false;app.rebuild()])
static func intent_color(action: String) -> Color:
 if action in ["Advance","Iron Advance","Scuttle","Burrow"]:return Color("e7cc75")
 if action in ["Brace","Raise Guard","Guard","Iron Guard","Brood Guard","Seal the Bell"]:return Color("8db7df")
 if action in ["Gathering Note","Crescendo","Ashen Chain","Distort","Fracture","Mend","Birth Cry","Brood Command","Devour Brood","Cinder Brand","Grave Tithe"]:return Color("c5a5e8")
 return Color("ed938b")
static func picker(app) -> void:
 var p: Dictionary = app.game.pending
 var title: String = app.Catalog.name_for(p.get("face",65))
 var column := panel(app,title,"")
 var instruction := "Choose a face"
 if p.kind == "essence_burden_ally":instruction = "Choose an ally’s ready face"
 elif p.face == 11:instruction = "Choose a face in range"
 elif p.face == 23:instruction = "Choose a face to skip" if p.stage == 0 else "Choose a spent face"
 elif p.face == 26:instruction = "Choose a Blank"
 elif p.face == 30:instruction = "Choose an Attack or Defense"
 elif p.face == 32:instruction = "Choose Step, Stride or Guard"
 M.text(column,instruction,19)
 var selected: Vector2i = app.choice_preview;var eligible := false
 if selected.x in range(3) and selected.y in range(3):
  var face: int = app.game.face(selected.x,selected.y)
  M.text(column,app.game.unit_name(selected.x)+" · "+app.Catalog.name_for(face),25,app.color_for_face(face));M.text(column,app.short_face_help(face).split("\n\n")[0],21)
  eligible = app.choice_eligible(p,selected.x,selected.y) if p.kind == "catalog_choice" else selected.x != app.game.active and app.game.heroes[selected.x].hp>0 and not app.game.heroes[selected.x].dead and (not app.game.heroes[selected.x].used[selected.y] or selected.y in app.game.heroes[selected.x].reaction) and app.game.distance(app.game.active,selected.x)<=2
  if not eligible:M.text(column,"Unavailable",19,Color("e9ab90"))
 for hero in range(3):
  var h: Dictionary = app.game.heroes[hero]
  M.text(column,app.game.unit_name(hero),24,app.COLORS[hero])
  var row := M.row(column)
  for die in range(3):
   if h.results.size()!=3:continue
   var face: int = app.game.face(hero,die);var spent: bool = h.used[die] and die not in h.reaction and (h.channel.is_empty() or h.channel.die!=die)
   var allowed: bool = app.choice_eligible(p,hero,die) if p.kind == "catalog_choice" else hero != app.game.active and h.hp>0 and not h.dead and (not h.used[die] or die in h.reaction) and app.game.distance(app.game.active,hero)<=2
   var state: String = "SPENT" if spent else "HELD" if h.used[die] else "READY"
   var pick := button(app,row,app.Catalog.name_for(face),func():app.choice_preview = Vector2i(hero,die);app.rebuild(),Color("8a929e") if spent else app.color_for_face(face))
   pick.name = "RolledChoice%d_%d" % [hero,die];pick.custom_minimum_size.y = 76;pick.add_theme_font_size_override("font_size",18)
   if spent:app.mark_spent(pick)
   if not allowed:pick.add_theme_color_override("font_color",Color("737f8e"))
   if app.choice_preview == Vector2i(hero,die):pick.add_theme_stylebox_override("normal",app.style(Color("293442"),app.GOLD))
 footer(app,["Use","Skip"],[func():
  if p.kind == "catalog_choice":
   if app.game.catalog_pick(selected.x,selected.y):app.selected = app.game.forced_die
  else:app.game.burden_ally(selected.x,selected.y);app.selected = app.game.forced_die
  app.choice_preview = Vector2i(-1,-1);app.rebuild(),func():
  if p.kind == "catalog_choice":app.game.pending = {};app.game.decline(p.die)
  else:app.game.essence_decline()
  app.selected = -1;app.choice_preview = Vector2i(-1,-1);app.rebuild()],[not eligible,false])
static func engrave(app) -> void:
 var notice: Dictionary = app.combat_notices[0]
 var column := panel(app,notice.title,"Updated installed sides · current rolled results stay unchanged")
 M.text(column,notice.text,22)
 var grid := GridContainer.new();grid.columns = 3;grid.add_theme_constant_override("h_separation",8);grid.add_theme_constant_override("v_separation",8);column.add_child(grid)
 var faces: Array = notice.get("faces",[])
 for side in range(faces.size()):
  var face: int = faces[side]
  var b := button(app,grid,"Side %d\n%s" % [side+1,app.Catalog.name_for(face)],func():pass,app.color_for_face(face));b.custom_minimum_size.y = 90
 footer(app,["Continue"],[func():app.combat_notices.pop_front();app.rebuild()])

static func collection(app) -> void:
 var column := panel(app,"Collection","Hold locked items to unlock" if app.debug_mode else "")
 M.heroes(app,column,true)
 var souls: Array = ["beginning","hollow","ashroad"]+app.Wilds.SOULS.keys()
 M.text(column,"Souls",24,app.GOLD)
 var grid := GridContainer.new();grid.columns = 3 if app.get_viewport_rect().size.x>700 else 2;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);column.add_child(grid)
 for soul in souls:
  var owned: bool = soul in app.expedition.camp.souls[app.camp_hero]
  var b := button(app,grid,app.Wilds.soul_name(soul),func():
   app.mobile_info = app.Wilds.SOULS.get(soul,{}).get("effect","Spend a rolled Blank as Move 1 once per turn." if soul == "beginning" else "Spend a rolled Blank as Move 2 once per turn.")
   app.info_return_collection = true;app.show_collection = false;app.rebuild(),app.GOLD if owned else app.MUTED)
  b.name = "CollectionSoul_"+soul;app.bind_unlock(b,"soul",soul,app.camp_hero)
 M.text(column,"Memories",24,app.GOLD)
 var memories := GridContainer.new();memories.columns = grid.columns;memories.add_theme_constant_override("h_separation",10);memories.add_theme_constant_override("v_separation",10);column.add_child(memories)
 for key in app.expedition.camp.memory_keys():
  var owned: bool = app.expedition.camp.unlocked.has(key)
  var b := button(app,memories,app.expedition.camp.reward_name(key),func():app.mobile_info = app.expedition.camp.reward_effect(key);app.info_return_collection = true;app.show_collection = false;app.rebuild(),app.GOLD if owned else app.MUTED)
  b.name = "CollectionMemory_"+key;app.bind_unlock(b,"recipe",key,app.camp_hero)
 footer(app,["Debug: "+("On" if app.debug_mode else "Off"),"Back"],[func():app.set_debug_mode(not app.debug_mode),func():app.show_collection = false;app.rebuild()])
