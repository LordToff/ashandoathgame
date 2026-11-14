"""Inspect real exported worm hit/miss sequencing, compact dice, log and settings."""
import json, os, time
from pathlib import Path
from playwright.sync_api import sync_playwright
OUT=Path(__file__).resolve().parents[1]/'exports/playback-browser';OUT.mkdir(parents=True,exist_ok=True)
results=[]
with sync_playwright() as pw:
 browser=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 for width,height in json.loads(os.environ.get("ASH_PLAYBACK_SIZES","[[390,844],[360,640],[844,390],[1440,900]]")):
  mobile=width!=1440
  ctx=browser.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile)
  p=ctx.new_page();errors=[];p.on('pageerror',lambda e:errors.append(str(e)));p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None)
  p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8952'));p.wait_for_function('typeof window.essenceProof==="function"');p.wait_for_timeout(1500)
  def state():p.evaluate('window.essenceProof("state")');return p.evaluate('JSON.parse(window.essenceState)')
  def fixture(mode):p.evaluate('(m)=>window.essenceProof(m)',mode);p.wait_for_timeout(120)
  def click(name):
   s=state();v=next(v for v in reversed(s['controls']) if v['name']==name);assert not v['disabled'],v
   scale=width/s['viewport'][0];(p.touchscreen.tap if mobile else p.mouse.click)((v['x']+v['w']/2)*scale,(v['y']+v['h']/2)*scale);p.wait_for_timeout(100)
  fixture('play41_worm');s=state();assert s['playback']['visible_hp'][0]==6;assert 'pixel_nugh' in s['art']['nugh'] and 'pixel_screaming_worm' in s['art']['worm'],s['art']
  fixture('play41_bite');rng=state()['rng'];observed=[];stages=set();begin=time.monotonic();hold_times=[]
  while time.monotonic()-begin<9:
   s=state();v=s['playback'];stage='result' if v['dice_busy'] and v['dice_elapsed']>=v['settle'] else 'rolling' if v['dice_busy'] else v['kind']
   if v['dice_busy'] or stage=='attack':assert v['visible_hp'][0]==6,(stage,v)
   if stage=='result':hold_times.append(time.monotonic())
   if stage=='damage':assert v['visible_hp'][0]==5 and v['visible_poison'][0]==0,v
   if stage=='poison':assert v['visible_hp'][0]==5 and v['visible_poison'][0]==1 and s['feedback_kind']=='poison_tick',s
   if stage and stage not in stages:
    stages.add(stage);observed.append({'stage':stage,'time':round(time.monotonic()-begin,2),'hp':v['visible_hp'][0],'poison':v['visible_poison'][0],'result':v['last_roll']})
    # Keep timing probes free of blocking screenshots.
   assert s['rng']==rng,'presentation consumed gameplay RNG'
   if not s['rolling']:break
   p.wait_for_timeout(35)
  assert {'rolling','result','attack','damage','poison'}<=stages,observed
  assert hold_times[-1]-hold_times[0]>=.9,hold_times
  assert state()['hp'][0]==5 and state()['playback']['visible_poison'][0]==1
  click('MobileLog' if mobile else 'BattleLogButton');assert 'Summary' in state()['ui_text'] and 'Extensive' in state()['ui_text'];p.screenshot(path=str(OUT/f'{width}x{height}-log.png'))
  fixture('play41_worm_miss');fixture('play41_bite');miss_stages=set();begin=time.monotonic()
  while time.monotonic()-begin<8:
   s=state();v=s['playback'];miss_stages.add(v['kind']);assert v['visible_hp'][0]==6 and v['visible_poison'][0]==0
   if v['dice_busy'] and v['dice_elapsed']>v['settle']:
    assert '0' in v['last_roll'],v
   if not s['rolling']:break
   p.wait_for_timeout(60)
  assert 'miss' in miss_stages and 'attack' not in miss_stages,miss_stages
  assert not errors,errors
  row={'viewport':[width,height],'hit_stages':observed,'miss_stages':sorted(miss_stages),'result_hold_observed_seconds':round(hold_times[-1]-hold_times[0],2),'errors':errors};results.append(row);(OUT/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2));print(json.dumps(row),flush=True);ctx.close()
 browser.close()
(OUT/'results.json').write_text(json.dumps({'result':'passed','devices':results},indent=2))
