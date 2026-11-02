"""Verify normal Camp/events plus a separate deterministic Essence fixture.
Build the normal game and tools/make_essence_fixture.py output with Godot 4.6.3.
Serve them only on loopback ports 8890/8891, or set ASH_WEB_URL/ASH_FIXTURE_URL.
Requires Playwright, Chromium and Tesseract. Writes ignored exports/essence-browser.
No remote writes, player save edits or publication.
"""
from playwright.sync_api import sync_playwright
from pathlib import Path
import os,subprocess,json
os.environ['OMP_THREAD_LIMIT']='1';out=Path(__file__).resolve().parents[1]/'exports'/'essence-browser';out.mkdir(parents=True,exist_ok=True)
def snap(p,name):
 path=out/(name+'.png');p.screenshot(path=str(path));return subprocess.check_output(['tesseract',str(path),'stdout'],stderr=subprocess.DEVNULL,text=True)
def click(p,x,y):p.mouse.click(x,y);p.wait_for_timeout(300)
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 p=b.new_page(viewport={'width':1440,'height':900});errors=[]
 p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);p.on('pageerror',lambda e:errors.append(str(e)))
 p.goto(os.environ.get('ASH_WEB_URL','http://127.0.0.1:8890'));p.wait_for_timeout(6500)
 for hero in range(3):click(p,180,280);click(p,490,280);click(p,1130,830)
 click(p,480,850);text=snap(p,'01-camp-before-crafting');assert 'ESSENCE FORGE' in text and 'hidden until crafted' in text,text
 assert 'Bone Growth' not in text and 'Bone Strike' not in text,text
 click(p,1200,860);click(p,1200,850);text=snap(p,'02-required-event');assert 'THE ASH ROAD' in text,text
 # Resolve safe event options until a live mixed group is genuinely rolled.
 for trial in range(40):
  click(p,720,620);text=snap(p,'event-current')
  if 'Fight mixed prototype group' in text:
   click(p,1040,710);p.wait_for_timeout(1000);click(p,350,125);click(p,650,590);text=snap(p,'03-real-mixed-enemy-cards')
   assert 'Support Creature' in text and 'Movement Creature' in text and 'Mend' in text,text
   break
  click(p,400,710);click(p,330,710)
 else:raise AssertionError('No mixed group rolled')
 p.goto(os.environ.get('ASH_FIXTURE_URL','http://127.0.0.1:8891'));p.wait_for_timeout(6000);p.wait_for_function('typeof window.essenceProof === "function"')
 def fixture(mode):p.evaluate('(m)=>window.essenceProof(m)',mode);p.wait_for_timeout(600)
 def state():fixture('state');return p.evaluate('JSON.parse(window.essenceState)')
 fixture('victory');text=snap(p,'04-victory-banking');assert 'Bone Creature Essence' in text,text
 assert state()['bank']['bone_creature']==2
 click(p,650,640);text=snap(p,'05-defeated-card-tokens');assert text.count('1 Essence token')>=2,text
 click(p,1200,850);click(p,650,595);text=snap(p,'06-bank-at-camp');assert '2 Essence' in text,text
 click(p,620,240);assert state()['copies']['60']==1 and state()['bank']['bone_creature']==1
 text=snap(p,'07-first-craft-reveal');assert 'Bone Growth' in text and 'Move 1' in text,text
 click(p,620,240);assert state()['copies']['60']==2 and state()['bank']['bone_creature']==0
 data=state();slot=next((d,s) for d,die in enumerate(data['builds'][0]) for s,f in enumerate(die) if f==7)
 click(p,847+slot[1]*94,517+slot[0]*72);assert state()['builds'][0][slot[0]][slot[1]]==60
 snap(p,'08-second-copy-and-refit')
 fixture('support_camp');click(p,250,535);click(p,620,535);assert state()['bank']['support_creature']==6
 click(p,1080,510);assert state()['memories'][0]=='memory_loss';snap(p,'09-memory-crafted-equipped')
 fixture('remedy');text=snap(p,'10-remedy-after-self-heal');assert state()['hp'][0]==4 and 'Shared Remedy' in text,text
 click(p,650,495);assert state()['hp'][1]==4
 fixture('burden');text=snap(p,'11-burden-rolled-history');assert 'Guard' in text,text
 click(p,650,410);click(p,485,485);assert state()['active']==1
 click(p,900,580);assert state()['block'][1]==1
 click(p,900,710);assert state()['active']==0;snap(p,'12-burden-returned-owner')
 fixture('evasive');click(p,520,505);text=snap(p,'13-evasive-post-attack');assert 'no HP lost' in text,text
 click(p,520,452);assert state()['hp'][0]==6
 fixture('friendly');text=snap(p,'friendly-evasive-before');assert 'Friendly Attack' in text,text
 click(p,530,534);text=snap(p,'friendly-evasive-after');assert 'no HP lost' in text and state()['hp'][1]==6,text
 click(p,520,452)
 fixture('defeat');text=snap(p,'14-defeat-bank-safe');assert state()['bank']['bone_creature']==7 and 'discarded' in text,text
 # Screenshot of all three provisional creature cards.
 fixture('mixed');snap(p,'15-prototype-cards')
 assert not errors,errors
 report={'normal_flow':'passed','deterministic_fixture_ui':'passed','errors':errors,'tested':['hidden recipes','genuine event to mixed encounter','individual defeated-card tokens','victory banking','same-cost second copy','legal refitting','Memory crafting/equip and healing','Shared Burden source/ally/return','Evasive post-Attack step','defeat preserves bank']}
 (out/'results.json').write_text(json.dumps(report,indent=2));print('PASS actual browser Camp/events and all deterministic progression/ability UI scenarios; no browser errors.',flush=True)
 b.close()
