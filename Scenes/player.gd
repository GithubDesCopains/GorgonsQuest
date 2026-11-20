extends CharacterBody2D
class_name Player

const CONTROLLER_FEEDBACK = preload("res://Scripts/controller_feedback.gd")
const HERO_VISUAL_SCRIPT = preload("res://Scenes/hero_visual.gd")
const GameVFX = preload("res://Scenes/game_vfx.gd")

# Tiles a pushed statue may enter: it keeps sliding over them until something blocks it.
const SLIDABLE_TILES := [
	Constants.TileType.GROUND, Constants.TileType.ICE, Constants.TileType.SPRING, Constants.TileType.ROTATOR,
	Constants.TileType.WARP, Constants.TileType.SLIPPERY, Constants.TileType.CONVEYOR, Constants.TileType.HOLE,
	Constants.TileType.PLAYER_ONLY,
]
# Plain floor, with no special effect while sliding over it.
const PLAIN_FLOOR_TILES := [Constants.TileType.GROUND, Constants.TileType.ICE, Constants.TileType.HOLE, Constants.TileType.PLAYER_ONLY]

## Player Controller - Hero with Gorgon's Eye
## Grid-based movement with smooth interpolation

@export var move_speed: float = 300.0

var current_grid_pos: Vector2i
var target_grid_pos: Vector2i
var previous_grid_pos: Vector2i
var is_moving: bool = false
var current_direction: int = Constants.Direction.DOWN
var is_pushing: bool = false

# Player state
var is_alive: bool = true
var starting_position: Vector2i

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var grid_manager: GridManager
var game_manager: Node
var sound_manager: Node
var hero_visual: Node2D
var last_slide_direction: Vector2i = Vector2i.ZERO
var last_slide_path: Array[Vector2i] = []
var forced_move_direction: Vector2i = Vector2i.ZERO

const TURN_DELAY := 0.07  # a tap shorter than this only turns the hero; holding the key walks
const SHOT_TIMEOUT_MSEC := 3000  # safety net if a shot is never reported as finished
var held_direction := Vector2i.ZERO  # direction key currently held (zero = none)
var held_time := 0.0                 # how long it has been held, counted even while the hero is mid-step
var facing_at_press: int = Constants.Direction.DOWN  # where the hero looked when that key went down
var shot_in_flight := false  # one laser at a time: the next shot waits for this one to hit something
var shot_started_msec := 0

signal moved_to_tile(grid_pos: Vector2i)
signal petrify_shot_fired(direction: int)
signal pillar_created(grid_pos: Vector2i)
signal statue_pushed(statue, direction: Vector2i)
signal player_died()

func _ready():
	await get_tree().process_frame
	
	grid_manager = get_node("/root/Main/GameManager/GridManager")
	game_manager = get_node("/root/Main/GameManager")
	sound_manager = game_manager.get_node_or_null("SoundManager")
	create_placeholder_visual()
	
	if starting_position == Vector2i.ZERO and current_grid_pos == Vector2i.ZERO:
		current_grid_pos = grid_manager.world_to_grid(position)
		target_grid_pos = current_grid_pos
		starting_position = current_grid_pos
	position = grid_manager.grid_to_world(current_grid_pos)
	# Always snap root to exact grid center, even if scene instance started subpixel-offset.
	position = grid_manager.grid_to_world(current_grid_pos)
	
	is_alive = true
	z_index = Constants.LAYER_PLAYER
	
	print("Player initialized at grid pos: ", current_grid_pos, " world pos: ", position)

func create_placeholder_visual():
	# Retain method name for existing callers; visual is now a fully procedural original hero.
	for child in sprite.get_children():
		child.queue_free()
	hero_visual = Node2D.new()
	hero_visual.name = "HeroVisual"
	hero_visual.set_script(HERO_VISUAL_SCRIPT)
	hero_visual.position = Vector2.ZERO
	sprite.add_child(hero_visual)
	_update_hero_pose()

func _physics_process(delta):
	if not is_alive:
		return  # Dead, no input
	# Actions remain responsive during grid interpolation, including firing while walking.
	if Input.is_action_just_pressed("petrify_shot"):
		fire_petrify_shot()
	if is_moving:
		move_towards_target(delta)
		track_direction_hold(delta)  # a key pressed mid-step already counts as held when the step ends
	else:
		handle_input(delta)
		if Input.is_action_just_pressed("break_statue"):
			break_facing_statue()
		if InputMap.has_action("rotate_mirror") and Input.is_action_just_pressed("rotate_mirror"):
			rotate_facing_mirror()
	
	_update_hero_pose()

func _update_hero_pose() -> void:
	if is_instance_valid(hero_visual) and hero_visual.has_method("set_pose"):
		hero_visual.set_pose(current_direction, is_moving, is_pushing)

func pressed_direction() -> Vector2i:
	if Input.is_action_pressed("move_right"):
		return Vector2i.RIGHT
	if Input.is_action_pressed("move_left"):
		return Vector2i.LEFT
	if Input.is_action_pressed("move_up"):
		return Vector2i.UP
	if Input.is_action_pressed("move_down"):
		return Vector2i.DOWN
	return Vector2i.ZERO

func track_direction_hold(delta: float) -> void:
	"""Measure how long the current direction key has been held (also called while the hero is mid-step)."""
	var pressed := pressed_direction()
	if pressed != held_direction:
		held_direction = pressed
		held_time = 0.0
		facing_at_press = current_direction
	elif pressed != Vector2i.ZERO:
		held_time += delta

func handle_input(delta: float = 1.0 / 60.0):
	track_direction_hold(delta)
	# On slippery tiles, continue in last movement direction and ignore steering.
	if forced_move_direction != Vector2i.ZERO:
		if try_forced_slide_step():
			return
	
	var input_dir = Vector2i.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_dir = Vector2i.RIGHT
		current_direction = Constants.Direction.RIGHT
	elif Input.is_action_pressed("move_left"):
		input_dir = Vector2i.LEFT
		current_direction = Constants.Direction.LEFT
	elif Input.is_action_pressed("move_up"):
		input_dir = Vector2i.UP
		current_direction = Constants.Direction.UP
	elif Input.is_action_pressed("move_down"):
		input_dir = Vector2i.DOWN
		current_direction = Constants.Direction.DOWN
	
	if input_dir != Vector2i.ZERO:
		# Toward the direction he already faced when the key went down: walk at once.
		# Toward another direction: a short press only turns the hero on the spot, a long press (TURN_DELAY) walks.
		if facing_at_press == direction_vector_to_enum(input_dir) or held_time >= TURN_DELAY:
			try_move(input_dir)
	
	if Input.is_action_just_pressed("create_pillar"):
		create_stone_pillar()
	
	if Input.is_action_just_pressed("restart_level") or Input.is_key_pressed(KEY_R):
		quick_retry()

func quick_retry():
	"""Player surrenders / quick retries the level"""
	if not is_alive:
		return
	if is_instance_valid(game_manager) and game_manager.has_method("quick_retry_level"):
		game_manager.quick_retry_level()
	else:
		die()

func try_move(direction: Vector2i) -> bool:
	var next_pos = current_grid_pos + direction
	if grid_manager.edge_blocked(current_grid_pos, next_pos):
		return false  # a closed door sits between the two cells
	var current_conveyor = grid_manager.get_conveyor_direction(current_grid_pos)
	if current_conveyor != Vector2i.ZERO and direction != current_conveyor:
		return false
	if not grid_manager.can_enter_one_way(next_pos, direction):
		return false
	
	var conveyor_direction = grid_manager.get_conveyor_direction(current_grid_pos)
	if conveyor_direction != Vector2i.ZERO and direction != conveyor_direction:
		return false
	
	# Dark-blue push block: slide it like a statue, then step into its old cell.
	if grid_manager.has_push_block(next_pos):
		if try_push_block(next_pos, direction):
			target_grid_pos = next_pos
			is_moving = true
			is_pushing = true
			return true
		return false

	# Check if there's a petrified enemy (statue) at next position
	var statue_at_next = get_statue_at(next_pos)
	if statue_at_next:
		# Try to push the statue
		if try_push_statue(statue_at_next, direction):
			# Move into statue's old position
			target_grid_pos = next_pos
			is_moving = true
			is_pushing = true
			return true
		else:
			print("Cannot push statue - blocked")
			return false
	
	# Normal movement check
	if grid_manager.is_walkable(next_pos):
		previous_grid_pos = current_grid_pos
		target_grid_pos = next_pos
		is_moving = true
		is_pushing = false
		return true
	else:
		print("Blocked at: ", next_pos)
		return false

func try_forced_slide_step() -> bool:
	"""Move one tile in forced direction; stop sliding cleanly at blockers or special tiles."""
	if forced_move_direction == Vector2i.ZERO:
		return false
	var conveyor_direction = grid_manager.get_conveyor_direction(current_grid_pos)
	if conveyor_direction != Vector2i.ZERO and forced_move_direction != conveyor_direction:
		forced_move_direction = conveyor_direction
	if forced_move_direction == Vector2i.ZERO:
		return false
	var next_pos = current_grid_pos + forced_move_direction
	if not grid_manager.is_walkable(next_pos) or not grid_manager.can_enter_one_way(next_pos, forced_move_direction) or get_statue_at(next_pos) != null or grid_manager.edge_blocked(current_grid_pos, next_pos):
		forced_move_direction = Vector2i.ZERO
		return false
	if grid_manager.get_tile(next_pos) == Constants.TileType.WARP:
		var main_node = SceneLookup.main_scene(self)
		var gm = main_node.get_node_or_null("GameManager") if main_node else null
		if not gm or gm.activate_warp(next_pos) == Vector2i(-1, -1):
			forced_move_direction = Vector2i.ZERO
			return false
	target_grid_pos = next_pos
	is_moving = true
	is_pushing = false
	return true

func find_push_block_at(grid_pos: Vector2i) -> Node:
	if not is_inside_tree():
		return null
	for block in get_tree().get_nodes_in_group("push_blocks"):
		if is_instance_valid(block) and block.grid_pos == grid_pos and not block.is_removed:
			return block
	return null

func try_push_block(block_pos: Vector2i, push_direction: Vector2i) -> bool:
	"""Push the block at block_pos; it slides until an obstacle, or sinks into water."""
	var block = find_push_block_at(block_pos)
	if block == null:
		return false
	if not grid_manager.can_enter_one_way(block_pos + push_direction, push_direction):
		return false
	var final_pos := calculate_slide_path_on_ground(block_pos, push_direction)
	if final_pos == block_pos:
		return false
	block.slide_to(final_pos)
	CONTROLLER_FEEDBACK.vibrate(0.14, 0.18, 0.55)
	return true

func get_statue_at(grid_pos: Vector2i) -> Enemy:
	"""Check if there's a petrified enemy at grid position"""
	if not is_inside_tree():
		return null
	var tree = get_tree()
	if not tree:
		return null
	for enemy in tree.get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.petrified and enemy.current_grid_pos == grid_pos:
			return enemy
	return null

func try_push_statue(statue: Enemy, push_direction: Vector2i) -> bool:
	"""Try to push a statue in the given direction"""
	var statue_next_pos = statue.current_grid_pos + push_direction
	if not grid_manager.can_enter_one_way(statue_next_pos, push_direction):
		return false
	# A mirror or a closed door stops a statue like a wall.
	if grid_manager.has_mirror(statue_next_pos) or grid_manager.edge_blocked(statue.current_grid_pos, statue_next_pos):
		return false
	
	# Check if statue can be pushed there
	if not grid_manager.is_valid_grid_pos(statue_next_pos):
		return false
	
	var tile_type = grid_manager.get_tile(statue_next_pos)
	
	# Ground, ice and routing tiles: block slides until blocked.
	if SLIDABLE_TILES.has(tile_type):
		var final_pos = calculate_slide_path_on_ground(statue.current_grid_pos, push_direction)
		if final_pos != statue.current_grid_pos:
			# Check if final position is water
			var final_tile = grid_manager.get_tile(final_pos)
			if final_tile == Constants.TileType.WATER:
				# Block slid into water
				statue.slide_on_ground_into_water(final_pos, push_direction)
			else:
				# Block slid on ground only
				statue.slide_on_ground(final_pos, push_direction)
			statue_pushed.emit(statue, push_direction)
			CONTROLLER_FEEDBACK.vibrate(0.14, 0.18, 0.55)
			return true
		return false
	
	# WATER: Block stops immediately and sinks (creates bridge)
	if tile_type == Constants.TileType.WATER:
		# Check no other statue (or spawner) is there
		if get_statue_at(statue_next_pos) != null or grid_manager.has_spawner(statue_next_pos):
			return false
		
		statue.push_into_water(statue_next_pos)
		statue_pushed.emit(statue, push_direction)
		print("💧 Pushed statue into water - stops and creates bridge!")
		return true
	
	return false

func calculate_slide_path_on_ground(start_pos: Vector2i, direction: Vector2i) -> Vector2i:
	"""Slide destination for statues and push blocks. Holes are crossed but never a resting cell."""
	var final_pos := _calculate_slide_path_raw(start_pos, direction)
	var guard := 0
	while grid_manager.get_tile(final_pos) == Constants.TileType.HOLE and final_pos != start_pos and guard < Constants.GRID_COLS + Constants.GRID_ROWS:
		final_pos -= last_slide_direction
		guard += 1
	return final_pos

func _calculate_slide_path_raw(start_pos: Vector2i, direction: Vector2i) -> Vector2i:
	"""Calculate statue slide destination, including springs, rotators, and warps."""
	last_slide_direction = direction
	last_slide_path.clear()
	var current_pos = start_pos
	var slide_direction = direction
	var visited_rotators: Dictionary = {}
	var visited_conveyors: Dictionary = {}
	var next_pos = current_pos + slide_direction
	
	while grid_manager.is_valid_grid_pos(next_pos):
		last_slide_path.append(next_pos)
		var tile_type = grid_manager.get_tile(next_pos)
		if is_instance_valid(game_manager) and is_instance_valid(game_manager.boss):
			var boss_grid_pos = grid_manager.world_to_grid(game_manager.boss.position)
			if next_pos == boss_grid_pos:
				last_slide_direction = slide_direction
				return next_pos
		
		if tile_type == Constants.TileType.WALL or tile_type == Constants.TileType.STONE_BLOCK or grid_manager.has_spawner(next_pos):
			return current_pos
		if grid_manager.has_mirror(next_pos) or grid_manager.edge_blocked(current_pos, next_pos):
			return current_pos  # mirrors and closed doors stop a sliding block or statue like a wall
		if get_statue_at(next_pos) != null or grid_manager.has_push_block(next_pos):
			return current_pos
		
		if tile_type == Constants.TileType.WATER:
			last_slide_direction = slide_direction
			return next_pos
		
		if tile_type == Constants.TileType.SPRING:
			var spring_direction = grid_manager.get_spring_direction(next_pos)
			if spring_direction == Vector2i.ZERO:
				return current_pos
			var spring = get_rotator_or_spring_at(next_pos, true)
			if spring:
				spring.animate_compression()
			slide_direction = spring_direction
			current_pos = next_pos
			last_slide_direction = slide_direction
			next_pos = current_pos + slide_direction
			continue
		
		if tile_type == Constants.TileType.CONVEYOR:
			if visited_conveyors.has(next_pos):
				return current_pos
			visited_conveyors[next_pos] = true
			var conveyor_direction = grid_manager.get_conveyor_direction(next_pos)
			if conveyor_direction == Vector2i.ZERO:
				return current_pos
			var main_node = SceneLookup.main_scene(self)
			var gm = main_node.get_node_or_null("GameManager") if main_node else null
			var conveyor = gm.find_conveyor_at(next_pos) if gm else null
			if conveyor:
				conveyor.animate_motion()
			slide_direction = conveyor_direction
			current_pos = next_pos
			last_slide_direction = slide_direction
			next_pos = current_pos + slide_direction
			continue
		
		if tile_type == Constants.TileType.WARP:
			var warp_destination = grid_manager.get_warp_destination(next_pos)
			if warp_destination == Vector2i(-1, -1):
				return current_pos
			if get_statue_at(warp_destination) != null:
				return current_pos
			var main_node = SceneLookup.main_scene(self)
			var gm = main_node.get_node_or_null("GameManager") if main_node else null
			var warp = gm.find_warp_at(next_pos) if gm else null
			if warp:
				warp.animate_activation()
			last_slide_path.append(next_pos)
			last_slide_path.append(warp_destination)
			current_pos = warp_destination
			next_pos = current_pos + slide_direction
			continue
		
		if tile_type == Constants.TileType.ROTATOR:
			if visited_rotators.has(next_pos):
				return current_pos
			visited_rotators[next_pos] = true
			var turn = grid_manager.get_rotator_turn(next_pos)
			if turn == 0:
				return current_pos
			var rotator = get_rotator_or_spring_at(next_pos, false)
			if rotator:
				rotator.animate_turn()
			slide_direction = rotate_direction_90(slide_direction, turn)
			current_pos = next_pos
			last_slide_direction = slide_direction
			next_pos = current_pos + slide_direction
			continue
		
		if PLAIN_FLOOR_TILES.has(tile_type):
			current_pos = next_pos
			next_pos = current_pos + slide_direction
		else:
			return current_pos
	
	return current_pos

func rotate_direction_90(direction: Vector2i, quarter_turns: int) -> Vector2i:
	"""Rotate cardinal direction 90 degrees clockwise (+1) or counter-clockwise (-1)."""
	if quarter_turns > 0:
		return Vector2i(-direction.y, direction.x)
	return Vector2i(direction.y, -direction.x)

func get_rotator_or_spring_at(grid_pos: Vector2i, is_spring: bool) -> Node:
	var main = SceneLookup.main_scene(self)
	var gm = main.get_node_or_null("GameManager") if main else null
	if not gm:
		return null
	if is_spring:
		return gm.find_spring_at(grid_pos)
	return gm.find_rotator_at(grid_pos)


func move_towards_target(delta):
	var target_world_pos = grid_manager.grid_to_world(target_grid_pos)
	var distance = move_speed * delta
	position = position.move_toward(target_world_pos, distance)
	
	if position.distance_to(target_world_pos) < 1.0:
		position = target_world_pos
		var movement_direction = target_grid_pos - current_grid_pos
		current_grid_pos = target_grid_pos
		is_moving = false
		is_pushing = false
		moved_to_tile.emit(current_grid_pos)
		var conveyor_direction = grid_manager.get_conveyor_direction(current_grid_pos)
		if conveyor_direction != Vector2i.ZERO:
			forced_move_direction = conveyor_direction
		elif grid_manager.get_tile(current_grid_pos) == Constants.TileType.SLIPPERY:
			forced_move_direction = movement_direction
		else:
			forced_move_direction = Vector2i.ZERO

func launch_from_spring(launch_direction: Vector2i) -> bool:
	"""Set next movement target when player enters directional spring."""
	if is_moving or launch_direction == Vector2i.ZERO or not is_alive:
		return false
	var launch_pos = current_grid_pos + launch_direction
	if not grid_manager.is_walkable(launch_pos) or grid_manager.edge_blocked(current_grid_pos, launch_pos):
		return false
	if get_statue_at(launch_pos) != null:
		return false
	if is_inside_tree():
		var tree = get_tree()
		if tree:
			for enemy in tree.get_nodes_in_group("enemies"):
				if is_instance_valid(enemy) and not enemy.is_squashed and enemy.current_grid_pos == launch_pos:
					return false
	current_direction = direction_vector_to_enum(launch_direction)
	target_grid_pos = launch_pos
	is_moving = true
	return true

func direction_vector_to_enum(dir: Vector2i) -> int:
	if dir == Vector2i.RIGHT:
		return Constants.Direction.RIGHT
	if dir == Vector2i.DOWN:
		return Constants.Direction.DOWN
	if dir == Vector2i.LEFT:
		return Constants.Direction.LEFT
	return Constants.Direction.UP

func try_spring_block_launch(statue: Enemy, direction: Vector2i) -> Vector2i:
	"""Return first spring-triggered destination for pushed statue, or zero if none."""
	if not statue or not grid_manager.is_valid_grid_pos(statue.current_grid_pos):
		return Vector2i.ZERO
	var spring_dir = grid_manager.get_spring_direction(statue.current_grid_pos)
	if spring_dir == Vector2i.ZERO:
		return Vector2i.ZERO
	var destination = statue.current_grid_pos + spring_dir
	if grid_manager.is_walkable(destination) and get_statue_at(destination) == null:
		return destination
	return Vector2i.ZERO

func update_direction_indicator():
	var indicator = sprite.get_node_or_null("ColorRect/DirectionIndicator")
	if indicator:
		match current_direction:
			Constants.Direction.RIGHT:
				indicator.position = Vector2(32, 22)
			Constants.Direction.LEFT:
				indicator.position = Vector2(-8, 22)
			Constants.Direction.UP:
				indicator.position = Vector2(22, -8)
			Constants.Direction.DOWN:
				indicator.position = Vector2(22, 32)

func rotate_facing_mirror() -> bool:
	"""Action button: turn the mirror right in front of the hero (adjacent, and he must be facing it)."""
	if is_moving or not is_alive:
		return false
	var cell := current_grid_pos + Vector2i(Constants.DIR_VECTORS[current_direction])
	if grid_manager.edge_blocked(current_grid_pos, cell) or not grid_manager.has_mirror(cell):
		return false
	var orientation := grid_manager.rotate_mirror(cell)
	if is_instance_valid(game_manager) and game_manager.has_method("find_mirror_at"):
		var mirror = game_manager.find_mirror_at(cell)
		if mirror:
			mirror.set_orientation(orientation)
	_play_sound("play_push")
	CONTROLLER_FEEDBACK.vibrate(0.08, 0.08, 0.2)
	return true

func _play_sound(method: StringName) -> void:
	"""Play a SoundManager effect; skipped when no sound manager is attached (tests, stubs)."""
	if sound_manager and sound_manager.has_method(method):
		sound_manager.call(method)

func reject_cell(cell: Vector2i) -> bool:
	"""A statue just appeared on 'cell': the hero must not stay on it or walk into it.
	Walking toward it: turn back. Standing on it: step out to a free neighbour (previous cell first)."""
	if is_moving and target_grid_pos == cell and current_grid_pos != cell:
		target_grid_pos = current_grid_pos
		forced_move_direction = Vector2i.ZERO
		return true
	if current_grid_pos != cell:
		return false
	var candidates: Array[Vector2i] = [previous_grid_pos]
	for dir in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		candidates.append(cell + dir)
	for candidate in candidates:
		if candidate == cell or not grid_manager.is_walkable(candidate) or get_statue_at(candidate) != null:
			continue
		current_grid_pos = candidate
		target_grid_pos = candidate
		position = grid_manager.grid_to_world(candidate)
		is_moving = false
		forced_move_direction = Vector2i.ZERO
		return true
	return false

func can_fire() -> bool:
	return is_alive and (not shot_in_flight or Time.get_ticks_msec() - shot_started_msec > SHOT_TIMEOUT_MSEC)

func on_shot_finished() -> void:
	"""The laser hit an enemy or an obstacle: the next shot is allowed."""
	shot_in_flight = false

func fire_petrify_shot():
	# Firing never waits for movement to finish; projectile starts at interpolated world position.
	# One laser at a time: the next shot waits until this one hit an enemy or an obstacle.
	if not can_fire():
		return
	shot_in_flight = true
	shot_started_msec = Time.get_ticks_msec()
	petrify_shot_fired.emit(current_direction)
	if is_instance_valid(hero_visual) and hero_visual.has_method("set_action"):
		hero_visual.set_action(true)
		var shot_tween := create_tween()
		shot_tween.tween_callback(func():
			if is_instance_valid(hero_visual):
				hero_visual.set_action(false)
		).set_delay(0.2)
	var effect_parent: Node = SceneLookup.effect_parent(self)
	var shot_direction: Vector2 = Constants.DIR_VECTORS[current_direction]
	GameVFX.spawn(effect_parent, global_position + shot_direction * 42.0, "gaze", shot_direction)
	CONTROLLER_FEEDBACK.vibrate(0.08, 0.08, 0.25)
	print("⚡ Petrifying shot fired: ", Constants.Direction.keys()[current_direction])
	_play_sound("play_shoot")

func break_facing_statue() -> bool:
	"""Break only the statue directly in front of a stationary hero."""
	if is_moving or not is_alive:
		return false
	var facing_pos := current_grid_pos + Vector2i(Constants.DIR_VECTORS[current_direction])
	var statue = get_statue_at(facing_pos)
	if statue == null or not statue.has_method("shatter"):
		return false
	statue.shatter()
	CONTROLLER_FEEDBACK.vibrate(0.12, 0.16, 0.35)
	return true

func create_stone_pillar():
	if is_moving:
		return
	
	var pillar_pos = current_grid_pos + Vector2i(Constants.DIR_VECTORS[current_direction])
	
	if grid_manager.is_valid_grid_pos(pillar_pos):
		var tile = grid_manager.get_tile(pillar_pos)
		if (tile == Constants.TileType.GROUND or tile == Constants.TileType.ICE) and not grid_manager.has_spawner(pillar_pos) and not grid_manager.has_mirror(pillar_pos) and not grid_manager.edge_blocked(current_grid_pos, pillar_pos):
			pillar_created.emit(pillar_pos)
			print("🗿 Stone pillar created at: ", pillar_pos)
		_play_sound("play_push")

func get_current_direction_vector() -> Vector2:
	return Constants.DIR_VECTORS[current_direction]

func celebrate() -> void:
	if is_instance_valid(hero_visual) and hero_visual.has_method("set_action"):
		hero_visual.set_action(false, true)

func die():
	"""Player death animation"""
	if not is_alive:
		return
	
	is_alive = false
	is_moving = false
	if is_instance_valid(hero_visual) and hero_visual.has_method("set_dead"):
		hero_visual.set_dead(true)
	player_died.emit()
	
	print("💀 Player died!")
	
	# Death animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_property(self, "scale", Vector2(0.2, 0.2), 0.5)
	tween.tween_property(self, "rotation", TAU, 0.5)

func respawn():
	"""Respawn player at starting position"""
	# Reset to starting position
	current_grid_pos = starting_position
	target_grid_pos = starting_position
	position = grid_manager.grid_to_world(starting_position)
	
	# Reset visuals
	modulate = Color.WHITE
	scale = Vector2.ONE
	rotation = 0.0
	is_alive = true
	is_moving = false
	shot_in_flight = false
	held_direction = Vector2i.ZERO
	held_time = 0.0
	if is_instance_valid(hero_visual) and hero_visual.has_method("set_dead"):
		hero_visual.set_dead(false)
	
	print("✨ Player respawned at: ", starting_position)
	
	# Spawn animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
