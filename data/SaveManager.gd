class_name SaveManager
extends RefCounted

const SETTINGS_PATH = "user://settings.cfg"
const SAVE_PATH = "user://save.cfg"

# --- Audio Settings ---

static func load_settings(game_feel: GameFeelData = null) -> Dictionary:
	var def_music_db = -6.0
	var def_sfx_db = 0.0
	if game_feel != null:
		def_music_db = game_feel.music_volume_db
		def_sfx_db = game_feel.sfx_volume_db
	
	var def_music_linear = clampf(db_to_linear(def_music_db), 0.0, 1.0)
	var def_sfx_linear = clampf(db_to_linear(def_sfx_db), 0.0, 1.0)
	
	var result = {
		"music_linear": def_music_linear,
		"sfx_linear": def_sfx_linear,
		"music_db": def_music_db,
		"sfx_db": def_sfx_db
	}
	
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err == OK:
		var loaded_music = config.get_value("audio", "music_linear", def_music_linear)
		var loaded_sfx = config.get_value("audio", "sfx_linear", def_sfx_linear)
		if typeof(loaded_music) == TYPE_FLOAT or typeof(loaded_music) == TYPE_INT:
			result["music_linear"] = clampf(float(loaded_music), 0.0, 1.0)
			result["music_db"] = linear_to_db(result["music_linear"]) if result["music_linear"] > 0.0 else -80.0
		if typeof(loaded_sfx) == TYPE_FLOAT or typeof(loaded_sfx) == TYPE_INT:
			result["sfx_linear"] = clampf(float(loaded_sfx), 0.0, 1.0)
			result["sfx_db"] = linear_to_db(result["sfx_linear"]) if result["sfx_linear"] > 0.0 else -80.0
	
	apply_audio_settings(result["music_linear"], result["sfx_linear"])
	return result

static func save_settings(music_linear: float, sfx_linear: float) -> void:
	music_linear = clampf(music_linear, 0.0, 1.0)
	sfx_linear = clampf(sfx_linear, 0.0, 1.0)
	
	var config = ConfigFile.new()
	var _err = config.load(SETTINGS_PATH)
	config.set_value("audio", "music_linear", music_linear)
	config.set_value("audio", "sfx_linear", sfx_linear)
	config.save(SETTINGS_PATH)
	
	apply_audio_settings(music_linear, sfx_linear)

static func apply_audio_settings(music_linear: float, sfx_linear: float) -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		if music_linear <= 0.001:
			AudioServer.set_bus_mute(music_bus, true)
		else:
			AudioServer.set_bus_mute(music_bus, false)
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_linear))
	
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		if sfx_linear <= 0.001:
			AudioServer.set_bus_mute(sfx_bus, true)
		else:
			AudioServer.set_bus_mute(sfx_bus, false)
			AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_linear))

# --- Records & Game Over Save ---

static func load_records() -> Dictionary:
	var records = {
		"best_time": 0.0,
		"best_kills": 0,
		"runs_completed": 0,
		"boss_kills": 0
	}
	
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		var t = config.get_value("records", "best_time", 0.0)
		var k = config.get_value("records", "best_kills", 0)
		var r = config.get_value("records", "runs_completed", 0)
		var b = config.get_value("records", "boss_kills", 0)
		if typeof(t) == TYPE_FLOAT or typeof(t) == TYPE_INT:
			records["best_time"] = maxf(0.0, float(t))
		if typeof(k) == TYPE_INT or typeof(k) == TYPE_FLOAT:
			records["best_kills"] = maxi(0, int(k))
		if typeof(r) == TYPE_INT or typeof(r) == TYPE_FLOAT:
			records["runs_completed"] = maxi(0, int(r))
		if typeof(b) == TYPE_INT or typeof(b) == TYPE_FLOAT:
			records["boss_kills"] = maxi(0, int(b))
	
	return records

static func get_runs_completed() -> int:
	var records = load_records()
	return records.get("runs_completed", 0)

static func increment_runs_completed() -> int:
	var current = get_runs_completed() + 1
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("records", "runs_completed", current)
	config.save(SAVE_PATH)
	return current

static func get_boss_kills() -> int:
	var records = load_records()
	return records.get("boss_kills", 0)

static func increment_boss_kills() -> int:
	var current = get_boss_kills() + 1
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("records", "boss_kills", current)
	config.save(SAVE_PATH)
	return current

static func is_hero_unlocked(hero: HeroData) -> bool:
	if hero == null:
		return true
	match hero.unlock_type:
		"none", "":
			return true
		"runs":
			return get_runs_completed() >= hero.unlock_requirement
		"boss_kills":
			return get_boss_kills() >= hero.unlock_requirement
		_:
			return true

static func save_game_result(survived_time: float, kills: int, souls_collected: int = 0, count_run_finished: bool = true) -> Dictionary:
	var current = load_records()
	var old_best_time = current["best_time"]
	var old_best_kills = current["best_kills"]
	var old_runs = current["runs_completed"]
	
	var new_best_time = survived_time > old_best_time
	var new_best_kills = kills > old_best_kills
	
	var final_best_time = maxf(old_best_time, survived_time)
	var final_best_kills = maxi(old_best_kills, kills)
	var final_runs = old_runs + (1 if count_run_finished else 0)
	
	var current_souls = get_total_souls()
	var final_total_souls = current_souls + maxi(0, souls_collected)
	
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("records", "best_time", final_best_time)
	config.set_value("records", "best_kills", final_best_kills)
	config.set_value("records", "runs_completed", final_runs)
	config.set_value("meta", "total_souls", final_total_souls)
	config.save(SAVE_PATH)
	
	return {
		"is_new_best_time": new_best_time,
		"is_new_best_kills": new_best_kills,
		"best_time": final_best_time,
		"best_kills": final_best_kills,
		"runs_completed": final_runs,
		"souls_collected": maxi(0, souls_collected),
		"total_souls": final_total_souls
	}

# --- Meta-Progression & Souls ---

static func get_total_souls() -> int:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		var val = config.get_value("meta", "total_souls", 0)
		if typeof(val) == TYPE_INT or typeof(val) == TYPE_FLOAT:
			return maxi(0, int(val))
	return 0

static func add_souls(amount: int) -> int:
	if amount <= 0:
		return get_total_souls()
	
	var current = get_total_souls()
	var new_total = current + amount
	
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("meta", "total_souls", new_total)
	config.save(SAVE_PATH)
	return new_total

static func spend_souls(amount: int) -> bool:
	if amount <= 0:
		return true
	var current = get_total_souls()
	if current < amount:
		return false
	
	var new_total = current - amount
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("meta", "total_souls", new_total)
	config.save(SAVE_PATH)
	return true

static func get_meta_upgrade_level(upgrade_id: String) -> int:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		var val = config.get_value("meta_upgrades", upgrade_id, 0)
		if typeof(val) == TYPE_INT or typeof(val) == TYPE_FLOAT:
			return maxi(0, int(val))
	return 0

static func set_meta_upgrade_level(upgrade_id: String, level: int) -> void:
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("meta_upgrades", upgrade_id, maxi(0, level))
	config.save(SAVE_PATH)

static func get_all_meta_upgrade_levels() -> Dictionary:
	var result: Dictionary = {}
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK and config.has_section("meta_upgrades"):
		for key in config.get_section_keys("meta_upgrades"):
			var val = config.get_value("meta_upgrades", key, 0)
			if typeof(val) == TYPE_INT or typeof(val) == TYPE_FLOAT:
				result[key] = maxi(0, int(val))
	return result

# --- Collectible Card Collection & Deck (Phase 8) ---

static func get_card_collection() -> Dictionary:
	var result: Dictionary = {}
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK and config.has_section("cards"):
		for card_id in config.get_section_keys("cards"):
			var card_data = config.get_value("cards", card_id, {})
			if typeof(card_data) == TYPE_DICTIONARY:
				result[card_id] = {
					"level": maxi(1, int(card_data.get("level", 1))),
					"duplicates": maxi(0, int(card_data.get("duplicates", 0)))
				}
	return result

static func add_card_to_collection(card_id: String) -> Dictionary:
	var collection = get_card_collection()
	var is_new = false
	if not collection.has(card_id):
		collection[card_id] = { "level": 1, "duplicates": 0 }
		is_new = true
	else:
		collection[card_id]["duplicates"] += 1
	
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("cards", card_id, collection[card_id])
	config.save(SAVE_PATH)
	
	return {
		"card_id": card_id,
		"level": collection[card_id]["level"],
		"duplicates": collection[card_id]["duplicates"],
		"is_new": is_new
	}

static func upgrade_card(card_id: String, cost: int, max_level: int) -> bool:
	var collection = get_card_collection()
	if not collection.has(card_id):
		return false
	var entry = collection[card_id]
	if entry["level"] >= max_level or entry["duplicates"] < cost:
		return false
	
	entry["duplicates"] -= cost
	entry["level"] += 1
	
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("cards", card_id, entry)
	config.save(SAVE_PATH)
	return true

static func get_equipped_cards() -> Array[String]:
	var result: Array[String] = []
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		var arr = config.get_value("deck", "equipped", [])
		if typeof(arr) == TYPE_ARRAY:
			for item in arr:
				if typeof(item) == TYPE_STRING and not item.is_empty():
					result.append(item)
	return result

static func set_equipped_cards(card_ids: Array) -> void:
	var valid_ids: Array[String] = []
	for cid in card_ids:
		if typeof(cid) == TYPE_STRING and not cid.is_empty() and valid_ids.size() < 3:
			if not valid_ids.has(cid):
				valid_ids.append(cid)
	
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("deck", "equipped", valid_ids)
	config.save(SAVE_PATH)

# --- Run Log & Career Stats (Playable Web Demo Part B) ---

static func get_run_history() -> Array:
	var result: Array = []
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK and config.has_section("history"):
		var raw_runs = config.get_value("history", "runs", [])
		if typeof(raw_runs) == TYPE_ARRAY:
			for item in raw_runs:
				if typeof(item) == TYPE_DICTIONARY:
					var sanitized_entry = {
						"duration": maxf(0.0, float(item.get("duration", 0.0))),
						"death_cause": str(item.get("death_cause", "Unknown")),
						"hero": str(item.get("hero", "Unknown")),
						"weapon": str(item.get("weapon", "Unknown")),
						"upgrades": item.get("upgrades", []) if typeof(item.get("upgrades", [])) == TYPE_ARRAY else [],
						"souls": maxi(0, int(item.get("souls", 0)))
					}
					result.append(sanitized_entry)
	return result

static func log_run(duration: float, death_cause: String, hero_name: String, weapon_name: String, upgrades: Array, souls: int) -> void:
	var runs = get_run_history()
	var new_entry = {
		"duration": maxf(0.0, duration),
		"death_cause": death_cause if not death_cause.is_empty() else "Zombie",
		"hero": hero_name if not hero_name.is_empty() else "Unknown",
		"weapon": weapon_name if not weapon_name.is_empty() else "Unknown",
		"upgrades": upgrades.duplicate() if upgrades != null else [],
		"souls": maxi(0, souls)
	}
	runs.append(new_entry)
	while runs.size() > 50:
		runs.pop_front()
	
	var config = ConfigFile.new()
	var _err = config.load(SAVE_PATH)
	config.set_value("history", "runs", runs)
	config.save(SAVE_PATH)

static func get_stats_summary() -> Dictionary:
	var records = load_records()
	var runs = get_run_history()
	var best_time = records.get("best_time", 0.0)
	var total_runs = maxi(records.get("runs_completed", 0), runs.size())
	
	var total_duration: float = 0.0
	var upgrade_counts: Dictionary = {}
	
	for r in runs:
		total_duration += float(r.get("duration", 0.0))
		var upgs = r.get("upgrades", [])
		if typeof(upgs) == TYPE_ARRAY:
			for u in upgs:
				var u_name = str(u).strip_edges()
				if not u_name.is_empty():
					upgrade_counts[u_name] = upgrade_counts.get(u_name, 0) + 1
	
	var avg_duration: float = 0.0
	if runs.size() > 0:
		avg_duration = total_duration / float(runs.size())
	
	var most_picked_upgrade: String = "None"
	var max_count = 0
	for u_name in upgrade_counts:
		if upgrade_counts[u_name] > max_count:
			max_count = upgrade_counts[u_name]
			most_picked_upgrade = "%s (%dx)" % [u_name, max_count]
	
	return {
		"best_time": best_time,
		"total_runs": total_runs,
		"avg_duration": avg_duration,
		"most_picked_upgrade": most_picked_upgrade
	}

