extends RefCounted
class_name LevelData

## Level Data Structure - Defines a single level

var world_idx: int
var level_idx: int
var level_name: String
var grid_layout: Array  # 16x15 grid of tile types
var player_start: Vector2i
var soul_urns: Array  # Array of Vector2i
var enemies: Array  # Array of Dictionary [{type, pos, pattern}]
var spawners: Array  # Array of Dictionary [{pos, type, pattern, interval}]
var springs: Array  # Array of Dictionary [{pos, direction}]
var rotators: Array  # Array of Dictionary [{pos, quarter_turns}]
var warps: Array  # Array of Dictionary [{pos, pair_id}]
var slippery_tiles: Array  # Array of Vector2i positions
var one_way_gates: Array  # Array of Dictionary [{pos, direction}]
var conveyors: Array  # Array of Dictionary [{pos, direction}]
var bonus_items: Array  # Array of Dictionary [{pos, kind}] kind: ambrosia | gorgon_orb
var push_blocks: Array  # Array of Vector2i positions of dark-blue pushable blocks
var mirrors: Array  # Array of Dictionary [{pos, orientation}] orientation: slash | backslash
var switches: Array  # Array of Dictionary [{pos, id}] pressure plates, held down by a pushable block
var doors: Array  # Array of Dictionary [{pos, direction, id}] barrier on the edge between pos and pos+direction
var hammers: Array  # Array of Dictionary [{pos, direction}] pivot cell and the direction its head points to
var is_boss_level: bool
var boss_type: String
var boss_name: String
var boss_health: int
var boss_position: Vector2i
var boss_arena: Rect2i
var boss_minion_type: String
var boss_spawn_interval: float
var time_limit: int

func _init(w: int = 1, l: int = 1):
	world_idx = w
	level_idx = l
	level_name = "World %d - Level %d" % [w, l]
	grid_layout = []
	soul_urns = []
	enemies = []
	spawners = []
	springs = []
	rotators = []
	warps = []
	slippery_tiles = []
	one_way_gates = []
	conveyors = []
	bonus_items = []
	push_blocks = []
	mirrors = []
	switches = []
	doors = []
	hammers = []
	is_boss_level = false
	boss_type = "generic"
	boss_name = ""
	boss_health = 0
	boss_position = Vector2i.ZERO
	boss_arena = Rect2i()
	boss_minion_type = "noggle"
	boss_spawn_interval = 4.0
	player_start = Vector2i(2, 7)
	time_limit = 90

static func create_test_level() -> LevelData:
	"""Create a test level"""
	var lvl = LevelData.new(1, 1)
	lvl.level_name = "Garden of Gorgon"
	lvl.player_start = Vector2i(2, 7)
	lvl.springs = [{"pos": Vector2i(4, 10), "direction": Vector2i.RIGHT}]
	lvl.rotators = [{"pos": Vector2i(10, 3), "quarter_turns": 1}]
	lvl.warps = [
		{"pos": Vector2i(2, 10), "pair_id": "A"},
		{"pos": Vector2i(13, 4), "pair_id": "A"}
	]
	# Short polished marble lane for movement-testing; separate from urn/enemy placements.
	lvl.slippery_tiles = [Vector2i(6, 12), Vector2i(7, 12), Vector2i(8, 12)]
	lvl.one_way_gates = [{"pos": Vector2i(13, 7), "direction": Vector2i.RIGHT}]
	# Visible test lane stays separate from water and the start point.
	lvl.conveyors = [
		{"pos": Vector2i(4, 13), "direction": Vector2i.RIGHT},
		{"pos": Vector2i(5, 13), "direction": Vector2i.RIGHT},
		{"pos": Vector2i(6, 13), "direction": Vector2i.RIGHT}
	]
	
	# Create simple grid layout
	lvl.grid_layout = []
	for y in range(Constants.GRID_ROWS):
		var row = []
		for x in range(Constants.GRID_COLS):
			# Borders are walls
			if x == 0 or x == Constants.GRID_COLS - 1 or y == 0 or y == Constants.GRID_ROWS - 1:
				row.append(Constants.TileType.WALL)
			# Water zone in center
			elif x >= 5 and x <= 10 and y >= 5 and y <= 9:
				row.append(Constants.TileType.WATER)
			else:
				row.append(Constants.TileType.GROUND)
		lvl.grid_layout.append(row)
	
	# Soul urns
	lvl.soul_urns = [
		Vector2i(3, 3),
		Vector2i(12, 3),
		Vector2i(8, 11),
		Vector2i(3, 11),
		Vector2i(12, 11)
	]
	
	# Enemies
	lvl.enemies = [
		{
			"type": "noggle",
			"pos": Vector2i(4, 2),
			"pattern": [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.LEFT, Vector2i.LEFT]
		},
		{
			"type": "birdie",
			"pos": Vector2i(8, 4),
			"pattern": [Vector2i.DOWN, Vector2i.DOWN, Vector2i.UP, Vector2i.UP]
		},
		{
			"type": "wall_hugger",
			"pos": Vector2i(13, 2),
			"pattern": []
		},
		{
			"type": "jumper",
			"pos": Vector2i(3, 9),
			"pattern": [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
		},
		{
			"type": "zapper",
			"pos": Vector2i(7, 7),
			"pattern": [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
		},
		{
			"type": "pusher",
			"pos": Vector2i(6, 6),
			"pattern": [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
		},
		{
			"type": "hades_shadow",
			"pos": Vector2i(13, 11),
			"pattern": []
		},
		{
			"type": "flame_beast",
			"pos": Vector2i(11, 11),
			"pattern": [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]
		},
		{
			"type": "noggle",
			"pos": Vector2i(12, 8),
			"pattern": [Vector2i.LEFT, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.RIGHT]
		}
	]
	
	return lvl

static func create_level_1_2() -> LevelData:
	"""World 1 - Level 2"""
	var lvl = LevelData.new(1, 2)
	lvl.level_name = "Medusa's Trial"
	lvl.player_start = Vector2i(2, 13)
	
	# Create grid layout
	lvl.grid_layout = []
	for y in range(Constants.GRID_ROWS):
		var row = []
		for x in range(Constants.GRID_COLS):
			# Borders are walls
			if x == 0 or x == Constants.GRID_COLS - 1 or y == 0 or y == Constants.GRID_ROWS - 1:
				row.append(Constants.TileType.WALL)
			# Two water pools
			elif (x >= 3 and x <= 5 and y >= 3 and y <= 5) or (x >= 10 and x <= 12 and y >= 8 and y <= 10):
				row.append(Constants.TileType.WATER)
			else:
				row.append(Constants.TileType.GROUND)
		lvl.grid_layout.append(row)
	
	# Soul urns
	lvl.soul_urns = [
		Vector2i(4, 4),   # In first water
		Vector2i(11, 9),  # In second water
		Vector2i(8, 2),
		Vector2i(2, 8),
		Vector2i(13, 13)
	]
	
	# More enemies
	lvl.enemies = [
		{"type": "noggle", "pos": Vector2i(8, 7), "pattern": [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.LEFT]},
		{"type": "noggle", "pos": Vector2i(6, 3), "pattern": [Vector2i.DOWN, Vector2i.DOWN, Vector2i.UP, Vector2i.UP]},
		{"type": "birdie", "pos": Vector2i(10, 5), "pattern": [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.UP]},
		{"type": "zapper", "pos": Vector2i(4, 4), "pattern": [Vector2i.RIGHT, Vector2i.LEFT]},
		{"type": "zapper", "pos": Vector2i(11, 9), "pattern": [Vector2i.UP, Vector2i.DOWN]}
	]
	
	return lvl

static func create_boss_test_level() -> LevelData:
	"""World 1 boss arena (level 20): Polyphemus."""
	var lvl = LevelData.new(1, Constants.BOSS_LEVEL)
	lvl.level_name = "Polyphemus Arena"
	lvl.is_boss_level = true
	lvl.boss_type = "cyclops"
	lvl.boss_name = "Polyphemus"
	lvl.boss_health = 3
	lvl.boss_position = Vector2i(8, 7)
	lvl.boss_arena = Rect2i(Vector2i(4, 3), Vector2i(9, 9))
	lvl.boss_minion_type = "noggle"
	lvl.boss_spawn_interval = 3.0
	lvl.player_start = Vector2i(8, 10)
	lvl.time_limit = 180
	lvl.grid_layout = []
	for y in range(Constants.GRID_ROWS):
		var row: Array = []
		for x in range(Constants.GRID_COLS):
			var pos = Vector2i(x, y)
			if x == 0 or x == Constants.GRID_COLS - 1 or y == 0 or y == Constants.GRID_ROWS - 1:
				row.append(Constants.TileType.WALL)
			elif lvl.boss_arena.has_point(pos) and (x == lvl.boss_arena.position.x or x == lvl.boss_arena.end.x - 1 or y == lvl.boss_arena.position.y or y == lvl.boss_arena.end.y - 1):
				row.append(Constants.TileType.WALL)
			else:
				row.append(Constants.TileType.GROUND)
		lvl.grid_layout.append(row)
	return lvl

static func create_hydra_boss_level() -> LevelData:
	"""World 2 boss arena fixture for the Lernaean Hydra."""
	var lvl = LevelData.new(2, Constants.BOSS_LEVEL)
	lvl.level_name = "Lernaean Hydra Arena"
	lvl.is_boss_level = true
	lvl.boss_type = "hydra"
	lvl.boss_name = "Lernaean Hydra"
	lvl.boss_health = 4
	lvl.boss_position = Vector2i(8, 7)
	lvl.boss_arena = Rect2i(Vector2i(4, 3), Vector2i(9, 9))
	lvl.boss_minion_type = "zapper"
	lvl.boss_spawn_interval = 2.8
	lvl.player_start = Vector2i(8, 10)
	lvl.time_limit = 210
	lvl.grid_layout = []
	for y in range(Constants.GRID_ROWS):
		var row: Array = []
		for x in range(Constants.GRID_COLS):
			var pos = Vector2i(x, y)
			if x == 0 or x == Constants.GRID_COLS - 1 or y == 0 or y == Constants.GRID_ROWS - 1:
				row.append(Constants.TileType.WALL)
			elif lvl.boss_arena.has_point(pos) and (x == lvl.boss_arena.position.x or x == lvl.boss_arena.end.x - 1 or y == lvl.boss_arena.position.y or y == lvl.boss_arena.end.y - 1):
				row.append(Constants.TileType.WALL)
			elif (x >= 6 and x <= 10 and y >= 5 and y <= 9):
				row.append(Constants.TileType.WATER)
			else:
				row.append(Constants.TileType.GROUND)
		lvl.grid_layout.append(row)
	return lvl

static func create_chimera_boss_level() -> LevelData:
	"""World 3 boss arena fixture for the Chimera."""
	var lvl = LevelData.new(3, Constants.BOSS_LEVEL)
	lvl.level_name = "Chimera Arena"
	lvl.is_boss_level = true
	lvl.boss_type = "chimera"
	lvl.boss_name = "Chimera"
	lvl.boss_health = 5
	lvl.boss_position = Vector2i(8, 7)
	lvl.boss_arena = Rect2i(Vector2i(4, 3), Vector2i(9, 9))
	lvl.boss_minion_type = "flame_beast"
	lvl.boss_spawn_interval = 2.5
	lvl.player_start = Vector2i(8, 10)
	lvl.time_limit = 210
	lvl.grid_layout = []
	for y in range(Constants.GRID_ROWS):
		var row: Array = []
		for x in range(Constants.GRID_COLS):
			var pos = Vector2i(x, y)
			if x == 0 or x == Constants.GRID_COLS - 1 or y == 0 or y == Constants.GRID_ROWS - 1:
				row.append(Constants.TileType.WALL)
			elif lvl.boss_arena.has_point(pos) and (x == lvl.boss_arena.position.x or x == lvl.boss_arena.end.x - 1 or y == lvl.boss_arena.position.y or y == lvl.boss_arena.end.y - 1):
				row.append(Constants.TileType.WALL)
			else:
				row.append(Constants.TileType.GROUND)
		lvl.grid_layout.append(row)
	return lvl

static func create_medusa_boss_level() -> LevelData:
	"""World 4 final arena fixture for Medusa, the original Gorgon."""
	var lvl = LevelData.new(4, Constants.BOSS_LEVEL)
	lvl.level_name = "Medusa's Final Sanctum"
	lvl.is_boss_level = true
	lvl.boss_type = "medusa"
	lvl.boss_name = "Medusa, First Gorgon"
	lvl.boss_health = 6
	lvl.boss_position = Vector2i(8, 7)
	lvl.boss_arena = Rect2i(Vector2i(4, 3), Vector2i(9, 9))
	lvl.boss_minion_type = "hades_shadow"
	lvl.boss_spawn_interval = 2.2
	lvl.player_start = Vector2i(8, 10)
	lvl.time_limit = 240
	lvl.grid_layout = []
	for y in range(Constants.GRID_ROWS):
		var row: Array = []
		for x in range(Constants.GRID_COLS):
			var pos = Vector2i(x, y)
			if x == 0 or x == Constants.GRID_COLS - 1 or y == 0 or y == Constants.GRID_ROWS - 1:
				row.append(Constants.TileType.WALL)
			elif lvl.boss_arena.has_point(pos) and (x == lvl.boss_arena.position.x or x == lvl.boss_arena.end.x - 1 or y == lvl.boss_arena.position.y or y == lvl.boss_arena.end.y - 1):
				row.append(Constants.TileType.WALL)
			else:
				row.append(Constants.TileType.GROUND)
		lvl.grid_layout.append(row)
	return lvl

static func create_level_1_3() -> LevelData:
	"""World 1 - Level 3"""
	var lvl = LevelData.new(1, 3)
	lvl.level_name = "Stone Labyrinth"
	lvl.player_start = Vector2i(8, 13)
	
	# Create grid layout with more water
	lvl.grid_layout = []
	for y in range(Constants.GRID_ROWS):
		var row = []
		for x in range(Constants.GRID_COLS):
			if x == 0 or x == Constants.GRID_COLS - 1 or y == 0 or y == Constants.GRID_ROWS - 1:
				row.append(Constants.TileType.WALL)
			# Cross pattern of water
			elif (x == 8 and y >= 3 and y <= 11) or (y == 7 and x >= 3 and x <= 12):
				row.append(Constants.TileType.WATER)
			else:
				row.append(Constants.TileType.GROUND)
		lvl.grid_layout.append(row)
	
	# Soul urns on islands
	lvl.soul_urns = [
		Vector2i(4, 4),
		Vector2i(12, 4),
		Vector2i(4, 10),
		Vector2i(12, 10),
		Vector2i(8, 7)  # Center on water cross
	]
	
	# Multiple enemies
	lvl.enemies = [
		{"type": "noggle", "pos": Vector2i(4, 2), "pattern": [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]},
		{"type": "noggle", "pos": Vector2i(12, 2), "pattern": [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.UP]},
		{"type": "birdie", "pos": Vector2i(6, 7), "pattern": [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.LEFT]},
		{"type": "birdie", "pos": Vector2i(10, 7), "pattern": [Vector2i.LEFT, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.RIGHT]},
		{"type": "zapper", "pos": Vector2i(8, 5), "pattern": [Vector2i.UP, Vector2i.DOWN]},
		{"type": "zapper", "pos": Vector2i(8, 9), "pattern": [Vector2i.DOWN, Vector2i.UP]}
	]
	
	return lvl
