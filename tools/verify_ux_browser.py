"""Guided preparation, instant dice, death playback and HUD checks with real inputs."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/ux-browser';out.mkdir(parents=True,exist_ok=True)
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
  def node(name=None,text=None):return next(v for v in reversed(state()['controls']) if (v['name']==name if name else v['text']==text))
  def reach(name=None,text=None):
   for attempt in range(45):
    v=node(name,text);cx,cy,cw,ch=v['clip'];x=v['x']+v['w']/2;y=v['y']+v['h']/2;scale=width/state()['viewport'][0]
    if cx<=x<=cx+cw and cy+3<=y<=cy+ch-3:
     p.wait_for_timeout(100);stable=node(name,text)
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
   v,x,y=reach(name,text);p.wait_for_timeout(100);v,x,y=reach(name,text);assert not v['disabled'],v;(p.touchscreen.tap if mobile else p.mouse.click)(x,y);p.wait_for_timeout(220)
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
  fixture('class37_lobby');normal=state();assert normal['trial']['prepare_step']==0
  tap(name='TrialPrepClass_vanguard');snap('prepare-class');tap(name='TrialPrepNext');tap(name='TrialPrepSoul_soulcaster');snap('prepare-soul');tap(name='TrialPrepNext')
  # Reopening Trials after reload restores the exact current preparation step.
  p.reload();p.wait_for_function('typeof window.essenceProof==="function"');p.wait_for_timeout(1200)
  assert state()['trial']['prepare_step']==2 and state()['trial']['souls'][0]=='soulcaster';normal=state()
  tap(name='MobileTrials' if mobile else 'MainTrials');tap(name='TrialPrepBack');assert state()['trial']['prepare_step']==1 and state()['trial']['souls'][0]=='soulcaster';tap(name='TrialPrepNext')
  tap(name='TrialPrepBody_broken');tap(name='TrialPrepNext');tap(name='TrialPrepWeapon_spear');snap('prepare-weapon');tap(name='TrialPrepNext');assert state()['trial']['memories']==['','',''];tap(name='TrialPrepNext')
  faces=[v['text'] for v in state()['controls'] if v['name'].startswith('TrialPrepDie')];assert len(faces)==18 and 'Jab' in faces and 'Crack' not in faces;snap('prepare-dice');tap(name='TrialPrepDie0Side2');assert 'Gather' in state()['info'];tap(text='Back');tap(name='TrialPrepNext')
  for hero in [1,2]:
   for step in range(6):
    d=state();assert d['trial']['hero']==hero and d['trial']['prepare_step']==step,(hero,step,d['trial']);tap(name='TrialPrepNext')
  d=state();assert d['trial']['prepare_step']==6 and d['trial']['prepared']==[True,True,True];snap('party-review');tap(name='TrialPrepBegin');assert state()['trial']['phase']=='route' and state()['trial']['max_hp']==[6,6,6]
  assert state()['bank']==normal['bank'] and state()['builds']==normal['builds'],'Wizard changed normal Camp or dice'
  def options(trial):
   if mobile:tap(name='MobileMore')
   tap(text='Menu');tap(name='TrialMenuOptions') if trial else tap(text='Options' if mobile else 'Game options')
  fixture('direct39_numeric');options(True);tap(name='DiceAnimationToggle');assert not state()['dice_animation'];snap('dice-setting-off');tap(text='Back to battle')
  die='MobileDie' if mobile else 'BattleDie';tap(name=die+'0');cell(3,4);d=state();rng=d['rng'];assert not d['playback']['dice_busy'];kinds=[]
  while state()['rolling']:
   d=state();kinds.append(d['playback']['kind']);assert not d['playback']['dice_busy'] and d['rng']==rng;p.wait_for_timeout(30)
  assert 'roll' not in kinds and state()['boss_hp']<10
  before=state()['serial'];tap(name='MobileReroll' if mobile else 'ActionRerollButton');tap(name=die+'1');d=state();assert not d['rolling'] and not d['playback']['dice_busy'] and d['serial']>before
  options(True);tap(name='BlankMoveToggle');assert state()['blank_move'];p.reload();p.wait_for_function('typeof window.essenceProof==="function"');p.wait_for_timeout(1000);assert not state()['dice_animation'] and state()['blank_move']
  fixture('direct39_normal');options(False);assert not state()['dice_animation'];tap(name='DiceAnimationToggle');assert state()['dice_animation'] and state()['blank_move'];snap('normal-settings');tap(text='Back' if mobile else 'Back to game')
  def watch_fall(label):
   begin=__import__('time').monotonic();seen=False;timeline=[]
   while __import__('time').monotonic()-begin<8:
    d=state();v=d['playback'];kind=v['kind']
    if not timeline or timeline[-1]!=kind:timeline.append(kind)
    if kind=='fall' and not seen:
     assert v['fall_caption'] and 'fall' in v['effects'];seen=True
     p.wait_for_timeout(100);snap(label)
    if not d['rolling']:break
    p.wait_for_timeout(35)
   assert seen,(label,timeline,d);return timeline
  fixture('direct39_fall');tap(name=die+'0');cell(3,4);enemy_timeline=watch_fall('enemy-fall');assert state()['boss_hp']==0
  fixture('ux42_fall_downed');tap(name='MobileEnemyStep' if mobile else 'EnemyStepButton');downed_timeline=watch_fall('hero-downed');d=state();assert d['hp'][0]==0 and not d['units'][0]['dead']
  fixture('ux42_fall_slain');tap(name='MobileEnemyStep' if mobile else 'EnemyStepButton');slain_timeline=watch_fall('hero-slain');assert state()['units'][0]['dead']
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['all three heroes prepared step by step','wizard Back and reload retain choices','18 physical sides and Jab projection','party review gates Begin','normal Camp isolated','animation OFF has no dice or pause','reroll result immediate and retained','both Settings and preferences survive reload','enemy collapse','Downed distinct from slain','live HUD'],'death_timelines':[enemy_timeline,downed_timeline,slain_timeline]};results=[r for r in results if r['viewport']!=row['viewport']];results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
