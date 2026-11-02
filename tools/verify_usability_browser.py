"""Local-only Chromium UI regression check.
Serve the normal exports/web build at 127.0.0.1:8876 and the deterministic
fixture created by make_usability_fixture.py at 127.0.0.1:8877. Requires
Playwright, Chromium and Tesseract. No remote writes or publication.
"""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,subprocess,json
os.environ['OMP_THREAD_LIMIT']='1'
out=Path('/workspace/outputs/v26-browser');out.mkdir(exist_ok=True)
def snap(p,n):
 path=out/(n+'.png');p.screenshot(path=str(path));return subprocess.check_output(['tesseract',str(path),'stdout'],stderr=subprocess.DEVNULL,text=True)
def click(p,x,y):p.mouse.click(x,y);p.wait_for_timeout(300)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 p=b.new_page(viewport={'width':1440,'height':900});errors=[]
 p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
 p.goto('http://127.0.0.1:8876');p.wait_for_timeout(6500)
 for hero in range(3):
  click(p,180,280);click(p,490,280);click(p,1130,830)
 click(p,1200,850);text=snap(p,'01-required-event');assert 'THE ASH ROAD' in text,text
 click(p,720,620);click(p,400,710);text=snap(p,'02-resolved-event');assert 'Enter selected boss' in text,text
 click(p,1050,710);p.wait_for_timeout(1200);text=snap(p,'03-boss');assert 'THE HOLLOW' in text,text
 click(p,350,125);click(p,500,470);text=snap(p,'04-options');assert 'ANY TIME' in text and 'Main menu' in text,text
 click(p,600,600);text=snap(p,'05-restart');assert '0/2' in text and 'VESPER' in text,text
 p.goto('http://127.0.0.1:8877');p.wait_for_timeout(6500)
 p.wait_for_function('typeof window.ashProof === "function"')
 def fixture(mode):p.evaluate('(m)=>window.ashProof(m)',mode);p.wait_for_timeout(600)
 fixture('poison');text=snap(p,'06-poison-tick');assert 'POISON TICKS' in text and 'Poison 2' in text and 'HP 6' in text,text
 click(p,650,600);text=snap(p,'07-poison-after');assert '4/6 HP' in text,text
 fixture('borrow');text=snap(p,'08-borrow');assert 'ROOK' in text and 'WREN' in text,text
 click(p,450,470);text=snap(p,'09-copied-guard');assert 'Guard' in text,text
 fixture('focus');click(p,900,250);click(p,900,345);text=snap(p,'10-focus-result');assert 'FOCUS' in text and 'Same ability' in text,text
 click(p,650,600);click(p,344,448);p.wait_for_timeout(400)
 click(p,900,440);click(p,900,640);text=snap(p,'11-anytime-reroll');assert 'ACTION REROLL RESULT' in text and 'charge' in text,text
 click(p,650,600);click(p,1320,220);text=snap(p,'12-extensive-log');assert 'REACTION' in text or 'ROLL' in text,text
 fixture('reaction');text=snap(p,'13-reaction-before');assert 'gain 2 Block' in text or 'Gain 2 Block' in text,text
 click(p,520,505);click(p,1320,220);text=snap(p,'14-reaction-after');assert '6/6 HP' in text,text
 assert not errors,errors
 (out/'results.json').write_text(json.dumps({'normal_flow':'passed','fixture_ui':'passed','errors':errors},indent=2));print('PASS normal event → boss → options → restart; rendered Poison, Borrow Shape, Focus, anytime reroll, full log and Reaction UI. No browser errors.',flush=True)
 b.close()
