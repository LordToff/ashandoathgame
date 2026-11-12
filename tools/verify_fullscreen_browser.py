"""Exercise actual browser fullscreen via the game's mouse/touch Settings controls."""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json
out=Path(__file__).resolve().parents[1]/'exports/fullscreen-browser';out.mkdir(parents=True,exist_ok=True)
with sync_playwright() as pw:
 browser=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 reports=json.loads((out/"checkpoint.json").read_text()) if os.environ.get("ASH_FULLSCREEN_RESUME") else []
 for width,height in json.loads(os.environ.get("ASH_FULLSCREEN_SIZES","[[1440,900],[390,844],[360,640],[844,390]]")):
  mobile=width!=1440;context=browser.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=1)
  page=context.new_page();errors=[];page.on('pageerror',lambda e:errors.append(str(e)));page.on('console',lambda m:errors.append(m.text) if m.type=='error' else None)
  page.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8950'));page.wait_for_function('typeof window.essenceProof==="function"');page.wait_for_timeout(1000)
  def state():page.evaluate('window.essenceProof("state")');return page.evaluate('JSON.parse(window.essenceState)')
  def fixture(mode):page.evaluate('(mode)=>window.essenceProof(mode)',mode);page.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');page.wait_for_timeout(400)
  def control(name=None,text=None):return next(v for v in reversed(state()['controls']) if v['name']==name) if name else next(v for v in reversed(state()['controls']) if v['text']==text)
  def tap(name=None,text=None):
   for attempt in range(30):
    v=control(name,text);cx,cy,cw,ch=v['clip'];center=v['y']+v['h']/2
    if cy+3<=center<=cy+ch-3:break
    data=state();canvas=page.evaluate('(()=>{const r=document.querySelector("canvas").getBoundingClientRect();return {x:r.x,y:r.y,w:r.width,h:r.height}})()');gw,gh=data['viewport'];scale=min(canvas['w']/gw,canvas['h']/gh)
    x=canvas['x']+(canvas['w']-gw*scale)/2+(cx+cw*.6)*scale;y=canvas['y']+(canvas['h']-gh*scale)/2+(cy+ch*.6)*scale
    page.mouse.move(x,y);page.mouse.wheel(0,200 if center>cy+ch else -200);page.wait_for_timeout(180)
   else:raise AssertionError(('unreachable',v))
   assert not v['disabled'],v
   data=state();canvas=page.evaluate('(()=>{const r=document.querySelector("canvas").getBoundingClientRect();return {x:r.x,y:r.y,w:r.width,h:r.height}})()');gw,gh=data['viewport'];scale=min(canvas['w']/gw,canvas['h']/gh)
   x=canvas['x']+(canvas['w']-gw*scale)/2+(v['x']+v['w']/2)*scale;y=canvas['y']+(canvas['h']-gh*scale)/2+(v['y']+v['h']/2)*scale
   (page.touchscreen.tap if mobile else page.mouse.click)(x,y);page.wait_for_timeout(350)
  def check_fullscreen(on):
   page.wait_for_function('on=>!!document.fullscreenElement===on',arg=on,timeout=4000)
   page.wait_for_timeout(350)
   assert control('OptionsFullscreen')['text']==('Exit fullscreen' if on else 'Fullscreen · use whole screen')
   if on:
    dimensions=page.evaluate('(()=>{const r=document.fullscreenElement.getBoundingClientRect();return [r.width,r.height,innerWidth,innerHeight]})()');assert abs(dimensions[0]-dimensions[2])<2 and abs(dimensions[1]-dimensions[3])<2,dimensions
  print('viewport',width,height,flush=True)
  fixture('class37_main');tap(text='Options')
  tap('OptionsFullscreen');check_fullscreen(True);page.screenshot(path=str(out/f'{width}x{height}-fullscreen-settings.png'))
  tap('OptionsFullscreen');check_fullscreen(False)
  # Browser-owned exit must update the label without reopening Settings.
  tap('OptionsFullscreen');check_fullscreen(True);page.evaluate('document.exitFullscreen()');check_fullscreen(False)
  fixture('soul38_blank');before=state();tap('MobileMore' if mobile else None,text=None if mobile else 'Menu')
  if mobile:tap(text='Menu')
  tap('TrialMenuOptions');tap('OptionsFullscreen');check_fullscreen(True)
  after=state();assert after['hp']==before['hp'] and after['results']==before['results'] and after['rng']==before['rng'] and after['trial']['phase']==before['trial']['phase']
  page.screenshot(path=str(out/f'{width}x{height}-fullscreen-trial-settings.png'));tap('OptionsFullscreen');check_fullscreen(False)
  assert not errors,errors
  row={'viewport':[width,height],'result':'passed','browser_errors':errors,'tested':['real mouse/touch entry','fullscreen element fills viewport','button exits fullscreen','browser-owned exit updates label','Trial Settings toggle','battle and RNG preserved']};reports=[old for old in reports if old['viewport']!=row['viewport']];reports.append(row);(out/'checkpoint.json').write_text(json.dumps(reports,indent=2));print(json.dumps(row),flush=True);context.close()
 browser.close();(out/'results.json').write_text(json.dumps({'result':'passed','devices':reports},indent=2))
