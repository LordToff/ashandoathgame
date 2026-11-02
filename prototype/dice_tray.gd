extends Control
## Presentation only: every resting face comes from the recorded model result.
signal finished
var busy := false
var batches: Array = []
var elapsed := 0.0
const DURATION := 1.12
const SETTLE := 0.82
const FONT = preload("res://prototype/assets/body.ttf")
const SURFACES = [[4,5,7,6],[1,0,2,3],[0,4,6,2],[5,1,3,7],[0,1,5,4],[6,7,3,2]]
var box: StyleBoxFlat
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP;z_index = 90
 box = StyleBoxFlat.new();box.bg_color = Color("14232e");box.border_color = Color("967d52")
 box.set_border_width_all(1);box.set_corner_radius_all(14);box.shadow_color = Color(0,0,0,0.4);box.shadow_size = 24
 hide()
func play(incoming: Array) -> void:
 batches.append_array(incoming.duplicate(true))
 if not busy and not batches.is_empty():busy = true;elapsed = 0;show();queue_redraw()
func _process(delta: float) -> void:
 if not busy:return
 elapsed += delta
 while elapsed >= DURATION and not batches.is_empty():
  batches.pop_front();elapsed -= DURATION
 if batches.is_empty():finish();return
 queue_redraw()
func cancel() -> void:
 batches.clear();busy = false;elapsed = 0;hide()
func finish() -> void:
 cancel();finished.emit()
func _draw() -> void:
 if not busy or batches.is_empty():return
 var roll: Dictionary = batches[0]
 var progress := clampf(elapsed/SETTLE,0,1)
 if roll.has("rows"):
  draw_round(roll.rows,progress)
 else:
  var rect := Rect2(1116,290,296,390)
  draw_style_box(box,rect)
  draw_string(FONT,Vector2(1138,327),str(roll.actor),HORIZONTAL_ALIGNMENT_LEFT,252,16,Color("e9cd98"))
  draw_string(FONT,Vector2(1138,358),"NUMERIC DIE",HORIZONTAL_ALIGNMENT_LEFT,252,12,Color("99b4c3"))
  cube(Vector2(1264,457),49,progress,0,str(roll.faces[0][int(roll.sides[0])]),true)
  if progress >= 1:
   draw_string(FONT,Vector2(1138,588),"RESULT  /  "+str(roll.results[0]),HORIZONTAL_ALIGNMENT_CENTER,252,24,Color("f6d99f"))
  draw_string(FONT,Vector2(1138,632),str(roll.kind),HORIZONTAL_ALIGNMENT_CENTER,252,12,Color("b7c5cd"))
func draw_round(rows: Array, progress: float) -> void:
 draw_rect(Rect2(0,0,1440,900),Color(0.02,0.03,0.05,0.58))
 var height := 100.0+rows.size()*143.0
 var top := (900-height)/2
 draw_style_box(box,Rect2(204,top,1032,height))
 draw_string(FONT,Vector2(236,top+40),"DICE IN MOTION" if progress < 1 else "THE DICE HAVE SPOKEN",HORIZONTAL_ALIGNMENT_LEFT,960,18,Color("e9cd98"))
 draw_string(FONT,Vector2(236,top+66),"Recorded results · available dice roll together",HORIZONTAL_ALIGNMENT_LEFT,960,13,Color("99b4c3"))
 for row in range(rows.size()):
  var roll: Dictionary = rows[row];var y := top+105+row*143
  draw_string(FONT,Vector2(236,y+32),str(roll.actor),HORIZONTAL_ALIGNMENT_LEFT,180,16,Color("dce3df"))
  for die in range(roll.sides.size()):
   var x := 510+die*269
   var side: int = int(roll.sides[die]);var label: String = str(roll.faces[die][side])
   cube(Vector2(x,y+26),27,progress,row*3+die,str(side+1),false)
   if progress >= 1:
    var text: String = str(roll.results[die]);var fs := 15 if text.length()<24 else 12
    draw_string(FONT,Vector2(x-116,y+95),text,HORIZONTAL_ALIGNMENT_CENTER,232,fs,Color("f1ddb6"))
   else:draw_string(FONT,Vector2(x-116,y+95),"DIE "+["I","II","III"][int(roll.dice[die])],HORIZONTAL_ALIGNMENT_CENTER,232,12,Color("99b4c3"))
func cube(rest: Vector2, scale_px: float, progress: float, seed_index: int, result: String, numeric: bool) -> void:
 # Cubic deceleration reaches zero angular velocity. The landing has zero vertical
 # velocity too; no transform or position is snapped on the final frame.
 var remaining := pow(1.0-progress,3)
 var offset := seed_index*0.13
 var rotation := Vector3(0.22+remaining*(TAU*0.9+offset),-0.28+remaining*(TAU*1.05+offset),remaining*1.4)
 var transform := Basis.from_euler(rotation)
 var lift := sin(progress*PI)*pow(1-progress,0.8)*scale_px*0.9
 var center := rest+Vector2(sin(progress*TAU)*(1-progress)*8,-lift)
 var shadow := PackedVector2Array()
 for step in range(40):shadow.append(rest+Vector2(cos(step*TAU/40)*scale_px*1.2,sin(step*TAU/40)*scale_px*0.22)+Vector2(0,scale_px*1.65))
 draw_colored_polygon(shadow,Color(0,0,0,0.25))
 var vertices: Array[Vector3] = []
 for z in [-1,1]:
  for y in [-1,1]:
   for x in [-1,1]:vertices.append(transform*Vector3(x,y,z))
 var order: Array = range(6)
 order.sort_custom(func(a,b):return vertices[SURFACES[a][0]].z+vertices[SURFACES[a][2]].z < vertices[SURFACES[b][0]].z+vertices[SURFACES[b][2]].z)
 for face in order:
  var surface: Array = SURFACES[face]
  var normal: Vector3 = (vertices[surface[1]]-vertices[surface[0]]).cross(vertices[surface[2]]-vertices[surface[0]])
  if normal.z <= 0:continue
  var polygon := PackedVector2Array();var midpoint := Vector2.ZERO
  for index in surface:
   var p: Vector3 = vertices[index];var projected := center+Vector2(p.x,p.y)*scale_px*(5.8/(5.8-p.z))
   polygon.append(projected);midpoint += projected/4
  var light := clampf(normal.normalized().dot(Vector3(-0.3,-0.5,1).normalized()),0.38,1)
  draw_colored_polygon(polygon,Color("eee0bd")*Color(light,light,light,1))
  var border := polygon.duplicate();border.append(polygon[0]);draw_polyline(border,Color("6a5d48"),1.5,true)
  if normal.normalized().z > 0.38:
   var text := result if face == 0 else str((face+seed_index)%6+1)
   if not numeric and face == 0:text = result
   var font_size := int(scale_px*0.6)
   draw_string(FONT,midpoint+Vector2(-scale_px*0.6,font_size*0.32),text,HORIZONTAL_ALIGNMENT_CENTER,scale_px*1.2,font_size,Color("293139"))
