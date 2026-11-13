extends RefCounted
## Original pixel frames by 0x72, CC0. See vendor/dungeon_tileset_ii/SOURCE.md.
const STILLS = {
 "bone_creature":preload("res://prototype/assets/enemies/bone_creature.tres"),
 "support_creature":preload("res://prototype/assets/enemies/support_creature.tres"),
 "movement_creature":preload("res://prototype/assets/enemies/movement_creature.tres"),
 "mire_leech":preload("res://prototype/assets/enemies/mire_leech.tres"),
 "glasswing_moth":preload("res://prototype/assets/enemies/glasswing_moth.tres"),
 "iron_husk":preload("res://prototype/assets/enemies/iron_husk.tres"),
 "shield":preload("res://prototype/assets/enemies/shield.tres"),
 "healer":preload("res://prototype/assets/enemies/healer.tres"),
 "ram":preload("res://prototype/assets/enemies/ram.tres"),
 "thief":preload("res://prototype/assets/enemies/thief.tres"),
 "archer":preload("res://prototype/assets/enemies/archer.tres"),
 "hollow":preload("res://prototype/assets/enemies/hollow.tres"),
 "nugh":preload("res://prototype/assets/enemies/nugh.tres"),
 "cantor":preload("res://prototype/assets/enemies/cantor.tres"),
 "bugh":preload("res://prototype/assets/enemies/bugh.tres"),
 "worm":preload("res://prototype/assets/enemies/worm.tres"),
 "mite":preload("res://prototype/assets/enemies/mite.tres"),
 "cocoon":preload("res://prototype/assets/enemies/cocoon.tres"),
}
static var frames: Dictionary = {}
static func texture(key: String, seconds: float = 0, moving: bool = false) -> Texture2D:
 if not STILLS.has(key):key = "bone_creature"
 var index: int = int(seconds*(10 if moving else 5))%4+(4 if moving else 0)
 var cache: String = key+str(index)
 if not frames.has(cache):
  var still: AtlasTexture = STILLS[key];var frame := AtlasTexture.new();frame.atlas = still.atlas
  frame.region = Rect2(still.region.position+Vector2((index%4)*32,(index/4)*32),still.region.size);frames[cache] = frame
 return frames[cache]
static func key_for(g, id: int) -> String:
 if id==3 and g.encounter_id!="event":return g.encounter_id
 var unit: Dictionary = g.unit_data(id)
 if unit.has("trial_role"):return str(unit.trial_role)
 if g.friendly(id):return "worm"
 if g.encounter_id=="event":return g.essence_type(id)
 return "cocoon" if unit.get("kind","")=="cocoon" else "mite" if unit.get("kind","")=="mite" else "worm"
static func draw(app, key: String, foot: Vector2, seconds: float, moving: bool = false, boss: bool = false) -> void:
 var sprite: Texture2D = texture(key,seconds,moving)
 var zoom: int = (4 if sprite.get_height()>24 else 5) if boss else (2 if sprite.get_height()>24 else 3)
 var size: Vector2 = sprite.get_size()*zoom
 app.draw_texture_rect(sprite,Rect2((foot-Vector2(size.x/2,size.y)).round(),size),false)
