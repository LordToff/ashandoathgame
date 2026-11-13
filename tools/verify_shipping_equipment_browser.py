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
  def tap_words(phrase):
   file=capture('current');tsv=subprocess.check_output(['tesseract',str(file),'stdout','--psm','11','tsv'],stderr=subprocess.DEVNULL,text=True)
   lines={}
   for item in csv.DictReader(io.StringIO(tsv),delimiter='\t',quoting=csv.QUOTE_NONE):
    if item.get('text','').strip():lines.setdefault((item['block_num'],item['par_num'],item['line_num']),[]).append(item)
   for line in lines.values():
    text=' '.join(item['text'] for item in line)
    if phrase.lower() in text.lower():
     start=text.lower().index(phrase.lower());end=start+len(phrase);selected=[];offset=0
     for item in line:
      if offset<end and offset+len(item['text'])>start:selected.append(item)
      offset+=len(item['text'])+1
     left=min(int(i['left']) for i in selected);right=max(int(i['left'])+int(i['width']) for i in selected);top=min(int(i['top']) for i in selected);bottom=max(int(i['top'])+int(i['height']) for i in selected)
     (p.touchscreen.tap if mobile else p.mouse.click)((left+right)/2/scale,(top+bottom)/2/scale);p.wait_for_timeout(500);return
   raise AssertionError((phrase,ocr(file)))
  assert 'v0.40' in ocr(capture('main-menu'))
  tap_words('Camp & Essence Forge');tap_words('Equipment')
  if not mobile:
   p.mouse.click(155,445);p.wait_for_timeout(350)
   text=ocr(capture('weapon'));assert 'minimum 2' in text and 'maximum 5' in text and 'Poke' in text,text
   p.mouse.click(155,347);p.wait_for_timeout(350)
   text=ocr(capture('body'));assert 'Defense' in text and 'Movement' in text and 'Skill' in text,text
   p.mouse.click(1290,62);p.wait_for_timeout(300);p.mouse.click(1090,685);p.wait_for_timeout(500)
   text=ocr(capture('trial-lobby'));assert 'Skirmisher' in text and '6 HP' in text and 'No Memory' in text,text
  else:
   text=ocr(capture('equipment'));assert 'Broken Body' in text and 'Defense' in text and 'Weapon' in text,text
  assert not errors,errors
  rows.append({'viewport':[width,height],'result':'passed','no_test_hooks':True,'browser_errors':errors});c.close()
 b.close()
(out/'results.json').write_text(json.dumps(rows,indent=2));print(json.dumps(rows))
