extends RefCounted
## Original 2016 DCSS/RLTiles knights. Unchanged source PNGs, public-domain tiles.
const STILLS = [preload("res://prototype/assets/vendor/crawl_party_arena/vesper.png"),preload("res://prototype/assets/vendor/crawl_party_arena/rook.png"),preload("res://prototype/assets/vendor/crawl_party_arena/wren.png")]
static var portraits: Dictionary = {}
static func texture(hero: int) -> Texture2D:return STILLS[clampi(hero,0,2)]
static func portrait(hero: int) -> Texture2D:
 if not portraits.has(hero):
  var atlas := AtlasTexture.new();atlas.atlas = texture(hero);atlas.region = Rect2(6,0,20,23);portraits[hero] = atlas
 return portraits[hero]
