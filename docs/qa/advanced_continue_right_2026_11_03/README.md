# Advanced OR Continue alignment

The dialogue toolbar now orders Autoplay, Skip, Dialogue log, then a flexible spacer and Continue at the right. The compact result row uses the same right edge for Continue. No dialogue text, surgery action, probability, or timing changed.

- Godot headless `advanced_petra_ui_test.gd`: 35 checks, 0 failures.
- Godot visible native window `advanced_petra_ui_test.gd -- --native`: 50 checks, 0 failures. The driver uses an isolated in-memory session and programmatic button signals; these screenshots demonstrate actual Godot rendering, not manual mouse input.
- `t01_dialogue_toolbar.png` and `t01_result_compact.png` show the two Continue states. Their right edges align within the 24 px assertion tolerance. `t02_english.png` confirms the English toolbar uses the same arrangement.
- The native engine log contains no script errors or missing-resource errors. No player save was written.
