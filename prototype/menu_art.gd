extends Control
## Decorative only: deterministic drawing, no input or game RNG.
const CHAMBER = preload("res://prototype/assets/pixel_chamber.png")
const HEROES = preload("res://prototype/assets/pixel_units.png")
var main_menu := false
var header_end := 96.0
var footer_top := 814.0
var tint := Color("c6985c")
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw)
func diamond(at: Vector2, radius: float, color: Color) -> void:
 draw_colored_polygon(PackedVector2Array([at+Vector2(0,-radius),at+Vector2(radius,0),at+Vector2(0,radius),at+Vector2(-radius,0)]),color)
func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,size),Color("101411"))
 var factor: float = maxf(size.x/CHAMBER.get_width(),size.y/CHAMBER.get_height())
 var picture: Vector2 = CHAMBER.get_size()*factor
 draw_texture_rect(CHAMBER,Rect2((size-picture)/2,picture),false,Color(.8,.72,.58,.65))
 draw_rect(Rect2(Vector2.ZERO,size),Color(.035,.055,.05,.58))
 # A faint oath seal and stone pillars remain behind the readable surfaces.
 var center := Vector2(size.x*.79,size.y*.48);var radius: float = minf(size.x*.29,size.y*.31)
 for ring in [radius,radius*.88,radius*.56]:draw_arc(center,ring,0,TAU,80,Color(tint,.09),1,true)
 for index in range(8):
  var angle: float = PI/4*index
  var at: Vector2 = center+Vector2(cos(angle),sin(angle))*radius
  diamond(at,4,Color(tint,.15))
 var outer := PackedVector2Array()
 for index in range(6):outer.append(center+Vector2(cos(PI/3*index-PI/2),sin(PI/3*index-PI/2))*radius*.72)
 outer.append(outer[0]);draw_polyline(outer,Color(tint,.11),1,true)
 for side in [0.0,1.0]:
  var x: float = 26 if side==0 else size.x-26
  draw_line(Vector2(x,header_end+18),Vector2(x,footer_top-16),Color(tint,.13),1)
  for mark in range(5):
   var y: float = header_end+38+float(mark)*(footer_top-header_end-70)/4
   diamond(Vector2(x,y),3,Color(tint,.18))
 if main_menu and size.x>=1000:
  var hearth := Vector2(size.x*.5,size.y*.70)
  # An oathfire scene uses the game's existing hero sprites, not new artwork.
  for glow in range(12,0,-1):draw_circle(hearth-Vector2(0,52),glow*12,Color(.8,.36,.08,.012))
  oval(hearth+Vector2(0,38),Vector2(184,30),Color(.42,.29,.12,.12))
  var stone := PackedVector2Array([hearth+Vector2(-82,0),hearth+Vector2(-60,-18),hearth+Vector2(60,-18),hearth+Vector2(82,0),hearth+Vector2(68,31),hearth+Vector2(-68,31)])
  draw_colored_polygon(stone,Color("242d25"));var rim := stone.duplicate();rim.append(stone[0]);draw_polyline(rim,Color("7d6946"),2,true)
  draw_line(hearth+Vector2(-74,3),hearth+Vector2(74,3),Color("b28b4a"),2)
  var fire := PackedVector2Array([hearth+Vector2(-40,-18),hearth+Vector2(-47,-52),hearth+Vector2(-23,-79),hearth+Vector2(-18,-50),hearth+Vector2(6,-129),hearth+Vector2(26,-91),hearth+Vector2(20,-58),hearth+Vector2(44,-89),hearth+Vector2(45,-42),hearth+Vector2(29,-18)])
  draw_colored_polygon(fire,Color("ad6331"))
  draw_colored_polygon(PackedVector2Array([hearth+Vector2(-25,-18),hearth+Vector2(-22,-51),hearth+Vector2(-8,-38),hearth+Vector2(5,-93),hearth+Vector2(22,-57),hearth+Vector2(16,-18)]),Color("d1a45b"))
  draw_colored_polygon(PackedVector2Array([hearth+Vector2(-10,-18),hearth+Vector2(0,-53),hearth+Vector2(11,-18)]),Color("e8c68b"))
  for hero in range(3):
   var at: Vector2 = hearth+Vector2([-188,104,-42][hero],[10,10,75][hero])
   oval(at+Vector2(48,92),Vector2(41,9),Color(0,0,0,.35))
   var region := Rect2(Vector2(hero%2,hero/2)*32,Vector2(32,32))
   draw_texture_rect_region(HEROES,Rect2(at,Vector2(96,96)),region,Color(.76,.75,.64,.9))
 # Fixed header and footer are opaque enough to keep text clear.
 draw_rect(Rect2(0,0,size.x,header_end-5),Color(.055,.075,.07,.95))
 draw_rect(Rect2(0,footer_top,size.x,size.y-footer_top),Color(.045,.06,.055,.97))
 for y in [header_end-5,footer_top]:
  draw_line(Vector2(12,y),Vector2(size.x-12,y),Color(tint,.45),1)
  draw_line(Vector2(12,y+3),Vector2(size.x-12,y+3),Color(tint,.09),1)
  diamond(Vector2(size.x/2,y),3,tint.darkened(.25))
 # Small ash flecks, stable while reading and unaffected by combat preferences.
 for index in range(28):
  var at := Vector2(fmod(index*137.0+41,size.x),fmod(index*83.0+159,size.y))
  if at.y>header_end and at.y<footer_top:draw_rect(Rect2(at,Vector2(2,2)),Color("c78c48")*Color(1,1,1,.13))

func oval(center: Vector2, radius: Vector2, color: Color) -> void:
 var points := PackedVector2Array()
 for index in range(36):points.append(center+Vector2(cos(TAU*index/36)*radius.x,sin(TAU*index/36)*radius.y))
 draw_colored_polygon(points,color)
