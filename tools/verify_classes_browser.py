"""Trials navigation and real touch controls in a separate nonshipping fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/classes-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_CLASSES_RESUME") else []
 for width,height in json.loads(os.environ.get('ASH_CLASSES_SIZES','[[390,844],[360,640],[844,390],[1440,900]]')):
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=2 if mobile else 1)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8940'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
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
  def cell(x,y):
   data=state();scale=width/data['viewport'][0];px,py=40+(x+.5)*76,144+(y+.5)*76
   if mobile:
    bx,by,bw,bh=data['board'];px=bx+(px-24)*bw/716;py=by+(py-128)*bh/716
   (p.touchscreen.tap if mobile else p.mouse.click)(px*scale,py*scale);p.wait_for_timeout(300)
  def confirm():tap(name='MobileResolve' if mobile else 'TrialConfirm')
  print('viewport',width,height,flush=True)
  fixture('class37_main');normal=state();tap(text='Trials' if mobile else 'Trials · experimental expeditions')
  data=state();assert data['trial']['classes']==['skirmisher','vanguard','skirmisher'] and data['trial']['max_hp']==[4,6,4]
  for slot in ['body','memory','soul','weapon']:
   v=node(name='TrialSlot_'+slot);assert v['y']+v['h']<=data['viewport'][1]-76,v
  snap('lobby-classes')
  tap(name='TrialClassOverview');assert node(name='TrialClass_skirmisher') and node(name='TrialClass_vanguard')
  before=state()['trial']['classes'];tap(name='TrialClass_vanguard');assert state()['trial']['classes']==before
  assert node(name='TrialClassFace0')['text']=='Crack' and node(name='TrialClassFace3')['text']=='Strike'
  tap(name='TrialClassFace0');assert 'remove up to 2 Block' in state()['info'] and 'No HP damage' in state()['info'];snap('crack-face-description');tap(text='Back')
  tap(name='TrialClassDie1');assert node(name='TrialClassFace0')['text']=='Strike Numeric' and node(name='TrialClassFace1')['text']=='Strike';snap('vanguard-retained-attacks')
  tap(name='TrialClassExample');assert 'another rolled Attack' in state()['info'] and 'Beginning Soul' in state()['info'];snap('vanguard-example');tap(text='Back')
  tap(text='Use Vanguard');data=state();assert data['trial']['classes']==['vanguard','vanguard','skirmisher'] and data['trial']['max_hp']==[6,6,4]
  assert data['trial']['bodies']==['stone','stone','fleet'] and data['trial']['loadout_weapons']==['hammer','hammer','spear'] and not data['trial']['crafted']
  snap('equipped-vanguard')
  p.reload();p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');tap(text='Trials' if mobile else 'Trials · experimental expeditions')
  assert state()['trial']['classes']==['vanguard','vanguard','skirmisher'] and state()['trial']['bodies']==['stone','stone','fleet']
  tap(name='TrialHero2');tap(name='TrialClassOverview');tap(name='TrialClass_skirmisher');tap(name='TrialClassDie1')
  tap(name='TrialClassFace0');assert '2 spaces' in state()['info'];snap('fleet-step-description');tap(text='Back')
  tap(text='Use Skirmisher');tap(text='Begin Trial');data=state();assert data['trial']['phase']=='route'
  # Class-specific combat uses actual class starter sides, then real tap/confirm actions.
  fixture('class37_skirmisher');data=state();assert data['hp'][0]==4 and data['effective'][0][0]==73 and data['effective'][0][1]==2
  die='MobileDie' if mobile else 'BattleDie'
  tap(name=die+'0');assert 3 not in state()['preview']['targets']
  tap(name=die+'1');cell(3,5);assert state()['forecast'] and state()['positions'][0]==[3,7];confirm()
  assert state()['positions'][0]==[3,5] and state()['used'][0][1]
  tap(name=die+'0');cell(3,4);assert '2 HP damage' in state()['forecast']['forecast']['text'];snap('skirmisher-jab-preview')
  confirm();assert state()['boss_hp']==8 and state()['used'][0][0];snap('skirmisher-jab-resolved')
  fixture('class37_vanguard');assert state()['hp'][0]==6 and state()['effective'][0][:2]==[74,1]
  tap(name=die+'0');assert 3 not in state()['preview']['targets']
  tap(name=die+'1');cell(3,4);confirm();assert state()['enemy_block']==2 and state()['boss_hp']==10
  tap(name=die+'0');cell(3,4);assert '2 Block removed' in state()['forecast']['forecast']['text'];snap('vanguard-crack-preview')
  confirm();data=state();assert data['enemy_block']==0 and data['boss_hp']==10 and data['used'][0][0]
  snap('vanguard-crack-resolved');assert data['bank']==normal['bank'] and data['builds']==normal['builds'] and not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['two class choices per hero','four equipment slots remain visible','class preview does not apply before Use','Crack and retained Strike on starter dice','face and turn explanations','free starting class equipment','per-hero choices and safe reload','Fleet Step description','classed Trial start','real Step then Jab with Momentum','real Attack then Crack','die consumption and conditional targets','normal collection preserved']}
  results=[old for old in results if old['viewport']!=row['viewport']];results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
