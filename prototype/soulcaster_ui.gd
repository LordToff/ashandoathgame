extends RefCounted
const S = preload("res://prototype/soulcaster.gd")
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
static func change(app, fn: Callable) -> void:
 fn.call();app.selected = -1;app.trial_choice.clear();app.hint = "";app.rebuild()
static func pick(app, parent, label: String, fn: Callable, name: String, color: Color, disabled: bool = false) -> Button:
 var button := P.button(app,parent,label,fn,color,disabled);button.name = name;return button
static func resource(g, hero: int) -> String:return "%d/3 Soul Charges · %d/4 spells" % [S.charges(g,hero),S.count_spells(g,hero)]
static func pending(app) -> bool:
 match app.game.pending.get("kind",""):
  "soul_blank":blank(app)
  "soul_fate":fate(app)
  "soul_omen":omen(app)
  "soul_friendly_mirror":mirror(app)
  "soul_steps":steps(app)
  _:return false
 return true
static func spells(app, column) -> void:
 var grid := GridContainer.new();grid.columns = 2 if app.mobile_mode else 3;grid.add_theme_constant_override("h_separation",8);grid.add_theme_constant_override("v_separation",8);column.add_child(grid)
 for face in S.SPELLS:
  var info: Dictionary = S.SPELLS[face]
  var button := pick(app,grid,info.name+"\n%d %s + 1 HP" % [info.cost,"charge" if info.cost==1 else "charges"],func():app.soulcaster_spell = face;app.rebuild(),"SoulSpell"+str(face),app.color_for_face(face))
  button.add_theme_font_size_override("font_size",18);button.custom_minimum_size.y = 72
  if face==app.soulcaster_spell:button.add_theme_stylebox_override("normal",app.style(Color("293747"),app.GOLD))
 var selected: Dictionary = S.SPELLS[app.soulcaster_spell]
 M.text(column,selected.name,25,app.color_for_face(app.soulcaster_spell));M.text(column,selected.text,21)
static func blank(app) -> void:
 var g = app.game;var hero: int = g.pending.hero;var size: Vector2 = app.get_viewport_rect().size
 var at := Vector2(752,144);var width := 352.0;var height := 694.0;var card_height := 104.0
 if app.mobile_mode:
  var board: Rect2 = M.board_rect(app);var x: float = board.end.x+12 if size.x>size.y else 12
  at = Vector2(x,size.y-280);width = size.x-x-12;height = 280;card_height = 56
 app.setup_panel(Rect2(at,Vector2(width,height)),app.GOLD)
 app.label_at("Soulcaster · "+resource(g,hero),at+Vector2(10,7),16,app.GOLD,width-20,false,true)
 var hp: int = g.heroes[hero].hp
 app.label_at("Create costs 1 HP · %d HP now%s" % [hp," · will Down you" if hp==1 else ""],at+Vector2(10,29),15,Color("efba99") if hp==1 else app.MUTED,width-20)
 var usable: float = width-20;var gather_width: float = usable*.48;var other_width: float = (usable-gather_width-12)/2
 var gather: Button = app.button("Gather +1" if S.charges(g,hero)<3 else "Charges full",at+Vector2(10,52),Vector2(gather_width,40),func():change(app,func():S.gather(g)),app.GOLD,S.charges(g,hero)>=3);gather.name = "SoulcasterGather";gather.add_theme_font_size_override("font_size",18);gather.size = Vector2(gather_width,40)
 var help: Button = app.button("Help",at+Vector2(16+gather_width,52),Vector2(other_width,40),func():app.show_soulcaster_help = true;app.rebuild(),app.MUTED);help.name = "SoulcasterHelp";help.add_theme_font_size_override("font_size",18);help.size = Vector2(other_width,40)
 var close: Button = app.button("Close",at+Vector2(22+gather_width+other_width,52),Vector2(other_width,40),func():g.pending = {};app.rebuild(),app.MUTED);close.name = "SoulcasterCancel";close.add_theme_font_size_override("font_size",18);close.size = Vector2(other_width,40)
 for index in range(6):
  var face: int = 75+index;var info: Dictionary = S.SPELLS[face];var reason: String = S.manifest_reason(g,hero,face)
  var w: float = (usable-6)/2;var top: float = (98 if app.mobile_mode else 104)+(index/2)*(card_height+4)
  var caption: String = ("Mirror (Reaction)" if face==77 else str(info.name))+"\n%d charge%s · 1 HP" % [int(info.cost),"s" if int(info.cost)!=1 else ""]
  var button: Button = app.button(caption,at+Vector2(10+(index%2)*(w+6),top),Vector2(w,card_height),func():change(app,func():S.manifest(g,face)),app.color_for_face(face),reason!="")
  button.name = "SoulSpell"+str(face);button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;button.add_theme_font_size_override("font_size",18 if app.mobile_mode else 17);button.size = Vector2(w,card_height)
  button.tooltip_text = info.text+"\n\n"+(reason if reason!="" else "Create on the selected Blank. It must roll on a later turn.")
 if not app.mobile_mode:
  app.label_at("Tap Gather, or tap a spell to create it.\nSpells must roll on a later turn.\nHelp explains each spell before you spend.",at+Vector2(12,446),18,app.MUTED,width-24,false,true)
static func guide(app) -> void:
 var column := P.panel(app,"Soulcaster spellbook","Free starter Soul · either class · Trials only")
 M.text(column,"The loop",27,app.GOLD)
 M.text(column,"1. Tap a rolled Blank. Gather spends it for +1 Soul Charge (maximum 3).\n2. With enough charges, tap another Blank, then tap the spell to create it. Pay its charges and 1 HP.\n3. That result is spent. The spell becomes available only when its new physical side is rolled on a later turn.",21)
 M.text(column,"Your build",27,app.GOLD)
 M.text(column,"Soulcaster starts at 6 base HP, then applies the equipped Memory’s HP penalty. Guard / Momentum Memory makes 5 HP; No Memory keeps 6. Every starting die has four Blanks. Your Weapon still replaces its Strike side with Jab / Crack where applicable. Body movement modifiers still apply to normal movement.",21)
 M.text(column,"Up to four spells may exist on each caster’s dice. Soul Charges begin at 0 each encounter; all manifested sides return to your starting build after it. Soulcasting replaces Blank movement. Soul Charges pay for spells; Action Rerolls reroll dice; Run Essence buys rewards.",21)
 spells(app,column)
 P.footer(app,["Back"],[func():app.show_soulcaster_help = false;app.rebuild()])
static func fate(app) -> void:
 var g = app.game;var column := P.panel(app,"Fatebreaker","+1 Action Reroll gained, up to the normal cap")
 M.text(column,"Reroll one unresolved enemy die. Keep its new result, even if unchanged. Each enemy die may be rerolled once per shared round. The spell itself is already spent.",21)
 var options: Array = S.fate_options(g)
 for entry in options:
  pick(app,column,g.unit_name(entry.source)+" · "+["I","II","III"][entry.slot]+" · "+entry.action,func():change(app,func():S.choose_fate(g,entry.source,entry.slot)),"FateEnemy%d_%d" % [entry.source,entry.slot],P.intent_color(entry.action))
 if options.is_empty():
  M.text(column,"No enemy die is eligible. You keep the gained Action Reroll.",21)
  P.footer(app,["Continue"],[func():change(app,func():S.no_fate(g))])
static func omen(app) -> void:
 var g = app.game;var hero: int = g.active;var column := P.panel(app,"Hoarded Omen","Save one ready ability · original die stays aside")
 M.text(column,"This turn, choose one ordinary ready result to keep. Its die skips the next shared roll; the saved result becomes ready on your turn in round %d. You have three dice in total. You can decide later through More / Trial menu." % [g.round_no+1],21)
 for die in range(3):
  var face: int = g.face(hero,die)
  pick(app,column,g.Catalog.name_for(face),func():change(app,func():S.store(g,die)),"OmenDie"+str(die),app.color_for_face(face),not S.can_store(g,hero,die))
 M.text(column,"No Blanks, Reactions, Channels, Constants, Negative / when-rolled results or Hoarded Omen.",18,app.MUTED)
 P.footer(app,["Not now"],[func():S.later_omen(g);app.rebuild()])
static func mirror(app) -> void:
 var g = app.game;var p: Dictionary = g.pending;var choice: Dictionary = p.choices[int(p.index)]
 var column := P.panel(app,"Mirror of the Damned",g.unit_name(choice.hero)+" may protect "+g.unit_name(p.victim))
 M.text(column,"Friendly Attack from "+g.unit_name(p.attacker),24,app.GOLD);M.text(column,S.text(77),22)
 P.footer(app,["Use Reaction","Hold"],[func():change(app,func():S.friendly_mirror(g,true)),func():change(app,func():S.friendly_mirror(g,false))])
static func steps(app) -> void:
 var g = app.game;var hero: int = g.pending.heroes[0];var size: Vector2 = app.get_viewport_rect().size
 var at := Vector2(752,144);var width := 352.0;var height := 570.0
 if app.mobile_mode:
  var board: Rect2 = M.board_rect(app)
  var x: float = board.end.x+12 if size.x>size.y else 12
  at = Vector2(x,size.y-238);width = size.x-x-12;height = 238
 app.setup_panel(Rect2(at,Vector2(width,height)),app.GOLD)
 app.label_at(g.unit_name(hero)+" · optional Move 1",at+Vector2(10,8),19,app.GOLD,width-20,true,true)
 var captions := ["North","East","South","West","Stay"]
 for i in range(5):
  var dir: Vector2i = g.DIRS[i] if i<4 else Vector2i.ZERO
  var legal: bool = i==4 or (g.heroes[hero].hp>0 and int(g.heroes[hero].get("rooted",0))<=0 and g.legal(hero,g.heroes[hero].pos+dir))
  var w: float = (width-28)/3;var pos: Vector2 = at+Vector2(8+(i%3)*(w+6),48+(i/3)*76)
  var b = app.button(captions[i],pos,Vector2(w,66),func():change(app,func():S.optional_step(g,dir)),app.GOLD,not legal);b.name = "WraithStep"+str(i)
