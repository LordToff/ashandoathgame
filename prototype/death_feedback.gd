extends RefCounted
## A collapse belongs to presentation only. It never changes a unit or its rewards.
static func start(app, step: Dictionary) -> void:
 var lethal := false
 for fallen in step.fallen:
  var id: int = fallen.id;var sprite: Texture2D
  var objective: bool = app.Model.TrialRules.objective_unit(app.game,id)
  if id<3:sprite = app.HeroArt.texture(id)
  elif not objective:sprite = app.EnemyArt.texture(app.EnemyArt.key_for(app.game,id),app.t)
  var boss: bool = id==3 and app.game.encounter_id!="event"
  var zoom: int = (4 if sprite.get_height()>24 else 5) if boss else (2 if sprite!=null and sprite.get_height()>24 else 3)
  var dimensions: Vector2 = Vector2.ONE*64 if id<3 else Vector2.ONE*48 if objective else sprite.get_size()*zoom
  app.effects.append({"kind":"fall","target":id,"sprite":sprite,"at":app.effect_center(id),"size":dimensions,"dead":fallen.dead,"object":objective,"life":app.CombatPlayback.FALL,"length":app.CombatPlayback.FALL})
  lethal = lethal or bool(fallen.dead)
 app.status_sounds.push_front("death" if lethal else "downed");app.status_cooldown = 0
 if app.combat_effects:app.impact_time = .22;app.impact_strength = 5.0 if lethal else 3.0
static func caption(app) -> String:
 if app.playback.current.get("kind","")!="fall":return ""
 var targets: Array = app.playback.current.fallen
 if targets.size()>1:return "%d fall" % targets.size()
 var unit: Dictionary = targets[0]
 if app.Model.TrialRules.objective_unit(app.game,unit.id):return app.game.unit_name(unit.id)+" · fallen"
 return app.game.unit_name(unit.id)+(" · fallen" if unit.id>=3 else " · slain" if unit.dead else " · downed")
static func draw(app, fx: Dictionary) -> void:
 var p: Vector2 = fx.at;var progress: float = clampf(1.0-fx.life/fx.length,0,1)
 var tint := Color("d49c71") if fx.dead else Color("c6b6a0")
 var alpha: float = 1.0-smoothstep(.12,.92,progress)
 var size: Vector2 = fx.size
 # A bright hit, a downward slump, then a fade into drifting ash.
 var ghost := Rect2(p-size/2+Vector2(0,progress*14),Vector2(size.x,size.y*(1.0-progress*.3)))
 var modulate := Color(1.8,1.55,1.25,alpha) if progress<.14 else Color(.72,.68,.65,alpha)
 if fx.sprite!=null:app.draw_texture_rect(fx.sprite,ghost,false,modulate)
 app.draw_arc(p+Vector2(0,23),14+progress*35,0,TAU,32,Color(tint,(1-progress)*.85),2)
 for index in range(12):
  var angle: float = index*TAU/12
  var point: Vector2 = p+Vector2(cos(angle)*(10+progress*43),sin(angle)*10-progress*44)
  var pixel: float = 5 if index%3==0 else 3
  app.draw_rect(Rect2(point.round(),Vector2.ONE*pixel),Color(tint,sin(progress*PI)*.85))
 if fx.target<3 and not fx.dead:
  # Downed remains revivable; its crossed marker stays on the board afterward.
  app.draw_line(p+Vector2(-13,-12),p+Vector2(13,14),Color("efc296"),3)
  app.draw_line(p+Vector2(13,-12),p+Vector2(-13,14),Color("efc296"),3)
