"""Trials navigation and real touch controls in a separate nonshipping fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/trials-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_TRIAL_RESUME") else []
 for width,height in json.loads(os.environ.get('ASH_TRIAL_SIZES','[[390,844],[360,640],[844,390],[1440,900]]')):
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=2 if mobile else 1)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8917'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
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
   v,x,y=reach(name,text);p.wait_for_timeout(750 if mobile else 120);v,x,y=reach(name,text);assert not v['disabled'],v;(p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.wait_for_timeout(220)
  def select(name,index):
   tap(name=name);data=state();popup=next(item for item in data['popups'] if item['control']==name)
   row=(popup['h']-popup['top']-popup['bottom'])/len(popup['items']);scale=width/data['viewport'][0]
   x=(popup['x']+popup['w']/2)*scale;y=(popup['y']+popup['top']+row*(index+.5))*scale
   (p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.wait_for_timeout(250)
  def snap(name):
   path=out/f'{width}x{height}-{name}.png';p.screenshot(path=str(path));return subprocess.check_output(['tesseract',str(path),'stdout'],stderr=subprocess.DEVNULL,text=True)
  print('viewport',width,height,flush=True)
  fixture('trials_main');normal=state();tap(text='Trials' if mobile else 'Trials · experimental expeditions')
  assert state()['page']=='trials' and state()['trial']['phase']=='lobby';snap('lobby')
  select('TrialMemory',1);assert state()['trial']['memories'][0]=='guard';select('TrialMemory',0)
  select('TrialBoss',2);assert 'Veyl' in node(name='TrialBoss')['text'];select('TrialBoss',0)
  tap(name='TrialPreview');text=snap('field-guide');assert 'Venom' in text or 'Iron vow' in text,text;tap(text='Back')
  tap(text='Begin Trial');assert state()['trial']['phase']=='route' and state()['trial']['stage']==0;snap('route')
  tap(name='TrialRoute0');p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');assert state()['page']=='battle' and state()['trial']['fight']
  assert state()['builds']==normal['builds'] and state()['bank']==normal['bank']
  if mobile:
   end=node(name='MobileEndTurn' if state()['active']<3 else 'MobileEnemyStep');assert end['y']+end['h']<=state()['viewport'][1]
   tap(name='MobileMore');tap(text='Equipment & arena help');snap('combat-guide');tap(text='Back')
   tap(name='MobileMore');tap(text='Menu');tap(text='Main menu · leave Trial')
  else:
   tap(text='Menu');tap(text='Equipment & arena help');snap('combat-guide');tap(text='Back');tap(text='Menu');tap(text='Main menu · leave Trial')
  assert state()['page']=='main' and state()['trial']['phase']=='failed' and state()['bank']==normal['bank']
  fixture('trials_crates');tap(name='MobileDie0' if mobile else 'BattleDie0')
  d=state();bx,by,edge,_=d['board'];scale=width/d['viewport'][0]
  if mobile:x=(bx+(40+2.5*76-24)*edge/716)*scale;y=(by+(144+5.5*76-128)*edge/716)*scale
  else:x=40+2.5*76;y=144+5.5*76
  (p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.wait_for_timeout(250)
  assert state()['forecast'] and len(state()['terrain']['crates'])==2 and not state()['used'][0][0]
  tap(name='MobileResolve' if mobile else 'TrialConfirm')
  assert len(state()['terrain']['crates'])==1 and state()['used'][0][0];snap('broken-barricade')
  fixture('trials_charge');snap('charge-warning');assert len(state()['terrain']['charges'][0]['tiles'])==3
  fixture('trials_reward');tap(name='TrialRewardFace');assert state()['trial']['phase']=='reward'
  tap(name='TrialSlot4');assert state()['trial']['phase']=='reward' and state()['trial']['essence']==7
  select('TrialRewardChoice',2);tap(name='TrialSlot0');d=state();assert d['trial']['phase']=='route' and d['trial']['builds'][0][0][0]==69 and d['trial']['essence']==5
  fixture('trials_reward');tap(name='TrialRewardWeapon');select('TrialWeaponChoice',1);tap(name='TrialEquipWeapon');assert state()['trial']['weapons'][0]=='heavy' and state()['trial']['phase']=='route'
  fixture('trials_win');assert state()['trial']['phase']=='reward' and state()['bank']==normal['bank'];snap('victory');tap(text='Continue');assert state()['page']=='trials';tap(text='Take +2 Essence');assert state()['trial']['stage']==1
  tap(name='TrialRoute0');tap(name='TrialRest');assert state()['trial']['stage']==2;snap('camp-and-route')
  # A safe checkpoint restores through the normal game save, not fixture editing.
  p.reload();p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');tap(text='Trials' if mobile else 'Trials · experimental expeditions');assert state()['trial']['stage']==2 and state()['trial']['phase']=='route'
  fixture('trials_boss_win');assert state()['trial']['completed']==['hollow'];tap(text='Continue');text=snap('boss-soul');assert 'Cinder Soul' in text,text
  tap(text='New Trial');assert state()['trial']['phase']=='lobby';tap(name='TrialSlot_soul');select('TrialSoul',1);assert state()['trial']['souls'][0]=='hollow';snap('equipped-boss-soul')
  if width in [390,1440]:
   fixture('trials_debug');v,x,y=reach(name='TrialSoulCard_bugh');p.wait_for_timeout(800);v,x,y=reach(name='TrialSoulCard_bugh')
   if mobile:session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':x,'y':y}]})
   else:p.mouse.move(x,y);p.mouse.down()
   p.wait_for_timeout(1400)
   if mobile:session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]})
   else:p.mouse.up()
   p.wait_for_timeout(250);assert state()['trial']['completed']==['bugh'] and state()['bank']==normal['bank']
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['main-menu Trials entry','Memory slot and boss selection','field guide','actual route to combat','fixed combat controls','separate ordinary builds and bank','abandon fight','touch/click barricade breaking','charge lane display','illegal Blank replacement refused','paid face replacement','paid Weapon slot replacement','victory reward and Camp route','safe checkpoint reload','boss Soul unlock and equipment']};
  if width in [390,1440]:row['tested'].append('gated Trial Soul Debug hold')
  results=[old for old in results if old["viewport"]!=row["viewport"]];results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
