extends RefCounted
## Quiet stone tiles and clear legal-cell markers. Rendering never changes combat.
const UiSkin = preload("res://prototype/game_skin.gd")
static func tile(app, cell: Vector2i, rect: Rect2) -> void:
 var shade: Color = Color("20252a") if (cell.x+cell.y)%2==0 else Color("1b2025")
 app.draw_rect(rect,shade)
 var stone: Texture2D = UiSkin.FLOORS[(cell.x*7+cell.y*11)%3]
 app.draw_texture_rect(stone,rect.grow(-2),false,Color(.74,.77,.82,.88))
 app.draw_rect(rect.grow(-1),Color("3c434b"),false,1)
 app.draw_line(rect.position+Vector2(3,2),rect.position+Vector2(rect.size.x-3,2),Color(.55,.58,.61,.08),1)
 if app.game.active in range(3) and cell==app.game.heroes[app.game.active].pos and app.game.heroes[app.game.active].hp>0:
  app.draw_rect(rect.grow(-3),Color(app.COLORS[app.game.active],.2))
  app.draw_rect(rect.grow(-4),Color(app.COLORS[app.game.active],.8),false,2)
static func boss_footprint(app) -> void:
 if app.game.encounter_id=="event" or app.display_unit(3).hp<=0:return
 var at: Vector2 = app.ORIGIN+Vector2(app.game.boss.pos)*app.CELL
 var rect := Rect2(at+Vector2.ONE*3,Vector2.ONE*(app.CELL*2-6))
 app.draw_rect(rect,Color("815361"),false,2)
 for corner in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:
  var direction: Vector2 = (rect.get_center()-corner).sign()
  app.draw_line(corner,corner+Vector2(direction.x*14,0),Color("ba8490"),2)
  app.draw_line(corner,corner+Vector2(0,direction.y*14),Color("ba8490"),2)
static func boss_bar(center: Vector2) -> Rect2:return Rect2(center+Vector2(-66,65),Vector2(132,5))
static func destination(app, rect: Rect2, tint: Color) -> void:
 app.draw_circle(rect.get_center(),5,Color(tint,.85))
 app.draw_circle(rect.get_center(),9,Color(tint,.28),false,1)

static func room(app) -> void:
 var edge: float = app.CELL*9
 var start: Vector2 = app.ORIGIN
 var texture: Texture2D = UiSkin.WALL
 for index in range(43):
  var offset: float = index*16
  app.draw_texture_rect(texture,Rect2(start+Vector2(offset-2,-16),Vector2(16,14)),false,Color(.75,.72,.76))
  app.draw_texture_rect(texture,Rect2(start+Vector2(offset-2,edge+2),Vector2(16,14)),false,Color(.65,.62,.68))
  app.draw_texture_rect(texture,Rect2(start+Vector2(-16,offset-2),Vector2(14,16)),false,Color(.65,.62,.68))
  app.draw_texture_rect(texture,Rect2(start+Vector2(edge+2,offset-2),Vector2(14,16)),false,Color(.65,.62,.68))
