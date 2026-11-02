"""Original 16px placeholder creatures; geometric pixels, no external artwork."""
from pathlib import Path
from PIL import Image,ImageDraw
out=Path(__file__).resolve().parents[1]/'prototype/assets'
for name,color in [('bone_creature','#e4d8b2'),('support_creature','#c7a2df'),('movement_creature','#79cbb4')]:
 im=Image.new('RGBA',(32,16));d=ImageDraw.Draw(im)
 for f in range(2):
  x=f*16
  def rect(box,fill):d.rectangle((box[0]+x,box[1],box[2]+x,box[3]),fill=fill)
  if name=='bone_creature':
   rect((4,2,11,7),color);rect((3,3,12,5),color);rect((5,4,6,5),'#27313c');rect((9,4,10,5),'#27313c');rect((7,8,8,12),color)
   for y in [9,11]:rect((4,y,11,y),color)
   rect((3,12+f,5,14),color);rect((10,12,12,14-f),color)
  elif name=='support_creature':
   rect((5,2,10,3),color);rect((3,4,12,11),color);rect((4,12,11,13),'#73588c');rect((5,5,10,8),'#303442');rect((6,6,6,6),'#f1d596');rect((9,6,9,6),'#f1d596');rect((0,8+f,2,11+f),color);rect((13,8-f,15,11-f),color);rect((6,10,9,11),'#84d3b2')
  else:
   rect((6,3,13,8),color);rect((9,2,12,2),color);rect((11,4,12,5),'#202e3c');rect((2,7,8,10),color);rect((1,9,3,12),'#499e95');rect((5,11,6,14-f),color);rect((11,9,12,13+f),color);rect((12,13+f,15,13+f),color)
 im.save(out/(name+'.png'))
