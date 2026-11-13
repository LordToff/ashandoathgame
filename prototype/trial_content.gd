extends RefCounted
## Original experiments, available only inside Trials. No ordinary Camp inventory.
const ESSENCE = {
 "ward":{"name":"Ward Essence","source":"Ward & Whisper; Protect the Spirit"},
 "cinder":{"name":"Cinder Essence","source":"The Long Charge; Break the Ritual"},
 "shade":{"name":"Shade Essence","source":"Essence Thieves"},
 "hollow":{"name":"Hollow Essence","source":"The Hollow, final Trial boss"}
}
const RECIPES = {
 "oathblade":{"slot":"weapon","item":"oathblade","name":"Oathblade","cost":{"ward":4,"hollow":2}},
 "venom":{"slot":"weapon","item":"venom","name":"Poison Dagger","cost":{"shade":2}},
 "heavy":{"slot":"weapon","item":"heavy","name":"Heavy Dagger","cost":{"cinder":2,"hollow":1}},
 "fleet":{"slot":"body","item":"fleet","name":"Fleet Body","cost":{"cinder":3}},
 "stone":{"slot":"body","item":"stone","name":"Stone Body","cost":{"ward":3}},
 "shelter_memory":{"slot":"memory","item":"shelter","name":"Memory of Shelter","cost":{"ward":2}},
 "hearth_soul":{"slot":"memory","item":"hearth","name":"Memory of Hearth","cost":{"ward":3}},
 "wind_soul":{"slot":"memory","item":"wind","name":"Memory of Wind","cost":{"cinder":3}}
}
const BUILDS = {
 "poison":{"name":"Poison","memory":"venom","body":"broken","weapon":"venom","soul":"nugh","text":"Attack to apply Poison → Poke with Poison Dagger after enemy HP damage → Brood Soul spreads your first Poison to an adjacent enemy. Healing received is weaker. Until Brood Soul is unlocked, Beginning Soul supplies Last Ember. Memories start empty."},
 "movement":{"name":"Movement","memory":"stride","body":"fleet","weapon":"spear","soul":"","text":"Fleet Body permits 4 Movement faces → use Stride or two Steps → Jab reaches an enemy within 2. Soul sets HP and Blanks; Memory starts empty. Earn Memory of Wind to convert a Blank to Move 2 later."},
 "protection":{"name":"Protection","memory":"guard","body":"stone","weapon":"hammer","soul":"bugh","text":"Block an enemy Attack completely → Memory of Guard primes +1 damage for your next Attack. Attack first, then Crack strips an adjacent enemy’s Block for a following ally. Stone Body permits 4 Defense and 2 Movement faces. Soul sets HP and Blanks; Memory starts empty. Warden Soul keeps up to 2 Block and has its own movement penalty."}
}
const OBJECTIVES = {
 "ritual":{"name":"Break the Ritual","text":"Break all three violet ritual stones (2 HP each). Any Attack can damage them; they cannot move or receive Poison. Enemies retreat when all three break. Clearing only the creatures does not complete this objective. Victory: +3 Run Essence and 2 Cinder Essence."},
 "spirit":{"name":"Protect the Spirit","text":"Keep the blue spirit (5 HP) alive through three enemy turns, or defeat all its attackers sooner. Enemies prefer the spirit when their ability can reach it; otherwise they target a hero. First Aid can heal it. Shield Wall and Taunt can protect it. Its death ends this Trial. Victory: +3 Run Essence and 2 Ward Essence."}
}
static func reward_source(current: Dictionary) -> String:
 if current.get("kind","")=="boss":return "hollow" if current.get("boss","")=="hollow" else ""
 if current.get("objective","")=="ritual":return "cinder"
 if current.get("objective","")=="spirit":return "ward"
 return ["ward","cinder","shade"][clampi(int(current.get("group",0)),0,2)]
