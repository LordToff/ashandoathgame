extends RefCounted
## Original v0.29 playtest content; existing PDF recipes remain unchanged.
const MEMORIES = {
 "mire":{"name":"Memory of the Mire","mode":"heal","distance":0,"effect":"Spend one rolled Blank to heal yourself 1 HP, once per own turn. Requires missing HP. No movement; cannot revive a Downed hero."},
 "glasswing":{"name":"Glasswing Memory","mode":"blink","distance":2,"effect":"Spend one rolled Blank to blink up to 2 orthogonal spaces, once per own turn. May cross occupied cells; landing must be empty. Rooted prevents it. No extra action."},
 "iron":{"name":"Ironbound Memory","mode":"block","distance":0,"effect":"Spend one rolled Blank to gain 2 Block, once per own turn. Block expires normally at the next own turn. No movement."}
}
const GROUPS = [
 {"title":"BONE PATROL","enemy":"bone_creature","types":["bone_creature","bone_creature"],"description":"Two Bone Creatures, 3 HP each. Scuttle 2, Bite 1, Guard 1.","reward":"Up to 2 Bone Essence"},
 {"title":"MIXED GROUP","enemy":"support_creature","types":["support_creature","movement_creature","movement_creature"],"description":"One Support Creature (2 HP) and two Movement Creatures (3 HP each). Mend restores 1 HP within 2.","reward":"1 Support + 2 Movement Essence"},
 {"title":"SWIFT PACK","enemy":"movement_creature","types":["movement_creature","movement_creature"],"description":"Two Movement Creatures, 3 HP each. Scuttle 3, Bite 1, Guard 1.","reward":"Up to 2 Movement Essence"},
 {"title":"THE SUNKEN BANK","enemy":"mire_leech","types":["mire_leech","mire_leech"],"description":"Two Mire Leeches, 4 HP each. Venom Bite deals 1 at reach 1; actual HP loss adds Poison 1. Scuttle 2, Guard 1.","reward":"Up to 2 Mire Leech Essence"},
 {"title":"GLASSWING SWARM","enemy":"glasswing_moth","types":["glasswing_moth","glasswing_moth"],"description":"Two Glasswing Moths, 3 HP each. Needle deals 1 at range 3 with line of sight. Scuttle 2, Guard 1. Close the gap or block the shot.","reward":"Up to 2 Glasswing Moth Essence"},
 {"title":"RUSTED PROCESSION","enemy":"iron_husk","types":["iron_husk","movement_creature"],"description":"An Iron Husk (5 HP) with one Movement Creature (3 HP). Husk: Scuttle 1, Bash 2 at reach 1, Iron Guard +2 Block. No passive armor.","reward":"1 Iron Husk + 1 Movement Essence"}
]
static func soul_name(key: String) -> String:
 return preload("res://prototype/equipment.gd").SOULS.get(key,{"name":"None equipped"}).name
