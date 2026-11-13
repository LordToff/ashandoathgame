"""Extract 0x72's original CC0 idle/run frames. No generated art or resampling.
Source archive, licences and artist's explicit No-generative-AI statement are vendored.
"""
from pathlib import Path
from PIL import Image
import zipfile,json,hashlib
ROOT=Path(__file__).resolve().parents[1];vendor=ROOT/'prototype/assets/vendor/dungeon_tileset_ii';out=ROOT/'prototype/assets/enemies';out.mkdir(exist_ok=True)
z=zipfile.ZipFile(vendor/'0x72_DungeonTilesetII_v1.7.zip');prefix='0x72_DungeonTilesetII_v1.7/frames/'
from io import BytesIO
def read(name):return Image.open(BytesIO(z.read(prefix+name+'.png'))).convert('RGBA')
selections={'bone_creature':'skelet','support_creature':'necromancer','movement_creature':'imp','mire_leech':'slug','glasswing_moth':'angel','iron_husk':'orc_warrior','shield':'masked_orc','healer':'orc_shaman','ram':'chort','thief':'goblin','archer':'skelet','hollow':'big_demon','nugh':'ogre','cantor':'necromancer','bugh':'knight_f','worm':'slug','mite':'imp','cocoon':'muddy'}
info={}
for key,actor in selections.items():
 frames=[]
 for action in ['idle','run']:
  for i in range(4):
   name=f'{actor}_{action}_anim_f{i}'
   if prefix+name+'.png' not in z.namelist():name=f'{actor}_anim_f{i}'
   im=read(name);box=im.getbbox();im=im.crop(box)
   cell=Image.new('RGBA',(32,32));cell.alpha_composite(im,((32-im.width)//2,31-im.height))
   if key=='archer':cell.alpha_composite(read('weapon_bow'),(22,15))
   frames.append((cell,name))
 union=Image.new('RGBA',(32,32))
 for im,_ in frames:union.alpha_composite(im)
 box=union.getbbox();atlas=Image.new('RGBA',(128,64))
 for i,(im,_) in enumerate(frames):atlas.alpha_composite(im,((i%4)*32,(i//4)*32))
 atlas.save(out/(key+'.png'))
 x,y,r,b=box;w,h=r-x,b-y
 (out/(key+'.tres')).write_text(f'[gd_resource type="AtlasTexture" load_steps=2 format=3]\n\n[ext_resource type="Texture2D" path="res://prototype/assets/enemies/{key}.png" id="1"]\n\n[resource]\natlas = ExtResource("1")\nregion = Rect2({x}, {y}, {w}, {h})\n')
 info[key]={'source':actor,'original_frames':[name+'.png' for _,name in frames],'region':[x,y,w,h],'sha256':hashlib.sha256((out/(key+'.png')).read_bytes()).hexdigest()}
(vendor/'SELECTIONS.json').write_text(json.dumps(info,indent=2)+'\n')
lines=['extends RefCounted','## Original pixel frames by 0x72, CC0. See vendor/dungeon_tileset_ii/SOURCE.md.','const STILLS = {']
lines += [f' "{key}":preload("res://prototype/assets/enemies/{key}.tres"),' for key in info];lines+=['}','static var frames: Dictionary = {}','static func texture(key: String, seconds: float = 0, moving: bool = false) -> Texture2D:',' if not STILLS.has(key):key = "bone_creature"',' var index: int = int(seconds*(10 if moving else 5))%4+(4 if moving else 0)',' var cache: String = key+str(index)',' if not frames.has(cache):','  var still: AtlasTexture = STILLS[key];var frame := AtlasTexture.new();frame.atlas = still.atlas','  frame.region = Rect2(still.region.position+Vector2((index%4)*32,(index/4)*32),still.region.size);frames[cache] = frame',' return frames[cache]','static func key_for(g, id: int) -> String:',' if id==3 and g.encounter_id!="event":return g.encounter_id',' var unit: Dictionary = g.unit_data(id)',' if unit.has("trial_role"):return str(unit.trial_role)',' if g.friendly(id):return "worm"',' if g.encounter_id=="event":return g.essence_type(id)',' return "cocoon" if unit.get("kind","")=="cocoon" else "mite" if unit.get("kind","")=="mite" else "worm"','static func draw(app, key: String, foot: Vector2, seconds: float, moving: bool = false, boss: bool = false) -> void:',' var sprite: Texture2D = texture(key,seconds,moving)',' var zoom: int = (4 if sprite.get_height()>24 else 5) if boss else (2 if sprite.get_height()>24 else 3)',' var size: Vector2 = sprite.get_size()*zoom',' app.draw_texture_rect(sprite,Rect2((foot-Vector2(size.x/2,size.y)).round(),size),false)']
(ROOT/'prototype/enemy_art.gd').write_text('\n'.join(lines)+'\n')
print('Extracted',len(info),'original animated sprites')
