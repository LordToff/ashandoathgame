extends RefCounted
const M = preload("res://prototype/mobile_ui.gd")
const P = preload("res://prototype/battle_panels.gd")
const H = preload("res://prototype/menu_helpers.gd")
const TOPICS = ["Start here","Combat","Equipment","Resources","Normal adventure","Trials","Camp","All words"]
const ENTRIES = [
 ["Start here","What should I do first?","Normal adventure: prepare your party, choose a boss, resolve one road event, then fight. Trials: prepare each hero, follow five stops, then face the chosen boss. The two modes keep separate rewards."],
 ["Start here","Which button do I press?","Gold buttons move you forward or apply the choice described on them. Back returns to the previous step. Help explains this screen without changing your choices. A disabled action has a reason beside it."],
 ["Combat","Action Dice and faces","Each hero has three dice with six physical sides each. A shared round roll gives one ability per available die. You may spend ready abilities in any order. A spent face darkens. Unused abilities may be left unspent when you end the turn."],
 ["Combat","Targeting","Tap or click an Attack, then its highlighted target on the map. Movement: ability, then destination. Guard and other self effects resolve on their ability tap. Special choices and Reactions use their own controls."],
 ["Combat","Health / HP","HP is life. At zero, a hero is Downed unless already Broken. Healing can revive a Downed hero and makes them Broken. A later fall while Broken is lethal for that encounter. Slain heroes cannot be healed."],
 ["Combat","Block","Block absorbs ordinary incoming damage before HP. Unspent Block usually expires at that unit’s next turn. It is not extra maximum HP. Pierce can bypass some Block; unavoidable damage skips it."],
 ["Combat","Poison","Applications add together. At activation, Poison removes that much HP, then its amount decreases by one. Poison 2 deals 2, then later Poison 1 deals 1. Green smoke marks a poisoned unit."],
 ["Combat","Stunned and Rooted","Stunned costs a die; becoming Stunned again while already Stunned causes unavoidable damage instead. Rooted prevents voluntary movement, including swaps. Inspect a hero’s status card for duration and remaining effects."],
 ["Combat","Reaction and Channel","A Reaction is held after it rolls, for use when its trigger happens. A Channel holds its die until you maintain or end it. These are ability timings, not extra equipment slots."],
 ["Combat","Action Reroll","Spend a stored Action Reroll to roll one eligible die again. It may show the same ability. Focus instead spends its own ability to reroll another die. Settings can skip dice animation and its pause without changing results."],
 ["Combat","Enemy intent","An intent shows an enemy’s rolled ability and expected target. Tap it to read damage, range and target priority. The target can change if conditions or Reactions change before resolution."],
 ["Combat","Colors","Red = Attack. Blue = Defense. Yellow = Movement. Purple = Skill. Light gray = Blank. Dark gray = spent. A Blank has no starting action unless an equipped effect or explicit Settings option gives it one."],
 ["Equipment","The four equipment slots","Each hero has one Body, Soul, Memory and Weapon. A Trial class is a starting kit for those slots, not another equipment layer. Equipment belongs to the selected hero; read their name before changing it."],
 ["Equipment","Body","A Body sets the minimum and maximum number of Defense, Movement and Skill faces across that hero’s three dice. It does not set Attack limits or HP. Abilities use their printed movement distance unless another printed effect changes it."],
 ["Equipment","Soul","A Soul sets maximum HP, minimum Blanks on every die, and a strong effect. A Soul copy belongs to one hero. Soulcaster has its own Gather / Manifest effect; it is not a Memory."],
 ["Equipment","Memory / passive","A Memory adds a passive modifier: an automatic effect or another use for a rolled Blank. It does not add a new kind of slot. New parties start empty; Trials always begin the first encounter without a Memory. Earn one after a victory."],
 ["Equipment","Weapon","A Weapon alone sets Attack-face minimum / maximum and replaces 1–3 basic Strike sides with its own attacks. Those sides must roll before use. Some Weapons also modify all that hero’s Attacks. Changing weapons does not grant free attacks."],
 ["Equipment","Physical copies and Blanks","A crafted ability is one owned face copy shared by the normal party. One copy cannot occupy several sides at once. Returning it to the collection keeps it owned. Every die must retain its Soul’s minimum Blanks; equipment must also satisfy Body and Weapon limits."],
 ["Equipment","Soulcaster / Soul Charges","Spend a rolled Blank to Gather 1 charge, up to 3, or Manifest a spell for charges + 1 HP. A new spell must roll on a later turn before use. Up to four spells; spells and charges are encounter-only. Settings may separately offer Blank → Move 1."],
 ["Resources","Creature Essence — normal Camp","Defeat a complete creature encounter to bank matching creature Essence; bosses give three matching Essence. Spend it on that creature’s recipes in Craft upgrades. Types cannot be mixed. Crafted rewards remain owned after fights."],
 ["Resources","Run Essence — Trials only","This is the carried reward currency for the current Trial. A victory upgrade costs 2 Run Essence; taking currency instead adds 2. It resets for a new Trial. It cannot pay normal Camp recipes or permanent Trial Forge recipes."],
 ["Resources","Trial Forge materials — kept","Ward, Cinder, Shade and Hollow Essence are separate permanent Trial crafting ingredients. Recipes show what you have, what you need and where to earn it. These are different from Run Essence and normal creature Essence."],
 ["Resources","Gold","Normal adventure uses Gold for road-event choices such as Shrine offerings. It does not pay Camp crafting recipes. Gold recorded by a combat ability can be encounter-local; follow that ability’s text."],
 ["Resources","Salve and Reroll Seal","A Salve restores up to 2 HP to a standing hero, once per own turn, and cannot revive. A Reroll Seal adds one Action Reroll if below the cap. Use them through Supplies in normal combat; Trials have their own rewards instead."],
 ["Resources","Soul Fragments","In normal adventure, spend 3 fragments to bind and equip the Ash Road Soul to a chosen hero, once. Check its HP, required Blanks and Last Ember effect in Equipment. The new Soul may require adjusting that hero’s dice; it is not a free move."],
 ["Normal adventure","Your route","Prepare all three heroes → choose a boss → resolve one road event → fight the boss. Direct creature battles are optional ways to earn crafting materials; they do not replace the required road event."],
 ["Normal adventure","Suggested bonuses","Each normal hero chooses two different bonus ability designs. Suggestions automatically create legal starter dice using that hero’s current equipment. You can instead choose your own bonuses or edit individual sides. Owned crafted rewards are kept."],
 ["Trials","Preparation and route","Prepare Class, Soul, Body, Weapon, Memory and Dice for each hero. Review the party and choose a boss. Complete five stops, then that boss. HP carries between fights; rest heals the party."],
 ["Trials","Victory rewards","Choose the hero receiving the reward, then buy one ability, Memory or Weapon for 2 Run Essence, or take +2 Run Essence instead. A new ability replaces a legal physical side. Buying ends that reward choice; browsing spends nothing."],
 ["Trials","Safe checkpoints","Route, reward, Camp and cache choices can resume after reload. Preparation also saves. Leaving or reloading during an actual fight ends the Trial without a victory reward; permanent Trial unlocks remain."],
 ["Camp","Crafting is not equipping","Craft upgrades adds an owned reward. Equip gear puts a Body, Soul, Memory or Weapon on one hero. Install abilities places an owned crafted ability on a die. These are separate actions, and the menu shows the next step after crafting."],
 ["Camp","Keeping rewards","Normal Camp owns your banked Essence and crafted copies. Trial Forge owns a separate permanent collection. Merely viewing an item, opening Help, changing tabs or pressing Back spends nothing."]
]
static func context(app) -> String:
 if app.page=="trials" or app.trial_fight:return "Trials"
 if app.page=="camp":return "Camp"
 if app.page in ["normal","setup","events"]:return "Normal adventure"
 if app.page=="forge":return "Equipment"
 if app.page=="battle":return "Combat"
 return "Start here"
static func populate(app, target: VBoxContainer, query: String, topic: String) -> void:
 for child in target.get_children():target.remove_child(child);child.queue_free()
 var found := 0;var wanted := query.strip_edges().to_lower()
 for entry in ENTRIES:
  if wanted!="":
   if not wanted in (entry[1]+" "+entry[2]).to_lower():continue
  elif topic!="All words" and entry[0]!=topic:continue
  found += 1;H.card(app,target,entry[1],entry[2],app.GOLD)
 if found==0:M.text(target,"No match. Try a shorter word, such as Soul, Block, Blank or Essence.",20)
static func render(app) -> void:
 var column := P.panel(app,"Help & glossary","Look up a word, or choose a short topic. Your current choices stay unchanged.")
 var search := LineEdit.new();search.name = "GuideSearch";search.placeholder_text = "Find a word: Soul, Block, Essence…";search.text = app.player_guide_search;search.custom_minimum_size = Vector2(0,48);search.add_theme_font_size_override("font_size",18);column.add_child(search)
 M.choose(app,column,"Topic",TOPICS,maxi(0,TOPICS.find(app.player_guide_topic)),func(index):app.player_guide_topic = TOPICS[index];app.player_guide_search = "";app.rebuild(),"GuideTopic")
 var results := VBoxContainer.new();results.name = "GuideResults";results.add_theme_constant_override("separation",12);column.add_child(results)
 populate(app,results,app.player_guide_search,app.player_guide_topic)
 search.text_changed.connect(func(value):app.player_guide_search = value;populate(app,results,value,app.player_guide_topic))
 P.footer(app,["Back to game"],[func():app.show_player_guide = false;app.rebuild()])
 for node in app.ui.get_children():
  if node is Button and node.text=="Back to game":node.name = "GuideClose"
