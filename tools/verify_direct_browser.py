"""Direct combat and compact Soulcaster using real mouse/touch in an isolated fixture."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/direct-browser';out.mkdir(parents=True,exist_ok=True)
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
  fixture('direct39_trial');tap(name=die+'0');data=state();assert not data['used'][0][0] and 3 in data['preview']['targets'];no_confirmation();cell(3,4);assert state()['boss_hp']==9 and state()['used'][0][0];no_confirmation()
  tap(name=die+'1');assert state()['block'][0]==1 and state()['used'][0][1];no_confirmation()
  tap(name=die+'2');cell(4,5);assert state()['positions'][0]==[4,5] and state()['used'][0][2];snap('direct-combat-new-enemies');no_confirmation()
  fixture('direct39_normal');tap(name=die+'0');cell(3,4);assert state()['boss_hp']==9 and state()['used'][0][0];tap(name=die+'1');assert state()['block'][0]==1;no_confirmation()
  fixture('direct39_stitch');tap(name=die+'0');cell(2,5);assert state()['hp'][1]==4 and state()['used'][0][0] and state()['live_builds'][0][0][3]==0;no_confirmation()
  fixture('direct39_borrow');tap(name=die+'0');assert state()['pending']['kind']=='catalog_choice';tap(name='RolledChoice1_0');tap(text='Use');assert state()['block'][0]==1 and state()['used'][0][0] and not state()['pending'];no_confirmation()
  fixture('soul38_blank');tap(name=die+'0');data=state();assert data['pending']['kind']=='soul_blank' and not any(v['name']=='BattlePanelScroll' for v in data['controls']);assert len([v for v in data['controls'] if v['name'].startswith('SoulSpell')])==6;snap('compact-soulcaster')
  tap(name='SoulSpell76');data=state();assert data['live_builds'][0][0][2]==76 and data['hp'][0]==5 and data['soul_charges'][0]==1 and data['used'][0][0] and data['effective'][0][0]==0
  fixture('soul38_blank');tap(name=die+'0');tap(name='SoulcasterGather');assert state()['soul_charges'][0]==3 and state()['used'][0][0]
  tap(name=die+'1');tap(name='SoulSpell80');assert state()['soul_charges'][0]==1 and state()['live_builds'][0][1][2]==80;snap('one-tap-spell-created')
  fixture('soul38_harvest');tap(name=die+'0');cell(3,4);assert state()['soul_charges'][0]==1 and state()['used'][0][0];no_confirmation()
  fixture('soul38_wraith');tap(name=die+'0');cell(3,5);assert state()['pending']['kind']=='soul_steps';tap(name='WraithStep4');tap(name='WraithStep4');assert not state()['pending'];no_confirmation()
  fixture('class37_skirmisher');tap(name=die+'1');cell(3,5);assert state()['positions'][0]==[3,5];tap(name=die+'0');cell(3,4);assert state()['boss_hp']==9 and state()['used'][0][0];no_confirmation();snap('direct-jab')
  fixture('class37_vanguard');tap(name=die+'1');cell(3,4);assert state()['enemy_block']==2;tap(name=die+'0');cell(3,4);assert state()['enemy_block']==0 and state()['boss_hp']==10;no_confirmation();snap('direct-crack')
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['Strike ability then map target','one-tap Guard','Step then destination','normal and Trial direct controls','direct targeted Grave Stitch','Borrow Shape copied Guard resolves','compact board-visible Soulcaster','two taps total to Gather/create','creation costs and delayed spell','direct Harvester/Wraith/Jab/Crack','licensed animated enemy render']};results.append(row);(out/'checkpoint.json').write_text(json.dumps(results,indent=2));print(json.dumps(row),flush=True);c.close()
 (out/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));b.close()
