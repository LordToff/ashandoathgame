"""Shared menu journeys and safe previews with real mouse/touch in an isolated fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/menus-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_CLASSES_RESUME") else []
 for width,height in json.loads(os.environ.get('ASH_CLASSES_SIZES','[[390,844],[360,640],[844,390],[1440,900]]')):
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=1)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8952'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
  def state():p.evaluate('window.essenceProof("state")');return p.evaluate('JSON.parse(window.essenceState)')
  def fixture(mode):
   p.evaluate('(m)=>window.essenceProof(m)',mode);p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');p.wait_for_timeout(200)
  def node(name=None,text=None):
   data=state();matches=[v for v in reversed(data['controls']) if (v['name']==name if name else v['text']==text)]
   if not matches:
    (out/f'{width}x{height}-failure.json').write_text(json.dumps(data,indent=2));p.screenshot(path=str(out/f'{width}x{height}-failure.png'));raise AssertionError(('missing control',name,text,data['ui_text']))
   return matches[0]
  def reach(name=None,text=None):
   for attempt in range(45):
    v=node(name,text);cx,cy,cw,ch=v['clip'];x=v['x']+v['w']/2;y=v['y']+v['h']/2;scale=width/state()['viewport'][0]
    if cx<=x<=cx+cw and cy+3<=y<=cy+ch-3:
     p.wait_for_timeout(250);stable=node(name,text)
     if abs(stable['y']-v['y'])>1:continue
     return stable,(stable['x']+stable['w']/2)*scale,(stable['y']+stable['h']/2)*scale
    if not mobile:p.mouse.move((cx+cw*.6)*scale,(cy+ch*.6)*scale);p.mouse.wheel(0,220 if y>cy+ch else -220);p.wait_for_timeout(180);continue
    sx=(cx+cw*.6)*scale;sy=(cy+ch*(.8 if y>cy+ch else .2))*scale;distance=min(90,max(25,ch*scale*.4));sign=-1 if y>cy+ch else 1
    session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':sx,'y':sy}]})
    for i in range(1,8):session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':sx,'y':sy+sign*distance*i/7}]});p.wait_for_timeout(45)
    # Stop the gesture before lifting, so native kinetic scrolling cannot
    # carry the target past the tap while automation is measuring it.
    p.wait_for_timeout(200);session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':sx,'y':sy+sign*distance}]})
    p.wait_for_timeout(120);session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]});p.wait_for_timeout(350)
   raise AssertionError(('unreachable',v))
  def tap(name=None,text=None):
   p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}')
   v,x,y=reach(name,text);p.wait_for_timeout(750 if mobile else 120);v,x,y=reach(name,text);assert not v['disabled'],v;(p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.wait_for_timeout(220)
  def select(name,index):
   tap(name=name)
   p.wait_for_function('(name)=>{window.essenceProof("state");return JSON.parse(window.essenceState).popups.some(p=>p.control===name)}',arg=name)
   data=state();popup=next(item for item in data['popups'] if item['control']==name)
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
  fixture('menu43_main');snap('main');tap(name='MobilePlay' if mobile else 'MainPlay');assert state()['page']=='normal'
  tap(name='NormalPrepareAll');d=state();assert all(len(g)==2 for g in d['gifts']);normal_builds=d['builds'];normal_bank=d['bank'];snap('normal-party')
  tap(text='Next: choose boss');tap(name='EncounterNugh');snap('boss-choice');tap(text='Next: road event');snap('road-event');assert state()['page']=='events'
  tap(name='EventResourceHelp');snap('resource-guide');v,x,y=reach(name='GuideSearch');(p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.keyboard.type('Salve');p.wait_for_timeout(300);assert 'Salve and Reroll Seal' in state()['ui_text'];snap('guide-search')
  tap(name='GuideClose');assert state()['page']=='events' and state()['builds']==normal_builds and state()['bank']==normal_bank
  fixture('menu43_craft');snap('craft-inspect')
  if mobile:
   v,x,y=reach(name='CampMaterialPicker');before=v['text']
   session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':x,'y':y}]})
   for i in range(1,8):session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':x,'y':y-60*i/7}]});p.wait_for_timeout(45)
   p.wait_for_timeout(200);session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':x,'y':y-60}]});p.wait_for_timeout(120);session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]});p.wait_for_timeout(350)
   assert not state()['popups'] and node(name='CampMaterialPicker')['text']==before,'Scrolling opened or changed a selector'
  tap(text='Craft · 1 Essence');assert state()['copies'].get('60')==1 and state()['bank']['bone_creature']==2
  tap(name='CampUseCrafted');d=state();assert d['camp_tab']==1;unchanged=d['builds'];snap('install-ability')
  # Pick a legal Skill side on this known starter party. The footer remains fixed.
  tap(name='CampDie2');tap(name='CampSlot2_1');assert state()['builds']==unchanged
  tap(name='CampRefitApply');d=state();assert d['builds'][0][2][1]==60 and d['bank']['bone_creature']==2
  tap(text='Back to Camp');snap('camp-home');tap(name='CampTab2');tap(name='CampSlot_weapon');d=state();before=d['weapons'];select('MobileWeaponPicker' if mobile else 'Equipment_weapon',1);assert state()['weapons']==before
  tap(name='CampEquipApply');assert state()['weapons'][0]=='spear';snap('gear-apply')
  fixture('menu43_reward');snap('reward-hero');tap(text='Next: reward type');snap('reward-type');tap(name='TrialRewardMemory');d=state();assert not any(v['name'].startswith('TrialSlot') or v['name']=='TrialDie0' for v in d['controls']);assert d['trial']['essence']==5;snap('reward-memory')
  tap(text='Back to rewards');assert state()['trial']['essence']==5;tap(name='TrialRewardMemory');tap(name='TrialMemoryBuy');d=state();assert d['trial']['essence']==3 and d['trial']['stage']==1 and d['trial']['memories'][0];snap('after-reward')
  fixture('soul38_blank');pending=state()['pending'];rng=state()['rng'];tap(name='ContextHelp') if any(v['name']=='ContextHelp' for v in state()['controls']) else None
  if state()['guide']:tap(name='GuideClose');assert state()['pending']==pending and state()['rng']==rng
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['normal suggested party and boss/event navigation','resource guide search and return','craft to install exact physical copy','equipment preview and explicit apply','stepwise Trial Memory reward without dice grid','Back without payment']};results=[r for r in results if r['viewport']!=row['viewport']];results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
