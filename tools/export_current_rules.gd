extends SceneTree
const B = preload("res://prototype/battle.gd")
const Cantor = preload("res://prototype/cantor.gd")
const N = preload("res://prototype/nugh.gd")
const Bug = preload("res://prototype/bugh.gd")
const C = preload("res://prototype/catalog.gd")
const Copy = preload("res://prototype/ability_copy.gd")
func _initialize():
 var g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],1)
 var n = N.new();n.start([B.default_build(),B.default_build(),B.default_build()],1)
 var c = Cantor.new();c.start([B.default_build(),B.default_build(),B.default_build()],1)
 var bug = Bug.new();bug.start([B.default_build(),B.default_build(),B.default_build()],1)
 var copy = Copy.new()
 var result := {"faces":[],"bugh":[],"bugh_dice":bug.boss_dice(),"hollow":[],"nugh":[],"cantor":[],"cantor_dice":c.boss_dice(),"defaults":{},"build":B.default_build(),"dice":g.boss_dice(),"nugh_dice":n.boss_dice(),"original":{}}
 for def in B.Balance.DEFINITIONS:
  result.defaults[def.key] = B.Balance.value({},def.key,true)
  if B.Balance.value({},def.key,false) != result.defaults[def.key]:result.original[def.key] = B.Balance.value({},def.key,false)
 for id in range(C.FACE_COUNT):result.faces.append({"id":id,"name":C.name_for(id),"type":C.classification(id),"description":copy.face(id)})
 for entry in g.phase_upgrades():result.hollow.append({"name":entry[0],"description":"Targeting: "+g.enemy_intent(3,entry[0],0).policy+". "+g.intent_effect(entry[0]),"upgrade":entry[1]})
 for entry in n.phase_upgrades():result.nugh.append({"name":entry[0],"description":"Targeting: "+n.enemy_intent(3,entry[0],0).policy+". "+n.intent_effect(entry[0]),"upgrade":entry[1]})
 for entry in c.phase_upgrades():result.cantor.append({"name":entry[0],"description":"Targeting: "+c.enemy_intent(3,entry[0],0).policy+". "+c.intent_effect(entry[0]),"upgrade":entry[1]})
 for entry in bug.phase_upgrades():result.bugh.append({"name":entry[0],"description":"Targeting: "+bug.enemy_intent(3,entry[0],0).policy+". "+bug.intent_effect(entry[0]),"upgrade":entry[1]})
 var wilds = preload("res://prototype/wilds.gd")
 var creatures = preload("res://prototype/event_battle.gd").new()
 var essence = preload("res://prototype/essence.gd")
 result.wilds = {"souls":wilds.SOULS,"groups":wilds.GROUPS,"enemies":{}}
 for type in ["mire_leech","glasswing_moth","iron_husk"]:result.wilds.enemies[type] = {"name":essence.type_name(type),"hp":essence.TYPES[type].hp,"dice":creatures.creature_dice(type),"description":creatures.creature_help(type)}
 var trial_rules = preload("res://prototype/trial_rules.gd")
 var trial_content = preload("res://prototype/trial_content.gd")
 result.trials = {"memories":trial_rules.MEMORIES,"souls":trial_rules.SOULS,"bodies":trial_rules.BODIES,"weapons":trial_rules.WEAPONS,"recipes":trial_content.RECIPES,"essence":trial_content.ESSENCE,"builds":trial_content.BUILDS,"objectives":trial_content.OBJECTIVES}
 var classes = preload("res://prototype/trial_classes.gd")
 result.trials.soulcaster = trial_rules.Soulcaster.SPELLS
 result.trials.soulcaster_dice = trial_rules.Soulcaster.STARTER_DICE.map(func(die):return die.map(func(face):return C.name_for(face)))
 result.trials.classes = classes.CLASSES
 result.trials.class_dice = {}
 for key in classes.CLASSES:
  result.trials.class_dice[key] = range(3).map(func(die):return range(6).map(func(side):return C.name_for(classes.face_for(key,die,side))))
 result["original_dice"] = B.BOSS_DICE
 var f = FileAccess.open("/tmp/current-rules-data.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));quit()
