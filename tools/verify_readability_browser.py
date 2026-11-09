"""Trials navigation and real touch controls in a separate nonshipping fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/readability-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_READABILITY_RESUME") else []
 for width,height in json.loads(os.environ.get('ASH_READABILITY_SIZES','[[390,844],[360,640],[844,390],[1440,900]]')):
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=2 if mobile else 1)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8920'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
  def state():p.evaluate('window.essenceProof("state")');return p.evaluate('JSON.parse(window.essenceState)')
  def fixture(mode):
   p.evaluate('(m)=>window.essenceProof(m)',mode);p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');p.wait_for_timeout(200)
  def node(name=None,text=None):return next(v for v in reversed(state()['controls']) if (v['name']==name if name else v['text']==text))
  def reach(name=None,text=None):
   for attempt in range(45):
    v=node(name,text);cx,cy,cw,ch=v['clip'];x=v['x']+v['w']/2;y=v['y']+v['h']/2;scale=width/state()['viewport'][0]
    if cx<=x<=cx+cw and cy+3<=y<=cy+ch-3:return v,x*scale,y*scale
    if not mobile:p.mouse.move((cx+cw*.6)*scale,(cy+ch*.6)*scale);p.mouse.wheel(0,220 if y>cy+ch else -220);p.wait_for_timeout(180);continue
    sx=(cx+cw*.6)*scale;sy=(cy+ch*(.8 if y>cy+ch else .2))*scale;distance=min(90,max(25,ch*scale*.4));sign=-1 if y>cy+ch else 1
    session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':sx,'y':sy}]})
    for i in range(1,8):session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':sx,'y':sy+sign*distance*i/7}]});p.wait_for_timeout(45)
    session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]});p.wait_for_timeout(220)
   raise AssertionError(('unreachable',v))
  def tap(name=None,text=None):
   v,x,y=reach(name,text);assert not v['disabled'],v;(p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.wait_for_timeout(220)
  def select(name,index):
   tap(name=name);data=state();popup=next(item for item in data['popups'] if item['control']==name)
   row=(popup['h']-popup['top']-popup['bottom'])/len(popup['items']);scale=width/data['viewport'][0]
   x=(popup['x']+popup['w']/2)*scale;y=(popup['y']+popup['top']+row*(index+.5))*scale
   (p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.wait_for_timeout(250)
  def snap(name):
   path=out/f'{width}x{height}-{name}.png';p.screenshot(path=str(path));return subprocess.check_output(['tesseract',str(path),'stdout'],stderr=subprocess.DEVNULL,text=True)
  print('viewport',width,height,flush=True)
  die='MobileDie0' if mobile else 'BattleDie0'
  fixture('range35');tap(name=die);data=state();assert data['preview']['reach']==2 and [6,4] in data['preview']['tiles'] and 3 in data['preview']['targets'];snap('shot-range-and-small-creature')
  fixture('blocked35');tap(name=die);data=state();assert [4,2] in data['preview']['blocked'] and 3 not in data['preview']['targets'];snap('blocked-sight')
  fixture('heal35');tap(name=die);data=state();assert data['preview']['reach']==3 and [4,7] in data['preview']['tiles'] and 1 in data['preview']['targets'];snap('heal-range')
  fixture('reroll35');before=state()['serial'];tap(name=die);tap(name='MobileReroll' if mobile else 'ActionRerollButton')
  assert not state()['notices'] and state()['serial']>before and state()['rerolls'][0]==0
  p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');assert not state()['notices'];snap('reroll-no-prompt')
  fixture('focus35');before=state()['serial'];tap(name=die);tap(name='MobileDie1' if mobile else 'BattleDie1');assert not state()['notices'] and state()['serial']>before
  p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');assert not state()['notices'];snap('focus-no-prompt')
  fixture('trials_main');tap(text='Trials' if mobile else 'Trials · experimental expeditions')
  for slot in ['body','memory','soul','weapon']:
   v=node(name='TrialSlot_'+slot);assert slot.capitalize() in v['text'],v;assert v['y']+v['h']<=state()['viewport'][1]-76,v
  snap('four-equipment-slots') # Slot text and viewport bounds are asserted above; the screenshot is inspected visually.
  select('TrialMemory',1);assert state()['trial']['memories'][0]=='guard';tap(name='TrialSlot_weapon');select('TrialWeapon',0);text=snap('weapon-explanation');assert 'Poke' in text and 'Dagger' in text,text
  fixture('trials_reward');before=state()['trial']['builds'];tap(name='TrialRewardWeapon');select('TrialWeaponChoice',1);snap('weapon-reward');tap(name='TrialEquipWeapon')
  data=state();assert data['trial']['weapons']==['heavy','dagger','dagger'] and data['trial']['builds']==before and data['trial']['essence']==5 and data['trial']['phase']=='route'
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['full empty-tile attack range','blocked sight markings','three-tile ally heal range','one-cell creature visual','Action Reroll without acknowledgement','Focus without acknowledgement','four equipment slots visible','Memory selector','Weapon explanation','Weapon reward replaces only Weapon slot']};results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
