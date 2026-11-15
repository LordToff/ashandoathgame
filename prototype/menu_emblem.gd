extends Control
var tint := Color("d6b47b")
var kind := "oath"
func _ready() -> void:mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 var c: Vector2 = size/2;var r: float = minf(size.x,size.y)*.43
 draw_circle(c,r,Color(tint,.055));draw_arc(c,r,0,TAU,40,Color(tint,.4),1,true)
 if kind=="trial":
  for index in range(3):
   var x: float = c.x+(index-1)*r*.55
   draw_line(Vector2(x,c.y+r*.4),Vector2(x,c.y-r*.45),tint,2,true)
   draw_line(Vector2(x-r*.16,c.y-r*.2),Vector2(x+r*.16,c.y-r*.2),tint,2,true)
 elif kind=="camp":
  draw_polyline(PackedVector2Array([c+Vector2(-r*.55,r*.4),c+Vector2(0,-r*.55),c+Vector2(r*.55,r*.4)]),tint,2,true)
  draw_line(c+Vector2(-r*.5,r*.4),c+Vector2(r*.5,r*.4),tint,2)
 elif kind=="soul":
  draw_colored_polygon(PackedVector2Array([c+Vector2(0,-r*.65),c+Vector2(r*.4,0),c+Vector2(0,r*.65),c+Vector2(-r*.4,0)]),Color(tint,.55))
 else:
  var box := PackedVector2Array([c+Vector2(0,-r*.67),c+Vector2(r*.58,-r*.28),c+Vector2(r*.58,r*.35),c+Vector2(0,r*.7),c+Vector2(-r*.58,r*.35),c+Vector2(-r*.58,-r*.28),c+Vector2(0,-r*.67)])
  draw_polyline(box,tint,1.5,true)
  draw_line(c+Vector2(-r*.58,-r*.28),c,tint,1.5,true);draw_line(c+Vector2(r*.58,-r*.28),c,tint,1.5,true);draw_line(c,c+Vector2(0,r*.7),tint,1.5,true)
  draw_circle(c+Vector2(0,-r*.28),2,tint)
