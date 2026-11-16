extends RefCounted
## Restrained gothic HUD: ink, bone and crimson. Original symbols are credited.
const Symbols = preload("res://prototype/ability_symbols.gd")
const CHAMBER = preload("res://prototype/assets/pixel_chamber.png")
const WALL = preload("res://prototype/assets/vendor/crawl_party_arena/masonry.png")
const FLOORS = [preload("res://prototype/assets/vendor/crawl_party_arena/cobble_1.png"),preload("res://prototype/assets/vendor/crawl_party_arena/cobble_2.png"),preload("res://prototype/assets/vendor/crawl_party_arena/cobble_3.png")]

const INK = Color("e5dfd4")
const CRIMSON = Color("9d2835")
static func surface(kind: String, color: Color = Color.WHITE) -> StyleBoxFlat:
 var box := StyleBoxFlat.new();box.bg_color = Color("0d0d11");box.border_color = Color("38363a");box.set_border_width_all(1);box.set_corner_radius_all(0);box.set_content_margin_all(12)
 if kind=="frame":box.bg_color = Color(0,0,0,0);box.border_color = Color("655c57")
 if kind=="intent_active":box.bg_color = Color("241014");box.border_color = Color("b3a391")
 return box
static func button(button: Button, accent: Color, primary: bool = false) -> void:
 button.set_meta("gothic_skin",true)
 for state in ["normal","hover","pressed","disabled"]:
  var box := surface("button");box.bg_color = Color("210d12") if primary else Color("111115");box.set_content_margin_all(8)
  box.border_color = Color("7d3540") if primary else Color("39363b")
  if state=="hover":box.bg_color = Color("272128");box.border_color = Color("b0a69b")
  elif state=="pressed":box.bg_color = Color("38161f")
  elif state=="disabled":box.bg_color = Color("0a0a0d");box.border_color = Color("25232a")
  button.add_theme_stylebox_override(state,box)
 button.add_theme_color_override("font_color",INK);button.add_theme_color_override("font_hover_color",Color.WHITE);button.add_theme_color_override("font_disabled_color",Color("66626a"))
static func apply_theme(theme: Theme) -> void:
 for control in ["OptionButton","MenuButton"]:
  for state in ["normal","hover","pressed","disabled"]:
   var box := surface("input");box.bg_color = Color("161419") if state=="hover" else Color("0a0a0e");theme.set_stylebox(state,control,box)
  theme.set_color("font_color",control,INK)
 theme.set_stylebox("panel","PopupMenu",surface("popup"))
 var hover := surface("popup");hover.bg_color = Color("34151e");theme.set_stylebox("hover","PopupMenu",hover)
 theme.set_color("font_color","PopupMenu",INK);theme.set_color("font_hover_color","PopupMenu",Color.WHITE)
 theme.set_stylebox("panel","TooltipPanel",surface("tooltip"))
 theme.set_stylebox("normal","LineEdit",surface("input"));var focus := surface("input");focus.border_color = Color("c6b9a8");theme.set_stylebox("focus","LineEdit",focus)
static func mat(app, size: Vector2) -> void:
 app.draw_rect(Rect2(Vector2.ZERO,size),Color("08080b"))
 app.draw_texture_rect(WALL,Rect2(Vector2.ZERO,size),true,Color(.28,.29,.33,.14))
 app.draw_rect(Rect2(Vector2.ZERO,size),Color(.02,.02,.025,.65))
static func panel(app, rect: Rect2, tint: Color, body: bool = true) -> void:
 if body:app.draw_rect(rect,Color("0b0b0f"))
 app.draw_rect(rect,Color("39343a"),false,1)
 app.draw_rect(rect.grow(-4),Color("1e1c22"),false,1)
 for at in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:
  var d: Vector2 = (rect.get_center()-at).sign();app.draw_line(at,at+Vector2(d.x*10,0),Color("867a70"),1);app.draw_line(at,at+Vector2(0,d.y*10),Color("867a70"),1)
