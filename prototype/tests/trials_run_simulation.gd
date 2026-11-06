extends "res://prototype/tests/trial_battles.gd"
const Run = preload("res://prototype/trials.gd")
const Fight = preload("res://prototype/trial_encounter.gd")
func run():
 var report := {"policy":"visible-board heuristic adapted to living group targets and Trial terrain; no forced outcomes","scenarios":[],"errors":0}
 for group in range(3):
  for elite in [false,true]:
   var stat := {"group":Fight.GROUPS[group].title,"elite":elite,"wins":0,"losses":0,"stalls":0,"rounds":0}
   for seed_number in range(1,7):
    var trial = Run.new(false);trial.start(seed_number)
    var profile: Dictionary = trial.profile();profile["trial.terrain"] = Fight.GROUPS[group].terrain
    var g = Fight.new();g.group_index = group;g.elite = elite;g.start(trial.builds,seed_number,true,true,profile)
    var actions := 0
    while g.outcome=="" and actions<3600 and g.round_no<=80:
     actions += 1
     if not g.pending.is_empty():resolve_choice(g)
     elif g.active==3:g.boss_step()
     elif not hero_step(g):
      if g.forced_die>=0:g.decline(g.forced_die)
      else:g.finish_turn()
     for h in g.heroes:
      if h.hp<0 or h.hp>h.max_hp or h.block<0 or (h.dead and h.hp>0):report.errors += 1
    stat.rounds += g.round_no
    if g.outcome=="victory":stat.wins += 1
    elif g.outcome=="defeat":stat.losses += 1
    else:stat.stalls += 1;printerr("TRIAL SIM STALL ",group," ",elite," seed ",seed_number," pending ",g.pending)
   report.scenarios.append(stat)
   print("TRIAL SIM ",JSON.stringify(stat))
 var file := FileAccess.open("/tmp/ash34-simulation.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "))
 var stalls: int = report.scenarios.reduce(func(total,item):return total+item.stalls,0)
 print("TRIAL SIMULATION: 36 encounters, %d stalls, %d invalid states" % [stalls,report.errors]);quit(1 if stalls>0 or report.errors>0 else 0)

func movement_value(g, id: int, p: Vector2i) -> float:
 var nearest := 99
 for target in g.attack_targets(id,99):nearest = mini(nearest,g.distance(id,target,p))
 var value: float = -nearest*1.1
 if p in g.trial_state.spikes and p!=g.heroes[id].pos:value -= 3.0 if g.heroes[id].hp>1 else 100.0
 for mark in g.trial_state.charges:
  if p in mark.tiles:value -= 10.0
 if p in g.trial_state.cover:value += .15
 return value
