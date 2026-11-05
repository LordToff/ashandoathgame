"""Combat clarity and sound playback in isolated, nonshipping fixtures."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1';out=Path(__file__).resolve().parents[1]/'exports/clarity-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_CLARITY_RESUME") else []
 for width,height in json.loads(os.environ.get("ASH_CLARITY_SIZES","[[390,844],[360,640],[844,390],[1440,900]]")):
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},device_scale_factor=2 if mobile else 1,is_mobile=mobile,has_touch=mobile)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)));p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8912'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
  def state():p.evaluate('window.essenceProof("state")');return p.evaluate('JSON.parse(window.essenceState)')
  def fixture(mode,wait=280):p.evaluate('(m)=>window.essenceProof(m)',mode);p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');p.wait_for_timeout(wait)
  def snap(name):
   path=out/f'{width}x{height}-{name}.png';p.screenshot(path=str(path));return subprocess.check_output(['tesseract',str(path),'stdout'],stderr=subprocess.DEVNULL,text=True)
  def tap(name=None,text=None):
   for attempt in range(35):
    data=state();items=[v for v in data['controls'] if (v['name']==name if name else v['text']==text)];assert items,(name,text,data)
    node=items[-1];x=node['x']+node['w']/2;y=node['y']+node['h']/2;cx,cy,cw,ch=node['clip'];scale=width/data['viewport'][0]
    if cx<=x<=cx+cw and cy+3<=y<=cy+ch-3:
     assert not node['disabled'],node
     (p.touchscreen.tap if mobile else p.mouse.click)(x*scale,y*scale);p.wait_for_timeout(240);return
    if not mobile:p.mouse.move((cx+cw*.6)*scale,(cy+ch*.6)*scale);p.mouse.wheel(0,200 if y>cy+ch else -200);p.wait_for_timeout(250);continue
    sx=(cx+cw*.55)*scale;sy=(cy+ch*(.8 if y>cy+ch else .2))*scale;distance=min(75,max(22,ch*scale*.35));direction=-1 if y>cy+ch else 1
    session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':sx,'y':sy}]})
    for i in range(1,9):session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':sx,'y':sy+direction*distance*i/8}]});p.wait_for_timeout(65)
    session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]});p.wait_for_timeout(300)
   raise AssertionError(('unreachable',node))
  print('viewport',width,height,flush=True)
  fixture('clarity_intents');data=state();assert len(data['intents'])==3 and data['intents'][0]['policy']=='Lowest HP' and data['intents'][1]['policy']=='Furthest hero'
  text=snap('intents');assert 'Smoking' in text and 'Strike' in text and 'Lowest HP' in text,text;tap(text='Back');tap(name='EnemyIntent0' if mobile else 'EnemyIntentsButton');tap(text='Back')
  fixture('clarity_borrow');data=state();assert len([v for v in data['controls'] if v['name'].startswith('RolledChoice')])==9;assert not any(v['name'].startswith('ViewDie') for v in data['controls']);snap('borrow-nine-rolled')
  tap(name='RolledChoice1_0');text=snap('borrow-spent-guard');assert 'Guard' in text and 'Block' in text,text
  tap(text='Use');assert not state()['pending'] and state()['selected']==0;assert state()['results'][0][0]==4 and state()['used'][1][0]
  fixture('clarity_engrave');data=state();assert data['live_builds'][0][0].count(41)==2 and data['notices'][0]['faces'].count(41)==2
  text=snap('engrave-new-side');assert 'NEW SIDE' in text and 'Engrave' in text,text;tap(text='Continue')
  for mode,kind in [('clarity_poison','poison_tick'),('clarity_heal','heal'),('clarity_stun','stun')]:
   fixture(mode,0)
   proof=p.wait_for_function('(kind)=>{window.essenceProof("state");const s=JSON.parse(window.essenceState);return s.feedback_kind===kind && s.feedback_playing ? {kind:s.feedback_kind,playing:s.feedback_playing} : false;}',arg=kind,polling=20,timeout=6000).json_value()
   data=state();assert kind in data['effects'],data
   # Read model-backed AudioStreamPlayer during the actual generated SFX.
   assert proof['kind']==kind and proof['playing'],proof
   if kind=='poison_tick':assert not state()['notices'];p.wait_for_timeout(160)
   snap(kind)
  fixture('wilds_camp');p.wait_for_timeout(1200)
  if mobile:tap(name='MobileRecipe_mire_soul')
  text=snap('recipe-before-paying');assert 'Soul of the Mire' in text and ('Essence' in text),text
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['readable live named intents','persistent intent button','nine rolled face picker','spent face copy and confirmation','Engrave physical side and notice','Poison damage effect and actual audio playback','healing effect and actual audio playback','Stun effect and actual audio playback','free recipe preview']};results=[v for v in results if v['viewport']!=row['viewport']];results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
