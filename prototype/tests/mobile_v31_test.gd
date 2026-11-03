extends SceneTree
const B = preload("res://prototype/battle.gd")
const UI = preload("res://prototype/mobile_ui.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("MOBILE FAIL: ",why)
func find(node: Node, name: String) -> Node:
 if str(node.name) == name:return node
 for child in node.get_children():
  var result = find(child,name)
  if result != null:return result
 return null
func _initialize():call_deferred("run")
func run():
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app)
 await process_frame
 app.set_mobile_mode(false,false);app.rebuild()
 check(app.ui.has_node("MainMobileMode"),"desktop main menu exposes phone mode")
 var model = app.game;var ledger = app.expedition.camp;var old_builds: Array = app.builds.duplicate(true)
 root.size = Vector2i(390,844);app.set_mobile_mode(true,false)
 await process_frame;await process_frame;app.rebuild();await process_frame
 check(app.mobile_mode and app.dice_tray.mobile_mode,"touch and dice layouts enabled together")
 check(app.game == model and app.expedition.camp == ledger and app.builds == old_builds,"layout switch retains model, rewards and dice")
 check(root.content_scale_size.x == 480 and root.content_scale_size.y > 1000,"portrait fits phone aspect")
 check(find(app.ui,"MobilePlay") != null,"phone start control")
 for hero in range(3):app.gifts[hero] = [34,47];app.builds[hero] = B.bonus_build([34,47])
 app.start_creature_encounter(0);app.dice_tray.cancel();app.rolling_time = 0;app.combat_notices.clear()
 app.game.active = 0;app.game.cursor = app.game.order.find(0);app.game.pending = {};app.game.forced_die = -1
 for hero in range(3):
  app.game.heroes[hero].pos = Vector2i(hero*3,7);app.game.heroes[hero].results = [2,4,0];app.game.heroes[hero].used = [false,false,false];app.game.heroes[hero].reaction = []
 app.rebuild();app.dice_tray.cancel();app.rolling_time = 0;app.combat_notices.clear();app.rebuild()
 await process_frame;await process_frame
 find(app.ui,"MobileDie0").pressed.emit();await process_frame
 check(app.selected == 0,"tap selects die")
 var board: Rect2 = UI.board_rect(app)
 var destination := Vector2i(0,6)
 var desktop_point: Vector2 = app.ORIGIN+Vector2(destination)*app.CELL+Vector2.ONE*app.CELL/2
 var touch_point: Vector2 = board.position+(desktop_point-UI.SOURCE_RECT.position)*board.size.x/UI.SOURCE_RECT.size.x
 check(UI.board_point(app,touch_point).distance_to(desktop_point)<0.01,"board coordinate transform round trips")
 var input := InputEventMouseButton.new();input.pressed = true;input.button_index = MOUSE_BUTTON_LEFT;input.position = touch_point
 app._gui_input(input)
 check(app.game.heroes[0].pos == destination and app.game.heroes[0].used[0],"phone board tap moves and spends one die")
 find(app.ui,"MobileDie1").pressed.emit();await process_frame
 find(app.ui,"MobileResolve").pressed.emit();await process_frame
 check(app.game.heroes[0].block > 0 and app.game.heroes[0].used[1],"phone Resolve applies actual Guard")
 app.dice_tray.cancel();app.rolling_time = 0;app.combat_notices.clear();app.rebuild()
 find(app.ui,"MobileDetails").pressed.emit();await process_frame
 check(find(app.ui,"MobileModal") != null and app.mobile_info != "","ability help opens without hover")
 await process_frame;await process_frame
 var modal = find(app.ui,"MobileModal")
 var labels: Array = modal.find_children("*","Label",true,false)
 check(not labels.is_empty() and labels[0].get_minimum_size().y > 20,"reflowed explanation retains visible text height")
 app.mobile_info = "";app.show_history = true;app.rebuild();await process_frame
 check(find(app.ui,"BattleHistory") != null,"full log available on phone")
 app.show_history = false;app.game.pending = {"kind":"fracture","hero":0};app.rebuild();await process_frame;await process_frame
 var choices: Array = find(app.ui,"MobileModal").find_children("*","Button",true,false)
 check(choices.size() == 18,"all installed-slot choices survive phone reflow")
 var slot = choices.filter(func(choice):return not choice.disabled)[0];slot.pressed.emit();await process_frame
 check(app.game.pending.is_empty() and app.game.heroes[0].build[0][0] == 0,"mandatory choice calls original mutation once")
 app.open_camp();app.camp_tab = 2;app.rebuild();await process_frame
 check(find(app.ui,"MobileSoulPicker") != null,"equipment available by touch")
 root.size = Vector2i(844,390);app.refresh_mobile_layout();await process_frame;await process_frame
 app.page = "battle";app.rebuild();await process_frame
 board = UI.board_rect(app)
 var controls = find(app.ui,"MobileBattleActions")
 check(board.end.x < controls.position.x and board.end.y <= root.content_scale_size.y,"landscape places controls beside board")
 app.set_mobile_mode(false,false);app.rebuild();await process_frame
 check(root.content_scale_size == Vector2i(1440,900) and app.game.heroes[0].pos == destination,"return to desktop preserves combat")
 print("MOBILE v0.31: %d checks, %d failures" % [checks,failures]);app.queue_free();await process_frame;quit(1 if failures else 0)
