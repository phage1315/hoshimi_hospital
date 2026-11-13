extends Node
const PreopSession = preload("res://godot/systems/preop_session.gd")
## Local prerecorded dialogue only; never serialized into player saves.

const SURGICAL_ACTORS := {
	"doc_aoi": true,
	"doc_rei": true,
	"doc_emiko": true,
	"doc_artoria": true,
	"doc_asuka": true,
	"doc_shiori": true,
	"doc_aqua": true,
	"doc_sayaka": true,
	"doc_serika": true,
	"doc_minato": true,
	"doc_takemi": true,
	"visiting_maya": true,
	"visiting_futaba": true,
	"doc_sakura_anesthesiology": true,
	"nurse_hiroko": true,
	"nurse_haru": true,
	"nurse_yui": true,
	"nurse_rin": true,
	"nurse_ange": true,
	"nurse_moe": true,
	"nurse_iwasaki_rumi": true,
	"nurse_yoneda_shiori": true,
	"nurse_sonoda_itsumi": true,
	"nurse_kariya_megumi": true,
	"nurse_hikami_saeko": true,
	"patient_chihaya": true,
	"guest_mizuho": true,
}

const NON_SURGICAL_ACTORS := {
	"pharmacist_manami": true,
	"nurse_ishigami": true,
	"nurse_satsuki": true,
	"guest_ayako": true,
}

const DAILY_SLOTS := {
	"greeting": "ohayou.wav",
	"otsukaresama": "otsukaresama.wav",
	"neutral": "neutral.wav",
	"smile": "smile.wav",
	"serious": "serious.wav",
	"worried": "worried.wav",
	"tired": "tired.wav",
	"surprised": "surprised.wav",
}

const SURGICAL_SLOTS := {
	"timeout": "timeout.wav",
	"or_clear": "or_clear.wav",
	"or_caution": "or_caution.wav",
}

const VOICE_CUES_PATH := "res://data/audio/event_voice_cues.json"
const BGM_DUCK_DB := -9.5
const DUCK_ATTACK_SECONDS := 0.08
const DUCK_HOLD_SECONDS := 0.28
const DUCK_RELEASE_SECONDS := 0.50
const TARGET_ACTIVE_RMS_DB := -15.5
const MAX_VOICE_BOOST_DB := 16.5
const MAX_VOICE_CUT_DB := -2.0
const VOICE_LIMITER_CEILING_DB := -0.5

const EXPRESSION_FINE_SLOT := {
	"shy": "shy",
	"shy_reproach": "shy",
	"embarrassed": "shy",
	"teasing": "teasing",
	"playful": "teasing",
}

const SILENT_EXPR_OUTFITS := {
	"adult_nude": true,
	"intraoperative": true,
	"intraoperative_avatar": true,
	"operating_patient": true,
	"operating_table": true,
	"operating_table_lithotomy": true,
	"or_table_awake": true,
	"patient_gown": true,
	"postop_patient": true,
	"postop_recovery": true,
	"preop_patient": true,
	"preop_patient_gown": true,
	"ward_preparation": true,
}

const EXPRESSION_TO_SLOT := {
	"neutral": "neutral",
	"calm": "neutral",
	"soft": "neutral",
	"talking": "neutral",
	"awake": "neutral",
	"smile": "smile",
	"warm": "smile",
	"gentle_smile": "smile",
	"closed_eye_smile": "smile",
	"soft_smile": "smile",
	"competitive_smile": "smile",
	"dry_smile": "smile",
	"wry_smile": "smile",
	"bright": "smile",
	"pharm_bright": "smile",
	"pharm_smile": "smile",
	"pharm_playful": "smile",
	"playful": "smile",
	"happy": "smile",
	"joyful": "smile",
	"cheerful": "smile",
	"laugh": "smile",
	"amused": "smile",
	"pleased": "smile",
	"teasing": "smile",
	"touched": "smile",
	"relief": "smile",
	"relieved": "smile",
	"masked_warm": "smile",
	"serious": "serious",
	"focused": "serious",
	"stern": "serious",
	"professional": "serious",
	"pharm_professional": "serious",
	"pharm_thoughtful": "serious",
	"thoughtful": "serious",
	"observing": "serious",
	"determined": "serious",
	"guarded": "serious",
	"cold": "serious",
	"brave": "serious",
	"masked_focused": "serious",
	"worried": "worried",
	"nervous": "worried",
	"troubled": "worried",
	"pensive": "worried",
	"tense": "worried",
	"shy": "worried",
	"shy_reproach": "worried",
	"embarrassed": "worried",
	"afraid": "worried",
	"hurt": "worried",
	"tearful": "worried",
	"crying": "worried",
	"strain": "worried",
	"impatient": "worried",
	"angry": "worried",
	"annoyed": "worried",
	"pout": "worried",
	"masked_hesitant": "worried",
	"masked_tense": "worried",
	"tired": "tired",
	"exhausted": "tired",
	"bored": "tired",
	"depressed": "tired",
	"sad": "tired",
	"drowsy": "tired",
	"blank": "tired",
	"blurred_focus": "tired",
	"nausea": "tired",
	"pale": "tired",
	"surprised": "surprised",
	"pharm_surprised": "surprised",
	"startled": "surprised",
	"shocked": "surprised",
	"excited": "surprised",
	"terrified": "surprised",
}

var VOICE_ACTORS: Dictionary = _build_voice_actors()
var VOICE_CUE_MANIFEST: Dictionary = _load_voice_cue_manifest()
var CLIPS: Dictionary = _build_clips(VOICE_CUE_MANIFEST)
var FAVORITE_DATE_CLIPS: Dictionary = VOICE_CUE_MANIFEST.get("favorite_date_clips", {}).duplicate()
var EVENT_NODE_CUES: Dictionary = VOICE_CUE_MANIFEST.get("nodes", {}).duplicate()
var H_RUNNER_CUES: Dictionary = VOICE_CUE_MANIFEST.get("h_runner", {}).duplicate(true)
var player := AudioStreamPlayer.new()
var voice_limiter: AudioEffectHardLimiter = null
var bgm_ducker: AudioEffectAmplify = null
var bgm_duck_db := 0.0
var duck_hold_remaining := 0.0
var clip_gain_cache: Dictionary = {}
var current_context := ""
var played: Dictionary = {}
var play_count := 0
var last_played_clip := ""
var staff_view_actor := ""
var staff_view_outfit := ""
var staff_view_expression := ""
var staff_visit_serial := 0

static func _build_voice_actors() -> Dictionary:
	var result := {}
	for actor_id in SURGICAL_ACTORS.keys():
		result[actor_id] = true
	for actor_id in NON_SURGICAL_ACTORS.keys():
		result[actor_id] = true
	return result

static func _load_voice_cue_manifest() -> Dictionary:
	if not FileAccess.file_exists(VOICE_CUES_PATH):
		return {"schema_version": 1, "extra_clips": {}, "favorite_date_clips": {}, "nodes": {}}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(VOICE_CUES_PATH))
	if parsed is Dictionary:
		return parsed
	return {"schema_version": 1, "extra_clips": {}, "favorite_date_clips": {}, "nodes": {}}

static func valid_cue_manifest(config: Variant, clips: Dictionary) -> bool:
	if not config is Dictionary:
		return false
	if int(config.get("schema_version", 0)) != 1:
		return false
	for section in ["extra_clips", "favorite_date_clips", "nodes"]:
		if not config.get(section) is Dictionary:
			return false
	for clip_id in config["extra_clips"].keys():
		var path: Variant = config["extra_clips"][clip_id]
		if not clip_id is String or not path is String or str(path).is_empty():
			return false
	for section in ["favorite_date_clips", "nodes"]:
		for key in config[section].keys():
			var clip_id: Variant = config[section][key]
			if not key is String or not clip_id is String or not clips.has(str(clip_id)):
				return false
	if config.has("h_runner"):
		if not config["h_runner"] is Dictionary:
			return false
		for actor_id in config["h_runner"].keys():
			var h_cfg: Variant = config["h_runner"][actor_id]
			if not actor_id is String or not h_cfg is Dictionary:
				return false
			for list_field in ["entry", "stage_start", "finish", "aftercare"]:
				var arr: Variant = h_cfg.get(list_field, [])
				if not arr is Array:
					return false
				for cid in arr:
					if not cid is String or not clips.has(str(cid)):
						return false
			for str_field in ["max_prompt", "event_overlay_1", "event_overlay_3", "stage_mid", "stage_build", "stage_near"]:
				var scid := str(h_cfg.get(str_field, ""))
				if not scid.is_empty() and not clips.has(scid):
					return false
			var tiers: Variant = h_cfg.get("foreplay_tiers", {})
			if not tiers is Dictionary:
				return false
			for tier_key in tiers.keys():
				var t_arr: Variant = tiers[tier_key]
				if not t_arr is Array:
					return false
				for cid in t_arr:
					if not cid is String or not clips.has(str(cid)):
						return false
			for dict_field in ["openings", "midpoints"]:
				var style_map: Variant = h_cfg.get(dict_field, {})
				if not style_map is Dictionary:
					return false
				for style_key in style_map.keys():
					var ocid := str(style_map[style_key])
					if not ocid.is_empty() and not clips.has(ocid):
						return false
	return true

static func _build_clips(manifest: Dictionary = _load_voice_cue_manifest()) -> Dictionary:
	var result := {}
	for actor_id in SURGICAL_ACTORS.keys():
		for slot in DAILY_SLOTS.keys():
			result["%s_%s" % [actor_id, slot]] = "res://assets/audio/voice/%s/%s" % [actor_id, DAILY_SLOTS[slot]]
		for slot in SURGICAL_SLOTS.keys():
			result["%s_%s" % [actor_id, slot]] = "res://assets/audio/voice/%s/%s" % [actor_id, SURGICAL_SLOTS[slot]]
	for actor_id in NON_SURGICAL_ACTORS.keys():
		for slot in DAILY_SLOTS.keys():
			result["%s_%s" % [actor_id, slot]] = "res://assets/audio/voice/%s/%s" % [actor_id, DAILY_SLOTS[slot]]
	var extra: Variant = manifest.get("extra_clips", {})
	if extra is Dictionary:
		for clip_id in extra.keys():
			result[str(clip_id)] = str(extra[clip_id])
	return result

func _ready() -> void:
	var trim_doc = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio/voice_gain_trim.json"))
	if trim_doc is Dictionary and trim_doc.get("clips") is Dictionary:
		clip_gain_cache = trim_doc["clips"]
	_ensure_voice_limiter()
	_ensure_bgm_ducker()
	player.bus = "Voice"
	add_child(player)

func _exit_tree() -> void:
	if bgm_ducker != null:
		bgm_ducker.volume_db = 0.0
	bgm_duck_db = 0.0
	duck_hold_remaining = 0.0

func _process(delta: float) -> void:
	step_ducking(delta)

func _ensure_voice_limiter() -> void:
	if AudioServer.get_bus_index("Voice") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Voice")
	var voice_bus := AudioServer.get_bus_index("Voice")
	if voice_limiter == null:
		for i in range(AudioServer.get_bus_effect_count(voice_bus)):
			var fx := AudioServer.get_bus_effect(voice_bus, i)
			if fx is AudioEffectHardLimiter and fx.has_meta("voice_peak_limiter"):
				voice_limiter = fx
				break
	if voice_limiter == null:
		voice_limiter = AudioEffectHardLimiter.new()
		voice_limiter.set_meta("voice_peak_limiter", true)
		voice_limiter.pre_gain_db = 0.0
		voice_limiter.ceiling_db = VOICE_LIMITER_CEILING_DB
		voice_limiter.release = 0.1
		AudioServer.add_bus_effect(voice_bus, voice_limiter)
	else:
		voice_limiter.ceiling_db = VOICE_LIMITER_CEILING_DB

func _ensure_bgm_ducker() -> void:
	if AudioServer.get_bus_index("BGM") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "BGM")
	var bgm_bus := AudioServer.get_bus_index("BGM")
	if bgm_ducker == null:
		for i in range(AudioServer.get_bus_effect_count(bgm_bus)):
			var fx := AudioServer.get_bus_effect(bgm_bus, i)
			if fx is AudioEffectAmplify and fx.has_meta("voice_bgm_ducker"):
				bgm_ducker = fx
				break
	if bgm_ducker == null:
		bgm_ducker = AudioEffectAmplify.new()
		bgm_ducker.set_meta("voice_bgm_ducker", true)
		bgm_ducker.volume_db = 0.0
		AudioServer.add_bus_effect(bgm_bus, bgm_ducker)

func step_ducking(delta: float) -> void:
	_ensure_bgm_ducker()
	var dt := maxf(delta, 0.0)
	var should_duck := player.playing
	if should_duck:
		duck_hold_remaining = DUCK_HOLD_SECONDS
	elif duck_hold_remaining > 0.0:
		duck_hold_remaining = maxf(0.0, duck_hold_remaining - dt)
		if duck_hold_remaining > 0.0:
			should_duck = true
	var target_db := BGM_DUCK_DB if should_duck else 0.0
	if target_db < bgm_duck_db:
		var attack_rate := absf(BGM_DUCK_DB) / maxf(DUCK_ATTACK_SECONDS, 0.001)
		bgm_duck_db = move_toward(bgm_duck_db, target_db, attack_rate * dt)
	elif target_db > bgm_duck_db:
		var release_rate := absf(BGM_DUCK_DB) / maxf(DUCK_RELEASE_SECONDS, 0.001)
		bgm_duck_db = move_toward(bgm_duck_db, target_db, release_rate * dt)
	bgm_ducker.volume_db = bgm_duck_db

func _clip_gain_db(clip_id: String) -> float:
	return clampf(float(clip_gain_cache.get(clip_id, 0.0)), MAX_VOICE_CUT_DB, MAX_VOICE_BOOST_DB)

func _reset_staff_view_tracking() -> void:
	staff_view_actor = ""
	staff_view_outfit = ""
	staff_view_expression = ""

func _resolve_expression_clip(actor_id: String, expression: String) -> String:
	var direct := "%s_%s" % [actor_id, expression]
	if CLIPS.has(direct):
		return direct
	var fine_slot := str(EXPRESSION_FINE_SLOT.get(expression, ""))
	if not fine_slot.is_empty():
		var fine_clip := "%s_%s" % [actor_id, fine_slot]
		if CLIPS.has(fine_clip):
			return fine_clip
	var slot := str(EXPRESSION_TO_SLOT.get(expression, ""))
	if not slot.is_empty():
		var mapped := "%s_%s" % [actor_id, slot]
		if CLIPS.has(mapped):
			return mapped
	return ""

func _active_story_event(app) -> RefCounted:
	match str(app.screen):
		"character_event":
			return app.game.character_events.get(app.game.active_character_event_id)
		"gallery_replay":
			return app.gallery_replay_event
		"special_event":
			return app.game.active_special_event
		"special_gallery_replay":
			return app.special_event_gallery_replay
	return null

func _resolve_h_runner_cue(app) -> Dictionary:
	var session = app.h_profile_test_session
	if session == null:
		return {"context": "", "clip": "", "once_key": ""}
	var actor_id := str(session.actor_id)
	var sid: int = session.get_instance_id()
	var h_cfg: Dictionary = H_RUNNER_CUES.get(actor_id, {})
	if app.screen == "h_profile_test_entry":
		var entry_idx := int(app.h_profile_test_entry_index)
		var ctx := ":%s:%s:%s" % [sid, actor_id, entry_idx]
		var entry_pool: Variant = h_cfg.get("entry", [])
		var clip := ""
		var once_key := ""
		if entry_pool is Array and not entry_pool.is_empty():
			var cur_line := str(app.h_profile_test_entry_lines[entry_idx]) if entry_idx >= 0 and entry_idx < app.h_profile_test_entry_lines.size() else ""
			var pick_idx := entry_idx
			if entry_pool.size() >= 2 and ("紧张" in cur_line or "nervous" in cur_line.to_lower()):
				pick_idx = 1
			clip = str(entry_pool[posmod(pick_idx, entry_pool.size())])
			once_key = "h_entry:%s:%s" % [sid, entry_idx]
		return {"context": ctx, "clip": clip, "once_key": once_key}
	var phase := str(session.phase)
	if phase == "foreplay":
		var hist_len: int = session.history.size()
		var ctx := ":%s:%s:foreplay:%s" % [sid, actor_id, hist_len]
		var clip := ""
		var once_key := ""
		if hist_len > 0 and not h_cfg.is_empty():
			var last_rec: Dictionary = session.history[hist_len - 1]
			if bool(last_rec.get("show_max_prompt", false)) and not str(h_cfg.get("max_prompt", "")).is_empty():
				clip = str(h_cfg["max_prompt"])
			else:
				var tier := str(last_rec.get("tier", "mild"))
				var tier_pool: Variant = h_cfg.get("foreplay_tiers", {}).get(tier, [])
				if tier_pool is Array and not tier_pool.is_empty():
					var tier_hits := 0
					for item in session.history:
						if item is Dictionary and str(item.get("tier", "")) == tier and not bool(item.get("show_max_prompt", false)):
							tier_hits += 1
					clip = str(tier_pool[posmod(maxi(tier_hits - 1, 0), tier_pool.size())])
			if not clip.is_empty():
				once_key = "h_foreplay:%s:%s" % [sid, hist_len]
		return {"context": ctx, "clip": clip, "once_key": once_key}
	if phase == "h_stage":
		var idx := int(session.h_scene_index)
		var is_event := bool(app.h_profile_event_mode)
		var style := str(session.h_scene_style)
		var ctx := ":%s:%s:h_stage:%s" % [sid, actor_id, idx]
		var clip := ""
		var once_key := ""
		if not h_cfg.is_empty():
			var offset := 3 if is_event else 0
			var stage_start: Variant = h_cfg.get("stage_start", [])
			var midpoints: Variant = h_cfg.get("midpoints", {})
			if idx == 0:
				clip = str(h_cfg.get("openings", {}).get(style, ""))
			elif is_event and idx == 1:
				clip = str(h_cfg.get("event_overlay_1", ""))
			elif is_event and idx == 3:
				clip = str(h_cfg.get("event_overlay_3", ""))
			elif idx == 1 + offset and stage_start is Array and stage_start.size() >= 1:
				clip = str(stage_start[0])
			elif idx == 2 + offset and stage_start is Array and stage_start.size() >= 2:
				clip = str(stage_start[1])
			elif idx == 3 + offset:
				if midpoints is Dictionary and midpoints.has(style):
					clip = str(midpoints[style])
				else:
					clip = str(h_cfg.get("stage_mid", ""))
			elif idx == 4 + offset:
				clip = str(h_cfg.get("stage_build", ""))
			elif idx == 5 + offset:
				clip = str(h_cfg.get("stage_near", ""))
			if not clip.is_empty():
				once_key = "h_stage:%s:%s" % [sid, idx]
		return {"context": ctx, "clip": clip, "once_key": once_key}
	if phase == "h_finish_wait":
		return {"context": ":%s:%s:h_finish_wait" % [sid, actor_id], "clip": "", "once_key": ""}
	if phase == "h_finish_response":
		var ctx := ":%s:%s:h_finish_response" % [sid, actor_id]
		var finish_pool: Variant = h_cfg.get("finish", [])
		var clip := ""
		var once_key := ""
		if finish_pool is Array and not finish_pool.is_empty():
			var resp := str(session.h_finish_response_line)
			var lower := resp.to_lower()
			var f_idx := 0
			if finish_pool.size() >= 4:
				if "等" in resp or "wait" in lower:
					f_idx = 1
				elif "厉害" in resp or "amazing" in lower or "incredible" in lower:
					f_idx = 2
				elif "热" in resp or "hot" in lower:
					f_idx = 3
				else:
					f_idx = 0
			elif finish_pool.size() >= 2 and ("厉害" in resp or "热" in resp or "amazing" in lower or "hot" in lower):
				f_idx = 1
			clip = str(finish_pool[f_idx])
			once_key = "h_finish:%s" % sid
		return {"context": ctx, "clip": clip, "once_key": once_key}
	if phase == "after_cg":
		var aftercare_ready := is_instance_valid(app.page) and app.page.get_node_or_null("HProfileAftercareAdvance") != null
		if not aftercare_ready:
			return {"context": ":%s:%s:after_cg_transition" % [sid, actor_id], "clip": "", "once_key": ""}
		var ac_idx := int(app.h_profile_test_aftercare_index)
		var ctx := ":%s:%s:after_cg:%s" % [sid, actor_id, ac_idx]
		var ac_pool: Variant = h_cfg.get("aftercare", [])
		var clip := ""
		var once_key := ""
		if ac_pool is Array and ac_idx >= 0 and ac_idx < ac_pool.size():
			clip = str(ac_pool[ac_idx])
			once_key = "h_aftercare:%s:%s" % [sid, ac_idx]
		return {"context": ctx, "clip": clip, "once_key": once_key}
	return {"context": ":%s:%s:%s" % [sid, actor_id, phase], "clip": "", "once_key": ""}

func sync(app) -> void:
	var context := str(app.screen)
	var clip := ""
	var once_key := ""
	if app.screen != "staff":
		_reset_staff_view_tracking()
	if app.screen == "dialogue":
		context += ":" + str(app.session.current_id)
		if app.session.current_id == "aoi_welcome":
			clip = "doc_aoi_greeting"
			once_key = "%s:%s" % [app.session.get_instance_id(), clip]
		# A new opening playthrough starts at arrival, even if Session is reused.
		if app.session.current_id == "arrival":
			played.erase("%s:doc_aoi_greeting" % app.session.get_instance_id())
	elif app.screen == "staff" and is_instance_valid(app.page) and app.page.has_meta("voice_staff_id"):
		var actor_id := str(app.page.get_meta("voice_staff_id", ""))
		var outfit := str(app.page.get_meta("voice_staff_outfit", ""))
		var expression := str(app.page.get_meta("voice_staff_expression", "neutral"))
		context += ":%s:%s:%s" % [actor_id, outfit, expression]
		if actor_id != staff_view_actor:
			staff_visit_serial += 1
			staff_view_actor = actor_id
			staff_view_outfit = outfit
			staff_view_expression = expression
			if VOICE_ACTORS.has(actor_id):
				var clock_minutes := int(app.game.display_schedule().get("absolute_clock", 540))
				clip = ("%s_greeting" % actor_id) if clock_minutes >= 5 * 60 and clock_minutes < 11 * 60 else ("%s_otsukaresama" % actor_id)
				once_key = "staff_enter:%s" % staff_visit_serial
		else:
			var prev_outfit := staff_view_outfit
			var prev_expression := staff_view_expression
			staff_view_outfit = outfit
			staff_view_expression = expression
			if VOICE_ACTORS.has(actor_id) and not SILENT_EXPR_OUTFITS.has(outfit) and outfit == prev_outfit and expression != prev_expression:
				var resolved := _resolve_expression_clip(actor_id, expression)
				if not resolved.is_empty():
					clip = resolved
					staff_visit_serial += 1
					once_key = "staff_expr:%s:%s" % [staff_visit_serial, expression]
	elif app.screen == "time_event_result" and is_instance_valid(app.page) and app.page.has_meta("music_event_id"):
		var event_id := str(app.page.get_meta("music_event_id", ""))
		var log_serial: int = app.game.time_log.size()
		context += ":%s:%s" % [event_id, log_serial]
		var definition: Dictionary = app.content.find_record("time_events", event_id)
		var actor_id := str(definition.get("actor_id", ""))
		if VOICE_ACTORS.has(actor_id):
			var actor: Dictionary = app.content.find_record("staff", actor_id)
			var outfit: String = app.chat_outfit_for_location(actor, str(definition.get("location_id", "")))
			var expr: String = app.chat_expression_for_outfit(actor, outfit)
			var slot := "smile" if str(EXPRESSION_TO_SLOT.get(expr, "")) == "smile" else "neutral"
			clip = "%s_%s" % [actor_id, slot]
			once_key = "time_event:%s:%s" % [event_id, log_serial]
	elif app.screen == "after_work_walk":
		var walk: Dictionary = app.game.active_after_work_walk
		var actor_id := str(walk.get("actor_id", ""))
		var phase := str(walk.get("phase", ""))
		var outcome := str(walk.get("outcome", ""))
		var on_walk_root := is_instance_valid(app.page) and app.page.get_node_or_null("AfterWorkShade") != null
		context += ":%s:%s:%s:%s" % [actor_id, phase, outcome, "root" if on_walk_root else "sub"]
		if VOICE_ACTORS.has(actor_id) and on_walk_root:
			var workday := int(walk.get("workday", app.game.day_number()))
			if phase == "offer":
				clip = "%s_otsukaresama" % actor_id
				once_key = "after_work_offer:%s:%s" % [workday, actor_id]
			elif phase == "result" and outcome == "completed":
				clip = "%s_smile" % actor_id
				once_key = "after_work_accept:%s:%s" % [workday, actor_id]
	elif app.screen == "free_h_response":
		var booking: Dictionary = app.game.free_h_booking
		var actor_id := str(booking.get("actor_id", ""))
		var booked_day := int(booking.get("day", app.game.day_number()))
		var page_id: int = app.page.get_instance_id() if is_instance_valid(app.page) else 0
		context += ":%s:%s:%s" % [actor_id, booked_day, page_id]
		if VOICE_ACTORS.has(actor_id):
			var dedicated := "%s_free_h_accept" % actor_id
			clip = dedicated if CLIPS.has(dedicated) else ("%s_smile" % actor_id)
			once_key = "free_h_accept:%s:%s:%s" % [booked_day, actor_id, page_id]
	elif app.screen == "sunday_date" and is_instance_valid(app.page) and app.page.has_meta("voice_sunday_actor_id"):
		var actor_id := str(app.page.get_meta("voice_sunday_actor_id", ""))
		var accepted := app.page.get_node_or_null("SundayAcceptedDialogue") != null
		var satisfied := app.page.get_node_or_null("SundaySatisfiedDialogue") != null
		var step_tag := "accepted" if accepted else "satisfied" if satisfied else "other"
		var bg_id := str(app.displayed_background_id) if satisfied else ""
		context += ":%s:%s:%s" % [actor_id, step_tag, bg_id]
		if VOICE_ACTORS.has(actor_id):
			var day_num: int = app.game.day_number()
			if accepted:
				clip = "%s_neutral" % actor_id
				once_key = "sunday_accept:%s:%s" % [day_num, actor_id]
			elif satisfied:
				var fav_key := "%s/%s" % [actor_id, bg_id]
				clip = str(FAVORITE_DATE_CLIPS.get(fav_key, "%s_smile" % actor_id))
				once_key = "sunday_satisfied:%s:%s:%s" % [day_num, actor_id, bg_id]
	elif app.screen in ["character_event", "gallery_replay", "special_event", "special_gallery_replay"]:
		var event := _active_story_event(app)
		if event != null:
			var event_id := str(event.definition.get("id", ""))
			var step: Dictionary = event.current_step() if event.has_method("current_step") else {}
			var step_id := str(step.get("id", ""))
			var node: Dictionary = event.current() if event.has_method("current") else {}
			var node_id := str(node.get("id", ""))
			var ev_instance_id: int = event.get_instance_id()
			context += ":%s:%s:%s:%s" % [ev_instance_id, event_id, step_id, node_id]
			var scoped_key := "%s/%s/%s" % [event_id, step_id, node_id]
			var node_key := "%s/%s" % [event_id, node_id]
			var cue_clip := ""
			if not step_id.is_empty() and EVENT_NODE_CUES.has(scoped_key):
				cue_clip = str(EVENT_NODE_CUES[scoped_key])
			elif EVENT_NODE_CUES.has(node_key):
				cue_clip = str(EVENT_NODE_CUES[node_key])
			if not cue_clip.is_empty() and int(app.dialogue_page_index) == 0:
				clip = cue_clip
				once_key = "event_cue:%s:%s:%s:%s" % [ev_instance_id, event_id, step_id, node_id]
	elif app.screen in ["h_profile_test_entry", "h_profile_test"]:
		var h_resolved := _resolve_h_runner_cue(app)
		context += str(h_resolved.get("context", ""))
		clip = str(h_resolved.get("clip", ""))
		once_key = str(h_resolved.get("once_key", ""))
	elif app.screen == "preop":
		var prep = app.game.preops.get(app.game.active_preop_id)
		if prep is PreopSession:
			var stage: Dictionary = prep.current()
			var stage_id := str(stage.get("id", ""))
			var stage_kind := str(stage.get("kind", ""))
			context += ":%s:%s:%s" % [prep.get_instance_id(), stage_id, prep.event_count]
			var pid: int = prep.get_instance_id()
			var speaker_id := str(prep.last_staff_id)
			var assistant_id := str(prep.team.get("assistant_surgeon", ""))
			if stage_id == "preparation" and prep.flags.has("team_confirmed") and prep.feedback_speaker == "staff" and speaker_id == assistant_id and SURGICAL_ACTORS.has(speaker_id):
				clip = "%s_serious" % speaker_id
				once_key = "%s:%s_team_confirmed" % [pid, speaker_id]
			elif stage_id == "team_confirmations" and prep.feedback_speaker == "staff" and SURGICAL_ACTORS.has(speaker_id):
				if prep.last_staff_role == "scrub_nurse" and prep.flags.has("scrub_confirmed"):
					clip = "%s_timeout" % speaker_id
					once_key = "%s:scrub_timeout:%s" % [pid, speaker_id]
				elif prep.last_staff_role == "assistant_surgeon" and prep.flags.has("assistant_confirmed"):
					clip = "%s_timeout" % speaker_id
					once_key = "%s:assistant_timeout:%s" % [pid, speaker_id]
			elif stage_id == "procedure_select" and prep.flags.has("circulating_confirmed") and prep.feedback_speaker == "staff" and prep.last_staff_role == "circulating_nurse" and SURGICAL_ACTORS.has(speaker_id):
				clip = "%s_timeout" % speaker_id
				once_key = "%s:circulating_timeout:%s" % [pid, speaker_id]
			elif not prep.active_crisis.is_empty() and prep.feedback_speaker == "staff" and SURGICAL_ACTORS.has(speaker_id):
				if prep.awaiting_crisis_acknowledgement:
					clip = "%s_or_clear" % speaker_id
					once_key = "%s:%s_crisis_clear:%s" % [pid, speaker_id, prep.crisis_history.size()]
				else:
					clip = "%s_or_caution" % speaker_id
					once_key = "%s:%s_crisis_alert:%s:%s" % [pid, speaker_id, prep.crisis_history.size(), int(prep.active_crisis.get("attempt", 1))]
			elif stage_kind == "surgery_flow" and prep.active_crisis.is_empty() and prep.awaiting_flow_acknowledgement and prep.feedback_speaker == "staff" and SURGICAL_ACTORS.has(speaker_id):
				if prep.pending_flow_retry:
					clip = "%s_or_caution" % speaker_id
					once_key = "%s:%s_flow_caution:%s" % [pid, speaker_id, prep.procedure_corrections]
				else:
					clip = "%s_or_clear" % speaker_id
					once_key = "%s:%s_flow_clear" % [pid, speaker_id]
			elif prep.surgery_aborted and stage_id == "surgery_abort" and VOICE_ACTORS.has(assistant_id):
				clip = "%s_tired" % assistant_id
				once_key = "%s:%s_surgery_abort" % [pid, assistant_id]
	elif app.screen == "advanced_referral" and app.advanced_controller != null and app.advanced_controller.session != null:
		var adv_session = app.advanced_controller.session
		var sid: int = adv_session.get_instance_id()
		if adv_session.team_intro_index >= 0 and adv_session.team_intro_index < app.advanced_controller.ROLES.size():
			var role := str(app.advanced_controller.ROLES[adv_session.team_intro_index])
			var roster: Dictionary = app.advanced_controller.state().appointment.team
			var member_id := str(roster.get(role, ""))
			context += ":%s:intro:%s:%s" % [sid, role, member_id]
			if SURGICAL_ACTORS.has(member_id):
				clip = "%s_timeout" % member_id
				once_key = "adv:%s:intro:%s:%s" % [sid, role, member_id]
		elif adv_session.in_crisis() and is_instance_valid(app.page):
			var cast: Node = app.page.get_node_or_null("AdvancedCast")
			var cast_actor := str(cast.get_meta("actor_id", "")) if cast != null and cast.has_meta("actor_id") else ""
			var cast_text := str(cast.get_meta("source_text", "")) if cast != null and cast.has_meta("source_text") else ""
			context += ":%s:crisis:%s:%s" % [sid, cast_actor, hash(cast_text)]
			if SURGICAL_ACTORS.has(cast_actor):
				clip = "%s_or_caution" % cast_actor
				once_key = "adv:%s:crisis:%s:%s" % [sid, cast_actor, hash(cast_text)]
	if context != current_context:
		if player.playing:
			player.stop()
			duck_hold_remaining = 0.0
		current_context = context
	if clip.is_empty() or played.has(once_key):
		return
	var stream = load(CLIPS[clip]) as AudioStreamWAV
	if stream == null:
		push_error("Cannot load voice clip: " + clip)
		return
	stream = stream.duplicate()
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	player.volume_db = _clip_gain_db(clip)
	player.stream = stream
	player.play()
	duck_hold_remaining = DUCK_HOLD_SECONDS
	played[once_key] = true
	last_played_clip = clip
	play_count += 1
