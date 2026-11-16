extends Control
## A symbol-led skill tile; all actions remain on its existing Button.
const Symbols = preload("res://prototype/ability_symbols.gd")
var face := 0
var tint := Color("ddd4bf")
var spent := false
var selected := false
var locked := false
var hovered := false
var title: Label
func _ready() -> void:
 name = "DiceCardArtwork";mouse_filter = Control.MOUSE_FILTER_IGNORE;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var b: Button = get_parent()
 b.mouse_entered.connect(func():hovered = true;queue_redraw());b.mouse_exited.connect(func():hovered = false;queue_redraw());b.focus_entered.connect(queue_redraw);b.focus_exited.connect(queue_redraw)
 resized.connect(layout)
 title = Label.new();title.name = "AbilityName";title.text = b.text.replace("\nHeld","");title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;title.max_lines_visible = 2;title.clip_text = true;title.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(title);layout()
func layout() -> void:
 if not is_instance_valid(title):return
 var large: bool = size.y>=100
 title.position = Vector2(8,87) if large else Vector2(4,33)
 title.size = Vector2(size.x-16,size.y-93) if large else Vector2(size.x-8,size.y-35)
 var font_size: int = 17 if large else 14
 var font: Font = title.get_theme_font("font")
 var flags: int = TextServer.BREAK_MANDATORY|TextServer.BREAK_WORD_BOUND|TextServer.BREAK_ADAPTIVE
 while font_size>11 and font.get_multiline_string_size(title.text,HORIZONTAL_ALIGNMENT_CENTER,title.size.x,font_size,-1,flags).y>title.size.y:font_size -= 1
 title.add_theme_font_size_override("font_size",font_size)
 title.add_theme_color_override("font_color",Color("66626b") if spent else Color("8b8490") if locked else tint.lightened(.12));queue_redraw()
func _draw() -> void:
 var large: bool = size.y>=100
 draw_rect(Rect2(Vector2.ZERO,size),Color("0b0b0f") if not spent else Color("15141a"))
 var edge: Color = Color("b9aea0") if selected or get_parent().has_focus() else Color("6d565b") if hovered else Color("39363d")
 if spent:edge = Color("302d34")
 draw_rect(Rect2(Vector2.ONE,size-Vector2.ONE*2),edge,false,1)
 draw_rect(Rect2(Vector2.ONE*5,size-Vector2.ONE*10),Color("211d25"),false,1)
 var glyph_size: float = 70 if large else 29
 var at := Vector2((size.x-glyph_size)/2,10 if large else 3)
 var ink := Color("e5dfd4") if not spent and not locked else Color("65616b") if locked else Color("3e3b43")
 draw_texture_rect(Symbols.texture(face),Rect2(at,Vector2.ONE*glyph_size),false,ink)
 draw_rect(Rect2(7,size.y-5,size.x-14,3),Color("48434d") if spent else Color(tint,.7))
 if selected:draw_rect(Rect2(7,4,size.x-14,2),Color("a92f3d"))
 if "\nHeld" in get_parent().text:draw_circle(Vector2(size.x-10,10),3,Color("d4c8b7"))
