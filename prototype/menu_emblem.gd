extends Control
const Symbols = preload("res://prototype/ability_symbols.gd")
var tint := Color("ded7cc")
var kind := "oath"
func _ready() -> void:mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 draw_texture_rect(Symbols.menu_symbol(kind),Rect2(Vector2.ONE*3,size-Vector2.ONE*6),false,Color("d8d0c4"))
