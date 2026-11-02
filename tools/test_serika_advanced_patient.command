#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
exec "/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot" --path "$PWD" --log-file "/tmp/hoshimi_serika_manual_$$.log" --script tools/advanced_staff_patient_playtest.gd -- --serika
