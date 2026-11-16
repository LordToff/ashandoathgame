"""Turn refill, cancel controls and original knight / arena art through real input."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/turns-browser';out.mkdir(parents=True,exist_ok=True)
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
  die='MobileDie' if mobile else 'BattleDie';reroll='MobileReroll' if mobile else 'ActionRerollButton'
  def end_turn():tap(name='MobileEndTurn') if mobile else tap(text='End hero turn   →')
  def options(trial=False):
   if mobile:tap(name='MobileMore')
   tap(text='Menu');tap(name='TrialMenuOptions') if trial else tap(text='Options' if mobile else 'Game options')
  def close_options(trial=False):tap(text='Back to battle' if trial else 'Back' if mobile else 'Back to game')
  fixture('turns46_normal');original=state();assert not original['turn_refill'];snap('knights-arena')
  tap(name=reroll);assert state()['choosing_reroll'];snap('choose-reroll');tap(name=reroll);assert not state()['choosing_reroll'] and state()['rerolls'][0]==1
  tap(name=reroll);tap(name=die+'0');assert state()['rerolls'][0]==0 and not state()['choosing_reroll']
  options();tap(name='TurnRerollToggle');assert state()['turn_refill'] and state()['rerolls'][0]==0;snap('refill-setting');close_options()
  end_turn();assert state()['active']==1 and state()['rerolls'][1]==1 and state()['rerolls'][0]==0
  tap(name=die+'2');assert state()['preview']['tiles'];rng=state()['rng'];snap('movement-range');assert state()['rng']==rng
  end_turn();assert state()['active']==2 and state()['rerolls'][2]==1
  end_turn();assert state()['active']==3
  for step in range(8):
   if state()['active']!=3:break
   tap(name='MobileEnemyStep' if mobile else 'EnemyStepButton')
  assert state()['active']==0 and state()['rerolls'][0]==1
  tap(name=reroll);assert state()['choosing_reroll'];end_turn();assert state()['active']==1 and not state()['choosing_reroll']
  data=state();before=data['rerolls'][1]
  ready=next(i for i in range(3) if not data['used'][1][i] and data['results'][1][i] in [0,1,2,3,4,34])
  tap(name=die+str(ready));assert not state()['choosing_reroll'] and state()['rerolls'][1]==before
  p.reload();p.wait_for_function('typeof window.essenceProof==="function"');p.wait_for_timeout(700);assert state()['turn_refill']
  fixture('turns46_trial');assert state()['turn_refill'];options(True);tap(name='TurnRerollToggle');assert not state()['turn_refill'];close_options(True)
  end_turn();assert state()['active']==1 and state()['rerolls'][1]==0
  options(True);tap(name='TurnRerollToggle');assert state()['turn_refill'] and state()['rerolls'][1]==0;close_options(True)
  end_turn();assert state()['active']==2 and state()['rerolls'][2]==1;snap('trial-refill')
  assert state()['bank']==original['bank'] and state()['copies']==original['copies']
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['original knights and cobblestone arena','reroll selection and cancel','paid reroll','normal Settings toggle without immediate refill','per-hero turn refills','movement range without RNG reads','next round refill','stale selection clears before next hero action','web reload persistence','Trial OFF and ON from next turn','normal inventory unchanged']};results.append(row);print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
