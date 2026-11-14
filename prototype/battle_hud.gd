extends RefCounted
## Drawn ash-and-brass frames and compact, separate information lanes.
const PAPER = Color("eadfc7")
const ASH = Color("171f21")
static func frame(app, rect: Rect2, tint: Color, fill: Color = ASH) -> void:
 var p: Vector2 = rect.position;var s: Vector2 = rect.size;var cut := 7.0
 var corners := PackedVector2Array([p+Vector2(cut,0),p+Vector2(s.x-cut,0),p+Vector2(s.x,cut),p+Vector2(s.x,s.y-cut),p+Vector2(s.x-cut,s.y),p+Vector2(cut,s.y),p+Vector2(0,s.y-cut),p+Vector2(0,cut)])
 app.draw_colored_polygon(corners,fill)
 var border := corners.duplicate();border.append(corners[0]);app.draw_polyline(border,Color(tint,.52),1,true)
 app.draw_line(p+Vector2(12,4),p+Vector2(38,4),Color(tint,.7),1)
 app.draw_line(p+s-Vector2(12,4),p+s-Vector2(38,4),Color(tint,.7),1)
static func hero_card(app, hero: int, at: Vector2, dimensions: Vector2, compact: bool = false) -> Button:
 var h: Dictionary = app.display_unit(hero);var tint: Color = app.COLORS[hero]
 var b: Button = app.button(app.MobileUI.NAMES[hero],at,dimensions,func():app.mobile_info = app.MobileUI.NAMES[hero]+"\n"+app.game.status_description(hero);app.rebuild(),tint)
 b.name = "HeroStatus"+str(hero);b.clip_contents = true
 for state in ["normal","hover","pressed","disabled"]:
  var box: StyleBoxFlat = app.Polish.box(Color("222b2d") if app.game.active==hero else Color("151c1f"),Color(tint,.65 if app.game.active==hero else .25),1)
  box.border_width_left = 3 if app.game.active==hero else 1;box.shadow_size = 0;b.add_theme_stylebox_override(state,box)
 for name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color","font_hover_pressed_color"]:b.add_theme_color_override(name,Color.TRANSPARENT)
 var left := 8.0 if compact else 46.0
 if not compact:
  var icon := TextureRect.new();var atlas := AtlasTexture.new();atlas.atlas = app.PORTRAITS;atlas.region = app.portrait_region(hero)
  icon.texture = atlas;icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;icon.position = Vector2(8,8);icon.size = Vector2(28,28);icon.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(icon)
 var state_text := "Slain" if h.dead else "Downed" if h.hp<=0 else "Stunned" if h.stun else "Rooted" if int(h.get("rooted",0))>0 else "Poison %d" % int(h.get("poison",0)) if int(h.get("poison",0))>0 else "Reaction" if not h.reaction.is_empty() else "Channel" if not h.channel.is_empty() else "Broken" if h.get("broken",false) else ""
 var title := Label.new();title.text = app.MobileUI.NAMES[hero]+(" · "+state_text if not compact and state_text!="" else "");title.position = Vector2(left,3);title.size = Vector2(dimensions.x-left-7,18);title.clip_text = true;title.add_theme_font_size_override("font_size",12 if compact else 14);title.add_theme_color_override("font_color",tint);title.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(title)
 var vitals := Label.new();vitals.text = "%d HP · %d B" % [h.hp,h.block] if compact else "%d/%d HP   ·   %d Block" % [h.hp,h.max_hp,h.block]
 if h.dead:vitals.text = "Slain"
 elif h.hp<=0:vitals.text = "Downed"
 vitals.position = Vector2(left,20);vitals.size = Vector2(dimensions.x-left-7,17);vitals.clip_text = true;vitals.add_theme_font_size_override("font_size",11 if compact else 12);vitals.add_theme_color_override("font_color",PAPER);vitals.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(vitals)
 var track := ColorRect.new();track.color = Color("303937");track.position = Vector2(left,dimensions.y-6);track.size = Vector2(dimensions.x-left-8,3);track.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(track)
 var bar := ColorRect.new();bar.color = tint;bar.size = Vector2(track.size.x*clampf(float(h.hp)/maxi(1,h.max_hp),0,1),3);bar.mouse_filter = Control.MOUSE_FILTER_IGNORE;track.add_child(bar)
 return b
static func skin_button(app, button: Button, accent: Color) -> void:
 for entry in [["normal",Color("1c2527"),.36],["hover",Color("2c3536"),.9],["pressed",Color("38413e"),1.0],["disabled",Color("151b1e"),.2]]:
  var box: StyleBoxFlat = app.Polish.box(entry[1],Color(accent,entry[2]),1);box.shadow_size = 0;box.border_width_left = 3;button.add_theme_stylebox_override(entry[0],box)
static func category_mark(button: Button, tint: Color, spent: bool = false) -> void:
 var line := ColorRect.new();line.name = "FaceCategoryMark";line.position = Vector2(7,8);line.size = Vector2(4,maxf(8,button.size.y-16));line.color = Color("4c5150") if spent else tint;line.mouse_filter = Control.MOUSE_FILTER_IGNORE;button.add_child(line)
static func latest(app) -> String:
 var fall: String = app.DeathFeedback.caption(app)
 return fall if fall!="" else app.playback.last_roll
static func intent(app, action: String, target: String, at: Vector2, dimensions: Vector2, callback: Callable, tint: Color) -> Button:
 var b: Button = app.button(action,at,dimensions,callback,tint)
 b.clip_contents = true
 b.add_theme_font_size_override("font_size",12);b.custom_minimum_size = Vector2.ZERO;b.size = dimensions
 for name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color","font_hover_pressed_color"]:b.add_theme_color_override(name,Color.TRANSPARENT)
 for row in range(2):
  var label := Label.new();label.text = action if row==0 else "→ "+target.replace("No legal target → fallback","No target").replace("No legal target","No target")
  label.position = Vector2(10,4 if row==0 else dimensions.y-18);label.size = Vector2(dimensions.x-20,17)
  label.clip_text = true;label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS;label.add_theme_font_size_override("font_size",13 if row==0 else 11)
  label.add_theme_color_override("font_color",tint if row==0 else Color("b7c0ba"));label.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(label)
 b.tooltip_text = action+" → "+target;return b
