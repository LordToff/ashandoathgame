extends RefCounted
## Human-authored Game-icons.net originals, CC BY 3.0. See vendor/game_icons.
const Catalog = preload("res://prototype/catalog.gd")
const SYMBOLS = [
 preload("res://prototype/assets/ability_symbols/plain-circle.svg"),
 preload("res://prototype/assets/ability_symbols/broadsword.svg"),
 preload("res://prototype/assets/ability_symbols/footprint.svg"),
 preload("res://prototype/assets/ability_symbols/wingfoot.svg"),
 preload("res://prototype/assets/ability_symbols/round-shield.svg"),
 preload("res://prototype/assets/ability_symbols/shield-reflect.svg"),
 preload("res://prototype/assets/ability_symbols/eye-target.svg"),
 preload("res://prototype/assets/ability_symbols/first-aid-kit.svg"),
 preload("res://prototype/assets/ability_symbols/push.svg"),
 preload("res://prototype/assets/ability_symbols/two-coins.svg"),
 preload("res://prototype/assets/ability_symbols/bullseye.svg"),
 preload("res://prototype/assets/ability_symbols/magic-swirl.svg"),
 preload("res://prototype/assets/ability_symbols/angel-wings.svg"),
 preload("res://prototype/assets/ability_symbols/crystal-ball.svg"),
 preload("res://prototype/assets/ability_symbols/fist.svg"),
 preload("res://prototype/assets/ability_symbols/crowned-heart.svg"),
 preload("res://prototype/assets/ability_symbols/shadow-follower.svg"),
 preload("res://prototype/assets/ability_symbols/resonance.svg"),
 preload("res://prototype/assets/ability_symbols/crossed-chains.svg"),
 preload("res://prototype/assets/ability_symbols/healing.svg"),
 preload("res://prototype/assets/ability_symbols/dice-target.svg"),
 preload("res://prototype/assets/ability_symbols/target-shot.svg"),
 preload("res://prototype/assets/ability_symbols/death-note.svg"),
 preload("res://prototype/assets/ability_symbols/cycle.svg"),
 preload("res://prototype/assets/ability_symbols/vortex.svg"),
 preload("res://prototype/assets/ability_symbols/caged-ball.svg"),
 preload("res://prototype/assets/ability_symbols/evil-book.svg"),
 preload("res://prototype/assets/ability_symbols/drop.svg"),
 preload("res://prototype/assets/ability_symbols/divert.svg"),
 preload("res://prototype/assets/ability_symbols/pay-money.svg"),
 preload("res://prototype/assets/ability_symbols/raven.svg"),
 preload("res://prototype/assets/ability_symbols/stone-block.svg"),
 preload("res://prototype/assets/ability_symbols/smoking-orb.svg"),
 preload("res://prototype/assets/ability_symbols/backbone-shell.svg"),
 preload("res://prototype/assets/ability_symbols/dice-six-faces-three.svg"),
 preload("res://prototype/assets/ability_symbols/arrow-scope.svg"),
 preload("res://prototype/assets/ability_symbols/hook.svg"),
 preload("res://prototype/assets/ability_symbols/piercing-sword.svg"),
 preload("res://prototype/assets/ability_symbols/axe-swing.svg"),
 preload("res://prototype/assets/ability_symbols/backstab.svg"),
 preload("res://prototype/assets/ability_symbols/broken-bone.svg"),
 preload("res://prototype/assets/ability_symbols/rune-sword.svg"),
 preload("res://prototype/assets/ability_symbols/dice-shield.svg"),
 preload("res://prototype/assets/ability_symbols/armor-vest.svg"),
 preload("res://prototype/assets/ability_symbols/layered-armor.svg"),
 preload("res://prototype/assets/ability_symbols/shouting.svg"),
 preload("res://prototype/assets/ability_symbols/half-dead.svg"),
 preload("res://prototype/assets/ability_symbols/locked-fortress.svg"),
 preload("res://prototype/assets/ability_symbols/screaming.svg"),
 preload("res://prototype/assets/ability_symbols/heart-beats.svg"),
 preload("res://prototype/assets/ability_symbols/skull-signet.svg"),
 preload("res://prototype/assets/ability_symbols/dead-wood.svg"),
 preload("res://prototype/assets/ability_symbols/fire-ring.svg"),
 preload("res://prototype/assets/ability_symbols/jump-across.svg"),
 preload("res://prototype/assets/ability_symbols/bone-knife.svg"),
 preload("res://prototype/assets/ability_symbols/heart-bottle.svg"),
 preload("res://prototype/assets/ability_symbols/cancel.svg"),
 preload("res://prototype/assets/ability_symbols/smoke-bomb.svg"),
 preload("res://prototype/assets/ability_symbols/body-swapping.svg"),
 preload("res://prototype/assets/ability_symbols/worm-mouth.svg"),
 preload("res://prototype/assets/ability_symbols/dna1.svg"),
 preload("res://prototype/assets/ability_symbols/bone-mace.svg"),
 preload("res://prototype/assets/ability_symbols/ribcage.svg"),
 preload("res://prototype/assets/ability_symbols/heart-wings.svg"),
 preload("res://prototype/assets/ability_symbols/tear-tracks.svg"),
 preload("res://prototype/assets/ability_symbols/three-friends.svg"),
 preload("res://prototype/assets/ability_symbols/return-arrow.svg"),
 preload("res://prototype/assets/ability_symbols/sprint.svg"),
 preload("res://prototype/assets/ability_symbols/dodge.svg"),
 preload("res://prototype/assets/ability_symbols/fire-axe.svg"),
 preload("res://prototype/assets/ability_symbols/triple-needle.svg"),
 preload("res://prototype/assets/ability_symbols/musical-notes.svg"),
 preload("res://prototype/assets/ability_symbols/metal-scales.svg"),
 preload("res://prototype/assets/ability_symbols/barbed-spear.svg"),
 preload("res://prototype/assets/ability_symbols/cracked-shield.svg"),
 preload("res://prototype/assets/ability_symbols/ghost.svg"),
 preload("res://prototype/assets/ability_symbols/scythe.svg"),
 preload("res://prototype/assets/ability_symbols/mirror-mirror.svg"),
 preload("res://prototype/assets/ability_symbols/stitched-wound.svg"),
 preload("res://prototype/assets/ability_symbols/hourglass.svg"),
 preload("res://prototype/assets/ability_symbols/shattered-glass.svg"),
 preload("res://prototype/assets/ability_symbols/plain-dagger.svg"),
 preload("res://prototype/assets/ability_symbols/dripping-blade.svg"),
 preload("res://prototype/assets/ability_symbols/sacrificial-dagger.svg"),
 preload("res://prototype/assets/ability_symbols/ancient-sword.svg"),
]
static var small: Dictionary = {}
static var lookup: Dictionary = {}
static var glyphs: Dictionary = {}
static var menu_glyphs: Dictionary = {}
const MENU = {
 "trial":preload("res://prototype/assets/ability_symbols/crowned-skull.svg"),
 "camp":preload("res://prototype/assets/ability_symbols/anvil.svg"),
 "soul":preload("res://prototype/assets/ability_symbols/skull-crossed-bones.svg"),
 "oath":preload("res://prototype/assets/ability_symbols/crossed-swords.svg"),
 "guide":preload("res://prototype/assets/ability_symbols/book-cover.svg"),
 "heart":preload("res://prototype/assets/ability_symbols/heart-organ.svg")}
static func cutout(source: Texture2D) -> ImageTexture:
 var image: Image = source.get_image();image.convert(Image.FORMAT_RGBA8)
 for y in range(image.get_height()):
  for x in range(image.get_width()):
   var pixel := image.get_pixel(x,y)
   image.set_pixel(x,y,Color(1,1,1,pixel.a*maxf(pixel.r,maxf(pixel.g,pixel.b))))
 return ImageTexture.create_from_image(image)
static func texture(face: int) -> Texture2D:
 var id: int = clampi(face,0,SYMBOLS.size()-1)
 if not glyphs.has(id):glyphs[id] = cutout(SYMBOLS[id])
 return glyphs[id]
static func small_texture(face: int) -> Texture2D:
 if not small.has(face):
  var image: Image = texture(face).get_image();image.resize(20,20,Image.INTERPOLATE_LANCZOS);small[face] = ImageTexture.create_from_image(image)
 return small[face]
static func face_for_text(caption: String) -> int:
 if lookup.is_empty():
  for id in range(SYMBOLS.size()):lookup[Catalog.name_for(id).to_lower()] = id
 var key: String = caption.split("\n")[0].strip_edges().trim_prefix("✓ ").split(" (")[0].to_lower()
 return int(lookup.get(key,-1))
static func decorate(button: Button, caption: String) -> void:
 var face: int = face_for_text(caption)
 if face>=0:
  button.icon = small_texture(face);button.add_theme_color_override("icon_normal_color",Color("e5dfd4"));button.add_theme_color_override("icon_disabled_color",Color("505056"));button.add_theme_constant_override("h_separation",6)
static func menu_symbol(kind: String) -> Texture2D:
 var key: String = kind if MENU.has(kind) else "oath"
 if not menu_glyphs.has(key):menu_glyphs[key] = cutout(MENU[key])
 return menu_glyphs[key]
