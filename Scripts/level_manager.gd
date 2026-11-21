extends Node

## Level Manager - Handles level progression and loading

var current_world: int = 1
var current_level: int = 1
var max_world: int = Constants.WORLDS
var levels_per_world: int = Constants.LEVELS_PER_WORLD  # 19 puzzles, then the boss

var game_manager: Node
var current_level_data: LevelData
var json_loader = preload("res://Scripts/level_json_loader.gd").new()
## Optional GameSession stand-in, mainly for tests that run outside the scene tree.
var session_override: Node = null

signal level_loaded(level_data: LevelData)
signal world_complete(world: int)
signal all_worlds_complete()

func _ready():
	game_manager = get_parent()

func load_level(world: int, level: int):
	"""Load a specific level"""
	current_world = world
	current_level = level
	
	# Get level data
	current_level_data = get_level_data(world, level)
	
	if current_level_data:
		print("Loading: ", current_level_data.level_name)
		level_loaded.emit(current_level_data)
	else:
		print("ERROR: Level data not found for World ", world, " Level ", level)

func get_level_data(world: int, level: int) -> LevelData:
	"""Load external JSON data when present, then use legacy factory fallback."""
	var session = _get_session()
	if session != null and session.is_custom_level():
		var custom_result: Dictionary = json_loader.load_file(session.custom_level_path)
		if custom_result.get("ok", false):
			return custom_result["data"]
		push_warning("Ignoring invalid custom level %s: %s" % [session.custom_level_path, custom_result.get("error", "unknown error")])
	var json_path = "res://Data/Levels/world_%d_level_%d.json" % [world, level]
	if FileAccess.file_exists(json_path):
		var result: Dictionary = json_loader.load_file(json_path)
		if result.get("ok", false):
			return result["data"]
		push_warning("Ignoring invalid level JSON %s: %s" % [json_path, result.get("error", "unknown error")])
	
	# Legacy factory fallback for levels not migrated to JSON yet.
	if world == 2 and level == Constants.BOSS_LEVEL:
		return LevelData.create_hydra_boss_level()
	if world == 3 and level == Constants.BOSS_LEVEL:
		return LevelData.create_chimera_boss_level()
	if world == 4 and level == Constants.BOSS_LEVEL:
		return LevelData.create_medusa_boss_level()
	if world == 1:
		match level:
			1:
				return LevelData.create_test_level()
			2:
				return LevelData.create_level_1_2()
			3:
				return LevelData.create_level_1_3()
			Constants.BOSS_LEVEL:
				return LevelData.create_boss_test_level()
			_:
				# Fallback to test level
				return LevelData.create_test_level()
	else:
		# Other worlds not implemented yet
		return LevelData.create_test_level()

func _get_session() -> Node:
	if is_instance_valid(session_override):
		return session_override
	if is_inside_tree():
		return get_node_or_null("/root/GameSession")
	var loop = Engine.get_main_loop()
	if loop is SceneTree:
		return (loop as SceneTree).root.get_node_or_null("GameSession")
	return null

func next_level():
	"""Advance to next level"""
	current_level += 1
	
	if current_level > levels_per_world:
		# World complete, go to next world
		world_complete.emit(current_world)
		current_world += 1
		current_level = 1
		
		if current_world > max_world:
			# All worlds complete!
			all_worlds_complete.emit()
			return
	
	load_level(current_world, current_level)

func restart_level():
	"""Restart current level"""
	load_level(current_world, current_level)

func get_progress_string() -> String:
	"""Get progress as string"""
	return "World %d-%d" % [current_world, current_level]
