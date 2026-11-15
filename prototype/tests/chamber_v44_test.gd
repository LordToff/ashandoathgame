extends SceneTree
const E = preload("res://prototype/essence.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("CHAMBER44 FAIL: ",why)
func find(app, name: String):return app.ui.find_child(name,true,false)
func tap(app, name: String) -> void:
 var pick = find(app,name);check(pick!=null and not pick.disabled,"Reachable "+name)
 if pick and not pick.disabled:pick.pressed.emit()
func _initialize():call_deferred("run")
func run() -> void:
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.expedition.camp = E.new();app.expedition.camp.bank.bone_creature = 9
 var bank: Dictionary = app.expedition.camp.encode().duplicate(true);var builds: Array = app.builds.duplicate(true);var gifts: Array = app.gifts.duplicate(true)
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);app.go_main();await process_frame;await process_frame
  var button: Button = find(app,"MobileLab" if app.mobile_mode else "MainLab")
  check(button!=null and button.get_global_rect().position.y>=0 and button.get_global_rect().end.y<=app.get_viewport_rect().size.y,"Test chamber is on the visible main-menu footer")
  check(find(app,"MenuBackdrop")!=null and find(app,"MenuEmblem")!=null,"Menu artwork and emblems render")
  tap(app,"MobileLab" if app.mobile_mode else "MainLab");await process_frame;await process_frame
  check(app.lab and app.show_lab_tools and find(app,"LabAbilities")!=null and find(app,"LabTry")!=null,"Main button opens the ability picker directly")
  var picker: OptionButton = find(app,"LabAbilities")
  check(picker.allow_reselect,"A filtered single result can be selected even when shown first")
  check(picker.item_count==app.Essence.FACE_COUNT,"All normal and earned ability faces are available without unlocks")
  var search: LineEdit = find(app,"LabSearch");var rng: int = app.game.rng.state;var face: int = app.lab_face
  search.text = "Bone Growth";search.text_changed.emit(search.text)
  check(picker.get_item_index(60)>=0 and app.lab_face==face and app.game.rng.state==rng,"Search filters without resetting the test or consuming RNG")
  picker.item_selected.emit(picker.get_item_index(60));await process_frame;await process_frame
  check(app.lab_face==60 and app.game.face(0,0)==60,"Choosing an earned face prepares that actual test result")
  picker = find(app,"LabAbilities");search = find(app,"LabSearch");search.text = "no-such-ability";search.text_changed.emit(search.text)
  check(picker.disabled and app.lab_face==60,"No-match search cannot select an invalid ability")
  search.text = "";search.text_changed.emit("");picker.item_selected.emit(picker.get_item_index(34));await process_frame;await process_frame
  var numeric: OptionButton = find(app,"LabNumeric");numeric.item_selected.emit(2);await process_frame;await process_frame
  check(app.lab_numeric==1 and app.game.heroes[0].stored_num==1,"Forced Numeric selection sets the practice roll")
  tap(app,"LabTry");await process_frame;await process_frame
  check(not app.show_lab_tools and app.page=="battle","Try ability returns to direct map controls")
  if app.mobile_mode:
   tap(app,"MobileMore");await process_frame;await process_frame;tap(app,"MobileLabTools")
  else:tap(app,"LabTools")
  await process_frame;await process_frame
  check(app.show_lab_tools and find(app,"LabAbilities")!=null,"Tools remain reachable during a test in this layout")
  tap(app,"LabReset");await process_frame;await process_frame
  check(app.game.heroes[0].used==[false,false,false] and app.game.face(0,0)==34,"Reset restores the selected scenario")
  tap(app,"LabCombine");await process_frame;await process_frame
  check(app.show_lab_setup and find(app,"LabSupport")!=null,"Combination picker is shared by both layouts")
  var support: OptionButton = find(app,"LabSupport");support.item_selected.emit(4);await process_frame;await process_frame
  tap(app,"LabSupportApply");await process_frame;await process_frame
  check(not app.show_lab_setup and app.game.face(0,1)==4,"Applying a combination prepares its real second ability")
  check(app.expedition.camp.encode()==bank and app.builds==builds and app.gifts==gifts,"Practicing never spends normal materials or changes prepared dice")
  app.lab_search = "";app.go_main()
  check(not app.show_lab_tools and not app.show_lab_setup,"Leaving practice clears its tool panels")
 for face in range(app.Essence.FACE_COUNT):
  var game = app.Lab.create(face,1)
  check(game.heroes[0].results[0]==face,"Lab can construct face "+str(face))
 app.queue_free();await process_frame
 print("CHAMBER v44: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
