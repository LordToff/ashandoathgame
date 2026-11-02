extends RefCounted
## Local expedition ledger. A result is committed once, before it is displayed.
const Essence = preload("res://prototype/essence.gd")
var camp = Essence.new()
const SAVE = "user://ash-expedition-v25.json"
const TITLES = ["Abandoned Supplies", "Ash Shrine", "Stranded Traveller", "Scavenger Ambush", "Infested Ruins", "Buried Reliquary"]
const DETAILS = [
 "No cost or risk. Take 1 Salve or 1 Reroll Seal. Salve: restore 2 HP to one standing hero during their turn, once per turn. Seal: restore 1 Action Reroll below its bank cap. Neither spends an Action Die.",
 "Leave safely, or offer 2 Gold (paid now). Roll d6: 3–6 grants 1 Soul Fragment; 1–2 loses the offering. Collect 3 fragments, then spend them here to unlock the existing Soul: at most one rolled Blank per hero turn becomes Move 2. No free movement.",
 "Choose freely: give up 1 Salve to help and earn 3 Gold + 1 Reroll Seal; or take the traveller’s directions for 1 Gold. No hidden injury roll.",
 "Fight two Bone Creatures: each 3 HP, one cell. Provisional AI: Scuttle 2 / Bite 1 / Guard 1. Defeat BOTH for 3 Gold + 1 Salve and bank 1 Bone Creature Essence per harvested individual. No boss, phase, fire or Soul. Withdraw now safely for no reward; defeat gives nothing.",
 "Optional mixed group: Support Creature (2 HP, Mend 1 / Bite 1 / Guard 1 / Scuttle 2) and two Movement Creatures (3 HP each, Scuttle 3 / Bite 1 / Guard 1). AI and composition are provisional. Defeat ALL THREE for 5 Gold + 1 Soul Fragment + 1 Reroll Seal, plus each harvested creature’s own Essence. No boss or phase. Leave safely now; defeat gives nothing.",
 "Take 1 Gold safely, or search deeper. Roll d6: 4–6 grants 3 Gold + 1 Soul Fragment; 1–3 loses 1 held Salve (if none, gain nothing). The safe reward is replaced, never added."
]
var gold := 0
var salves := 0
var seals := 0
var fragments := 0
var soul := false
var fragment_soul_hero := -1
var selected := 0
var stage := "idle"
var summary := "No event resolved yet."
var serial := 0
var rng := RandomNumberGenerator.new()
func _init():rng.randomize()
func load_save():
 if not FileAccess.file_exists(SAVE):return
 var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
 if not data is Dictionary:return
 for key in ["gold","salves","seals","fragments","serial"]:set(key,maxi(0,int(data.get(key,0))))
 if data.get("camp") is Dictionary:camp.decode(data.camp)
 soul = bool(data.get("soul",false));selected = clampi(int(data.get("selected",0)),0,6)
 fragment_soul_hero = int(data.get("fragment_soul_hero",-1))
 if not data.has("camp") and soul:
  for hero in range(3):camp.grant_soul(hero,"ashroad")
 stage = str(data.get("stage","idle"));summary = str(data.get("summary",""))
 # Combat is not checkpointed. An interrupted fight never grants its victory reward.
 if stage == "combat":stage = "resolved";summary = "Interrupted monster encounter: no completion reward. Supplies already spent stay spent.";save()
func save():
 var data := {}
 for key in ["gold","salves","seals","fragments","soul","selected","stage","summary","serial","fragment_soul_hero"]:data[key] = get(key)
 data.camp = camp.encode()
 var file = FileAccess.open(SAVE,FileAccess.WRITE)
 if file:file.store_string(JSON.stringify(data))
func roll() -> int:
 if stage != "idle":return selected
 selected = rng.randi_range(1,6);stage = "choice";serial += 1;summary = "d6 → %d · %s" % [selected,TITLES[selected-1]];save();return selected
func award(g: int, s: int, rerolls: int, shards: int):
 gold += g;salves += s;seals += rerolls;fragments += shards
 summary += "\nGranted: %d Gold · %d Salve · %d Reroll Seal · %d Soul Fragment." % [g,s,rerolls,shards]
func choose(option: int) -> bool:
 if stage != "choice" or option not in [0,1]:return false
 if selected == 2 and option == 1 and gold < 2:return false
 if selected == 3 and option == 1 and salves < 1:return false
 if selected in [4,5] and option == 1:stage = "combat";summary = "Victory required: defeat both monsters. Defeat or abandoning grants nothing.";save();return true
 stage = "resolved";summary = TITLES[selected-1]+" resolved."
 match selected:
  1:
   if option == 0:award(0,1,0,0)
   else:award(0,0,1,0)
  2:
   if option == 0:summary += " Left safely; no cost, no reward."
   else:
    gold -= 2
    var die := rng.randi_range(1,6);summary += " Paid 2 Gold. d6 → %d." % die
    if die >= 3:award(0,0,0,1)
    else:summary += " Offering lost; no reward."
  3:
   if option == 0:award(1,0,0,0)
   else:salves -= 1;summary += " Spent 1 Salve.";award(3,0,1,0)
  4,5:summary += " Left safely; no reward."
  6:
   if option == 0:award(1,0,0,0)
   else:
    var die := rng.randi_range(1,6);summary += " d6 → %d." % die
    if die >= 4:award(3,0,0,1)
    elif salves > 0:salves -= 1;summary += " Lost 1 Salve; no reward."
    else:summary += " No Salve to lose; no reward."
 save();return true
func finish_combat(won: bool) -> bool:
 if stage != "combat":return false
 stage = "resolved";summary = "Monster victory." if won else "Monster defeat / abandoned: no completion reward."
 if won:
  if selected == 4:award(3,1,0,0)
  else:award(5,0,1,1)
 save();return true
func unlock_soul(hero: int = 0) -> bool:
 if fragments < 3 or soul or hero not in range(3):return false
 fragments -= 3;soul = true;fragment_soul_hero = hero;camp.grant_soul(hero,"ashroad");camp.equip_soul(hero,"ashroad");save();return true
func next_sortie():
 if stage == "combat":return
 stage = "idle";selected = 0;save()
func inventory() -> String:
 return "%d Gold · %d Salves · %d Reroll Seals · %d/3 Fragments · Soul %s" % [gold,salves,seals,fragments,"unlocked" if soul else "locked"]
func use_supply(game, kind: String) -> bool:
 if game.outcome != "" or game.active not in [0,1,2] or not game.pending.is_empty():return false
 var hero: Dictionary = game.heroes[game.active]
 if hero.dead or hero.hp <= 0:return false
 if kind == "salve":
  if salves <= 0 or hero.hp >= hero.max_hp or hero.get("event_salve_used",false):return false
  salves -= 1;hero.hp = mini(hero.max_hp,hero.hp+2);hero.event_salve_used = true
 elif kind == "seal":
  if seals <= 0 or hero.rerolls >= game.v("hero.reroll_cap"):return false
  seals -= 1;hero.rerolls += 1
 else:return false
 game.note("Expedition supply: %s used by %s. %s" % [kind,hero.name,inventory()]);save();return true
