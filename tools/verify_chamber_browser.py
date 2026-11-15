"""Test chamber access and styled menus with real mouse/touch in an isolated fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/chamber-browser';out.mkdir(parents=True,exist_ok=True)
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
   path=out/f'{width}x{height}-{name}.png';p.screenshot(path=str(path));return str(path)
  def cell(x,y):
   data=state();scale=width/data['viewport'][0];px,py=40+(x+.5)*76,144+(y+.5)*76
   if mobile:
    bx,by,bw,bh=data['board'];px=bx+(px-24)*bw/716;py=by+(py-128)*bh/716
   (p.touchscreen.tap if mobile else p.mouse.click)(px*scale,py*scale);p.wait_for_timeout(300)
  def confirm():tap(name='MobileResolve' if mobile else 'TrialConfirm')
  print('viewport',width,height,flush=True)
  die='MobileDie' if mobile else 'BattleDie'
  def no_confirmation():assert not any(v['name']=='TrialConfirm' or v['text'] in ['Confirm','Confirm action'] for v in state()['controls']) and not state()['forecast']
  fixture('menu43_main');snap('main-menu');original=state();lab_name='MobileLab' if mobile else 'MainLab';v=node(name=lab_name);assert v['clip'][1]<=v['y'] and v['y']+v['h']<=height
  tap(name=lab_name);assert 'Test chamber' in state()['ui_text'];snap('test-chamber')
  def search_for(words):
   v,x,y=reach(name='LabSearch');(p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.keyboard.press('Control+A');p.keyboard.type(words);p.wait_for_timeout(250)
  def choose_ability(label):
   tap(name='LabAbilities');data=state();popup=next(item for item in data['popups'] if item['control']=='LabAbilities');index=next(i for i,item in enumerate(popup['items']) if item.startswith(label+' (') or item==label)
   row=(popup['h']-popup['top']-popup['bottom'])/len(popup['items']);scale=width/data['viewport'][0]
   (p.touchscreen.tap if mobile else p.mouse.click)((popup['x']+popup['w']/2)*scale,(popup['y']+popup['top']+row*(index+.5))*scale);p.wait_for_timeout(300)
  search_for('Strike Numeric');choose_ability('Strike Numeric');d=state();snap('after-ability');assert d['results'][0][0]==34,(d['ui_text'],d['results'],d['popups']);snap('numeric-ability')
  select('LabNumeric',2);tap(name='LabTry');d=state();hp=d['boss_hp'];tap(name='MobileDie0' if mobile else 'BattleDie0');cell(4,3)
  p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');d=state();assert d['used'][0][0] and d['boss_hp']<hp;snap('ability-hit')
  if mobile:tap(name='MobileMore');tap(name='MobileLabTools')
  else:tap(name='LabTools')
  snap('reopen-tools');tap(name='LabReset');assert not state()['used'][0][0]
  if os.environ.get('ASH_CHAMBER_COMBOS'):
   tap(name='LabCombine');assert any(v['name']=='LabSupport' for v in state()['controls']);snap('combine-tools');tap(text='Back to tools')
  search_for('Bone Growth');choose_ability('Bone Growth');d=state();assert d['results'][0][0]==60;snap('earned-face')
  search_for('no-such-ability');assert node(name='LabAbilities')['disabled'];search_for('')
  assert state()['bank']==original['bank'] and state()['builds']==original['builds'] and state()['copies']==original['copies']
  tap(text='Main menu');assert state()['page']=='main' and node(name=lab_name);snap('return-main')
  tap(name='MobileCamp' if mobile else 'MainCamp');snap('camp-art');tap(name='CampTab2');snap('equipment-art');tap(name='ContextHelp');snap('help-art');tap(name='GuideClose')
  fixture('class37_lobby');snap('trial-art');assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['test chamber always visible without More','opens searchable ability picker directly','choose and use a real Numeric ability on map','force Numeric result','tools reachable from combat on desktop and phone','reset actual practice scenario','earned face available without spending inventory','search with no match safely disabled','normal builds and bank preserved','main/Camp/equipment/Help/Trial artwork']};results=[r for r in results if r['viewport']!=row['viewport']];results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
