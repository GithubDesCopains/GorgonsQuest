extends Node

## Main Game Manager - Handles game state, coordination, score, and sound

var grid_manager: GridManager
var level_manager: Node
var current_level: int = 1
var current_world: int = 1
var souls_collected: int = 0
var souls_required: int = 0

# Score system
var score: int = 0
var level_score_start: int = 0
var enemies_squashed_this_level: int = 0
var level_completion_started: bool = false
signal score_changed(new_score: int)

# Sound system
var sound_manager: Node

# Lives system
var max_lives: int = 5
var current_lives: int = 5
var is_player_dead: bool = false
var respawn_delay: float = 2.0

var projectile_scene = preload("res://Scenes/petrify_projectile.tscn")
var pillar_scene = preload("res://Scenes/stone_pillar.tscn")
var soul_urn_scene = preload("res://Scenes/soul_urn.tscn")
var enemy_scene = preload("res://Scenes/enemy.tscn")
var noggle_scene = preload("res://Scenes/noggle.tscn")
var wall_hugger_scene = preload("res://Scenes/wall_hugger.tscn")
var jumper_enemy_scene = preload("res://Scenes/jumper_enemy.tscn")
var pusher_enemy_scene = preload("res://Scenes/pusher_enemy.tscn")
var hades_shadow_scene = preload("res://Scenes/hades_shadow.tscn")
var flame_beast_scene = preload("res://Scenes/flame_beast.tscn")
var birdie_scene = preload("res://Scenes/birdie.tscn")
var zapper_scene = preload("res://Scenes/zapper.tscn")
var enemy_spawner_scene = preload("res://Scenes/enemy_spawner.tscn")
var boss_scene = preload("res://Scenes/boss.tscn")
var cyclops_boss_script = preload("res://Scripts/cyclops_boss.gd")
var hydra_boss_script = preload("res://Scripts/hydra_boss.gd")
var chimera_boss_script = preload("res://Scripts/chimera_boss.gd")
var medusa_boss_script = preload("res://Scripts/medusa_boss.gd")
var boss: Node
var boss_arena_rect: Rect2i = Rect2i()
var spring_scene = preload("res://Scenes/spring_tile.tscn")
var rotator_scene = preload("res://Scenes/rotator_tile.tscn")
var warp_scene = preload("res://Scenes/warp_tile.tscn")
var slippery_scene = preload("res://Scenes/slippery_tile.tscn")
var one_way_scene = preload("res://Scenes/one_way_tile.tscn")
var conveyor_scene = preload("res://Scenes/conveyor_tile.tscn")
var spring_tiles: Array = []
var conveyor_tiles: Array = []
var one_way_tiles: Array = []
var rotator_tiles: Array = []
var warp_tiles: Array = []
var slippery_tiles: Array = []
var last_warp_frame: int = -1
signal warp_activated(source: Vector2i, destination: Vector2i)
signal spring_triggered(grid_pos: Vector2i, direction: Vector2i)
var victory_screen_scene = preload("res://Scenes/victory_screen.tscn")
var game_over_screen_scene = preload("res://Scenes/game_over_screen.tscn")
var level_manager_script = preload("res://Scripts/level_manager.gd")
var sound_manager_script = preload("res://Scripts/sound_manager.gd")
var save_manager_script = preload("res://Scripts/save_manager.gd")
var save_manager: Node

var pillars: Array = []
var soul_urns: Array = []
var enemies: Array = []
var spawners: Array = []
var push_blocks: Array = []
var bonus_items: Array = []
var push_block_script = preload("res://Scenes/push_block.gd")
var bonus_item_script = preload("res://Scenes/bonus_item.gd")
var mirror_script = preload("res://Scenes/mirror_tile.gd")
var switch_script = preload("res://Scenes/switch_tile.gd")
var door_script = preload("res://Scenes/door_tile.gd")
var hammer_script = preload("res://Scenes/hammer_tile.gd")
var hammer_tiles: Array = []
var mirror_tiles: Array = []
var switch_tiles: Array = []
var door_tiles: Array = []

signal lives_changed(lives: int)
signal bonus_collected(kind: String)
signal game_over()
signal enemy_squashed(enemy, points: int)
signal enemy_shattered(enemy)
signal pillar_destroyed(grid_pos: Vector2i)
signal time_changed(time_left: int)
signal time_out()

# Timer system
var time_limit: int = 90
var time_remaining: float = 90.0
var is_timer_active: bool = false

@onready var player: Player

func _ready():
	# Create grid manager
	grid_manager = GridManager.new()
	grid_manager.name = "GridManager"
	add_child(grid_manager)
	
	# Create level manager
	level_manager = level_manager_script.new()
	level_manager.name = "LevelManager"
	add_child(level_manager)
	level_manager.level_loaded.connect(_on_level_loaded)
	
	# Create sound manager
	sound_manager = sound_manager_script.new()
	sound_manager.name = "SoundManager"
	add_child(sound_manager)
	
	# Create save manager
	save_manager = save_manager_script.new()
	save_manager.name = "SaveManager"
	add_child(save_manager)
	
	# Initialize lives
	current_lives = max_lives
	
	is_player_dead = false
	
	# Wait for scene tree to be ready
	await get_tree().process_frame
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.moved_to_tile.connect(_on_player_moved)
		player.petrify_shot_fired.connect(_on_petrify_shot_fired)
		player.pillar_created.connect(_on_pillar_created)
		player.player_died.connect(_on_player_died_animation_done)
	
	print("GameManager initialized - Lives: ", current_lives)

func _process(delta):
	update_switches()
	if is_timer_active and not is_player_dead:
		var prev_sec = int(ceil(time_remaining))
		time_remaining -= delta
		var curr_sec = int(ceil(time_remaining))
		
		if curr_sec != prev_sec:
			time_changed.emit(max(0, curr_sec))
			if is_inside_tree():
				var tree = get_tree()
				if tree:
					var hud = tree.get_first_node_in_group("hud")
					if hud and hud.has_method("update_time"):
						hud.update_time(max(0, curr_sec))
		
		if time_remaining <= 0.0:
			time_remaining = 0.0
			is_timer_active = false
			on_time_out()

func on_time_out():
	"""Trigger penalty when time limit expires"""
	print("⏱️ TIME OUT! Player out of time!")
	time_out.emit()
	player_hit_by_enemy()

func _on_player_moved(grid_pos: Vector2i):
	"""Called when player moves to a new tile"""
	if boss_arena_rect.size != Vector2i.ZERO and not boss_arena_rect.has_point(grid_pos) and is_instance_valid(boss) and not boss.get("defeated"):
		var blocked_entry = player.previous_grid_pos
		if not boss_arena_rect.has_point(blocked_entry):
			var move_vector: Vector2i = Constants.DIR_VECTORS.get(player.current_direction, Vector2i.ZERO)
			blocked_entry = grid_pos - move_vector
		if not boss_arena_rect.has_point(blocked_entry):
			blocked_entry = player.starting_position
		player.current_grid_pos = blocked_entry
		player.target_grid_pos = blocked_entry
		player.position = grid_manager.grid_to_world(blocked_entry)
		player.is_moving = false
		return
	if Engine.get_process_frames() == last_warp_frame:
		return # Prevent instant return through paired endpoint
	check_tile_events(grid_pos)
	if not is_instance_valid(grid_manager):
		return
	if grid_manager.get_tile(grid_pos) == Constants.TileType.WARP:
		var warp_destination = activate_warp(grid_pos)
		if warp_destination != Vector2i(-1, -1) and is_instance_valid(player):
			var source_world = grid_manager.grid_to_world(grid_pos)
			var destination_world = grid_manager.grid_to_world(warp_destination)
			player.position = source_world
			var tween = player.create_tween()
			tween.tween_property(player, "modulate:a", 0.15, 0.08)
			tween.tween_callback(func(): player.position = destination_world)
			tween.tween_property(player, "modulate:a", 1.0, 0.1)
			player.current_grid_pos = warp_destination
			player.target_grid_pos = warp_destination
			player.is_moving = false
			player.moved_to_tile.emit(warp_destination)
			return
	if grid_manager.get_tile(grid_pos) == Constants.TileType.SPRING:
		var spring_dir = grid_manager.get_spring_direction(grid_pos)
		if spring_dir != Vector2i.ZERO and is_instance_valid(player):
			var spring = find_spring_at(grid_pos)
			if spring:
				spring.animate_compression()
			spring_triggered.emit(grid_pos, spring_dir)
			player.launch_from_spring(spring_dir)

func find_spring_at(grid_pos: Vector2i) -> SpringTile:
	for spring in spring_tiles:
		if is_instance_valid(spring) and spring.grid_pos == grid_pos:
			return spring
	return null

func spawn_spring(grid_pos: Vector2i, launch_direction: Vector2i) -> SpringTile:
	if not grid_manager.is_valid_grid_pos(grid_pos):
		return null
	if not grid_manager.is_walkable(grid_pos):
		return null
	var spring = spring_scene.instantiate()
	get_parent().add_child(spring)
	grid_manager.set_tile(grid_pos, Constants.TileType.SPRING)
	grid_manager.set_spring_direction(grid_pos, launch_direction)
	spring.initialize(grid_pos, launch_direction)
	spring_tiles.append(spring)
	return spring

func spawn_spring_for_level(grid_pos: Vector2i, launch_direction: Vector2i):
	spawn_spring(grid_pos, launch_direction)

func spawn_rotator(grid_pos: Vector2i, quarter_turns: int = 1) -> RotatorTile:
	if not grid_manager.is_valid_grid_pos(grid_pos) or not grid_manager.is_walkable(grid_pos):
		return null
	var rotator = rotator_scene.instantiate()
	get_parent().add_child(rotator)
	grid_manager.set_tile(grid_pos, Constants.TileType.ROTATOR)
	grid_manager.set_rotator_turn(grid_pos, quarter_turns)
	rotator.initialize(grid_pos, quarter_turns)
	rotator_tiles.append(rotator)
	return rotator

func find_rotator_at(grid_pos: Vector2i) -> RotatorTile:
	for rotator in rotator_tiles:
		if is_instance_valid(rotator) and rotator.grid_pos == grid_pos:
			return rotator
	return null

func spawn_conveyor(grid_pos: Vector2i, direction: Vector2i):
	if not is_instance_valid(grid_manager) or not grid_manager.is_valid_grid_pos(grid_pos):
		return null
	if grid_manager.get_tile(grid_pos) != Constants.TileType.GROUND:
		return null
	if not grid_manager.set_conveyor_direction(grid_pos, direction):
		return null
	var conveyor = conveyor_scene.instantiate()
	get_parent().add_child(conveyor)
	grid_manager.set_tile(grid_pos, Constants.TileType.CONVEYOR)
	conveyor.initialize(grid_pos, direction)
	conveyor_tiles.append(conveyor)
	return conveyor

func find_conveyor_at(grid_pos: Vector2i):
	for conveyor in conveyor_tiles:
		if is_instance_valid(conveyor) and conveyor.grid_pos == grid_pos:
			return conveyor
	return null

func spawn_one_way_gate(grid_pos: Vector2i, direction: Vector2i):
	if not is_instance_valid(grid_manager) or not grid_manager.is_valid_grid_pos(grid_pos):
		return null
	if grid_manager.get_tile(grid_pos) != Constants.TileType.GROUND:
		return null
	if not grid_manager.set_one_way_direction(grid_pos, direction):
		return null
	var gate = one_way_scene.instantiate()
	get_parent().add_child(gate)
	grid_manager.set_tile(grid_pos, Constants.TileType.ONE_WAY)
	gate.initialize(grid_pos, direction)
	one_way_tiles.append(gate)
	return gate

func spawn_slippery_tile(grid_pos: Vector2i) -> SlipperyTile:
	if not grid_manager.is_valid_grid_pos(grid_pos):
		return null
	if grid_manager.get_tile(grid_pos) != Constants.TileType.GROUND:
		return null
	var slippery = slippery_scene.instantiate()
	get_parent().add_child(slippery)
	grid_manager.set_tile(grid_pos, Constants.TileType.SLIPPERY)
	slippery.initialize(grid_pos)
	slippery_tiles.append(slippery)
	return slippery

func find_slippery_tile(grid_pos: Vector2i) -> SlipperyTile:
	for tile in slippery_tiles:
		if is_instance_valid(tile) and tile.grid_pos == grid_pos:
			return tile
	return null

func spawn_warp_endpoint(grid_pos: Vector2i, pair_id: String) -> WarpTile:
	if pair_id.is_empty() or not grid_manager.is_valid_grid_pos(grid_pos):
		return null
	if grid_manager.get_tile(grid_pos) != Constants.TileType.GROUND and grid_manager.get_tile(grid_pos) != Constants.TileType.ICE:
		return null
	var warp = warp_scene.instantiate()
	get_parent().add_child(warp)
	if not grid_manager.register_warp_endpoint(pair_id, grid_pos):
		warp.queue_free()
		return null
	grid_manager.set_tile(grid_pos, Constants.TileType.WARP)
	warp.initialize(grid_pos, pair_id)
	warp_tiles.append(warp)
	return warp

func teleport_enemy_through_warp(enemy: Enemy, source_pos: Vector2i) -> bool:
	if not is_instance_valid(enemy) or not is_instance_valid(grid_manager):
		return false
	var destination = activate_warp(source_pos)
	if destination == Vector2i(-1, -1):
		return false
	enemy.current_grid_pos = destination
	enemy.target_grid_pos = destination
	enemy.position = grid_manager.grid_to_world(destination)
	enemy.is_moving = false
	return true

func find_warp_at(grid_pos: Vector2i) -> WarpTile:
	for warp in warp_tiles:
		if is_instance_valid(warp) and warp.grid_pos == grid_pos:
			return warp
	return null

func get_bridge_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	if not is_instance_valid(grid_manager):
		return positions
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			var pos = Vector2i(x, y)
			if grid_manager.get_tile(pos) == Constants.TileType.ICE:
				positions.append(pos)
	return positions

func remove_bridge_at(grid_pos: Vector2i) -> bool:
	if not is_instance_valid(grid_manager) or grid_manager.get_tile(grid_pos) != Constants.TileType.ICE:
		return false
	var player_pos = player.current_grid_pos if is_instance_valid(player) and player.is_alive else Vector2i(-1, -1)
	if player_pos == grid_pos:
		return false
	grid_manager.set_tile(grid_pos, Constants.TileType.WATER)
	var main_node = get_parent()
	if main_node and main_node.has_method("remove_bridge_visual"):
		main_node.remove_bridge_visual(grid_pos)
	print("🌊 Pusher dissolved bridge at: ", grid_pos)
	return true

func configure_boss_arena(arena: Rect2i):
	boss_arena_rect = arena

func is_inside_boss_arena(grid_pos: Vector2i) -> bool:
	return boss_arena_rect.size != Vector2i.ZERO and boss_arena_rect.has_point(grid_pos)

func find_open_boss_spawn_position(boss_world_position: Vector2) -> Vector2i:
	if not is_instance_valid(grid_manager):
		return Vector2i(-1, -1)
	var center = grid_manager.world_to_grid(boss_world_position)
	var candidates = [center + Vector2i.LEFT, center + Vector2i.RIGHT, center + Vector2i.UP, center + Vector2i.DOWN, center + Vector2i(-2, 0), center + Vector2i(2, 0)]
	for candidate in candidates:
		if not grid_manager.is_walkable(candidate) or not is_inside_boss_arena(candidate):
			continue
		if grid_manager.world_to_grid(boss_world_position) == candidate:
			continue
		if get_enemy_at(candidate) != null:
			continue
		if player and is_instance_valid(player) and player.current_grid_pos == candidate:
			continue
		return candidate
	return Vector2i(-1, -1)

func get_enemy_at(grid_pos: Vector2i) -> Enemy:
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_squashed and enemy.current_grid_pos == grid_pos:
			return enemy
	return null

func spawn_boss(level_data: LevelData):
	if not level_data.is_boss_level or level_data.boss_health <= 0:
		return null
	boss_arena_rect = level_data.boss_arena
	# Configure central exit as sealed until boss defeat.
	var exit_pos = Vector2i(boss_arena_rect.position.x + boss_arena_rect.size.x / 2, boss_arena_rect.end.y - 1)
	grid_manager.set_tile(exit_pos, Constants.TileType.WALL)
	var instance
	if level_data.boss_type == "cyclops":
		instance = Node2D.new()
		instance.set_script(cyclops_boss_script)
	elif level_data.boss_type == "hydra":
		instance = Node2D.new()
		instance.set_script(hydra_boss_script)
	elif level_data.boss_type == "chimera":
		instance = Node2D.new()
		instance.set_script(chimera_boss_script)
	elif level_data.boss_type == "medusa":
		instance = Node2D.new()
		instance.set_script(medusa_boss_script)
	else:
		instance = boss_scene.instantiate()
	get_parent().add_child(instance)
	instance.configure(level_data.boss_name, level_data.boss_health, level_data.boss_minion_type, level_data.boss_spawn_interval)
	instance.position = grid_manager.grid_to_world(level_data.boss_position)
	boss = instance
	boss.boss_defeated.connect(_on_boss_defeated)
	_play_sound("play_boss_music")
	return boss

func _on_boss_defeated():
	if is_instance_valid(grid_manager) and boss_arena_rect.size != Vector2i.ZERO:
		var exit_pos = Vector2i(boss_arena_rect.position.x + boss_arena_rect.size.x / 2, boss_arena_rect.end.y - 1)
		grid_manager.set_tile(exit_pos, Constants.TileType.GROUND)
		var main_scene = get_parent() if is_inside_tree() else null
		if main_scene and main_scene.has_method("refresh_tile_visual"):
			main_scene.refresh_tile_visual(exit_pos, Constants.TileType.GROUND)
	boss = null
	_play_sound("end_boss_music", [current_world])
	print("Boss defeated! Arena exit unlocked.")

func activate_warp(source_pos: Vector2i) -> Vector2i:
	if not is_instance_valid(grid_manager):
		return Vector2i(-1, -1)
	var destination = grid_manager.get_warp_destination(source_pos)
	if destination == Vector2i(-1, -1) or not grid_manager.is_walkable(destination):
		return Vector2i(-1, -1)
	if is_instance_valid(player):
		var player_grid = player.current_grid_pos
		if player_grid == source_pos:
			player_grid = player.target_grid_pos
		if player_grid == destination:
			return Vector2i(-1, -1)
		if player.get_statue_at(destination) != null:
			return Vector2i(-1, -1)
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_squashed and enemy.current_grid_pos == destination:
			return Vector2i(-1, -1)
	if grid_manager.get_tile(destination) == Constants.TileType.WATER:
		return Vector2i(-1, -1)
	for pillar in pillars:
		if is_instance_valid(pillar) and pillar.grid_pos == destination:
			return Vector2i(-1, -1)
	if is_instance_valid(player):
		player.position = grid_manager.grid_to_world(source_pos)
	var source_warp = find_warp_at(source_pos)
	var destination_warp = find_warp_at(destination)
	if source_warp:
		source_warp.animate_activation()
	if destination_warp:
		destination_warp.animate_activation()
	last_warp_frame = Engine.get_process_frames()
	warp_activated.emit(source_pos, destination)
	print("🌀 Warp activated: ", source_pos, " -> ", destination)
	return destination

func _on_petrify_shot_fired(direction: int):
	"""Handle petrifying shot"""
	# Create projectile
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	# Initialize at player position, slightly offset
	var offset = Constants.DIR_VECTORS[direction] * 40
	projectile.initialize(player.position + offset, direction, player.position)
	
	projectile.enemy_hit.connect(_on_projectile_hit_enemy)
	projectile.wall_hit.connect(_on_projectile_hit_wall)
	# The hero may fire again once this laser hit an enemy or an obstacle.
	if is_instance_valid(player) and player.has_method("on_shot_finished"):
		projectile.tree_exited.connect(player.on_shot_finished)

func _on_pillar_created(grid_pos: Vector2i):
	"""Handle pillar creation"""
	# Don't create if pillar already exists there
	for p in pillars:
		if is_instance_valid(p) and p.grid_pos == grid_pos:
			return
	
	grid_manager.set_tile(grid_pos, Constants.TileType.STONE_BLOCK)
	
	# Create visual pillar
	var pillar = pillar_scene.instantiate()
	get_parent().add_child(pillar)
	pillar.initialize(grid_pos)
	pillars.append(pillar)

func _on_projectile_hit_enemy(enemy):
	"""Handle projectile hitting an enemy: bosses resist direct gaze."""
	if is_instance_valid(boss) and is_instance_valid(enemy) and enemy == boss:
		boss.receive_gaze()
		return
	if not is_instance_valid(enemy):
		return
	if enemy.has_method("is_immune_to_petrification") and enemy.is_immune_to_petrification():
		if enemy.has_method("show_immune_flash"):
			enemy.show_immune_flash()
		print("🔥 The flame beast resists petrification!")
		return
	if enemy.petrified:
		if enemy.has_method("shatter"):
			enemy.shatter()
	else:
		if enemy.has_method("petrify"):
			enemy.petrify()

func on_enemy_shattered(enemy):
	"""Called when an already petrified enemy is shattered by a beam"""
	var idx = enemies.find(enemy)
	if idx != -1:
		enemies.remove_at(idx)
	enemy_shattered.emit(enemy)

func _on_projectile_hit_wall(grid_pos: Vector2i):
	"""Handle projectile hitting a wall or stone pillar"""
	if is_instance_valid(grid_manager) and grid_manager.get_tile(grid_pos) == Constants.TileType.STONE_BLOCK:
		destroy_pillar_at(grid_pos)

func destroy_pillar_at(grid_pos: Vector2i):
	"""Destroy a stone pillar at the given grid position"""
	for i in range(pillars.size() - 1, -1, -1):
		var pillar = pillars[i]
		if is_instance_valid(pillar) and pillar.grid_pos == grid_pos:
			pillars.remove_at(i)
			pillar.destroy()
			break
	
	if is_instance_valid(grid_manager):
		grid_manager.set_tile(grid_pos, Constants.TileType.GROUND)
	
	_play_sound("play_shatter")
	
	print("🗿 Stone pillar destroyed at: ", grid_pos)
	pillar_destroyed.emit(grid_pos)

func check_tile_events(grid_pos: Vector2i):
	"""Check for special tile events (collectibles, hazards, etc)"""
	# Check for soul urns (iterate safely)
	for i in range(soul_urns.size() - 1, -1, -1):
		var urn = soul_urns[i]
		if not is_instance_valid(urn):
			soul_urns.remove_at(i)
			continue
		
		if urn.grid_pos == grid_pos and not urn.collected:
			urn.collect()
			return
	check_bonus_at(grid_pos)

func spawn_push_block(grid_pos: Vector2i) -> Node2D:
	"""Create a dark-blue pushable block that slides and sinks into water."""
	var block := Node2D.new()
	block.set_script(push_block_script)
	get_parent().add_child(block)
	block.initialize(grid_pos, grid_manager)
	push_blocks.append(block)
	return block

func spawn_mirror(grid_pos: Vector2i, orientation: String) -> Node2D:
	var mirror := Node2D.new()
	mirror.set_script(mirror_script)
	get_parent().add_child(mirror)
	mirror.initialize(grid_pos, orientation, grid_manager)
	mirror_tiles.append(mirror)
	return mirror

func find_mirror_at(grid_pos: Vector2i) -> Node2D:
	for mirror in mirror_tiles:
		if is_instance_valid(mirror) and mirror.grid_pos == grid_pos:
			return mirror
	return null

func spawn_switch(grid_pos: Vector2i, id: String) -> Node2D:
	var plate := Node2D.new()
	plate.set_script(switch_script)
	get_parent().add_child(plate)
	plate.initialize(grid_pos, id, grid_manager)
	switch_tiles.append(plate)
	return plate

func spawn_door(grid_pos: Vector2i, direction: Vector2i, id: String) -> Node2D:
	var door := Node2D.new()
	door.set_script(door_script)
	get_parent().add_child(door)
	door.initialize(grid_pos, direction, id, grid_manager)
	door_tiles.append(door)
	return door

func spawn_hammer(pivot: Vector2i, head_dir: Vector2i) -> Node2D:
	if not is_instance_valid(grid_manager) or not grid_manager.set_hammer(pivot, head_dir):
		return null
	var hammer := Node2D.new()
	hammer.set_script(hammer_script)
	get_parent().add_child(hammer)
	hammer.initialize(pivot, head_dir, grid_manager, self)
	hammer_tiles.append(hammer)
	return hammer

func find_hammer_at(pivot: Vector2i) -> Node2D:
	for hammer in hammer_tiles:
		if is_instance_valid(hammer) and hammer.grid_pos == pivot:
			return hammer
	return null

func is_switch_pressed(grid_pos: Vector2i) -> bool:
	"""A switch is held down by a pushable block or by a petrified enemy resting on it."""
	if grid_manager.has_push_block(grid_pos):
		return true
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.petrified and not enemy.is_squashed and enemy.current_grid_pos == grid_pos:
			return true
	return false

func update_switches() -> void:
	"""Doors of an id are open while EVERY switch of that id is held down. A statue holds a switch for as long as it
	stays stone (20 s, renewed by shooting it again); then the door closes again."""
	if switch_tiles.is_empty() or not is_instance_valid(grid_manager):
		return
	var pressed_by_id: Dictionary = {}
	for plate in switch_tiles:
		if not is_instance_valid(plate):
			continue
		var held := is_switch_pressed(plate.grid_pos)
		plate.set_pressed(held)
		pressed_by_id[plate.switch_id] = pressed_by_id.get(plate.switch_id, true) and held
	for id in pressed_by_id:
		if grid_manager.set_door_open(id, pressed_by_id[id]):
			for door in door_tiles:
				if is_instance_valid(door) and door.door_id == id:
					door.set_open(pressed_by_id[id])
			_play_sound("play_bridge")

func spawn_bonus_item(grid_pos: Vector2i, kind: String = "ambrosia") -> Node2D:
	var item := Node2D.new()
	item.set_script(bonus_item_script)
	get_parent().add_child(item)
	item.initialize(grid_pos, kind, grid_manager)
	bonus_items.append(item)
	return item

func check_bonus_at(grid_pos: Vector2i) -> bool:
	for i in range(bonus_items.size() - 1, -1, -1):
		var item = bonus_items[i]
		if not is_instance_valid(item):
			bonus_items.remove_at(i)
			continue
		if item.grid_pos == grid_pos and not item.collected:
			bonus_items.remove_at(i)
			collect_bonus(item.kind)
			item.collect()
			return true
	return false

func collect_bonus(kind: String) -> void:
	"""Apply a bonus effect: ambrosia gives points, the Gorgon orb petrifies every living enemy."""
	bonus_collected.emit(kind)
	if kind == "gorgon_orb":
		petrify_all_enemies()
		add_score(300)
	else:
		add_score(bonus_item_script.AMBROSIA_POINTS)
	_play_sound("play_collect")

func petrify_all_enemies() -> int:
	"""Turn every living, petrifiable enemy into stone. Returns how many were petrified."""
	var count := 0
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.petrified or enemy.is_squashed:
			continue
		if enemy.has_method("is_petrifiable") and not enemy.is_petrifiable():
			continue
		if enemy.has_method("petrify"):
			enemy.petrify()
			if enemy.petrified:
				count += 1
	return count

func spawn_soul_urn(grid_pos: Vector2i):
	"""Spawn a soul urn at grid position"""
	var urn = soul_urn_scene.instantiate()
	get_parent().add_child(urn)
	urn.initialize(grid_pos)
	urn.collected_signal.connect(_on_soul_collected)
	soul_urns.append(urn)
	souls_required += 1

func spawn_enemy(grid_pos: Vector2i, patrol_pattern: Array = [], enemy_type: String = "noggle") -> Enemy:
	"""Spawn an enemy at grid position with patrol pattern and type"""
	var enemy: Enemy
	
	match enemy_type:
		"flame_beast":
			enemy = flame_beast_scene.instantiate()
		"hades_shadow":
			enemy = hades_shadow_scene.instantiate()
		"pusher":
			enemy = pusher_enemy_scene.instantiate()
		"jumper":
			enemy = jumper_enemy_scene.instantiate()
		"wall_hugger":
			enemy = wall_hugger_scene.instantiate()
		"birdie":
			enemy = birdie_scene.instantiate()
		"zapper":
			enemy = zapper_scene.instantiate()
		"noggle":
			enemy = noggle_scene.instantiate()
		_:
			enemy = enemy_scene.instantiate()
	
	get_parent().add_child(enemy)
	
	# Wait for enemy to be ready
	await get_tree().process_frame
	
	# Now initialize with position
	enemy.initialize(grid_pos, patrol_pattern)
	enemy.enemy_petrified.connect(_on_enemy_petrified)
	enemies.append(enemy)
	print("Enemy (", enemy_type, ") spawned at: ", grid_pos)
	return enemy

func spawn_enemy_spawner(grid_pos: Vector2i, type: String = "noggle", pattern: Array = [], interval: float = 5.0) -> EnemySpawner:
	"""Spawn an enemy spawner hole at grid position"""
	var spawner = enemy_spawner_scene.instantiate()
	get_parent().add_child(spawner)
	spawner.initialize(grid_pos, type, pattern, interval)
	spawners.append(spawner)
	if is_instance_valid(grid_manager):
		grid_manager.set_spawner(grid_pos)  # a spawner is as solid as a wall
	print("Enemy spawner created at: ", grid_pos, " type: ", type)
	return spawner

func _play_sound(method: StringName, args: Array = []) -> void:
	"""Call a SoundManager method if one exists; silently skipped when there is no sound manager (tests, stubs)."""
	if is_instance_valid(sound_manager) and sound_manager.has_method(method):
		sound_manager.callv(method, args)

func _on_enemy_petrified(enemy):
	"""Handle enemy being petrified"""
	print("Enemy turned to stone - can now be pushed!")
	# Score: petrify enemy
	add_score(100)
	_play_sound("play_petrify")

func on_enemy_squashed(enemy):
	"""Handle enemy being squashed by a sliding block"""
	enemies_squashed_this_level += 1
	add_score(200)
	var idx = enemies.find(enemy)
	if idx != -1:
		enemies.remove_at(idx)
	enemy_squashed.emit(enemy, 200)

func _on_soul_collected(urn):
	"""Handle soul collection"""
	souls_collected += 1
	add_score(1000)
	print("Souls: ", souls_collected, "/", souls_required)
	
	# Remove from array
	var idx = soul_urns.find(urn)
	if idx != -1:
		soul_urns.remove_at(idx)
	
	_play_sound("play_collect")
	
	# Update HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_souls"):
		hud.update_souls(souls_collected, souls_required)
	
	check_level_complete()

func add_score(points: int):
	"""Add points to score"""
	score += points
	score_changed.emit(score)
	
	# Update HUD if available
	if is_inside_tree():
		var tree = get_tree()
		if tree:
			var hud = tree.get_first_node_in_group("hud")
			if hud and hud.has_method("update_score"):
				hud.update_score(score)

func check_level_complete():
	"""Check if level is complete"""
	if souls_collected >= souls_required and souls_required > 0:
		level_complete()

func build_level_clear_summary() -> Dictionary:
	var time_bonus: int = int(ceil(maxf(time_remaining, 0.0))) * 20
	var level_points_before_clear: int = maxi(0, score - level_score_start)
	var completion_bonus: int = 5000
	var total_level_points: int = level_points_before_clear + completion_bonus + time_bonus
	return {
		"world": current_world,
		"level": current_level,
		"score_before_clear": score,
		"score_start": level_score_start,
		"earned_points": level_points_before_clear,
		"urn_points": souls_collected * 1000,
		"squash_points": enemies_squashed_this_level * 200,
		"squashed_count": enemies_squashed_this_level,
		"completion_bonus": completion_bonus,
		"time_remaining": int(ceil(maxf(time_remaining, 0.0))),
		"time_bonus": time_bonus,
		"level_points": total_level_points,
		"total_score": score + completion_bonus + time_bonus
	}

func level_complete():
	"""Handle level completion and display itemized score summary."""
	if level_completion_started:
		return
	level_completion_started = true
	print("🎉 LEVEL COMPLETE! 🎉")
	print("All Soul Urns collected!")
	is_timer_active = false
	if is_instance_valid(player) and player.has_method("celebrate"):
		player.celebrate()
	var summary: Dictionary = build_level_clear_summary()
	add_score(summary["completion_bonus"] + summary["time_bonus"])
	summary["total_score"] = score
	var previous_best: int = save_manager.get_best_score(current_world, current_level) if save_manager else 0
	summary["previous_best"] = previous_best
	summary["is_new_record"] = summary["level_points"] > previous_best
	if save_manager and save_manager.has_method("record_level_completion") and not _is_custom_level():
		save_manager.record_level_completion(current_world, current_level, summary["level_points"])
	# The last level of the last world gets the long campaign-winning fanfare.
	var is_final_level: bool = is_instance_valid(level_manager) and current_world >= level_manager.max_world and current_level >= level_manager.levels_per_world
	_play_sound("play_victory", [is_final_level])
	var victory_screen = victory_screen_scene.instantiate()
	get_parent().add_child(victory_screen)
	victory_screen.show_victory(summary)
	victory_screen.continue_pressed.connect(_on_victory_continue)


func _is_custom_level() -> bool:
	"""True while an editor test level is played; campaign progress must not be saved."""
	var session = get_node_or_null("/root/GameSession") if is_inside_tree() else null
	return session != null and session.is_custom_level()

func _on_victory_continue():
	"""Return to overworld after a level victory; selection reflects persisted unlock."""
	print("Returning to overworld after victory...")
	if _is_custom_level():
		var custom_session = get_node_or_null("/root/GameSession")
		get_tree().change_scene_to_file(custom_session.scene_after_level() if custom_session else "res://Scenes/overworld_map.tscn")
		return
	var session = get_node_or_null("/root/GameSession")
	if session:
		session.selected_world = current_world
		session.selected_level = min(current_level + 1, level_manager.levels_per_world)
	get_tree().change_scene_to_file("res://Scenes/overworld_map.tscn")


func player_hit_by_enemy():
	"""Called when player is hit by a non-petrified enemy"""
	if is_player_dead or not player or not player.is_alive:
		return  # Already dead, ignore
	
	print("⚠️ Player hit by enemy!")
	player.die()

func _on_player_died_animation_done():
	"""Called after player death animation completes"""
	is_player_dead = true
	current_lives -= 1
	
	print("💀 Lives remaining: ", current_lives)
	lives_changed.emit(current_lives)
	
	_play_sound("play_death")
	
	# Update HUD
	if is_inside_tree():
		var tree = get_tree()
		if tree:
			var hud = tree.get_first_node_in_group("hud")
			if hud and hud.has_method("update_lives"):
				hud.update_lives(current_lives)
	
	if current_lives <= 0:
		# Game Over
		print("☠️ GAME OVER ☠️")
		game_over.emit()
		
		_play_sound("play_game_over")
		
		show_game_over_screen()
	else:
		# Reset level cleanly so puzzle is fresh and solvable
		if is_inside_tree():
			await get_tree().create_timer(respawn_delay).timeout
		is_player_dead = false
		if is_instance_valid(level_manager):
			level_manager.restart_level()
		else:
			respawn_player()

func quick_retry_level():
	"""Quick surrender/retry: lose 1 life and reload fresh level"""
	if is_player_dead:
		return
	print("🔄 Quick retry requested by player!")
	if player and is_instance_valid(player) and player.is_alive:
		player.die()
	else:
		_on_player_died_animation_done()

func respawn_player():
	"""Respawn the player at starting position"""
	if player:
		is_player_dead = false
		player.respawn()
		print("✨ Lives: ", current_lives)

func reset_level():
	"""Reset level (for game over or restart)"""
	current_lives = max_lives
	souls_collected = 0
	is_player_dead = false
	lives_changed.emit(current_lives)
	print("🔄 Level reset - Lives: ", current_lives)

func show_game_over_screen():
	"""Show game over screen"""
	if not is_inside_tree() or get_parent() == null:
		return
	var game_over_screen = game_over_screen_scene.instantiate()
	get_parent().add_child(game_over_screen)
	game_over_screen.show_game_over()
	game_over_screen.retry_pressed.connect(_on_game_over_retry)

func _on_game_over_retry():
	"""Called when player clicks retry after game over"""
	print("Restarting level...")
	current_lives = max_lives
	lives_changed.emit(current_lives)
	level_manager.restart_level()

func _on_level_loaded(level_data: LevelData):
	"""Called when level manager loads a level"""
	print("=== Loading Level: ", level_data.level_name, " ===")
	
	# Clear existing level
	clear_level()
	
	# Update world/level tracking and reset per-level score breakdown.
	current_world = level_data.world_idx
	current_level = level_data.level_idx
	_play_sound("play_world_music", [current_world])
	level_score_start = score
	enemies_squashed_this_level = 0
	level_completion_started = false
	
	# Update HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_level"):
		hud.update_level(current_world, current_level)
	
	# Start level timer
	time_limit = level_data.time_limit if level_data.time_limit > 0 else 90
	time_remaining = float(time_limit)
	is_timer_active = true
	time_changed.emit(time_limit)
	if hud and hud.has_method("update_time"):
		hud.update_time(time_limit)
	
	# Notify main scene to rebuild level
	get_parent().build_level_from_data(level_data)
	if level_data.is_boss_level:
		spawn_boss(level_data)
	
	# Place configured springs after base level grid is built
	for spring_data in level_data.springs:
		spawn_spring(spring_data.get("pos", Vector2i.ZERO), spring_data.get("direction", Vector2i.UP))
	
	# Register warp pairs before they can be used
	for warp_data in level_data.warps:
		spawn_warp_endpoint(warp_data.get("pos", Vector2i.ZERO), warp_data.get("pair_id", ""))
	
	# Place slippery and one-way tiles after base terrain is initialized.
	for slippery_pos in level_data.slippery_tiles:
		spawn_slippery_tile(slippery_pos)
	for gate_data in level_data.one_way_gates:
		spawn_one_way_gate(gate_data.get("pos", Vector2i.ZERO), gate_data.get("direction", Vector2i.ZERO))
	for conveyor_data in level_data.conveyors:
		spawn_conveyor(conveyor_data.get("pos", Vector2i.ZERO), conveyor_data.get("direction", Vector2i.ZERO))
	for block_pos in level_data.push_blocks:
		spawn_push_block(block_pos)
	for bonus_data in level_data.bonus_items:
		spawn_bonus_item(bonus_data.get("pos", Vector2i.ZERO), bonus_data.get("kind", "ambrosia"))
	for mirror_data in level_data.mirrors:
		spawn_mirror(mirror_data.get("pos", Vector2i.ZERO), mirror_data.get("orientation", "slash"))
	for switch_data in level_data.switches:
		spawn_switch(switch_data.get("pos", Vector2i.ZERO), switch_data.get("id", ""))
	for door_data in level_data.doors:
		spawn_door(door_data.get("pos", Vector2i.ZERO), door_data.get("direction", Vector2i.RIGHT), door_data.get("id", ""))
	for hammer_data in level_data.hammers:
		spawn_hammer(hammer_data.get("pos", Vector2i.ZERO), hammer_data.get("direction", Vector2i.UP))

func clear_level():
	"""Clear all level objects"""
	if is_instance_valid(boss):
		boss.queue_free()
	boss = null
	boss_arena_rect = Rect2i()
	# Every spawned level object lives in one of these lists; free the nodes, then empty the list.
	for node_list in [pillars, soul_urns, enemies, spring_tiles, rotator_tiles, warp_tiles, slippery_tiles,
			one_way_tiles, conveyor_tiles, push_blocks, bonus_items, mirror_tiles, switch_tiles, door_tiles, hammer_tiles, spawners]:
		for node in node_list:
			if is_instance_valid(node):
				node.queue_free()
		node_list.clear()
	# The grid keeps its own per-cell metadata for the same objects.
	if is_instance_valid(grid_manager):
		grid_manager.clear_one_way_directions()
		grid_manager.clear_conveyor_directions()
		grid_manager.spring_directions.clear()
		grid_manager.rotator_turns.clear()
		grid_manager.clear_warp_pairs()
		grid_manager.clear_push_blocks()
		grid_manager.clear_spawners()
		grid_manager.clear_mirrors()
		grid_manager.clear_doors_and_switches()
		grid_manager.clear_hammers()
	
	# Reset counters
	souls_collected = 0
	souls_required = 0
	
	print("Level cleared")
