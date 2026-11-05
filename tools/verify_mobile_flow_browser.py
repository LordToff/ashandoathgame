"""Touch-first combat, no Poison modal, boss rewards and gated long-press unlocks."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1';out=Path(__file__).resolve().parents[1]/'exports/mobile-flow-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']);results=[]
 for width,height in [(360,640),(390,844),(844,390),(1440,900)]:
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=2 if mobile else 1)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)));p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8914'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
  def state():p.evaluate('window.essenceProof("state")');return p.evaluate('JSON.parse(window.essenceState)')
  def fixture(mode):p.evaluate('(m)=>window.essenceProof(m)',mode);p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');p.wait_for_timeout(180)
  def node(name=None,text=None):return next(v for v in reversed(state()['controls']) if (v['name']==name if name else v['text']==text))
  def point(v):
   scale=width/state()['viewport'][0];return ((v['x']+v['w']/2)*scale,(v['y']+v['h']/2)*scale)
  def swipe(x,y,distance,up=True):
   session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':x,'y':y}]})
   for i in range(1,9):session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':x,'y':y+(-1 if up else 1)*distance*i/8}]});p.wait_for_timeout(65)
   session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]});p.wait_for_timeout(260)
  def reach(name=None,text=None):
   for attempt in range(35):
    v=node(name,text);cx,cy,cw,ch=v['clip'];x=v['x']+v['w']/2;y=v['y']+v['h']/2;scale=width/state()['viewport'][0]
    if cx<=x<=cx+cw and cy+3<=y<=cy+ch-3:return v
    if mobile:swipe((cx+cw*.6)*scale,(cy+ch*(.8 if y>cy+ch else .2))*scale,min(80,max(22,ch*scale*.35)),y>cy+ch)
    else:p.mouse.move((cx+cw*.6)*scale,(cy+ch*.6)*scale);p.mouse.wheel(0,180 if y>cy+ch else -180);p.wait_for_timeout(220)
   raise AssertionError(('unreachable',v))
  def tap(name=None,text=None):
   v=reach(name,text);assert not v['disabled'],v;(p.touchscreen.tap if mobile else p.mouse.click)(*point(v));p.wait_for_timeout(180)
  def hold(name,drag=False):
   v=reach(name=name);x,y=point(v)
   if mobile:
    session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':x,'y':y}]})
    if drag:
     for i in range(1,5):session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':x,'y':y-i*13}]});p.wait_for_timeout(60)
    p.wait_for_timeout(900);session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]})
   else:
    p.mouse.move(x,y);p.mouse.down()
    if drag:p.mouse.move(x,y-55,steps=5)
    p.wait_for_timeout(900);p.mouse.up()
   p.wait_for_timeout(250)
  def snap(name):
   path=out/f'{width}x{height}-{name}.png';p.screenshot(path=str(path));return subprocess.check_output(['tesseract',str(path),'stdout'],stderr=subprocess.DEVNULL,text=True)
  print('viewport',width,height,flush=True)
  if mobile:
   fixture('flow_player');d=state();assert [node(name='MobileDie'+str(i))['text'] for i in range(3)]==['Step','Strike','Blank']
   for name in ['MobileDie0','MobileDetails','MobileReroll','MobileEndTurn']:
    v=node(name=name);assert v['clip'][1]<=v['y'] and v['y']+v['h']<=d['viewport'][1],v
   assert not any(v['name']=='MobileBattleActions' for v in d['controls'])
   snap('combat-fixed');tap(name='MobileDie0');d=state();bx,by,edge,_=d['board'];scale=width/d['viewport'][0]
   p.touchscreen.tap((bx+(78-24)*edge/716)*scale,(by+(638-128)*edge/716)*scale);p.wait_for_timeout(200);assert state()['positions'][0]==[0,6]
   tap(name='MobileEndTurn');assert state()['active']!=0
   fixture('flow_enemy');assert '4 Block' in node(name='EnemyStatsButton')['text'];tap(name='EnemyIntent0');text=snap('intent-one');assert 'Block' in text and 'Die' not in text,text;tap(text='Back')
   for i in range(3):tap(name='MobileEnemyStep')
   assert state()['enemy_block']==7 and node(name='MobileEnemyStep')['text']=='End enemy turn'
   snap('enemy-end-fixed');tap(name='MobileEnemyStep');assert state()['active']==0
   fixture('clarity_borrow');assert len([v for v in state()['controls'] if v['name'].startswith('RolledChoice')])==9
   assert all('Die' not in v['text'] for v in state()['controls'] if v['name'].startswith('RolledChoice'))
   tap(name='RolledChoice1_0');snap('copy-names');tap(text='Use');assert state()['results'][0][0]==4
  fixture('clarity_poison');assert state()['hp'][0]==4 and not state()['notices'];assert not any(v['name']=='AcknowledgeCombatNotice' for v in state()['controls'])
  p.wait_for_timeout(1850);snap('persistent-poison')
  fixture('flow_boss_win');assert state()['bank'].get('hollow')==3;state();state();assert state()['bank']['hollow']==3
  text=snap('boss-bank');assert '3' in text and 'Essence' in text,text
  tap(text='Return to Camp · bank / craft / refit');assert state()['page']=='camp'
  if width in [390,1440]:
   fixture('flow_debug');hold('CollectionSoul_mire');assert 'mire' not in state()['souls'][0]
   fixture('flow_debug');tap(text='Debug: Off');assert state()['debug'];hold('CollectionSoul_mire',drag=True);assert 'mire' not in state()['souls'][0]
   # Start fresh after the scroll-cancel test, then perform a stationary hold.
   fixture('flow_debug');tap(text='Debug: Off');hold('CollectionSoul_mire');assert 'mire' in state()['souls'][0] and state()['collection'];assert 'mire' not in state()['souls'][1]
   hold('CollectionMemory_memory_embers');assert state()['unlocked'].get('memory_embers') and not state()['bank']
   snap('debug-unlocked');fixture('flow_boss_forge');assert state()['debug'];hold('Recipe_ember_cut' if not mobile else 'MobileRecipe_ember_cut');assert state()['copies'].get('69')==1 and not state()['bank'];snap('boss-face-debug')
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['fixed combat actions and enemy turn finish'] if mobile else []};row['tested']+=['Poison without acknowledgement','persistent Poison smoke','three boss Essence banked once','boss Forge route']
  if width in [390,1440]:row['tested']+=['debug off blocks hold','scroll cancels unlock','stationary hold grants bound Soul and Memory','locked boss ability unlocks without cost']
  results.append(row);print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
