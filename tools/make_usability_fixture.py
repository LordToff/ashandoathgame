"""Create a separate local browser fixture; never adds test hooks to the game.
Import/export the resulting project with Godot 4.6.3 and the standard web templates.
"""
from pathlib import Path
import shutil
import argparse,subprocess
parser=argparse.ArgumentParser();parser.add_argument('--output',required=True);args=parser.parse_args()
src=Path(__file__).resolve().parents[1];dst=Path(args.output)
if dst.exists():raise SystemExit("Choose a new empty output path; existing files will not be overwritten.")
dst.mkdir(parents=True)
for name in subprocess.check_output(['git','ls-files','-z'],cwd=src).decode().split('\0'):
 if not name:continue
 rel=Path(name)
 if rel.parts[0] in ['docs','downloads','tools','exports']:continue
 target=dst/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src/rel,target)
s=(dst/'project.godot').read_text();import re
s=re.sub(r'run/main_scene=.*', 'run/main_scene="res://local_verification.tscn"',s);(dst/'project.godot').write_text(s)
(dst/'export_presets.cfg').write_bytes((src/'tools/web_export_presets.cfg').read_bytes());(dst/'exports/web').mkdir(parents=True,exist_ok=True)
(dst/'local_verification.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://local_verification.gd" id="1"]\n[node name="Verification" type="Node"]\nscript = ExtResource("1")\n')
(dst/'local_verification.gd').write_text('''extends Node
var app
var callback
func _ready():
 app = load("res://prototype/prototype.tscn").instantiate();add_child(app)
 await get_tree().process_frame
 if OS.has_feature("web"):
  callback = JavaScriptBridge.create_callback(proof)
  JavaScriptBridge.get_interface("window").ashProof = callback
func fresh():
 app.draft_modal = false;app.begin();app.game.active = 0;app.game.cursor = app.game.order.find(0);app.game.pending = {};app.game.forced_die = -1
 app.game.heroes[0].pos = Vector2i(2,3)
 for h in app.game.heroes:h.used = [false,false,false];h.results = [6,1,5];h.rolls = [0,0,0];h.reaction = [2];h.used[2] = true
 app.game.heroes[0].build = [[6,6,6,6,6,6],[1,1,1,1,1,1],[5,5,5,5,5,5]]
 app.game.heroes[0].opening = false
 app.inspect_actor = 0;app.selected = -1;app.combat_notices.clear();app.rebuild()
func proof(args):
 var mode: String = str(args[0])
 fresh()
 if mode == "poison":app.game.apply_poison(3,0,1);app.game.apply_poison(3,0,1);app.game.tick_poison(0)
 if mode == "borrow":
  app.game.heroes[0].results[0] = 16;app.game.heroes[1].used = [true,true,true];app.game.heroes[1].results = [4,2,1]
  app.game.hero_action(0)
 if mode == "reaction":
  app.game.pending = {"kind":"attack","action":"Test hit","victims":[0],"reacted":[],"amount":2,"source":3,"range":1};app.game.continue_attack()
 if mode == "focus":pass
 app.rebuild()
''')
