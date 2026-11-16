extends Control
## Quiet ink-and-stone backdrop; no animation, input, or gameplay RNG.
const CHAMBER = preload("res://prototype/assets/pixel_chamber.png")
const Symbols = preload("res://prototype/ability_symbols.gd")
var header_end := 96.0
var footer_top := 814.0
var ribbon_height := 52.0
var main_menu := false
var tint := Color("b8afa2")
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE;resized.connect(queue_redraw)
func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,size),Color("09090d"))
 draw_texture_rect(CHAMBER,Rect2(Vector2.ZERO,size),false,Color(.27,.27,.29,.2))
 draw_rect(Rect2(Vector2.ZERO,size),Color(.025,.025,.035,.66))
 if main_menu and size.x>=1000:
  var edge: float = minf(300,size.y*.34)
  draw_texture_rect(Symbols.menu_symbol("trial"),Rect2(size.x*.73-edge/2,size.y*.56-edge/2,edge,edge),false,Color(.55,.50,.47,.15))
 draw_rect(Rect2(0,0,size.x,header_end-4),Color(.025,.025,.035,.96))
 draw_rect(Rect2(0,footer_top,size.x,size.y-footer_top),Color(.025,.025,.035,.98))
 for y in [header_end-5,footer_top]:
  draw_line(Vector2(12,y),Vector2(size.x-12,y),Color("363139"),1)
  draw_line(Vector2(12,y),Vector2(82,y),Color("8f2436"),2)
 for x in [12.0,size.x-12]:
  draw_line(Vector2(x,header_end+7),Vector2(x,header_end+23),Color("4a4049"),1)
  draw_line(Vector2(x,footer_top-7),Vector2(x,footer_top-23),Color("4a4049"),1)
