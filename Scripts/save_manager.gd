extends Node

const AUDIO_BUS_SETUP = preload("res://Scripts/audio_bus_setup.gd")

## Persistent save system for Gorgon's Debt
## Saves to user://savegame.json

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1
var save_path: String = SAVE_PATH

# Save data structure
var save_data: Dictionary = {}

signal save_loaded
signal save_written

func _ready() -> void:
	load_game()

# â”€â”€ Public API â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func has_save() -> bool:
	return FileAccess.file_exists(save_path)

func save_game() -> void:
	save_data["version"] = SAVE_VERSION
	save_data["timestamp"] = Time.get_unix_time_from_system()
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open save file for writing.")
		return
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	save_written.emit()

func load_game() -> void:
	if not has_save():
		_reset_to_defaults()
		AUDIO_BUS_SETUP.apply_saved_volumes(save_data)
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: cannot open save file; using defaults.")
		_reset_to_defaults()
		return
	if file.get_length() > 65536:   # a real save is under 1 KB
		file.close()
		push_warning("SaveManager: save file is too large; using defaults.")
		_reset_to_defaults()
		return
	var text := file.get_as_text()
	file.close()
	var parser := JSON.new()
	var parse_error := parser.parse(text)
	if parse_error != OK or not parser.data is Dictionary:
		push_warning("SaveManager: invalid save JSON at line %d; using defaults." % parser.get_error_line())
		_reset_to_defaults()
		return
	var parsed: Dictionary = parser.data
	if int(parsed.get("version", 0)) != SAVE_VERSION:
		push_warning("SaveManager: save version mismatch; using defaults.")
		_reset_to_defaults()
		return
	save_data = _validated_data(parsed)
	AUDIO_BUS_SETUP.apply_saved_volumes(save_data)
	save_loaded.emit()

func reset_save() -> void:
	_reset_to_defaults()
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

# â”€â”€ Progression â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func get_max_world() -> int:
	return save_data.get("max_world", 1)

func get_max_level(world: int) -> int:
	var key := "max_level_w%d" % world
	return save_data.get(key, 1)

func record_level_completion(world: int, level: int, score: int) -> void:
	# Unlock next level
	var current_max := get_max_level(world)
	if level >= current_max:
		var key := "max_level_w%d" % world
		save_data[key] = level + 1
	# Unlock next world if final level of world beaten
	if level >= Constants.BOSS_LEVEL and world >= get_max_world():
		save_data["max_world"] = world + 1
	# Best score
	_update_best_score(world, level, score)
	# Total score
	save_data["total_score"] = save_data.get("total_score", 0) + score
	save_game()

func get_best_score(world: int, level: int) -> int:
	var key := "best_%d_%d" % [world, level]
	return save_data.get(key, 0)

func get_total_score() -> int:
	return save_data.get("total_score", 0)

# â”€â”€ Settings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func get_music_volume() -> float:
	return save_data.get("music_volume", 1.0)

func set_music_volume(v: float) -> void:
	save_data["music_volume"] = clampf(v, 0.0, 1.0)
	AUDIO_BUS_SETUP.set_volume(AUDIO_BUS_SETUP.MUSIC_BUS, save_data["music_volume"])
	save_game()

func get_sfx_volume() -> float:
	return save_data.get("sfx_volume", 1.0)

func set_sfx_volume(v: float) -> void:
	save_data["sfx_volume"] = clampf(v, 0.0, 1.0)
	AUDIO_BUS_SETUP.set_volume(AUDIO_BUS_SETUP.SFX_BUS, save_data["sfx_volume"])
	save_game()

# â”€â”€ Private â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const MAX_SCORE := 2000000000   # keeps int(float) well inside 64-bit range and the score display readable

func _num(value: Variant, fallback: float) -> float:
	"""A save file can be edited by hand: anything that is not a finite number falls back instead of crashing."""
	if (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value)):
		return float(value)
	return fallback

func _validated_data(parsed: Dictionary) -> Dictionary:
	var clean := _default_data()
	clean["timestamp"] = int(clampf(_num(parsed.get("timestamp", 0), 0.0), 0.0, 1.0e12))
	clean["max_world"] = clampi(int(clampf(_num(parsed.get("max_world", 1), 1.0), 1.0, 4.0)), 1, 4)
	clean["total_score"] = int(clampf(_num(parsed.get("total_score", 0), 0.0), 0.0, MAX_SCORE))
	for world in range(1, 5):
		var level_key := "max_level_w%d" % world
		clean[level_key] = clampi(int(clampf(_num(parsed.get(level_key, 1), 1.0), 1.0, float(Constants.LEVELS_PER_WORLD))), 1, Constants.LEVELS_PER_WORLD)
	for key in parsed.keys():
		if key is String and key.length() <= 16 and key.begins_with("best_"):
			clean[key] = int(clampf(_num(parsed[key], 0.0), 0.0, MAX_SCORE))
	clean["music_volume"] = clampf(_num(parsed.get("music_volume", 1.0), 1.0), 0.0, 1.0)
	clean["sfx_volume"] = clampf(_num(parsed.get("sfx_volume", 1.0), 1.0), 0.0, 1.0)
	return clean

func _default_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"timestamp": 0,
		"max_world": 1,
		"max_level_w1": 1,
		"max_level_w2": 1,
		"max_level_w3": 1,
		"max_level_w4": 1,
		"total_score": 0,
		"music_volume": 1.0,
		"sfx_volume": 1.0
	}

func _reset_to_defaults() -> void:
	save_data = _default_data()

func _update_best_score(world: int, level: int, score: int) -> void:
	var key := "best_%d_%d" % [world, level]
	var prev: int = save_data.get(key, 0)
	if score > prev:
		save_data[key] = score
