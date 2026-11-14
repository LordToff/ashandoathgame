extends RefCounted
static func drain(app) -> void:
 for count in range(500):
  if app.dice_tray.busy:app.dice_tray._process(app.dice_tray.DURATION+.01)
  else:
   for step in app.playback.tick(10,false):app.present_step(step)
  if not app.playback.busy() and not app.dice_tray.busy:break
 app.rolling_time = 0;app.rebuild()
