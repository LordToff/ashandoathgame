"""Trials navigation and real touch controls in a separate nonshipping fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/trials-v36-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 results=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_TRIAL36_RESUME") else []
 for width,height in json.loads(os.environ.get('ASH_TRIAL36_SIZES','[[390,844],[360,640],[844,390],[1440,900]]')):
  mobile=width!=1440;c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=2 if mobile else 1)
  p=c.new_page();errors=[];p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8930'));p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');session=c.new_cdp_session(p)
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
   data=state();scale=width/data['viewport'][0]
   px,py=40+(x+.5)*76,144+(y+.5)*76
   if mobile:
    bx,by,bw,bh=data['board'];px=bx+(px-24)*bw/716;py=by+(py-128)*bh/716
   (p.touchscreen.tap if mobile else p.mouse.click)(px*scale,py*scale);p.wait_for_timeout(250)
  def confirm():tap(name='MobileResolve' if mobile else 'TrialConfirm')
  def unit(id):return next(u for u in state()['units'] if u['id']==id)
  def calm():p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');p.wait_for_timeout(160)
  print('viewport',width,height,flush=True)
  die='MobileDie0' if mobile else 'BattleDie0'
  fixture('trial36_lobby');tap(name='TrialSlot_weapon');select('TrialWeapon',1)
  assert state()['trial']['loadout_weapons'][0]=='spear';snap('spear-lobby')
  tap(text='Forge / builds');assert node(name='TrialRecipe')
  tap(text='Build ideas');tap(name='TrialBuild_movement');snap('build-combinations');assert state()['trial']['memories'][0]=='stride' and state()['trial']['loadout_weapons'][0]=='spear',state()['trial']
  fixture('trial36_forge');tap(name='TrialPin');assert state()['trial']['wishlist']=='fleet'
  tap(name='TrialCraft');assert 'fleet' in state()['trial']['crafted'] and state()['trial']['ingredients']['cinder']==0;snap('crafted-body-wishlist')
  p.reload();p.wait_for_timeout(5500);p.wait_for_function('typeof window.essenceProof==="function"');assert 'fleet' in state()['trial']['crafted'] and state()['trial']['wishlist']=='fleet'
  fixture('trial36_ritual');tap(name=die);old=state();stone=next(u for u in old['units'] if u['object']=='ritual');cell(*stone['pos']);data=state()
  assert data['forecast'] and unit(stone['id'])['hp']==stone['hp'] and not data['used'][0][0]
  assert data['rng']==old['rng'] and data['event_count']==old['event_count'];snap('ritual-preview')
  confirm();assert unit(stone['id'])['hp']==stone['hp']-1 and state()['used'][0][0];snap('ritual-hit')
  fixture('trial36_jab');tap(name=die);assert state()['effective'][0][0]==73 and state()['preview']['reach']==2
  old=state();cell(*unit(3)['pos']);assert unit(3)['hp']==old['boss_hp'] and state()['forecast'];snap('jab-preview')
  confirm();assert unit(3)['hp']==old['boss_hp']-1 and state()['used'][0][0]
  fixture('trial36_crack');tap(name=die);cell(*unit(3)['pos']);assert '2 Block removed' in state()['forecast']['forecast']['text'];snap('crack-preview')
  old=state()['boss_hp'];confirm();assert unit(3)['block']==1 and state()['boss_hp']==old and state()['used'][0][0]
  fixture('trial36_numeric');tap(name=die);old=state();cell(*unit(3)['pos']);data=state();assert data['forecast']['forecast']['numeric'] and '0–1 HP damage' in data['forecast']['forecast']['text']
  assert data['rng']==old['rng'] and data['event_count']==old['event_count'];snap('numeric-range-preview')
  tap(name='MobileDetails' if mobile else 'TrialCancel');assert not state()['forecast'] and state()['boss_hp']==old['boss_hp'] and not state()['used'][0][0]
  fixture('trial36_spirit');tap(name=die);spirit=next(u for u in state()['units'] if u['object']=='spirit');cell(*spirit['pos']);assert 'heal 1' in state()['forecast']['forecast']['text'];snap('spirit-heal-preview')
  confirm();assert unit(spirit['id'])['hp']==4
  fixture('trial36_hollow');tap(name=die);cell(*unit(4)['pos']);confirm();assert unit(4)['hp']==1
  tap(name='MobileDie1' if mobile else 'BattleDie1');cell(*unit(4)['pos']);confirm();assert unit(4)['hp']==0 and 'cancelled' in state()['objective'];snap('boss-core-interrupted')
  fixture('trial36_ritual_win');tap(name=die);stone=next(u for u in state()['units'] if u['object']=='ritual' and u['hp']>0);cell(*stone['pos']);confirm();data=state()
  assert data['trial']['phase']=='reward' and data['trial']['ingredients']['cinder']==2 and '2/3' in data['trial']['last_progress'];snap('objective-wishlist-reward')
  tap(text='Continue');p.wait_for_function('()=>{window.essenceProof("state");return JSON.parse(window.essenceState).page==="trials";}');assert node(name='TrialPinned');snap('reward-to-route')
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['four-slot weapon selection','equipment combinations','paid Body crafting','wishlist pin and reload','ritual real target/confirm','read-only forecasts','Jab replaces Strike at range two','Crack replaces Strike and strips Block','Numeric uncertainty and cancel','First Aid on spirit','boss core interruption','objective completion and wishlist reward']};results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
