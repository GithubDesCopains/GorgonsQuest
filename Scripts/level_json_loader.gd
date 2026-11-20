extends RefCounted
class_name LevelJsonLoader

## Loads and validates level JSON into LevelData.

const TILE_CODES = {".": Constants.TileType.GROUND, "#": Constants.TileType.WALL, "~": Constants.TileType.WATER, "i": Constants.TileType.ICE, "b": Constants.TileType.STONE_BLOCK, "o": Constants.TileType.HOLE, "v": Constants.TileType.PLAYER_ONLY}
const BONUS_KINDS = ["ambrosia", "gorgon_orb"]
const MIRROR_ORIENTATIONS = ["slash", "backslash"]
const DIRECTIONS = {"right": Vector2i.RIGHT, "down": Vector2i.DOWN, "left": Vector2i.LEFT, "up": Vector2i.UP}

func load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "Level JSON not found: %s" % path}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "Could not open level JSON: %s" % path}
	return parse_text(file.get_as_text())

func parse_text(text: String) -> Dictionary:
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Root JSON value must be an object"}
	var validation_error = validate_document(parsed)
	if not validation_error.is_empty():
		return {"ok": false, "error": validation_error}
	return {"ok": true, "data": document_to_level(parsed), "error": ""}

func validate_document(doc: Dictionary) -> String:
	for key in ["world", "level", "name", "grid", "player_start"]:
		if not doc.has(key):
			return "Missing required property: %s" % key
	if not is_integer_number(doc["world"]) or int(doc["world"]) < 1:
		return "world must be a positive integer"
	if not is_integer_number(doc["level"]) or int(doc["level"]) < 1:
		return "level must be a positive integer"
	if typeof(doc["name"]) != TYPE_STRING:
		return "name must be a string"
	if typeof(doc["grid"]) != TYPE_ARRAY or doc["grid"].size() != Constants.GRID_ROWS:
		return "grid must contain exactly %d rows" % Constants.GRID_ROWS
	for y in range(Constants.GRID_ROWS):
		var row = doc["grid"][y]
		if typeof(row) != TYPE_STRING or row.length() != Constants.GRID_COLS:
			return "grid row %d must be a %d-character string" % [y, Constants.GRID_COLS]
		for x in range(row.length()):
			if not TILE_CODES.has(row.substr(x, 1)):
				return "Unknown tile code '%s' at (%d,%d)" % [row.substr(x, 1), x, y]
	var position_error = validate_position(doc["player_start"], "player_start")
	if not position_error.is_empty():
		return position_error
	for key in ["soul_urns", "enemies", "spawners", "springs", "rotators", "warps", "slippery_tiles", "one_way_gates", "conveyors", "bonus_items", "push_blocks", "mirrors", "switches", "doors"]:
		if doc.has(key) and typeof(doc[key]) != TYPE_ARRAY:
			return "%s must be an array" % key
	var mechanics_error := validate_mechanics(doc)
	if not mechanics_error.is_empty():
		return mechanics_error
	return validate_entity_positions(doc)

func validate_mechanics(doc: Dictionary) -> String:
	"""Mirrors, switches and doors: positions, orientation/direction. Pairing switches with doors is only
	reported as a warning by LevelChecker, so a level can be saved while it is still being built."""
	for mirror in doc.get("mirrors", []):
		if typeof(mirror) != TYPE_DICTIONARY:
			return "mirrors entries must be objects"
		var err = validate_position(mirror.get("pos"), "mirrors.pos")
		if not err.is_empty():
			return err
		if not MIRROR_ORIENTATIONS.has(str(mirror.get("orientation", ""))):
			return "mirror orientation must be slash or backslash"
	for entry in doc.get("switches", []):
		if typeof(entry) != TYPE_DICTIONARY:
			return "switches entries must be objects"
		var err = validate_position(entry.get("pos"), "switches.pos")
		if not err.is_empty():
			return err
		if str(entry.get("id", "")).is_empty():
			return "switch id cannot be empty"
	for entry in doc.get("doors", []):
		if typeof(entry) != TYPE_DICTIONARY:
			return "doors entries must be objects"
		var err = validate_position(entry.get("pos"), "doors.pos")
		if not err.is_empty():
			return err
		if not DIRECTIONS.has(str(entry.get("direction", "")).to_lower()):
			return "doors direction must be up, down, left, or right"
		var other = vector_from_array(entry["pos"]) + DIRECTIONS[str(entry["direction"]).to_lower()]
		if other.x < 0 or other.x >= Constants.GRID_COLS or other.y < 0 or other.y >= Constants.GRID_ROWS:
			return "a door must sit between two cells of the grid"
		if str(entry.get("id", "")).is_empty():
			return "door id cannot be empty"
	return ""

func validate_entity_positions(doc: Dictionary) -> String:
	for key in ["soul_urns", "slippery_tiles", "push_blocks"]:
		for entry in doc.get(key, []):
			var pos = entry.get("pos") if typeof(entry) == TYPE_DICTIONARY else entry
			var err = validate_position(pos, "%s entry" % key)
			if not err.is_empty():
				return err
	for key in ["enemies", "spawners", "springs", "rotators", "warps", "one_way_gates", "conveyors", "bonus_items"]:
		for entry in doc.get(key, []):
			if typeof(entry) != TYPE_DICTIONARY:
				return "%s entries must be objects" % key
			var err = validate_position(entry.get("pos"), "%s.pos" % key)
			if not err.is_empty():
				return err
			if key in ["springs", "one_way_gates", "conveyors"] and not DIRECTIONS.has(str(entry.get("direction", "")).to_lower()):
				return "%s direction must be up, down, left, or right" % key
			if key == "bonus_items" and not BONUS_KINDS.has(str(entry.get("kind", "ambrosia"))):
				return "bonus_items kind must be one of: %s" % ", ".join(PackedStringArray(BONUS_KINDS))
	if doc.has("warps"):
		var pair_counts: Dictionary = {}
		for warp in doc["warps"]:
			var pair_id = str(warp.get("pair_id", ""))
			if pair_id.is_empty():
				return "warp pair_id cannot be empty"
			pair_counts[pair_id] = int(pair_counts.get(pair_id, 0)) + 1
		for pair_id in pair_counts:
			if pair_counts[pair_id] != 2:
				return "warp pair '%s' must contain exactly two endpoints" % pair_id
	if doc.has("boss"):
		if typeof(doc["boss"]) != TYPE_DICTIONARY:
			return "boss must be an object"
		var boss: Dictionary = doc["boss"]
		if not is_integer_number(boss.get("health", 0)) or int(boss.get("health", 0)) <= 0:
			return "boss.health must be a positive integer"
		if boss.has("pos"):
			var boss_pos_error = validate_position(boss["pos"], "boss.pos")
			if not boss_pos_error.is_empty():
				return boss_pos_error
		if boss.has("arena_pos") or boss.has("arena_size"):
			if not boss.has("arena_pos") or not boss.has("arena_size"):
				return "boss arena_pos and arena_size must both be provided"
			var arena_pos_error = validate_position(boss["arena_pos"], "boss.arena_pos")
			if not arena_pos_error.is_empty():
				return arena_pos_error
			if typeof(boss["arena_size"]) != TYPE_ARRAY or boss["arena_size"].size() != 2:
				return "boss.arena_size must be [width,height]"
			var arena_size: Array = boss["arena_size"]
			if not is_integer_number(arena_size[0]) or not is_integer_number(arena_size[1]) or arena_size[0] < 3 or arena_size[1] < 3:
				return "boss.arena_size dimensions must be integers >= 3"
			if boss["arena_pos"][0] + arena_size[0] > Constants.GRID_COLS or boss["arena_pos"][1] + arena_size[1] > Constants.GRID_ROWS:
				return "boss arena extends outside grid"
	return ""

func is_integer_number(value) -> bool:
	return typeof(value) == TYPE_INT or (typeof(value) == TYPE_FLOAT and is_equal_approx(float(value), roundf(float(value))))

func validate_position(value, label: String) -> String:
	if typeof(value) != TYPE_ARRAY or value.size() != 2:
		return "%s must be [x,y]" % label
	if not is_integer_number(value[0]) or not is_integer_number(value[1]):
		return "%s coordinates must be integers" % label
	if value[0] < 0 or value[0] >= Constants.GRID_COLS or value[1] < 0 or value[1] >= Constants.GRID_ROWS:
		return "%s position is outside grid" % label
	return ""
func document_to_level(doc: Dictionary) -> LevelData:
	var data = LevelData.new(int(doc["world"]), int(doc["level"]))
	data.level_name = str(doc["name"])
	data.player_start = vector_from_array(doc["player_start"])
	data.time_limit = int(doc.get("time_limit", 90))
	data.grid_layout = []
	for row_text in doc["grid"]:
		var row: Array = []
		for x in range(row_text.length()):
			row.append(TILE_CODES[row_text.substr(x, 1)])
		data.grid_layout.append(row)
	for pos in doc.get("soul_urns", []):
		data.soul_urns.append(vector_from_array(pos.get("pos") if typeof(pos) == TYPE_DICTIONARY else pos))
	for enemy in doc.get("enemies", []):
		data.enemies.append({"type": str(enemy.get("type", "noggle")), "pos": vector_from_array(enemy["pos"]), "pattern": directions_from_names(enemy.get("pattern", []))})
	for spawner in doc.get("spawners", []):
		data.spawners.append({"type": str(spawner.get("type", "noggle")), "pos": vector_from_array(spawner["pos"]), "pattern": directions_from_names(spawner.get("pattern", [])), "interval": float(spawner.get("interval", 5.0))})
	for spring in doc.get("springs", []):
		data.springs.append({"pos": vector_from_array(spring["pos"]), "direction": direction_from_name(str(spring.get("direction", "up")))})
	for rotator in doc.get("rotators", []):
		data.rotators.append({"pos": vector_from_array(rotator["pos"]), "quarter_turns": int(rotator.get("quarter_turns", 1))})
	for warp in doc.get("warps", []):
		data.warps.append({"pos": vector_from_array(warp["pos"]), "pair_id": str(warp.get("pair_id", ""))})
	for pos in doc.get("slippery_tiles", []):
		data.slippery_tiles.append(vector_from_array(pos.get("pos") if typeof(pos) == TYPE_DICTIONARY else pos))
	for gate in doc.get("one_way_gates", []):
		data.one_way_gates.append({"pos": vector_from_array(gate["pos"]), "direction": direction_from_name(str(gate.get("direction", "right")))})
	for conveyor in doc.get("conveyors", []):
		data.conveyors.append({"pos": vector_from_array(conveyor["pos"]), "direction": direction_from_name(str(conveyor.get("direction", "right")))})
	for bonus in doc.get("bonus_items", []):
		data.bonus_items.append({"pos": vector_from_array(bonus["pos"]), "kind": str(bonus.get("kind", "ambrosia"))})
	for block in doc.get("push_blocks", []):
		data.push_blocks.append(vector_from_array(block.get("pos") if typeof(block) == TYPE_DICTIONARY else block))
	for mirror in doc.get("mirrors", []):
		data.mirrors.append({"pos": vector_from_array(mirror["pos"]), "orientation": str(mirror.get("orientation", "slash"))})
	for entry in doc.get("switches", []):
		data.switches.append({"pos": vector_from_array(entry["pos"]), "id": str(entry["id"])})
	for entry in doc.get("doors", []):
		data.doors.append({"pos": vector_from_array(entry["pos"]), "direction": direction_from_name(str(entry["direction"])), "id": str(entry["id"])})
	if typeof(doc.get("boss", null)) == TYPE_DICTIONARY:
		var boss_data: Dictionary = doc["boss"]
		data.is_boss_level = true
		data.boss_type = str(boss_data.get("type", "generic"))
		data.boss_name = str(boss_data.get("name", "Guardian"))
		data.boss_health = int(boss_data.get("health", 1))
		data.boss_position = vector_from_array(boss_data.get("pos", [8, 7]))
		data.boss_arena = Rect2i(vector_from_array(boss_data.get("arena_pos", [4, 3])), vector_from_array(boss_data.get("arena_size", [9, 9])))
		data.boss_minion_type = str(boss_data.get("minion_type", "noggle"))
		data.boss_spawn_interval = float(boss_data.get("spawn_interval", 4.0))
	return data

func vector_from_array(value: Array) -> Vector2i:
	return Vector2i(int(value[0]), int(value[1]))

func direction_from_name(name: String) -> Vector2i:
	return DIRECTIONS.get(name.to_lower(), Vector2i.ZERO)

func directions_from_names(values: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for value in values:
		result.append(direction_from_name(str(value)))
	return result

