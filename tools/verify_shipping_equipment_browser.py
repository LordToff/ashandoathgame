"""Smoke test the shipping export with real inputs and OCR, without game hooks."""
from pathlib import Path
from playwright.sync_api import sync_playwright
import csv,io,json,os,subprocess
os.environ['OMP_THREAD_LIMIT']='1'
out=Path(__file__).resolve().parents[1]/'exports/shipping-equipment';out.mkdir(parents=True,exist_ok=True)
rows=[]
with sync_playwright() as pw:
 b=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 for width,height in [(1440,900),(390,844)]:
  mobile=width==390;scale=2 if mobile else 1
  c=b.new_context(viewport={'width':width,'height':height},is_mobile=mobile,has_touch=mobile,device_scale_factor=scale)
  p=c.new_page();errors=[];p.on('pageerror',lambda e:errors.append(str(e)));p.on('console',lambda m:errors.append(m.text) if m.type=='error' else None)
  p.goto(os.environ.get('ASH_SHIPPING_URL','http://127.0.0.1:8953'));p.wait_for_timeout(6500)
  assert p.evaluate('typeof window.essenceProof')=='undefined'
  def capture(name):
   file=out/f'{width}x{height}-{name}.png';p.screenshot(path=str(file));return file
  def ocr(file):return subprocess.check_output(['tesseract',str(file),'stdout','--psm','11'],stderr=subprocess.DEVNULL,text=True)
  def tap_words(phrase,last=False):
   file=capture('current');tsv=subprocess.check_output(['tesseract',str(file),'stdout','--psm','11','tsv'],stderr=subprocess.DEVNULL,text=True)
   lines={}
   for item in csv.DictReader(io.StringIO(tsv),delimiter='\t',quoting=csv.QUOTE_NONE):
    if item.get('text','').strip():lines.setdefault((item['block_num'],item['par_num'],item['line_num']),[]).append(item)
   for line in (list(lines.values())[::-1] if last else lines.values()):
    text=' '.join(item['text'] for item in line)
    if phrase.lower() in text.lower():
     start=text.lower().index(phrase.lower());end=start+len(phrase);selected=[];offset=0
     for item in line:
      if offset<end and offset+len(item['text'])>start:selected.append(item)
      offset+=len(item['text'])+1
     left=min(int(i['left']) for i in selected);right=max(int(i['left'])+int(i['width']) for i in selected);top=min(int(i['top']) for i in selected);bottom=max(int(i['top'])+int(i['height']) for i in selected)
     (p.touchscreen.tap if mobile else p.mouse.click)((left+right)/2/scale,(top+bottom)/2/scale);p.wait_for_timeout(500);return
   raise AssertionError((phrase,ocr(file)))
  assert 'v0.43' in ocr(capture('main-menu'))
  def scroll_down():
   if not mobile:p.mouse.move(width*.7,height*.55);p.mouse.wheel(0,340);p.wait_for_timeout(300);return
   session=c.new_cdp_session(p);sx=width*.8;sy=height*.68
   session.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':sx,'y':sy}]})
   for i in range(1,9):
    session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':sx,'y':sy-160*i/8}]});p.wait_for_timeout(45)
   p.wait_for_timeout(200);session.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':sx,'y':sy-160}]});p.wait_for_timeout(150);session.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]});p.wait_for_timeout(400)
  def find_and_tap(phrase):
   for attempt in range(10):
    try:tap_words(phrase,last=True);return
    except AssertionError:scroll_down()
   raise AssertionError(('Not reachable',phrase,ocr(capture('missing'))))
  tap_words('Camp');capture('camp-home');find_and_tap('Open equip gear');text=ocr(capture('equipment'));assert 'Weapon' in text and ('Attack' in text or 'Dagger' in text),text
  tap_words('Body');text=ocr(capture('body'));assert 'Defense' in text and 'Movement' in text and 'Skill' in text,text
  tap_words('Soul');text=ocr(capture('soul'));assert 'HP' in text and 'Blank' in text,text
  tap_words('Help');text=ocr(capture('context-help'));assert 'Help' in text and 'Topic' in text,text
  tap_words('Back to game');tap_words('Back to Camp');tap_words('Main menu')
  tap_words('Prepare my party');find_and_tap('Prepare remaining');text=ocr(capture('normal-party'));assert 'Ready' in text,text
  tap_words('Next: choose');text=ocr(capture('boss-choice'));assert 'Hollow' in text,text
  tap_words('Next: road');text=ocr(capture('road-event'));assert 'road event' in text.lower(),text
  assert not errors,errors
  rows.append({'viewport':[width,height],'result':'passed','no_test_hooks':True,'browser_errors':errors,'tested':['main modes','Camp task navigation','Body/Soul/Weapon explanations','context Help and return','normal suggested party','boss and required road event']});c.close()
 b.close()
(out/'results.json').write_text(json.dumps(rows,indent=2));print(json.dumps(rows))
