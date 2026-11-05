extends RefCounted
const C = preload("res://prototype/camp_ui.gd")
const NAMES = ["Vesper","Rook","Wren"]

static func main_menu(app) -> void:
 app.chamber_background()
 var shade := ColorRect.new();shade.color = Color(0.025,0.045,0.065,0.82);shade.size = Vector2(1440,900);shade.mouse_filter = Control.MOUSE_FILTER_IGNORE;app.ui.add_child(shade)
 app.label_at("THREE HEROES. ONE OATH.",Vector2(80,115),14,app.GOLD,780)
 app.label_at("ASH & OATH",Vector2(72,164),80,Color("f0e6cf"),1000,true)
 C.detail(app,"Shape your dice. Face the creatures of the Ash Road.\nBring what you earn back to the fire.",Rect2(80,285,680,90),22)
 app.button("Build your party  →",Vector2(80,420),Vector2(480,62),func():app.open_forge(app.gifts.any(func(list):return list.size() != 2)),app.GOLD).name = "MainPlay"
 app.button("Camp & Essence Forge",Vector2(80,501),Vector2(480,54),func():app.camp_tab = 0;app.open_camp(),Color("9acfc0")).name = "MainCamp"
 app.button("Fight creatures",Vector2(80,572),Vector2(480,54),func():app.camp_tab = 3;app.open_camp(),Color("9acfc0")).name = "MainCreatures"
 app.button("Guided practice",Vector2(80,667),Vector2(232,48),app.start_training,app.MUTED)
 app.button("Options",Vector2(328,667),Vector2(232,48),app.open_settings,app.MUTED)
 app.button("Rules",Vector2(80,733),Vector2(232,46),func():app.show_help = true;app.rebuild(),app.MUTED)
 app.button("What changed",Vector2(328,733),Vector2(232,46),func():app.show_changes = true;app.rebuild(),app.MUTED)
 app.setup_panel(Rect2(850,132,510,620),Color("665c48"))
 app.label_at("THE FIRE STILL BURNS",Vector2(884,169),14,app.GOLD,438)
 for hero in range(3):
  app.portrait_at(hero,Vector2(892+hero*140,235),Vector2(118,118))
  app.label_at(NAMES[hero],Vector2(892+hero*140,375),20,app.COLORS[hero],132,true)
 C.detail(app,"A tactical dice-building adventure",Rect2(884,457,438,44),23)
 C.detail(app,"Three heroes, four bosses, and creature groups you can choose directly. Earn Essence, discover reward designs, then refit your party at Camp.",Rect2(884,525,438,113),18)
 app.label_at("Banked rewards save on this browser.",Vector2(884,681),15,app.MUTED,438)
 app.button("Mobile mode · play on a phone",Vector2(80,793),Vector2(480,40),func():app.set_mobile_mode(true),Color("9acfc0")).name = "MainMobileMode"
 app.label_at("PLAYABLE PROTOTYPE  /  v0.32",Vector2(80,838),12,app.MUTED,650)

static func forge(app) -> void:
 app.chamber_background()
 app.label_at("THE DICE FORGE",Vector2(48,30),36,app.GOLD,1100,true)
 app.label_at("Select a square. Read its ability. Choose its replacement.",Vector2(50,87),18,app.MUTED,1100)
 app.button("Main menu",Vector2(1210,40),Vector2(182,44),app.go_main,app.MUTED)
 for hero in range(3):
  app.button(NAMES[hero],Vector2(48+hero*310,136),Vector2(292,48),func():app.build_hero = hero;app.rebuild(),app.COLORS[hero] if app.build_hero == hero else app.MUTED)
 app.button("Choose bonus faces",Vector2(996,136),Vector2(396,48),func():app.draft_modal = true;app.rebuild(),app.GOLD)
 app.setup_panel(Rect2(48,210,920,534));app.setup_panel(Rect2(988,210,404,534))
 for die in range(3):
  var base := Vector2(72+die*294,288)
  app.label_at("DIE "+["I","II","III"][die],Vector2(base.x,239),16,app.GOLD,258)
  for side in range(6):
   var face: int = app.builds[app.build_hero][die][side]
   var selected: bool = app.forge_die == die and app.forge_side == side
   var slot = app.button(app.Catalog.name_for(face),base+Vector2(app.NET[side])*82,Vector2(78,78),func():app.forge_die = die;app.forge_side = side;app.rebuild(),app.GOLD if selected else app.color_for_face(face))
   slot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;slot.add_theme_font_size_override("font_size",13);slot.tooltip_text = app.Catalog.text(face);slot.name = "ForgeDie%dSide%d" % [die,side]
   for state in ["normal","hover","pressed"]:
    slot.get_theme_stylebox(state).content_margin_left = 4;slot.get_theme_stylebox(state).content_margin_right = 4
   slot.set_drag_forwarding(func(_at):return app.face_drag_data(slot,face,die,side),func(_at,data):return app.face_drop_allowed(die,side,data),func(_at,data):app.place_dragged_face(die,side,data))
 C.detail(app,"Each die keeps at least %d Blanks. Choose your two bonus designs above; return crafted rewards through Camp’s Refit dice tab." % app.balance_number("body.blanks"),Rect2(74,656,866,65),16)
 var face: int = app.builds[app.build_hero][app.forge_die][app.forge_side]
 app.label_at("SELECTED SQUARE",Vector2(1014,236),13,app.GOLD,350)
 app.label_at("Die %s · Side %d" % [["I","II","III"][app.forge_die],app.forge_side+1],Vector2(1014,274),27,Color("eee7d8"),350,true)
 var picker := OptionButton.new();picker.name = "ForgeFacePicker";picker.position = Vector2(1014,335);picker.size = Vector2(350,48)
 var ids: Array = range(9)
 for id in range(60,69):
  if app.expedition.camp.owned(id) > 0:ids.append(id)
 ids.append_array(app.gifts[app.build_hero])
 for id in ids:picker.add_item(app.Catalog.display_name(id),id)
 picker.select(picker.get_item_index(face));picker.get_popup().min_size = Vector2i(460,0)
 picker.item_selected.connect(func(index):app.forge_replace(picker.get_item_id(index)));app.ui.add_child(picker)
 C.detail(app,app.face_help(face),Rect2(1014,410,350,152)).name = "ForgeAbilityDetails"
 C.detail(app,"BODY LIMITS\n%d Movement · %d Defense · %d Skill\nOwned copies and two bonus designs remain required." % [app.balance_number("body.Movement"),app.balance_number("body.Defense"),app.balance_number("body.Skill")],Rect2(1014,586,350,114),16)
 var error: String = app.party_build_error()
 app.setup_panel(Rect2(48,762,1344,54))
 C.detail(app,error if error != "" else app.hint,Rect2(66,775,1308,32),15)
 app.button("Restore this hero",Vector2(48,831),Vector2(220,44),app.restore_hero_build,app.MUTED)
 app.button("Save preset",Vector2(284,831),Vector2(180,44),app.save_preset,app.MUTED)
 app.button("Load preset",Vector2(480,831),Vector2(180,44),app.load_preset,app.MUTED)
 app.button("Camp",Vector2(676,831),Vector2(180,44),app.open_camp,Color("9acfc0"))
 app.button("Choose boss & rules →",Vector2(996,831),Vector2(396,44),app.open_setup,app.GOLD,error != "").name = "ForgeContinue"
