"""Create a separate local Essence browser fixture; never adds test hooks to the game.
Import/export the resulting project with Godot 4.6.3 and the standard web templates.
"""
from pathlib import Path
import shutil
import argparse,subprocess
parser=argparse.ArgumentParser();parser.add_argument('--output',required=True);args=parser.parse_args()
src=Path(__file__).resolve().parents[1];dst=Path(args.output)
if dst.exists():raise SystemExit("Choose a new empty output path; existing files will not be overwritten.")
dst.mkdir(parents=True)
for name in subprocess.check_output(['git','ls-files','--cached','--others','--exclude-standard','-z'],cwd=src).decode().split('\0'):
 if not name:continue
 rel=Path(name)
 if rel.parts[0] in ['docs','downloads','tools','exports']:continue
 target=dst/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src/rel,target)
s=(dst/'project.godot').read_text();import re
s=re.sub(r'run/main_scene=.*', 'run/main_scene="res://local_verification.tscn"',s);(dst/'project.godot').write_text(s)
(dst/'export_presets.cfg').write_bytes((src/'tools/web_export_presets.cfg').read_bytes());(dst/'exports/web').mkdir(parents=True,exist_ok=True)
(dst/'local_verification.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://local_verification.gd" id="1"]\n[node name="Verification" type="Node"]\nscript = ExtResource("1")\n')
(dst/'local_verification.gd').write_text((src/'tools'/'essence_fixture.gd').read_text())
