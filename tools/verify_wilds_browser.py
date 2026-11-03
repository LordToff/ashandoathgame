"""Check new creature selection, bound Soul crafting/equipment and all three Blank abilities.
Runs normal export plus the separate local fixture; no callbacks ship in the game.
"""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,json,subprocess
os.environ['OMP_THREAD_LIMIT']='1';out=Path(__file__).resolve().parents[1]/'exports/wilds-browser';out.mkdir(parents=True,exist_ok=True)
def snap(p,name):
 path=out/(name+'.png');p.screenshot(path=str(path));return subprocess.check_output(['tesseract',str(path),'stdout'],stderr=subprocess.DEVNULL,text=True)
def click(p,x,y):p.mouse.click(x,y);p.wait_for_timeout(350)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 p=b.new_page(viewport={'width':1440,'height':900});errors=[]
 p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
 p.goto(os.environ.get('ASH_WEB_URL','http://127.0.0.1:8899'));p.wait_for_timeout(6000)
 click(p,300,595);click(p,780,850);text=snap(p,'01-wilds-encounters');assert all(w in text for w in ['Mire Leech','Glasswing Moth','Iron Husk']),text
 click(p,250,700)
 for hero in range(3):click(p,180,280);click(p,490,280);click(p,1130,830)
 p.wait_for_timeout(1800);click(p,350,125);click(p,650,590);text=snap(p,'02-real-leech-cards');assert text.count('Mire Leech')>=2 and 'Venom Bite' in text,text
 p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8902'));p.wait_for_timeout(6000);p.wait_for_function('typeof window.essenceProof === "function"')
 def state():p.evaluate('(m)=>window.essenceProof(m)','state');return p.evaluate('JSON.parse(window.essenceState)')
 def fixture(mode):
  p.evaluate('(m)=>window.essenceProof(m)',mode)
  p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}');p.wait_for_timeout(300)
 fixture('wilds_camp');text=snap(p,'03-hidden-soul-design');assert 'hidden until crafted' in text and 'Soul of the Mire' not in text,text
 click(p,1080,640);click(p,1080,700);data=state();assert 'mire' in data['souls'][1] and 'mire' not in data['souls'][0] and data['bank']['mire_leech']==3
 text=snap(p,'04-bound-to-rook');assert 'Soul of the Mire' in text,text
 click(p,880,160);click(p,370,258);click(p,450,544);click(p,450,643);assert state()['equipped_souls'][1]=='mire'
 text=snap(p,'05-equipped-mire-sprite');assert 'Mire' in text and 'heal' in text,text
 fixture('soul_heal');click(p,900,245);click(p,860,578);assert state()['hp'][0]==4 and state()['used'][0][0]
 click(p,900,442);click(p,860,578);assert state()['hp'][0]==4;snap(p,'06-mire-once')
 fixture('soul_block');click(p,900,245);click(p,860,578);assert state()['block'][0]==2 and state()['used'][0][0];snap(p,'07-ironbound-block')
 fixture('soul_blink');click(p,900,245);click(p,78,562);assert state()['positions'][0]==[0,5];snap(p,'08-glasswing-blink')
 fixture('wilds_cards');text=snap(p,'09-all-public-dice');assert 'Venom Bite' in text and 'Needle' in text and 'Iron Guard' in text,text
 assert not errors,errors
 report={'result':'passed','errors':errors,'tested':['normal Wilds pagination and creature sprites','real leech encounter','public new enemy dice','hidden Soul design','paid binding to chosen hero','bound Soul equipment and sprite','Mire actual healing/once per turn','Ironbound Block','Glasswing blink control']}
 (out/'results.json').write_text(json.dumps(report,indent=2));print(json.dumps(report));b.close()
