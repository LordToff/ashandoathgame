"""Check v0.28 normal navigation plus the separate local equipment/combat fixture.
See make_essence_fixture.py. No test hooks are added to the shipping game.
"""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,subprocess,json
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports'/'hub-browser';out.mkdir(parents=True,exist_ok=True)
def snap(p,name):
 path=out/(name+'.png');p.screenshot(path=str(path));return subprocess.check_output(['tesseract',str(path),'stdout'],stderr=subprocess.DEVNULL,text=True)
def click(p,x,y):p.mouse.click(x,y);p.wait_for_timeout(350)
with sync_playwright() as pw:
 browser=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 p=browser.new_page(viewport={'width':1440,'height':900});errors=[]
 p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
 p.goto(os.environ.get('ASH_WEB_URL','http://127.0.0.1:8899'));p.wait_for_timeout(6000)
 text=snap(p,'01-main');assert 'ASH & OATH' in text and 'Fight creatures' in text,text
 click(p,300,595);text=snap(p,'02-creatures');assert 'BONE PATROL' in text and 'SWIFT PACK' in text,text
 click(p,1200,700);p.wait_for_timeout(500)
 for hero in range(3):click(p,180,280);click(p,490,280);click(p,1130,830)
 snap(p,'03a-action-roll');p.wait_for_timeout(1400);text=snap(p,'03-direct-swift-battle');assert 'CREATURE' in text,text
 click(p,350,125);click(p,650,590);text=snap(p,'04-swift-cards');assert text.count('Movement Creature')>=2,text
 click(p,1200,850);click(p,350,125);click(p,810,475);text=snap(p,'05-return-main');assert 'Build your party' in text,text
 click(p,300,530);click(p,880,160);text=snap(p,'06-equipment');assert 'Beginning Soul' in text and 'Dagger' in text and 'Broken Body' in text,text
 click(p,450,445);click(p,440,489);text=snap(p,'07-unequipped');assert 'None equipped' in text,text
 p.wait_for_timeout(1500);p.reload();p.wait_for_timeout(6000);click(p,300,530);click(p,880,160);text=snap(p,'08-equipment-saved');assert 'None equipped' in text and 'Beginning Soul' in text,text
 click(p,450,445);click(p,440,516)
 click(p,200,850);text=snap(p,'09-roomy-forge');assert 'SELECTED SQUARE' in text and 'BODY LIMITS' in text,text
 click(p,1300,60);click(p,450,692);text=snap(p,'10-options');assert 'COMBAT RULES' in text and 'PRESENTATION' in text and 'ANY TIME' in text,text
 click(p,450,506);text=snap(p,'11-opening-only');assert 'OPENING ONLY' in text,text
 click(p,450,506);click(p,1050,746)
 # Isolated deterministic fixture exercises actual Poke and Blank controls.
 p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8900'));p.wait_for_timeout(6000);p.wait_for_function('typeof window.essenceProof === "function"')
 def fixture(mode):
  p.evaluate('(m)=>window.essenceProof(m)',mode)
  p.wait_for_function('()=>{window.essenceProof("state");return !JSON.parse(window.essenceState).rolling;}')
  p.wait_for_timeout(250)
 def state():p.evaluate('(m)=>window.essenceProof(m)','state');return p.evaluate('JSON.parse(window.essenceState)')
 fixture('equipment_all');text=snap(p,'12-owned-sprites');assert all(word in text for word in ['Beginning','Hollow','Memory']) and 'ashroad' in state()['souls'][0],text
 click(p,450,640);click(p,450,714);assert state()['memories'][0]=='memory_loss'
 fixture('poke');before=state();click(p,920,763);text=snap(p,'13-poke-target');assert 'DAGGER' in text and 'POKE' in text,text
 click(p,650,445);after=state();assert after['boss_hp']==before['boss_hp']-1 and after['used']==before['used'] and after['dagger_used'][0]
 text=snap(p,'14-poke-used');assert 'Poke used' in text,text
 fixture('beginning');click(p,900,245);click(p,78,638);after=state();assert after['positions'][0]==[0,6] and after['used'][0][0]
 # A second rolled Blank still cannot give another move in this turn.
 click(p,900,442);click(p,78,562);assert state()['positions'][0]==[0,6]
 snap(p,'15-beginning-limit')
 assert not errors,errors
 report={'result':'passed','browser_errors':errors,'tested':['main menu','direct Swift Pack via party creation','creature card dice','main menu return','equipment selectors and reload persistence','roomy Forge','reroll timing options','four owned item sprites','Memory equipment','Poke target, HP damage and no die cost','Poke once per turn','Beginning Soul Move 1 and second-Blank restriction']}
 (out/'results.json').write_text(json.dumps(report,indent=2));print(json.dumps(report));browser.close()
