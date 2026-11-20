extends Node2D

const CONTROLLER_INPUT = preload("res://Scripts/controller_input.gd")

## Main Scene Script - Handles level initialization and tilemap generation

@onready var tilemap: Node2D = $TileMapLayer
@onready var game_manager = $GameManager
@onready var player = $Player

var all_tile_visuals: Array[Node] = []
var bridge_visuals: Dictionary = {}
var ground_tiles: Array[Node] = []
var water_tiles: Array[Node] = []
var hud_scene = preload("res://Scenes/hud.tscn")
var hud: CanvasLayer
var pause_menu_scene = preload("res://Scenes/pause_menu.tscn")
var pause_menu: CanvasLayer
var border_art_script = preload("res://Scenes/level_border_art.gd")
var border_art: Node2D
const TILE_ART_SCRIPT = preload("res://Scenes/tile_art_layer.gd")
var tile_art: Node2D

func _ready():
	CONTROLLER_INPUT.configure()
	# Wait for GameManager to be ready
	await get_tree().process_frame
	
	# Procedural temple relief fills the side gutters, never overlapping the 16x15 board.
	border_art = Node2D.new()
	border_art.name = "LevelBorderArt"
	border_art.set_script(border_art_script)
	add_child(border_art)
	move_child(border_art, 0)

	# Create HUD
	hud = hud_scene.instantiate()
	add_child(hud)
	
	# Create Pause Menu
	pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)
	pause_menu.restart_requested.connect(_on_pause_restart)
	pause_menu.overworld_requested.connect(_on_pause_overworld)
	
	# Load the level selected on overworld, defaulting to 1-1.
	var session = get_node("/root/GameSession")
	game_manager.level_manager.load_level(session.selected_world, session.selected_level)
	
	print("=== Gorgon's Debt - Greek Mythology Puzzle Game ===")
	print("Movement: Arrow Keys or WASD")
	print("Petrify Shot: Space (turns enemies to stone)")
	print("Create Pillar: Shift")
	print("Push petrified enemies to create bridges!")

func build_level_from_data(level_data: LevelData):
	"""Build the level from LevelData"""
	# Clear existing visuals
	clear_level_visuals()
	
	# Build grid from layout
	for y in range(level_data.grid_layout.size()):
		for x in range(level_data.grid_layout[y].size()):
			var tile_type = level_data.grid_layout[y][x]
			game_manager.grid_manager.set_tile(Vector2i(x, y), tile_type)
			create_tile_visual(Vector2i(x, y), tile_type)
	# Add surface detail on top of flat tile fills, below entities and UI.
	tile_art = Node2D.new()
	tile_art.name = "ProceduralTileArt"
	tile_art.set_script(TILE_ART_SCRIPT)
	tilemap.add_child(tile_art)
	tile_art.set_layout(level_data.grid_layout)
	
	# Position player at start
	if player:
		player.current_grid_pos = level_data.player_start
		player.target_grid_pos = level_data.player_start
		player.starting_position = level_data.player_start
		player.position = game_manager.grid_manager.grid_to_world(level_data.player_start)
		player.is_alive = true
		player.is_moving = false
		player.modulate = Color.WHITE
		player.scale = Vector2.ONE
		player.rotation = 0.0
		print("Player positioned at: ", level_data.player_start, " world: ", player.position)
	
	# Spawn soul urns
	for urn_pos in level_data.soul_urns:
		game_manager.spawn_soul_urn(urn_pos)
	
	# Draw boss arena boundary distinctly; boundary tiles were created as walls in level data.
	if level_data.is_boss_level:
		add_boss_arena_visuals(level_data.boss_arena)
	
	# Each authored default enemy is emitted by a spawner at its home cell.
	# Explicit spawner configuration takes precedence at duplicate coordinates.
	var spawners_by_pos: Dictionary = {}
	for spawner_data in level_data.spawners:
		spawners_by_pos[spawner_data.get("pos", Vector2i.ZERO)] = spawner_data
	for enemy_data in level_data.enemies:
		var enemy_pos: Vector2i = enemy_data["pos"]
		if not spawners_by_pos.has(enemy_pos):
			spawners_by_pos[enemy_pos] = {
				"pos": enemy_pos,
				"type": enemy_data.get("type", "noggle"),
				"pattern": enemy_data.get("pattern", []),
				"interval": 5.0
			}
	for spawner_data in spawners_by_pos.values():
		game_manager.spawn_enemy_spawner(
			spawner_data.get("pos", Vector2i.ZERO),
			spawner_data.get("type", "noggle"),
			spawner_data.get("pattern", []),
			spawner_data.get("interval", 5.0)
		)
	
	# Spawn directional rotators (blocks only)
	for rotator_data in level_data.rotators:
		game_manager.spawn_rotator(rotator_data.get("pos", Vector2i.ZERO), rotator_data.get("quarter_turns", 1))
	
	# Warp endpoints, boss and special tiles are spawned by GameManager after grid construction.
	print("Level built: ", level_data.soul_urns.size(), " urns, ", level_data.enemies.size(), " enemies")

func add_boss_arena_visuals(arena: Rect2i):
	"""Tint arena wall cells red-marble to distinguish boss boundary."""
	for x in range(arena.position.x, arena.end.x):
		_add_arena_tint(Vector2i(x, arena.position.y))
		_add_arena_tint(Vector2i(x, arena.end.y - 1))
	for y in range(arena.position.y + 1, arena.end.y - 1):
		_add_arena_tint(Vector2i(arena.position.x, y))
		_add_arena_tint(Vector2i(arena.end.x - 1, y))

func _add_arena_tint(grid_pos: Vector2i):
	var tint = ColorRect.new()
	tint.size = Vector2(Constants.TILE_SIZE - 8, Constants.TILE_SIZE - 8)
	tint.position = Vector2(Constants.PLAYFIELD_OFFSET_X + grid_pos.x * Constants.TILE_SIZE + 4, Constants.PLAYFIELD_OFFSET_Y + grid_pos.y * Constants.TILE_SIZE + 4)
	tint.color = Color("#C493B4")
	tint.z_index = Constants.LAYER_GROUND + 1
	tilemap.add_child(tint)
	all_tile_visuals.append(tint)

func is_inside_arena(grid_pos: Vector2i) -> bool:
	return game_manager.is_inside_boss_arena(grid_pos)

func get_boss_arena_entry(from_pos: Vector2i, attempted_pos: Vector2i, arena: Rect2i) -> Vector2i:
	# If leaving through the bottom doorway before boss defeat, remain on inner side.
	var delta = attempted_pos - from_pos
	var boundary_pos = from_pos + delta
	if boundary_pos.x == arena.position.x + arena.size.x / 2 and boundary_pos.y == arena.end.y - 1:
		return boundary_pos + Vector2i.UP
	return from_pos

func refresh_tile_visual(grid_pos: Vector2i, tile_type: int):
	var tile_pos = Vector2(Constants.PLAYFIELD_OFFSET_X + grid_pos.x * Constants.TILE_SIZE + 1, Constants.PLAYFIELD_OFFSET_Y + grid_pos.y * Constants.TILE_SIZE + 1)
	for visual in all_tile_visuals:
		if is_instance_valid(visual) and visual.position == tile_pos and visual is ColorRect:
			match tile_type:
				Constants.TileType.GROUND, Constants.TileType.ICE:
					visual.color = Constants.COLOR_GROUND
				Constants.TileType.WALL:
					visual.color = Constants.COLOR_WALL
				_:
					visual.color = Constants.COLOR_GROUND
			return
	create_tile_visual(grid_pos, tile_type)

func clear_level_visuals():
	"""Clear all visual tiles from the scene"""
	for tile in all_tile_visuals:
		if is_instance_valid(tile):
			tile.queue_free()
	all_tile_visuals.clear()
	bridge_visuals.clear()
	ground_tiles.clear()
	water_tiles.clear()
	
	# Ensure tilemap container has no remaining children
	if tilemap:
		for child in tilemap.get_children():
			if is_instance_valid(child):
				child.queue_free()

func create_tile_visual(grid_pos: Vector2i, tile_type: int):
	"""Create visual representation of a tile aligned with grid_to_world"""
	var tile_pos = Vector2(
		Constants.PLAYFIELD_OFFSET_X + grid_pos.x * Constants.TILE_SIZE + 1,
		Constants.PLAYFIELD_OFFSET_Y + grid_pos.y * Constants.TILE_SIZE + 1
	)
	
	var tile_visual = ColorRect.new()
	tile_visual.size = Vector2(Constants.TILE_SIZE - 2, Constants.TILE_SIZE - 2)
	tile_visual.position = tile_pos
	tile_visual.z_index = Constants.LAYER_GROUND
	
	match tile_type:
		Constants.TileType.WALL:
			tile_visual.color = Constants.COLOR_WALL
		Constants.TileType.STONE_BLOCK:
			tile_visual.color = Color("#BDBDB4")  # Breakable pillar, grey stone
		Constants.TileType.WATER:
			tile_visual.color = Constants.COLOR_WATER
			water_tiles.append(tile_visual)
		Constants.TileType.GROUND, Constants.TileType.ICE, Constants.TileType.SPRING, Constants.TileType.ROTATOR:
			tile_visual.color = Constants.COLOR_GROUND
		Constants.TileType.HOLE:
			tile_visual.color = Color("#6BAAD0")
		Constants.TileType.PLAYER_ONLY:
			tile_visual.color = Color("#C3ADE8")
		Constants.TileType.SLIPPERY:
			tile_visual.color = Color("#D2E9EF")
		Constants.TileType.ONE_WAY:
			tile_visual.color = Color("#DDBC7E")
			ground_tiles.append(tile_visual)
		Constants.TileType.CONVEYOR:
			tile_visual.color = Color("#BBAA8C")
			ground_tiles.append(tile_visual)
		_:
			tile_visual.color = Constants.COLOR_GROUND
	
	tilemap.add_child(tile_visual)
	all_tile_visuals.append(tile_visual)

func add_bridge_visual(grid_pos: Vector2i) -> ColorRect:
	"""Add a bridge tile visual when a statue falls into water"""
	var tile_pos = Vector2(
		Constants.PLAYFIELD_OFFSET_X + grid_pos.x * Constants.TILE_SIZE + 1,
		Constants.PLAYFIELD_OFFSET_Y + grid_pos.y * Constants.TILE_SIZE + 1
	)
	
	var bridge_visual = ColorRect.new()
	bridge_visual.size = Vector2(Constants.TILE_SIZE - 2, Constants.TILE_SIZE - 2)
	bridge_visual.position = tile_pos
	bridge_visual.color = Color(0.6, 0.7, 0.8, 1.0)  # Lighter blue-gray for bridge
	bridge_visual.z_index = Constants.LAYER_GROUND + 1
	
	tilemap.add_child(bridge_visual)
	all_tile_visuals.append(bridge_visual)
	bridge_visuals[grid_pos] = bridge_visual
	return bridge_visual

func remove_bridge_visual(grid_pos: Vector2i) -> void:
	var bridge_visual = bridge_visuals.get(grid_pos)
	if bridge_visual and is_instance_valid(bridge_visual):
		bridge_visual.queue_free()
	bridge_visuals.erase(grid_pos)
	all_tile_visuals.erase(bridge_visual)

func _on_pause_restart() -> void:
	"""RappelÃ© quand le joueur choisit 'Recommencer le niveau' depuis la pause"""
	if game_manager and game_manager.has_method("quick_retry_level"):
		game_manager.quick_retry_level()

func _on_pause_overworld() -> void:
	"""RappelÃ© quand le joueur choisit 'Carte du monde' depuis la pause"""
	var session = get_node_or_null("/root/GameSession")
	get_tree().change_scene_to_file(session.scene_after_level() if session else "res://Scenes/overworld_map.tscn")

