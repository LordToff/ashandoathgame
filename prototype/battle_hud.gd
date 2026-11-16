extends RefCounted
## Drawn ash-and-brass frames and compact, separate information lanes.
const UiSkin = preload("res://prototype/game_skin.gd")
const PAPER = Color("eadfc7")
const ASH = Color("171f21")
static func frame(app, rect: Rect2, tint: Color, fill: Color = ASH) -> void:
 UiSkin.panel(app,rect,tint)
static func hero_card(app, hero: int, at: Vector2, dimensions: Vector2, compact: bool = false) -> Button:
 var h: Dictionary = app.display_unit(hero);var tint: Color = app.COLORS[hero]
 var b: Button = app.button(app.MobileUI.NAMES[hero],at,dimensions,func():app.mobile_info = app.MobileUI.NAMES[hero]+"\n"+app.game.status_description(hero);app.rebuild(),tint)
 b.name = "HeroStatus"+str(hero);b.clip_contents = true
 for state in ["normal","hover","pressed","disabled"]:
  var box := UiSkin.surface("metal",Color(.43,.46,.44) if app.game.active==hero else Color(.25,.29,.30));box.set_content_margin_all(6);b.add_theme_stylebox_override(state,box)
 for name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color","font_hover_pressed_color"]:b.add_theme_color_override(name,Color.TRANSPARENT)
 var left := 34.0 if compact else 48.0
 var icon := TextureRect.new();var atlas := AtlasTexture.new();atlas.atlas = app.PORTRAITS;atlas.region = app.portrait_region(hero)
 var mask := ShaderMaterial.new();mask.shader = preload("res://prototype/portrait_mask.gdshader");icon.material = mask
 icon.texture = atlas;icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;icon.name = "HeroPortrait";icon.position = Vector2(7,8);icon.size = Vector2(22,24) if compact else Vector2(30,30);icon.mouse_filter = Control.MOUSE_FILTER_IGNORE;mask.set_shader_parameter("mask_size",icon.size);b.add_child(icon)
 var state_text := "Slain" if h.dead else "Downed" if h.hp<=0 else "Stunned" if h.stun else "Rooted" if int(h.get("rooted",0))>0 else "Poison %d" % int(h.get("poison",0)) if int(h.get("poison",0))>0 else "Reaction" if not h.reaction.is_empty() else "Channel" if not h.channel.is_empty() else "Broken" if h.get("broken",false) else ""
 var title := Label.new();title.text = app.MobileUI.NAMES[hero]+(" · "+state_text if not compact and state_text!="" else "");title.position = Vector2(left,3);title.size = Vector2(dimensions.x-left-7,18);title.clip_text = true;title.add_theme_font_size_override("font_size",12 if compact else 14);title.add_theme_color_override("font_color",tint);title.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(title)
 var vitals := Label.new();vitals.text = "%d HP · %d B" % [h.hp,h.block] if compact else "%d/%d HP   ·   %d Block" % [h.hp,h.max_hp,h.block]
 if h.dead:vitals.text = "Slain"
 elif h.hp<=0:vitals.text = "Downed"
 vitals.position = Vector2(left,20);vitals.size = Vector2(dimensions.x-left-7,17);vitals.clip_text = true;vitals.add_theme_font_size_override("font_size",11 if compact else 12);vitals.add_theme_color_override("font_color",PAPER);vitals.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(vitals)
 var track := ColorRect.new();track.name = "HealthSegments";track.color = Color("25232b");track.position = Vector2(left,dimensions.y-6);track.size = Vector2(dimensions.x-left-8,4);track.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(track)
 var pieces: int = mini(12,maxi(1,h.max_hp))
 for point in range(pieces):
  var pip := ColorRect.new();pip.mouse_filter = Control.MOUSE_FILTER_IGNORE;pip.position = Vector2(point*track.size.x/pieces,0);pip.size = Vector2(maxf(1,track.size.x/pieces-2),4)
  pip.color = Color("c76b58") if float(point)/pieces<float(h.hp)/maxi(1,h.max_hp) else Color("3d4140");track.add_child(pip)

 return b
static func skin_button(app, button: Button, accent: Color) -> void:
 var primary: bool = button.text.begins_with("End ") or button.text in ["Next action","End turn","Try ability →"]
 UiSkin.button(button,accent,primary)
static func category_mark(button: Button, tint: Color, spent: bool = false, face: int = 0, selected: bool = false, locked: bool = false) -> void:
 button.icon = null
 for state in ["normal","hover","pressed","disabled","focus"]:button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
 for name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color","font_hover_pressed_color"]:button.add_theme_color_override(name,Color.TRANSPARENT)
 var card := preload("res://prototype/dice_card.gd").new();card.face = face;card.tint = tint;card.spent = spent;card.selected = selected;card.locked = locked;button.add_child(card)
static func latest(app) -> String:
 var fall: String = app.DeathFeedback.caption(app)
 return fall if fall!="" else app.playback.last_roll
static func intent(app, action: String, target: String, at: Vector2, dimensions: Vector2, callback: Callable, tint: Color) -> Button:
 var b: Button = app.button(action,at,dimensions,callback,tint)
 b.add_theme_stylebox_override("normal",UiSkin.surface("paper",Color(.79,.77,.7)))
 b.add_theme_stylebox_override("hover",UiSkin.surface("paper",Color(.95,.90,.78)))
 b.icon = null
 b.clip_contents = true
 b.add_theme_font_size_override("font_size",12);b.custom_minimum_size = Vector2.ZERO;b.size = dimensions
 for name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color","font_hover_pressed_color"]:b.add_theme_color_override(name,Color.TRANSPARENT)
 for row in range(2):
  var label := Label.new();label.text = action if row==0 else "→ "+target.replace("No legal target → fallback","No target").replace("No legal target","No target")
  label.position = Vector2(10,4 if row==0 else dimensions.y-18);label.size = Vector2(dimensions.x-20,17)
  label.clip_text = true;label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS;label.add_theme_font_size_override("font_size",13 if row==0 else 11)
  label.name = "IntentAction" if row==0 else "IntentTarget";label.add_theme_color_override("font_color",Color("e2dacf") if row==0 else Color("aaa1aa"));label.mouse_filter = Control.MOUSE_FILTER_IGNORE;b.add_child(label)
 b.tooltip_text = action+" → "+target;return b

static func active_hero(app, rect: Rect2) -> void:
 var hero: int = app.game.active;var h: Dictionary = app.display_unit(hero)
 var panel := Panel.new();panel.name = "ActiveHeroPanel";panel.position = rect.position;panel.size = rect.size;panel.mouse_filter = Control.MOUSE_FILTER_IGNORE;panel.add_theme_stylebox_override("panel",UiSkin.surface("hero"));app.ui.add_child(panel)
 var portrait := TextureRect.new();var atlas := AtlasTexture.new();atlas.atlas = app.PORTRAITS;atlas.region = app.portrait_region(hero);portrait.texture = atlas;portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;portrait.position = Vector2(12,10);portrait.size = Vector2(78,78);portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE;panel.add_child(portrait)
 var name := Label.new();name.text = app.game.unit_name(hero);name.position = Vector2(107,8);name.size = Vector2(rect.size.x-124,31);name.add_theme_font_override("font",app.TITLE);name.add_theme_font_size_override("font_size",29);name.add_theme_color_override("font_color",Color("e5ddd0"));name.mouse_filter = Control.MOUSE_FILTER_IGNORE;panel.add_child(name)
 var stats := Label.new();stats.text = "%d / %d HP     %d Block" % [h.hp,h.max_hp,h.block];stats.position = Vector2(108,44);stats.add_theme_font_size_override("font_size",17);stats.add_theme_color_override("font_color",Color("c3b8b1"));stats.mouse_filter = Control.MOUSE_FILTER_IGNORE;panel.add_child(stats)
 var track := ColorRect.new();track.color = Color("2c1720");track.position = Vector2(108,77);track.size = Vector2(rect.size.x-126,5);track.mouse_filter = Control.MOUSE_FILTER_IGNORE;panel.add_child(track)
 var life := ColorRect.new();life.color = Color("9c293c");life.size = Vector2(track.size.x*clampf(float(h.hp)/maxi(1,h.max_hp),0,1),5);life.mouse_filter = Control.MOUSE_FILTER_IGNORE;track.add_child(life)
