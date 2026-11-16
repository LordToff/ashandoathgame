extends SceneTree
const B = preload("res://prototype/battle.gd")
const Art = preload("res://prototype/enemy_art.gd")
const Symbols = preload("res://prototype/ability_symbols.gd")
const Catalog = preload("res://prototype/catalog.gd")
const UiSkin = preload("res://prototype/game_skin.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String) -> void:
 checks += 1
 if not ok:failures += 1;printerr("SKIN45 FAIL: ",why)
func find(app, name: String):return app.ui.find_child(name,true,false)
func fresh():
 var g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],45,false,true,{})
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.forced_die = -1
 for h in g.heroes:h.results = [1,4,0];h.rolls = [0,0,0];h.used = [false,false,false];h.reaction = []
 return g
func attach(app, g) -> void:
 app.game = g;app.page = "battle";app.lab = false;app.training = false;app.trial_fight = false;app.show_lab_tools = false;app.show_lab_setup = false;app.selected = -1
 app.dice_tray.cancel();app.roll_seen = g.roll_presentations.size();app.seen_event = g.event_id;app.playback.model_id = g.get_instance_id();app.playback.clear(app.CombatPlayback.capture(g));app.combat_notices.clear();app.rebuild()
func _initialize():call_deferred("run")
func run() -> void:
 var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://prototype/assets/vendor/crawl_roctavian/SELECTION.json"))
 check(FileAccess.get_sha256(Art.HOLLOW.resource_path)==source.sha256,"Hollow uses the unchanged pinned artist tile")
 check(Art.texture("hollow")==Art.HOLLOW and Art.HOLLOW.get_size()==Vector2(32,32),"Red demon selection is replaced by the authored 32px Hollow")
 var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://prototype/assets/vendor/game_icons/SELECTIONS.json"))
 for symbol in manifest.symbols:
  check(FileAccess.get_sha256("res://prototype/assets/ability_symbols/"+symbol+".svg")==manifest.symbols[symbol].sha256,"Original licensed symbol: "+symbol)
 var paths: Array = []
 for face in range(85):
  var tex: Texture2D = Symbols.texture(face)
  check(not paths.has(Symbols.SYMBOLS[face].resource_path),"Distinct symbol for "+Catalog.name_for(face));paths.append(Symbols.SYMBOLS[face].resource_path)
  check(tex.get_size()==Vector2(64,64) and Symbols.small_texture(face).get_size()==Vector2(20,20),"Bounded raster sizes for "+str(face))
  check(Symbols.face_for_text(Catalog.name_for(face))==face,"Name maps to symbol "+Catalog.name_for(face))
 var app = load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 var g = fresh();attach(app,g);app.set_mobile_mode(false,false);app.rebuild();await process_frame;await process_frame
 var rng: int = g.rng.state;var event: int = g.event_id;var cells: Array = g.cells(3).duplicate();var hp: int = g.boss.hp
 var cards: Array = []
 for die in range(3):
  var b: Button = find(app,"BattleDie"+str(die));cards.append(b.get_global_rect())
  var artwork = b.find_child("DiceCardArtwork",true,false)
  check(b.size==Vector2(208,138) and artwork!=null,"Desktop ability is a compact gothic skill tile")
  check(artwork.mouse_filter==Control.MOUSE_FILTER_IGNORE and artwork.title.size.y>0,"Card artwork cannot intercept targeting")
  check(find(app,"BattleDetails"+str(die)).get_global_rect().position.y>=b.get_global_rect().end.y,"Info stays below its own card")
 check(cards[0].position.y==cards[1].position.y and cards[1].position.y==cards[2].position.y and not cards[0].intersects(cards[1]) and not cards[1].intersects(cards[2]),"Three-card hand replaces the stacked ability rows without overlap")
 app.selected = 0;app.rebuild();check(find(app,"BattleDie0").find_child("DiceCardArtwork",true,false).selected,"Selected card is visibly marked")
 g.heroes[0].used[0] = true;app.rebuild();check(find(app,"BattleDie0").find_child("DiceCardArtwork",true,false).spent,"Spent card has the dark spent material")
 g.heroes[0].used[0] = false;g.forced_die = 1;app.rebuild();check(find(app,"BattleDie0").find_child("DiceCardArtwork",true,false).locked,"Forced resolution mutes the other desktop cards")
 g.forced_die = -1;app.selected = -1
 for size in [Vector2i(360,640),Vector2i(390,844),Vector2i(844,390),Vector2i(1440,900)]:
  root.size = size;app.set_mobile_mode(size.x<1440,false);app.rebuild();await process_frame;await process_frame
  for die in range(3):
   var b: Button = find(app,("MobileDie" if app.mobile_mode else "BattleDie")+str(die));var r: Rect2 = b.get_global_rect();var artwork = b.find_child("DiceCardArtwork",true,false)
   check(r.position.x>=0 and r.position.y>=0 and r.end.x<=app.get_viewport_rect().size.x and r.end.y<=app.get_viewport_rect().size.y,"Card stays within viewport "+str(size))
   check(artwork.title.get_global_rect().end.y<=r.end.y and artwork.title.get_global_rect().end.x<=r.end.x,"Wrapped card name stays within its face "+str(size))
  for hero in range(3):
   var status: Button = find(app,"HeroStatus"+str(hero))
   check(status!=null and status.has_meta("gothic_skin") and status.find_child("HeroPortrait",true,false)!=null,"Hero status uses the gothic portrait HUD")
  check(find(app,"EnemyIntent0").get_theme_stylebox("normal").bg_color.get_luminance()<0.08,"Enemy intent uses a dark high-contrast intent panel")
  if app.mobile_mode:check(find(app,"MobileEndTurn")!=null,"Turn completion remains visible on phone and landscape")
  g.forced_die = 1;app.rebuild()
  check(find(app,("MobileDie" if app.mobile_mode else "BattleDie")+"0").find_child("DiceCardArtwork",true,false).locked,"Forced reroll dims other faces in this layout")
  g.forced_die = -1;app.rebuild()
 for face in range(85):
  g.heroes[0].results[0] = face;app.rebuild();await process_frame
  var b: Button = find(app,("MobileDie" if app.mobile_mode else "BattleDie")+"0")
  check(b.find_child("DiceCardArtwork",true,false).title.text==b.text.replace("\nHeld",""),"Card names preserve actual face identity "+str(face))
 root.size = Vector2i(360,640);app.set_mobile_mode(true,false);app.rebuild();await process_frame
 for face in range(85):
  g.heroes[0].results[0] = face;app.rebuild();await process_frame
  var title: Label = find(app,"MobileDie0").find_child("AbilityName",true,false)
  var flags: int = TextServer.BREAK_MANDATORY|TextServer.BREAK_WORD_BOUND|TextServer.BREAK_ADAPTIVE
  var measured: Vector2 = title.get_theme_font("font").get_multiline_string_size(title.text,HORIZONTAL_ALIGNMENT_CENTER,title.size.x,title.get_theme_font_size("font_size"),-1,flags)
  check(measured.y<=title.size.y+1,"Full ability name fits the narrow phone rack: "+title.text)
 root.size = Vector2i(1440,900);app.set_mobile_mode(false,false);app.rebuild();await process_frame
 check(g.rng.state==rng and g.event_id==event and g.cells(3)==cells and g.boss.hp==hp,"Rendering all cards / layouts never changes RNG, events, footprint or HP")
 app.go_main();check(find(app,"MainLab")!=null and find(app,"MainLab").has_meta("gothic_skin"),"Visible test chamber is preserved in the new menu skin")
 app.queue_free();await process_frame
 print("SKIN v45: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
