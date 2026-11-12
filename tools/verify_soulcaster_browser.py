"""Trials navigation and real touch controls in a separate nonshipping fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/soulcaster-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_CLASSES_RESUME") else []
 for width,height in json.loads(os.environ.get('ASH_CLASSES_SIZES','[[390,844],[360,640],[844,390],[1440,900]]')):
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=2 if mobile else 1)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8948'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
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
  fixture('soul38_lobby');data=state();assert data['trial']['souls'][0]=='soulcaster' and data['trial']['max_hp'][0]==6
  snap('soulcaster-equipped');tap(name='TrialSoulcasterHelp');tap(name='TrialSpellbook');assert state()['soul_help'];tap(name='SoulSpell79');snap('omen-spell-help');tap(text='Back');tap(text='Back')
  select('TrialSoul',0);assert state()['trial']['souls'][0]=='';select('TrialSoul',1);assert state()['trial']['souls'][0]=='soulcaster'
  p.reload();p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');tap(text='Trials' if mobile else 'Trials · experimental expeditions');assert state()['trial']['souls'][0]=='soulcaster'
  fixture('soul38_blank');die='MobileDie' if mobile else 'BattleDie'
  tap(name=die+'0');tap(name='MobileResolve' if mobile else None,text=None if mobile else 'Resolve selected face');assert state()['pending']['kind']=='soul_blank'
  assert not node(name='SoulcasterManifest')['disabled'];tap(name='SoulSpell80');snap('create-fatebreaker');tap(text='Create spell')
  data=state();assert data['live_builds'][0][0][2]==80 and data['hp'][0]==5 and data['soul_charges'][0]==0 and data['used'][0][0] and data['effective'][0][0]==0
  fixture('soul38_blank');tap(name=die+'0');tap(name='MobileResolve' if mobile else None,text=None if mobile else 'Resolve selected face');tap(text='Gather +1');assert state()['soul_charges'][0]==3 and state()['used'][0][0]
  fixture('soul38_harvest');tap(name=die+'0');assert 3 in state()['preview']['targets'];cell(3,4);assert 'Soul Charge' in state()['forecast']['forecast']['text'];snap('harvester-target');confirm();assert state()['soul_charges'][0]==1 and state()['used'][0][0]
  fixture('soul38_wraith');tap(name=die+'0');cell(3,5);confirm();assert state()['pending']['kind']=='soul_steps';snap('wraith-optional-step');tap(name='WraithStep4');tap(name='WraithStep4');assert not state()['pending']
  fixture('soul38_fate');assert state()['pending']['kind']=='soul_fate';snap('fate-enemy-choice');tap(name='FateEnemy4_0');assert not state()['pending'] and '4:0' in state()['terrain']['fate_used']
  fixture('soul38_omen');assert node(name='OmenDie1')['disabled'] and node(name='OmenDie2')['disabled'];snap('omen-storage');tap(name='OmenDie0');assert state()['used'][0][0] and state()['terrain']
  fixture('soul38_reward');snap('legal-reward-preview');assert any(v['text']=='Buy · 2' and v['disabled'] for v in state()['controls'])
  before=state()['trial']['essence'];tap(name='TrialSlot2');assert state()['trial']['essence']==before and any(v['text']=='Buy · 2' and v['disabled'] for v in state()['controls'])
  fixture('class37_main');tap(text='Trials' if mobile else 'Trials · experimental expeditions');tap(name='TrialClassOverview');tap(name='TrialClass_vanguard');tap(text='Use Vanguard');assert state()['trial']['classes'][0]=='vanguard'
  snap('existing-classes');assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['free starter Soul and persistence','actual starter dice and spellbook','six spell costs and preview','Manifest later-turn restriction','Gather and charges','Harvester range and confirmation','Wraith optional steps','real secondary-enemy Fate reroll','held original Omen die','read-only reward preview','existing classes']}
  results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
