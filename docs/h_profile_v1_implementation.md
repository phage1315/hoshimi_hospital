# H Profile V1 — system implementation boundary

This V1 is being built as a separate, directly testable interaction loop before
any character profile or authored event is wired into production staff data.
The current legacy `adult_intimacy_session.gd` remains untouched during this
prototype; migration or schema merging is a later decision.

## First-pass loop

`foreplay (MAX prompt, optional further touches) -> explicit style choice -> h_stage -> manual h_finish -> one final response -> after_cg + external VN aftercare -> completed`

- Foreplay is a click on one of the nine character-specific body-map zones plus
  one of four actions: `caress`, `kiss`, `lick`, `light_bite`.
- Preference resolution: exact action/zone override, action-wide default,
  zone default, then `mild` fallback.
- Action-wide defaults are sparse: an action with no explicit default falls
  through to the zone preference. This preserves the authored Sayaka design
  where `light_bite` has a global `mild` default and the other actions use zone
  preferences.
- Gains are fixed: `low +2`, `mild +6`, `strong +12`, `favorite +18`, capped
  at 100. No hidden affinity, refusal, shame, decay, score, or position system
  is part of this first-pass loop.
- Reaction resolution: `combo` -> `zone_tier` at the actual resolved tier ->
  `action_tier` at that tier -> `tier_fallback`.
- A body map is a separate JSON document. Its current normalized UV polygons
  are tentative coordinates drafted against the supplied base image, not a
  calibrated final. They remain marked `draft` until the user validates them
  in the event test.
- Arms, shoulders, and buttocks are not interactive zones in V1. Breast-region
  hotspot polygons should be calibrated to visible body pixels; do not extend
  any hotspot over the arms or bedding.
- Sayaka's supplied base CGs are copied under
  `assets/characters/h_profile_v1/doc_sayaka/`. The body-map polygons remain a
  `draft` pending user event-test validation.
- The original V1.2 profile and V1.3.1 profile remain as historical inputs. The
  V1.3.2 authored profile is at `data/staff/doc_sayaka/h_profile_v1_3_2.json`,
  with its business-flow sidecar at `data/staff/doc_sayaka/h_flow_v1_3_2.json`.
  The package's nine old values matched exactly; only `dialogue.scene` changed.
  The MAX prompt, entry style, random draw plan, and two free-H aftercare lines
  are adapted from the sidecar and never inserted into the profile's reaction
  pools. The four archived V1.2 aftercare lines remain excluded. The ZIP's
  empty body-map draft was not imported over the existing tentative polygon
  draft.
- The six expression IDs use the approved transparent 3×2 atlas in row-major
  positions. Atlas rectangles follow the actual 1529×1029 image gutters rather
  than assuming equal 512px cells. Idle is top-right; low/mild/strong/favorite
  reactions map to top-middle, top-left, bottom-left, and bottom-middle; the
  100 excitement transition uses bottom-right. An authored reaction expression
  overrides the tier fallback. The earlier blue-drape atlas is retained as v1,
  but the test screen uses the approved v2 transparent sheet.
- MAX displays its prompt once, leaves foreplay interactions enabled, and does
  not advance automatically. The player's explicit gentle/intense choice only
  selects the opening and midpoint style lines; it does not affect gameplay
  results. Phase two draws two lines without replacement from the start and
  middle pools. The legacy `scene.finish` lines remain in the authored profile
  but are not automatically played. After the initial phase-two lines, one
  stable random global `h_finish` label is shown. Clicking it locks the action,
  independently draws and plays one of Sayaka's four finish responses, and waits
  for the player to advance that response before setting the transient
  `h_event_completed` result and entering aftercare. The H-stage-to-after-CG
  switch uses a roughly 4.5-second pixelation, desaturation, and darkening
  transition with input blocked during the transition.
  The five labels are visual variants of the same action, not distinct choices.
- The repeatable test opens with the two authored hotel-entry lines, then runs
  foreplay, the selected H-stage sequence, and after-CG with two external VN
  aftercare lines. These screens use the existing `date_hotel` background
  (`hotel_room_night_v2.png`); the supplied H-stage and after-CG remain the
  foreground images. Completion returns to the Event Test Hub, where the loop
  can be started again. Generic free-H aftercare is not injected into Lv4.

## Data contracts and current boundaries

- `data/schemas/h_profile_v1.schema.json` defines profile data independently of
  the current doctor/staff schema.
- `data/schemas/h_bodymap_v1.schema.json` defines the normalized clickable
  polygons independently from preferences and dialogue.
- `godot/systems/h_profile_v1_session.gd` implements preference resolution,
  hotspot hit-testing, reaction routing, phase transitions, and session
  snapshot/restore.
- `data/staff/doc_sayaka/h_context_overrides_v1.json` is the sparse per-location
  and per-event override sidecar. `scene_content_context.gd` resolves event
  dialogue, location dialogue, then the existing profile text. Location image
  slots resolve independently to their existing base images. Callers pass the
  location/event/locale when opening a session; the current test entry defaults
  to `hotel` with no event override.
- Dialogue keys may override `entry`, `reaction.combo:<action>|<zone>`,
  `reaction.zone_tier:<zone>|<tier>`,
  `reaction.action_tier:<action>|<tier>`,
  `reaction.tier_fallback:<tier>`, `max_prompt`, `style.opening.<style>`,
  `style.midpoint.<style>`, `scene.start`, `scene.middle`, `scene.finish`,
  `finish.labels`, `finish.responses`, and `aftercare`. Values are locale keyed
  arrays. A matching array replaces the corresponding pool. A missing key
  falls through; an explicitly empty or malformed pool is an error.
- Location asset slots are `background` (`{"id": "date_hotel"}`), `body_map`,
  `h_stage`, and `after_cg` (`{"path": "res://..."}`). Each missing slot uses
  its own base asset. A body-map replacement must declare the same `layout_id`,
  width and height as the base; art review must also confirm identical character
  placement, scale, pose and crop. Click coordinates are now mapped through the
  actual centered image rectangle, excluding letterbox margins.
- This first pass does not start from a character event, unlock locations,
  consume a day, or commit relationship rewards. Event handoff is later work.
- The Event Test Hub has a direct repeatable Sayaka H test entry. It exercises
  authored hotel-entry lines, MAX and both entry styles, foreplay on body-map
  hotspots, reaction portraits from the expression atlas, sampled H-stage
  dialogue, manual finish, after-CG and external free-H aftercare. This test entry does not
  start or modify a Lv4 event, consume a day, or write a save.

The resolver's general contract and sample bundle are documented in
`docs/scene_content_context.md`. The optional override sidecar currently has
empty event and location layers, so it preserves the existing hotel test
content until authored overrides and location-specific images are supplied.

## Test

Run `godot --headless --path . --script tools/h_profile_v1_system_test.gd` when
Godot is available. It checks synthetic preference/reaction cases, imported
Sayaka dialogue preservation, and atlas regions. Run
`godot --headless --path . --script tools/h_profile_v1_ui_test.gd` for the
end-to-end UI test. It opens the title-screen Event Test Hub, enters the direct
Sayaka test, taps the body map through the UI handler, checks the selected zone
and portrait, verifies MAX does not force an advance, checks both style paths
and no-repeat draws, confirms phase two waits for the manual finish action,
rejects duplicate finish input, advances the sampled final response and
aftercare lines, confirms both CGs load, then starts a fresh loop again from the hub. It also
verifies no game time was consumed. The clinical palpation/body-map system
remains separate.
