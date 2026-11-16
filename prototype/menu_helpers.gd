extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
static func card(app, parent: Control, title: String, description: String = "", tint: Color = Color("e6c58c")) -> VBoxContainer:
 var panel := PanelContainer.new();panel.mouse_filter = Control.MOUSE_FILTER_PASS;panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 var box := preload("res://prototype/game_skin.gd").surface("leather",Color(.27,.28,.27));box.set_content_margin_all(16);panel.add_theme_stylebox_override("panel",box);parent.add_child(panel)

 var content := VBoxContainer.new();content.mouse_filter = Control.MOUSE_FILTER_PASS;content.size_flags_horizontal = Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",10);panel.add_child(content)
 var heading := HBoxContainer.new();heading.add_theme_constant_override("separation",10);content.add_child(heading)
 var emblem := preload("res://prototype/menu_emblem.gd").new();emblem.name = "MenuEmblem";emblem.custom_minimum_size = Vector2(38,38);emblem.tint = tint
 emblem.kind = "trial" if "Trial" in title else "camp" if "raft" in title or "Camp" in title else "soul" if "Soul" in title or "Memory" in title else "oath"
 heading.add_child(emblem)
 var label: Label = M.text(heading,title,23,tint);label.add_theme_font_override("font",app.TITLE)

 if description!="":M.text(content,description,18)
 return content
static func grid(app, parent: Control, wide_columns: int = 2) -> GridContainer:
 var result := GridContainer.new();result.columns = wide_columns if app.get_viewport_rect().size.x>=1000 else 1
 result.add_theme_constant_override("h_separation",14);result.add_theme_constant_override("v_separation",14);parent.add_child(result);return result
static func action(app, parent: Control, caption: String, callback: Callable, name: String, tint: Color = Color("e6c58c"), disabled: bool = false) -> Button:
 var result: Button = M.btn(app,parent,caption,callback,tint,disabled);result.name = name;result.custom_minimum_size.y = 56;result.add_theme_font_size_override("font_size",18)
 for connection in result.pressed.get_connections():
  if not int(connection.flags)&Object.CONNECT_DEFERRED:
   result.pressed.disconnect(connection.callable);result.pressed.connect(connection.callable,int(connection.flags)|Object.CONNECT_DEFERRED)
 return result
static func note(parent: Control, title: String, explanation: String, tint: Color = Color("e6c58c")) -> void:
 M.text(parent,title,21,tint);M.text(parent,explanation,18)
