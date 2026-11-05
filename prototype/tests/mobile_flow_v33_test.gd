extends SceneTree
const B = preload("res://prototype/battle.gd")
const N = preload("res://prototype/nugh.gd")
const C = preload("res://prototype/cantor.gd")
const W = preload("res://prototype/bugh.gd")
const E = preload("res://prototype/essence.gd")
const UI = preload("res://prototype/mobile_ui.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks+=1
 if not ok:failures+=1;printerr("FLOW FAIL: ",why)
func fresh(type=B,profile={}):
 var g=type.new();g.start([B.default_build(),B.default_build(),B.default_build()],33,false,true,profile);g.active=0;g.pending={};g.forced_die=-1
 for h in g.heroes:h.used=[false,false,false];h.reaction=[];h.results=[1,4,0];h.rolls=[0,0,0]
 g.heroes[0].pos=Vector2i(3,5);return g
func find(node: Node, name: String):
 return node.find_child(name,true,false)
func _initialize():call_deferred("run")
func run():
 var e=E.new();check(e.memory_keys().size()==5,"five Memory designs")
 for type in [B,N,C,W]:
  var g=fresh(type);var key: String = g.encounter_id;g.damage(3,999,true)
  check(g.harvest_tokens.filter(func(token):return token.type==key).size()==3,"boss drops three matching Essence")
  e=E.new();check(e.settle(g.harvest_run,true,g.harvest_tokens,g.harvest_deaths,g.encounter_types()),"bank boss victory")
  check(e.bank.get(key,0)==3,"boss bank has three")
  check(not e.settle(g.harvest_run,true,g.harvest_tokens,g.harvest_deaths,g.encounter_types()),"no double claim")
  var recipes: Array = e.recipes_for(key)
  check(recipes.size()==2,"ability and Memory for every boss")
  var face: String = recipes.filter(func(id):return E.RECIPES[id].has("face"))[0]
  check(e.craft(face)=="" and e.owned(E.RECIPES[face].face)==1,"boss face crafts and owns copy")
 e=E.new();e.unlocked={"memory_embers":true,"memory_iron":true}
 check(e.equip_memory(0,"memory_embers") and e.equip_memory(1,"memory_iron"),"different Memories coexist")
 e.equip_memory(2,"memory_embers");check(e.memories==["","memory_iron","memory_embers"],"one party copy transfers")
 var g=fresh(B,{"memory.embers.0":true});g.hero_action(0,3);check(g.heroes[0].block==1,"Embers actual hit gains Block")
 g.heroes[0].used[0]=false;g.hero_action(0,3);check(g.heroes[0].block==1,"Embers once per own turn")
 g=fresh(B,{"memory.brood.0":true});g.apply_poison(0,3,1);g.apply_poison(0,3,1);check(g.boss.poison==3,"Brood adds one extra once")
 g=fresh(B,{"memory.silence.0":true});g.heroes[0].results[0]=71;g.heroes[0].hp=3;g.hero_action(0)
 check(g.heroes[0].hp==4 and g.heroes[0].block==1,"Quiet Note and Silence")
 g=fresh(B,{"memory.iron.0":true});g.hero_action(1);check(g.heroes[0].block==2,"Iron boosts first Defense")
 g=fresh();g.heroes[0].results[0]=69;g.hero_action(0,3);check(g.boss.hp==10 and g.heroes[0].block==1,"Ember Cut")
 g=fresh();g.heroes[0].results[0]=70;g.hero_action(0,3);check(g.boss.poison==1,"Brood Needle applies Poison")
 g=fresh();g.heroes[0].results[0]=72;g.hero_action(0);check(g.heroes[0].block==2,"Iron Shelter empty Block")
 var app=load("res://prototype/prototype.tscn").instantiate();root.add_child(app);await process_frame
 app.game=fresh();app.page="battle";app.seen_event=app.game.event_id;app.roll_seen=app.game.roll_presentations.size();app.dice_tray.cancel();app.rolling_time=0
 app.game.heroes[0].poison=2;app.game.tick_poison(0);app.sync_presentation()
 check(app.combat_notices.is_empty(),"Poison never opens a popup")
 check(app.effects.any(func(f):return f.kind=="poison_tick"),"Poison still has effect")
 check(not app.floaters.any(func(f):return "POISON" in f.text),"no Poison text pop")
 app.expedition.camp=E.new()
 app.debug_mode=false;check(not app.debug_unlock("recipe","ember_cut",0),"debug grants disabled by default")
 app.debug_mode=true;check(app.debug_unlock("recipe","ember_cut",0),"debug unlock face")
 check(app.expedition.camp.owned(69)==1 and app.expedition.camp.bank.is_empty(),"debug grants without spending")
 check(not app.debug_unlock("recipe","ember_cut",0),"debug grant idempotent")
 check(app.debug_unlock("soul","mire",1) and "mire" not in app.expedition.camp.souls[0],"debug Soul bound to chosen hero")
 for size in [Vector2i(390,844),Vector2i(360,640),Vector2i(844,390)]:
  root.size=size;app.set_mobile_mode(true,false);await process_frame;await process_frame;app.combat_notices.clear();app.game.pending={};app.game.active=0;app.rebuild();await process_frame
  var end=find(app.ui,"MobileEndTurn");var dice=find(app.ui,"MobileDie0")
  check(end!=null and app.get_viewport_rect().encloses(end.get_global_rect()),"end turn stays inside phone viewport")
  check(dice.text=="Strike" and not "Die" in dice.text,"ability names only")
  check(app.ui.find_children("*","ScrollContainer",true,false).is_empty(),"combat has no scroll panels")
  app.game.active=3;app.game.boss_index=3;app.rebuild();await process_frame
  var step=find(app.ui,"MobileEnemyStep")
  check(step.text=="End enemy turn" and app.get_viewport_rect().encloses(step.get_global_rect()),"enemy finish always visible")
 app.queue_free();await process_frame;print("MOBILE FLOW v0.33: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
