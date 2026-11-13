"""Direct combat and compact Soulcaster using real mouse/touch in an isolated fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/equipment-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_CLASSES_RESUME") else []
 for width,height in json.loads(os.environ.get('ASH_CLASSES_SIZES','[[390,844],[360,640],[844,390],[1440,900]]')):
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=2 if mobile else 1)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8952'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
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
  die='MobileDie' if mobile else 'BattleDie'
  def no_confirmation():assert not any(v['name']=='TrialConfirm' or v['text'] in ['Confirm','Confirm action'] for v in state()['controls']) and not state()['forecast']
  fixture('gear40_camp');d=state();assert d['memories']==['','',''];assert 'minimum 2 / maximum 5' in d['ui_text'];assert 'no Action Die' not in d['ui_text']
  select('MobileWeaponPicker' if mobile else 'Equipment_weapon',1);d=state();assert d['weapons'][0]=='spear';assert 'minimum 2 / maximum 6' in d['ui_text'];assert d['equipment_profile']['equipment.weapons'][0]=='spear';snap('equipment-weapon-limits')
  select('MobileWeaponPicker' if mobile else 'Equipment_weapon',3);d=state();assert d['weapons'][0]=='oathblade';assert '3 basic Strikes' in d['ui_text'] and 'ALL your Attack faces gain Pierce 1' in d['ui_text'];snap('unique-weapon-passive')
  fixture('gear40_poke');tap(name=die+'0');d=state();assert 3 not in d['preview']['targets'] and not d['used'][0][0]
  tap(name=die+'1');cell(3,3);assert state()['boss_hp']==11
  tap(name=die+'0');cell(3,3);d=state();assert d['boss_hp']==10 and d['used'][0][0] and d['used'][0][1];assert not any(v['name']=='DaggerPoke' for v in d['controls']);snap('rolled-poke')
  fixture('gear40_oathblade');tap(name=die+'0');cell(3,3);d=state();assert d['boss_hp']==11 and d['enemy_block']==1 and d['used'][0][0]
  tap(name=die+'1');cell(3,3);d=state();assert d['boss_hp']==10 and d['enemy_block']==1 and d['used'][0][1];snap('passive-on-other-attack')
  fixture('class37_lobby');d=state();assert d['trial']['memories']==['','',''] and d['trial']['max_hp']==[6,6,6];tap(name='TrialSlot_body');assert '0–2' in state()['ui_text'] and 'Attack limits come from your Weapon' in state()['ui_text']
  tap(name='TrialSlot_weapon');assert 'minimum 2 / maximum 6' in state()['ui_text'];snap('trial-equipment')
  fixture('gear40_trial_reward');tap(name='TrialRewardMemory');tap(name='TrialMemoryReward_first_step');d=state();assert d['trial']['stage']==1 and d['trial']['essence']==1 and d['trial']['memories'][0]=='first_step';snap('earned-memory')
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['normal equipment limits and 3-Strike unique Weapon','rolled Poke prerequisite and die spending','Attack passive on weapon and other Attack','Trial Soul HP and empty starting Memories','earned Memory after first encounter']};results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
