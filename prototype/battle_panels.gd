extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
static func panel(app, title: String, subtitle: String) -> VBoxContainer:
 var size: Vector2 = app.get_viewport_rect().size
 var shade := ColorRect.new();shade.color = Color("101923");shade.size = size;app.ui.add_child(shade)
 app.label_at(title,Vector2(16,12),26 if app.mobile_mode else 30,app.GOLD,size.x-32,true,true)
 app.label_at(subtitle,Vector2(18,54),17,app.MUTED,size.x-36,false,true)
 var width: float = minf(1180,size.x-24)
 var scroll := ScrollContainer.new();scroll.name = "BattlePanelScroll";scroll.position = Vector2((size.x-width)/2,104);scroll.size = Vector2(width,size.y-190);scroll.scroll_deadzone = 14;app.ui.add_child(scroll)
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
 var column := panel(app,"ENEMY INTENTS","Live targets · priorities update as the battlefield changes")
 M.text(column,"Out of reach → closest legal opponent. Random ties stay fixed while you inspect.",18)
 for intent in app.game.enemy_intents():
  var card := VBoxContainer.new();card.add_theme_constant_override("separation",8);column.add_child(card)
  var tint := Color("98a2af") if intent.done else intent_color(intent.action)
  M.text(card,app.game.unit_name(intent.source)+" · Die "+str(intent.slot+1)+( " · RESOLVED" if intent.done else ""),18,app.MUTED)
  M.text(card,intent.action,27,tint);M.text(card,"TARGET → "+intent.target_text,24,app.GOLD)
  M.text(card,"PRIORITY · "+intent.policy,19,tint);M.text(card,intent.detail,21)
  var rule := HSeparator.new();card.add_child(rule)
 footer(app,["Enemy cards","Back to battle"],[func():app.show_intents = false;app.show_enemy_cards = true;app.rebuild(),func():app.show_intents = false;app.rebuild()])
static func intent_color(action: String) -> Color:
 if action in ["Advance","Iron Advance","Scuttle","Burrow"]:return Color("e7cc75")
 if action in ["Brace","Raise Guard","Guard","Iron Guard","Brood Guard","Seal the Bell"]:return Color("8db7df")
 if action in ["Gathering Note","Crescendo","Ashen Chain","Distort","Fracture","Mend","Birth Cry","Brood Command","Devour Brood","Cinder Brand","Grave Tithe"]:return Color("c5a5e8")
 return Color("ed938b")
static func picker(app) -> void:
 var p: Dictionary = app.game.pending
 var title: String = app.Catalog.name_for(p.get("face",65))
 var column := panel(app,title,"FACE-UP DICE · this round’s nine results. Tap to inspect, then confirm.")
 var instruction := "Inspect a rolled result, then confirm. Borrow Shape can copy spent and held faces."
 if p.kind == "essence_burden_ally":instruction = "Choose an ally within 2 and a ready die to spend on the copied action."
 elif p.face == 11:instruction = "Choose a visible immediate ability within range. No copy/setup loops."
 elif p.face == 23:instruction = "Step 1: choose a ready non-Blank die to skip." if p.stage == 0 else "Step 2: choose a different spent immediate result to repeat."
 elif p.face == 26:instruction = "Choose your ready Blank result; next choose an installed ability on that die."
 elif p.face == 30:instruction = "Choose your ready Attack or Defense result to modify."
 elif p.face == 32:instruction = "Choose your ready Step, Stride or Guard; resolve it now and store a Reaction."
 M.text(column,instruction,19)
 var selected: Vector2i = app.choice_preview;var eligible := false
 if selected.x in range(3) and selected.y in range(3):
  var face: int = app.game.face(selected.x,selected.y)
  M.text(column,app.game.unit_name(selected.x)+" · "+app.Catalog.display_name(face),25,app.color_for_face(face));M.text(column,app.short_face_help(face),21)
  eligible = app.choice_eligible(p,selected.x,selected.y) if p.kind == "catalog_choice" else selected.x != app.game.active and app.game.heroes[selected.x].hp>0 and not app.game.heroes[selected.x].dead and (not app.game.heroes[selected.x].used[selected.y] or selected.y in app.game.heroes[selected.x].reaction) and app.game.distance(app.game.active,selected.x)<=2
  if not eligible:M.text(column,"Unavailable for this choice. Inspect another face, or spend without effect.",19,Color("e9ab90"))
 for hero in range(3):
  var h: Dictionary = app.game.heroes[hero]
  M.text(column,app.game.unit_name(hero)+" · %d HP" % h.hp,24,app.COLORS[hero])
  var row := M.row(column)
  for die in range(3):
   if h.results.size()!=3:continue
   var face: int = app.game.face(hero,die);var spent: bool = h.used[die] and die not in h.reaction and (h.channel.is_empty() or h.channel.die!=die)
   var allowed: bool = app.choice_eligible(p,hero,die) if p.kind == "catalog_choice" else hero != app.game.active and h.hp>0 and not h.dead and (not h.used[die] or die in h.reaction) and app.game.distance(app.game.active,hero)<=2
   var state: String = "SPENT" if spent else "HELD" if h.used[die] else "READY"
   var pick := button(app,row,"Die %s · %s\n%s\n%s" % [["I","II","III"][die],state,app.Catalog.name_for(face),app.Catalog.classification(face)],func():app.choice_preview = Vector2i(hero,die);app.rebuild(),Color("8a929e") if spent else app.color_for_face(face))
   pick.name = "RolledChoice%d_%d" % [hero,die];pick.custom_minimum_size.y = 112;pick.add_theme_font_size_override("font_size",18)
   if spent:app.mark_spent(pick)
   if not allowed:pick.add_theme_color_override("font_color",Color("737f8e"))
   if app.choice_preview == Vector2i(hero,die):pick.add_theme_stylebox_override("normal",app.style(Color("293442"),app.GOLD))
 footer(app,["Use selected result","Spend without effect"],[func():
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
