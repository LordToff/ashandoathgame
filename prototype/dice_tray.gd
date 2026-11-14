extends Control
## Compact recorded rolls: board stays visible; results rest before attack playback.
signal finished
signal cancelled
var mobile_mode := false
var busy := false
var batches: Array = []
var elapsed := 0.0
const SETTLE := 0.8
const RESULT_HOLD := 1.3
const DURATION := SETTLE+RESULT_HOLD
const FONT = preload("res://prototype/assets/body.ttf")
const SURFACES = [[4,5,7,6],[1,0,2,3],[0,4,6,2],[5,1,3,7],[0,1,5,4],[6,7,3,2]]
var box: StyleBoxFlat
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP;z_index = 90
 box = StyleBoxFlat.new();box.bg_color = Color("14232e");box.border_color = Color("967d52")
 box.set_border_width_all(2);box.set_corner_radius_all(10);box.shadow_color = Color(0,0,0,0.28);box.shadow_size = 8;hide()
func play(incoming: Array) -> void:
 batches.append_array(incoming.duplicate(true))
 if not busy and not batches.is_empty():busy = true;elapsed = 0;show();queue_redraw()
func _process(delta: float) -> void:
 if not busy:return
 elapsed += delta
 while elapsed>=DURATION and not batches.is_empty():batches.pop_front();elapsed -= DURATION
 if batches.is_empty():finish();return
 queue_redraw()
func cancel() -> void:
 batches.clear();busy = false;elapsed = 0;hide();cancelled.emit()
func finish() -> void:
 batches.clear();busy = false;elapsed = 0;hide();finished.emit()
func panel_rect(rows: int = 1, numeric: bool = false) -> Rect2:
 if not mobile_mode:return Rect2(760,204,640,204 if numeric else 66+rows*62)
 var size: Vector2 = get_viewport_rect().size
 var landscape: bool = size.x>size.y
 var x: float = minf(size.y-98,size.x*.45)+20 if landscape else 12
 var width: float = size.x-x-12
 var height: float = 180 if numeric else minf(size.y-142,62+rows*44)
 return Rect2(x,size.y-height-8,width,height)
func words(at: Vector2, text: String, width: float, size_px: int, color: Color, max_lines: int = 2) -> void:
 draw_multiline_string(FONT,at,text,HORIZONTAL_ALIGNMENT_LEFT,width,size_px,max_lines,color,TextServer.BREAK_MANDATORY|TextServer.BREAK_WORD_BOUND|TextServer.BREAK_ADAPTIVE)
func _draw() -> void:
 if not busy or batches.is_empty():return
 var roll: Dictionary = batches[0];var progress: float = clampf(elapsed/SETTLE,0,1)
 if roll.has("rows"):draw_round(roll.rows,progress);return
 var rect := panel_rect(1,true);draw_style_box(box,rect);var at := rect.position
 words(at+Vector2(14,26),str(roll.actor),rect.size.x-28,16,Color("e9cd98"))
 var result: String = str(roll.results[0])
 cube(at+Vector2(58,105),29,progress,0,str(roll.faces[0][int(roll.sides[0])]),true)
 words(at+Vector2(114,91),"RESULT  "+result if progress>=1 else "Rolling…",rect.size.x-128,26,Color("f6d99f"))
 words(at+Vector2(114,123),"Miss · no Poison" if progress>=1 and result=="0" and "Bite" in str(roll.kind) else str(roll.kind).trim_prefix("Numeric · "),rect.size.x-128,13,Color("b7c5cd"))
 words(at+Vector2(14,rect.size.y-14),("Miss · no attack" if result=="0" and "Bite" in str(roll.kind) else "Result shown before resolution") if progress>=1 else "Rolling…",rect.size.x-28,12,Color("99b4c3"),1)
func draw_round(rows: Array, progress: float) -> void:
 var rect := panel_rect(rows.size());draw_style_box(box,rect);var row_height: float = (rect.size.y-62)/maxi(1,rows.size())
 words(rect.position+Vector2(14,25),"DICE RESULTS" if progress>=1 else "ROLLING DICE",rect.size.x-28,17,Color("e9cd98"),1)
 var actor_width: float = minf(128,rect.size.x*.27)
 var col: float = (rect.size.x-actor_width-22)/3
 for r in range(rows.size()):
  var row: Dictionary = rows[r];var y: float = rect.position.y+44+r*row_height
  words(Vector2(rect.position.x+12,y+16),str(row.actor),actor_width-8,12 if mobile_mode else 14,Color("b7c5cd"))
  for die in range(row.sides.size()):
   var x: float = rect.position.x+actor_width+die*col
   draw_rect(Rect2(x,y, col-5,row_height-3),Color("1d303e"))
   if progress<1:cube(Vector2(x+(col-5)/2,y+row_height*.45),minf(15,row_height*.23),progress,r*3+die,str(int(row.sides[die])+1),false)
   else:words(Vector2(x+5,y+15),str(row.results[die]),col-14,12 if mobile_mode else 15,Color("f1ddb6"))
 words(rect.position+Vector2(14,rect.size.y-11),"Results are also kept on your ability buttons and in the battle log.",rect.size.x-28,11,Color("99b4c3"),1)
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
