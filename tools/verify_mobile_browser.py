"""Touch-test the isolated fixture (never shipped) at phone sizes and after rotation."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/mobile-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=[]
 for width,height in json.loads(os.environ.get('ASH_MOBILE_VIEWPORTS','[[390,844],[360,640],[844,390]]')):
  c=b.new_context(viewport={'width':width,'height':height},is_mobile=True,has_touch=True,device_scale_factor=2)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8909'));p.wait_for_timeout(6000);p.wait_for_function('typeof window.essenceProof === "function"')
  session=c.new_cdp_session(p)
  def state():p.evaluate('window.essenceProof("state")');return p.evaluate('JSON.parse(window.essenceState)')
  def fixture(mode):
   p.evaluate('(m)=>window.essenceProof(m)',mode);p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');p.wait_for_timeout(350)
  def swipe(x,y,up=True,distance=90):
   session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':x,'y':y}]})
   for i in range(1,9):
    session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':x,'y':y+(-1 if up else 1)*i*distance/8}]});p.wait_for_timeout(70)
   session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]});p.wait_for_timeout(400)
  def tap(name=None,text=None):
   print("tap",name or text,flush=True)
   for attempt in range(45):
    data=state();items=[v for v in data['controls'] if (v['name']==name if name else v['text']==text)]
    assert items,(name,text,data)
    node=items[-1];x=node['x']+node['w']/2;y=node['y']+node['h']/2;cx,cy,cw,ch=node['clip'];scale=p.viewport_size['width']/data['viewport'][0]
    if cx <= x <= cx+cw and cy+5 <= y <= cy+ch-5:
     assert not node['disabled'],node
     p.touchscreen.tap(x*scale,y*scale);p.wait_for_timeout(300);return
    # Swipe in the enclosing scroll panel; no programmatic scroll or button signals.
    sx=(cx+cw*.55)*scale;sy=(cy+ch*(.8 if y>cy+ch else .2))*scale
    swipe(sx,sy,y>cy+ch,min(90,max(22,ch*scale*.35)))
   raise AssertionError(('could not reach',node))
  print('viewport',width,height,flush=True)
  assert state()['mobile']
  if width==390:
   fixture('mobile_main');tap(name='MobilePlay');tap(name='MobileGift9');tap(name='MobileGift10')
   tap(text='Next hero');tap(name='MobileGift9');tap(name='MobileGift10');tap(text='Next hero');tap(name='MobileGift9');tap(name='MobileGift10');tap(text='Fight / review')
   print('draft complete',flush=True)
   assert state()['page']=='setup'
   tap(text='Begin expedition');tap(name='MobileRollEvent');p.wait_for_timeout(1600);tap(name='MobileEventChoice0');tap(name='MobileEnterBoss');p.wait_for_timeout(1900);assert state()['page']=='battle'
  print('boss entered',flush=True)
  fixture('mobile_move');tap(name='MobileDie0')
  data=state();vw,vh=data['viewport'];edge=min(vh-104,vw*.52) if vw>vh else vw-16;bx,by=(8,98) if vw>vh else (8,174)
  # Cell 0,6 -> desktop center 78,638 -> mobile board coordinates.
  scale=p.viewport_size['width']/vw;p.touchscreen.tap((bx+(78-24)*edge/716)*scale,(by+(638-128)*edge/716)*scale);p.wait_for_timeout(300)
  assert state()['positions'][0]==[0,6] and state()['used'][0][0],state()
  tap(name='MobileDetails');tap(text='Back');tap(name='MobileReroll');tap(name='MobileDie1');p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');p.wait_for_timeout(350)
  assert state()['rolling']==False
  # Reroll result acknowledgement closes the mandatory notice.
  data=state();labels=[v['text'] for v in data['controls']]
  if 'Continue' in labels:tap(text='Continue')
  p.screenshot(path=str(out/f'{width}x{height}-combat.png'))
  fixture('soul_block');tap(name='MobileDie0');tap(name='MobileResolve');assert state()['block'][0]==2
  fixture('soul_heal');tap(name='MobileDie0');tap(name='MobileResolve');assert state()['hp'][0]==4
  fixture('equipment_all');tap(name='MobileSoulPicker');p.screenshot(path=str(out/f'{width}x{height}-equipment-picker.png'));p.keyboard.press('Escape')
  fixture('evasive');p.screenshot(path=str(out/f'{width}x{height}-reaction.png'));ocr=subprocess.check_output(['tesseract',str(out/f'{width}x{height}-reaction.png'),'stdout'],stderr=subprocess.DEVNULL,text=True);assert 'can react' in ' '.join(ocr.split()) and 'incoming damage' in ' '.join(ocr.split()),ocr
  # Actual reaction choice through the adapted panel.
  labels=[v['text'] for v in state()['controls']];reaction=next(v for v in labels if 'Evasive' in v and 'Use' in v)
  tap(text=reaction)
  fixture('wilds_cards');p.screenshot(path=str(out/f'{width}x{height}-enemy-cards.png'))
  fixture('mobile_move');tap(text='Full log');p.screenshot(path=str(out/f'{width}x{height}-full-log.png'));tap(text='Back to battle')
  if width<height:
   p.set_viewport_size({'width':height,'height':width});p.wait_for_timeout(600);data=state();assert data['viewport'][0]>data['viewport'][1];assert data['positions'][0]==[0,7]
   p.screenshot(path=str(out/f'{width}x{height}-rotated.png'))
  fixture('mobile_main');tap(name='MobileDesktopMode');assert not state()['mobile'];p.reload();p.wait_for_timeout(5500);assert not state()['mobile']
  assert not errors,errors
  results.append({'viewport':[width,height],'result':'passed','browser_errors':errors});(out/f'{width}x{height}-results.json').write_text(json.dumps(results[-1],indent=2));c.close()
 report={'result':'passed','devices':results,'tested':['touch draft with scroll','required event into boss','tap board movement','ability details','reroll selection and notice','Blank Block/healing','equipment popup','reaction modal','enemy cards','full log','rotation preserves battle','desktop preference persists']}
 (out/'results.json').write_text(json.dumps(report,indent=2));print(json.dumps(report));b.close()
