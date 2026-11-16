extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const H = preload("res://prototype/menu_helpers.gd")
static func render(app) -> void:
 var column := P.panel(app,"Test chamber","Choose an ability, then try it on the map. Practice earns no rewards.")
 var search := LineEdit.new();search.name = "LabSearch";search.placeholder_text = "Find an ability…";search.text = app.lab_search;search.custom_minimum_size = Vector2(0,48);search.add_theme_font_size_override("font_size",18);column.add_child(search)
 var picker: OptionButton = M.choose(app,column,"Ability to test",["Choose an ability"],0,func(_index):pass,"LabAbilities")
 picker.allow_reselect = true
 for connection in picker.item_selected.get_connections():picker.item_selected.disconnect(connection.callable)
 fill_abilities(app,picker,app.lab_search)
 picker.item_selected.connect(func(index):app.training = false;app.lab_face = picker.get_item_id(index);app.reset_lab(),Object.CONNECT_DEFERRED)
 search.text_changed.connect(func(value):app.lab_search = value;fill_abilities(app,picker,value))

 var card := H.card(app,column,app.Catalog.name_for(app.lab_face),app.AbilityCopy.new().face(app.lab_face),app.color_for_face(app.lab_face))
 M.text(card,app.Lab.guide(app.lab_face),17)
 M.choose(app,column,"Numeric die",["Random result","Force 0","Force 1","Force 2"],app.lab_numeric+1,func(index):app.lab_numeric = index-1;app.reset_lab(),"LabNumeric")
 M.text(column,"Vesper: %d / %d HP · %d Block" % [app.game.heroes[0].hp,app.game.heroes[0].max_hp,app.game.heroes[0].block],18,app.GOLD)
 var tools := H.grid(app,column)
 H.action(app,tools,"Reset this test",app.reset_lab,"LabReset")
 H.action(app,tools,"Roll this ability again",func():app.show_lab_tools = false;app.Lab.roll_test_face(app.game,app.lab_face,app.lab_numeric);app.selected = -1;app.rebuild(),"LabRoll",Color("9acfc0"))
 var blocked: bool = not app.game.pending.is_empty() or app.game.outcome!=""
 H.action(app,tools,"Enemy attacks",func():app.show_lab_tools = false;app.Lab.attack(app.game,app.lab_face);app.selected = -1;app.rebuild(),"LabEnemy",Color("ed9986"),blocked)
 H.action(app,tools,"Advance a turn",func():app.show_lab_tools = false;app.Lab.next_turn(app.game,app.lab_numeric);app.selected = -1;app.rebuild(),"LabNext",app.GOLD,blocked)
 H.action(app,tools,"Combine with another ability",func():app.show_lab_tools = false;app.show_lab_setup = true;app.rebuild(),"LabCombine",app.MUTED)
 H.action(app,tools,"Copy test log",func():DisplayServer.clipboard_set("Ash & Oath · "+app.Catalog.name_for(app.lab_face)+"\n"+"\n".join(app.game.log_lines)),"LabCopy",app.MUTED)
 H.action(app,column,"Boss phase II active" if app.game.phase_two else "Test boss phase II",app.test_boss_phase_two,"LabPhase",app.GOLD,app.game.phase_two or blocked or app.game.v("boss.phase.percent")==0)
 M.text(column,"On the map: select an Attack and tap its target, select Movement and tap a destination, or tap Guard to defend. Reopen these tools during a test with Test tools (phone: More → Test tools).",17)
 P.footer(app,["Main menu","Try ability →"],[app.go_main,func():app.show_lab_tools = false;app.rebuild()])
 for node in app.ui.get_children():
  if node is Button and node.text=="Try ability →":node.name = "LabTry"

static func fill_abilities(app, picker: OptionButton, query: String) -> void:
 picker.clear();var wanted: String = query.strip_edges().to_lower()
 for id in range(app.Essence.FACE_COUNT):
  if wanted!="" and not wanted in (app.Catalog.display_name(id)+" "+app.Catalog.text(id)).to_lower():continue
  picker.add_icon_item(app.AbilityGlyphs.small_texture(id),app.Catalog.display_name(id),id);picker.get_popup().set_item_icon_max_width(picker.item_count-1,20)
 picker.disabled = picker.item_count==0
 if picker.disabled:picker.add_item("No match — try another word",-1)
 else:picker.select(maxi(0,picker.get_item_index(app.lab_face)))

static func combinations(app) -> void:
 var column := P.panel(app,"Combine abilities","Keep the first test face and choose the second ability. Apply starts a fresh practice scenario.")
 H.note(column,"First ability",app.Catalog.name_for(app.lab_face),app.color_for_face(app.lab_face))
 M.choose(app,column,"Second ability",range(app.Model.FACES.size()).map(func(id):return app.Catalog.display_name(id)),app.lab_support,func(index):app.lab_support = index;app.rebuild(),"LabSupport")
 H.card(app,column,app.Catalog.name_for(app.lab_support),app.AbilityCopy.new().face(app.lab_support),app.color_for_face(app.lab_support))
 P.footer(app,["Back to tools","Apply and test"],[func():app.show_lab_setup = false;app.show_lab_tools = true;app.rebuild(),func():app.show_lab_setup = false;app.reset_lab()])
 for node in app.ui.get_children():
  if node is Button and node.text=="Apply and test":node.name = "LabSupportApply"
