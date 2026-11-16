extends Control
## Sparse etched edges over the control's fill; input stays with its parent.
var accent := Color("79716b")
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var b: Button = get_parent()
 for event in [b.mouse_entered,b.mouse_exited,b.focus_entered,b.focus_exited,b.button_down,b.button_up]:event.connect(queue_redraw)
 resized.connect(queue_redraw)
func _draw() -> void:
 var b: Button = get_parent();var light: Color = Color("e6dfd2") if b.has_focus() or b.is_hovered() else accent
 if b.disabled:light = Color("333238")
 var cut := minf(6,size.y*.17)
 for corner in [Vector2(2,2),Vector2(size.x-2,2),Vector2(2,size.y-2),Vector2(size.x-2,size.y-2)]:
  var dx: float = 1 if corner.x<size.x/2 else -1
  var dy: float = 1 if corner.y<size.y/2 else -1
  draw_line(corner,corner+Vector2(dx*cut,0),light,1)
  draw_line(corner,corner+Vector2(0,dy*cut),light,1)
 draw_line(Vector2(9,size.y-3),Vector2(size.x-9,size.y-3),Color(light,.25),1)
