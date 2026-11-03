"""Assemble licensed human-authored 16px sprites, with explicit palette variants.
Source: Kenney Tiny Dungeon 1.0 (CC0), preserved with licence and provenance.
No image generation, synthesis, painted shapes, filters or downsampling.
"""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'prototype/assets'
SOURCE=OUT/'vendor/kenney_tiny_dungeon/tilemap_packed.png'

def rgb(hex_value):return tuple(bytes.fromhex(hex_value.lstrip('#')))
def tile(sheet,x,y,palette=None):
 im=sheet.crop((x*16,y*16,x*16+16,y*16+16)).convert('RGBA')
 mapping={rgb(a):rgb(b) for a,b in (palette or {}).items()}
 mapping[rgb('#3f2631')]=rgb('#101923')  # Match the game's existing dark outline.
 pixels=im.load()
 for py in range(16):
  for px in range(16):
   r,g,b,a=pixels[px,py]
   if a and (r,g,b) in mapping:pixels[px,py]=(*mapping[r,g,b],a)
 return im

def build():
 sheet=Image.open(SOURCE)
 # Coordinates refer to the unmodified 12-column source sheet. Existing pixel
 # silhouettes are reused verbatim; only these colour substitutions are applied.
 enemies=[
  tile(sheet,0,9,{'#43e1b3':'#6e9f50','#69ffd4':'#b1ca73','#25956a':'#3e6539'}), # slime/spirit -> Mire Leech
  tile(sheet,0,10,{'#bd6c4a':'#70a5bf','#eaa56c':'#acd8da','#763b36':'#443e66','#ffffff':'#f1d38e'}), # winged creature -> Moth
  tile(sheet,0,8,{'#8b9bb4':'#79808d','#c0cbdc':'#b4b4a4','#52607c':'#4e4e60','#bd6c4a':'#b27c50'}), # armoured creature -> Husk
 ]
 items=[
  tile(sheet,0,9,{'#43e1b3':'#5eafbf','#69ffd4':'#a4e6d4','#25956a':'#326b83'}), # Beginning spirit
  tile(sheet,1,10,{'#c0cbdc':'#dad5bd','#8b9bb4':'#8d7d9c'}), # Hollow mask
  tile(sheet,0,9,{'#43e1b3':'#cf8a50','#69ffd4':'#f0c979','#25956a':'#875035'}), # Ash Road spirit
  tile(sheet,5,8,{'#bd6c4a':'#70a6bd','#c0cbdc':'#c3d3d6','#8b9bb4':'#677d99'}), # Memory medallion
 ]
 rewards=[
  tile(sheet,0,9,{'#43e1b3':'#52ab61','#69ffd4':'#94d97a','#25956a':'#286346'}), # Mire spirit
  tile(sheet,0,10,{'#bd6c4a':'#9879bc','#eaa56c':'#c4b5df','#763b36':'#514066'}), # Glasswing spirit
  tile(sheet,6,8), # Ironbound shield
 ]
 atlas=Image.new('RGBA',(64,16))
 for i,im in enumerate(items):atlas.paste(im,(i*16,0))
 atlas.save(OUT/'souls_memory_sheet.png')
 atlas=Image.new('RGBA',(48,32))
 for row,group in enumerate([enemies,rewards]):
  for col,im in enumerate(group):atlas.paste(im,(col*16,row*16))
 atlas.save(OUT/'wilds_sheet.png')
 for row,names in enumerate([['mire_leech','glasswing_moth','iron_husk'],['mire_soul','glasswing_soul','iron_soul']]):
  for col,name in enumerate(names):
   (OUT/(name+'.tres')).write_text('[gd_resource type="AtlasTexture" load_steps=2 format=3]\n\n[ext_resource type="Texture2D" path="res://prototype/assets/wilds_sheet.png" id="1"]\n\n[resource]\natlas = ExtResource("1")\nregion = Rect2(%d, %d, 16, 16)\n' % (col*16,row*16))
 for im in enemies+items+rewards:
  assert set(im.getchannel('A').tobytes()) <= {0,255}
  assert len([c for n,c in im.getcolors() if c[3]]) <= 16
 preview=Image.new('RGBA',(112,44),'#19232e')
 for i,im in enumerate(enemies):preview.paste(im,(i*32,0),im)
 for i,im in enumerate(items+rewards):preview.paste(im,(i*16,28),im)
 (ROOT/'exports').mkdir(exist_ok=True)
 preview.resize((896,352),Image.Resampling.NEAREST).save(ROOT/'exports/retro-sprite-preview.png')
 print('Assembled 3 enemies and 7 items from Kenney CC0 16x16 tiles; hard alpha, small palettes, no image synthesis.')
if __name__=='__main__':build()
