extends CharacterBody2D
class_name Enemy

const PETRIFICATION_VISUAL_SCRIPT = preload("res://Scenes/petrification_visual.gd")
const ENEMY_VISUAL_SCRIPT = preload("res://Scenes/enemy_visual.gd")
const GAME_VFX = preload("res://Scenes/game_vfx.gd")
const PETRIFY_DURATION := 20.0
const PETRIFY_WARNING_SECONDS := 10.0

## Base enemy class with patrol AI

enum State {
	PATROL,
	PETRIFIED,
	FROZEN
}

var current_state: State = State.PATROL
var current_grid_pos: Vector2i
var target_grid_pos: Vector2i
var is_moving: bool = false:
	set(value):
		# First enemy to start moving owns the cell: a later one stays put instead of sharing it.
		if value and not is_moving and target_grid_pos != current_grid_pos and (is_cell_taken_by_other_enemy(target_grid_pos) or _door_in_the_way()):
			target_grid_pos = current_grid_pos
			value = false
		is_moving = value
var current_direction: int = Constants.Direction.DOWN
var move_speed: float = 150.0

# Patrol behavior
var patrol_pattern: Array = []
var patrol_index: int = 0
var wait_time: float = 0.5
var wait_timer: float = 0.0

var grid_manager: GridManager
var game_manager: Node
var sound_manager: Node
var petrified: bool = false
var petrify_time_remaining: float = 0.0
var petrify_warning_shown: bool = false
var is_sliding: bool = false
var is_squashed: bool = false
var initialized: bool = false

var visual: ColorRect
var eyes: ColorRect
var petrification_visual: Node2D
var creature_art: Node2D

signal enemy_petrified(enemy)
signal enemy_squashed(enemy)
signal enemy_shattered(enemy)

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Get grid manager AND game manager safely
	var main_node = SceneLookup.main_scene(self)
	if main_node:
		var game_mgr = main_node.get_node_or_null("GameManager")
		if game_mgr:
			grid_manager = game_mgr.get_node_or_null("GridManager")
			game_manager = game_mgr
			sound_manager = game_mgr.get_node_or_null("SoundManager")
	
	if not grid_manager:
		print("ERROR: Enemy could not find GridManager")
		queue_free()
		return
	
	if not game_manager:
		print("ERROR: Enemy could not find GameManager")
		queue_free()
		return
	
	create_visual()
	create_creature_art()
	create_petrification_overlay()
	z_index = Constants.LAYER_ENEMIES
	add_to_group("enemies")

func create_visual():
	"""Base-compatible living body; specialized enemy scenes may override this."""
	visual = ColorRect.new()
	visual.name = "LivingEnemyVisual"
	visual.size = Vector2(50, 50)
	visual.position = Vector2(-25, -25)
	visual.color = Color("C66A5B")
	add_child(visual)
	eyes = ColorRect.new()
	eyes.name = "Eyes"
	eyes.size = Vector2(20, 8)
	eyes.position = Vector2(-10, -5)
	eyes.color = Color("F6E7C5")
	visual.add_child(eyes)

func create_creature_art() -> void:
	"""Add species-specific original artwork; keep legacy ColorRect as hidden compatibility node."""
	creature_art = Node2D.new()
	creature_art.name = "ProceduralCreatureArt"
	creature_art.set_script(ENEMY_VISUAL_SCRIPT)
	creature_art.set("enemy_type", _get_visual_type())
	creature_art.position = Vector2.ZERO
	add_child(creature_art)
	if is_instance_valid(visual):
		visual.visible = false

func _get_visual_type() -> String:
	var script_resource: Script = get_script()
	if script_resource:
		var script_name := script_resource.resource_path.get_file().get_basename()
		if script_name != "enemy":
			return script_name
	return "noggle"

func create_petrification_overlay() -> void:
	petrification_visual = Node2D.new()
	petrification_visual.name = "SharedMarbleStatue"
	petrification_visual.set_script(PETRIFICATION_VISUAL_SCRIPT)
	petrification_visual.visible = false
	petrification_visual.z_index = 3
	add_child(petrification_visual)

func is_petrifiable() -> bool:
	return not (has_method("is_immune_to_petrification") and bool(call("is_immune_to_petrification")))

func initialize(grid_pos: Vector2i, pattern: Array = []):
	current_grid_pos = grid_pos
	target_grid_pos = grid_pos
	
	# Wait a bit more for grid_manager to be available
	for i in range(5):
		await get_tree().process_frame
		if grid_manager:
			break
	
	if grid_manager:
		position = grid_manager.grid_to_world(grid_pos)
		initialized = true
		print("✓ Enemy initialized at grid: ", grid_pos, " world pos: ", position)
	else:
		print("✗ ERROR: Enemy grid_manager still not ready after waiting!")
		position = Vector2(500, 500)  # Fallback position
	
	if pattern.is_empty():
		patrol_pattern = [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.LEFT]
	else:
		patrol_pattern = pattern

func _physics_process(delta):
	if not initialized or not grid_manager:
		return
	
	if is_sliding:
		var slide_grid_pos = grid_manager.world_to_grid(position)
		if slide_grid_pos != current_grid_pos:
			current_grid_pos = slide_grid_pos
			check_squash_enemies()
			check_boss_collision_during_slide()
		return
	
	if is_squashed:
		return
	
	match current_state:
		State.PATROL:
			process_patrol(delta)
		State.PETRIFIED:
			pass
	# Preserve root grid-center while copying subclass bob offset into procedural art.
	if is_instance_valid(visual) and is_instance_valid(creature_art):
		var visual_center := visual.position + visual.size * 0.5
		creature_art.position = visual_center
		creature_art.rotation = visual.rotation
		creature_art.scale = visual.scale
		creature_art.modulate = visual.modulate

func _process(delta: float) -> void:
	if not petrified or is_squashed or is_sliding:
		return
	petrify_time_remaining = maxf(0.0, petrify_time_remaining - delta)
	if not petrify_warning_shown and petrify_time_remaining <= PETRIFY_WARNING_SECONDS:
		petrify_warning_shown = true
		if is_instance_valid(petrification_visual):
			petrification_visual.set_warning_visible(true)
	if petrify_time_remaining <= 0.0:
		un_petrify()

func _door_in_the_way() -> bool:
	"""A closed door on the edge toward the target cell blocks every enemy, whatever its movement style."""
	return grid_manager != null and grid_manager.edge_blocked(current_grid_pos, target_grid_pos)

func is_cell_taken_by_other_enemy(pos: Vector2i) -> bool:
	"""True if another enemy (living or statue) stands on pos or is already heading there."""
	if not is_instance_valid(game_manager):
		return false
	for other in game_manager.enemies:
		if other != self and is_instance_valid(other) and other is Enemy and not other.is_squashed:
			if other.current_grid_pos == pos or other.target_grid_pos == pos:
				return true
	return false

func process_patrol(delta):
	if is_moving:
		move_towards_target(delta)
	else:
		wait_timer += delta
		if wait_timer >= wait_time:
			wait_timer = 0.0
			try_patrol_move()

func try_patrol_move():
	if patrol_pattern.is_empty():
		return
	
	var move_dir = patrol_pattern[patrol_index]
	var next_pos = current_grid_pos + move_dir
	
	if grid_manager.is_enemy_walkable(next_pos):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			if next_pos == player.current_grid_pos and player.is_alive:
				print("💀 Enemy will hit player at: ", next_pos)
				game_manager.player_hit_by_enemy()
				return  # Don't move, player is hit
		
		target_grid_pos = next_pos
		is_moving = true
		patrol_index = (patrol_index + 1) % patrol_pattern.size()
	else:
		patrol_index = (patrol_index + 1) % patrol_pattern.size()

func move_towards_target(delta):
	var target_world_pos = grid_manager.grid_to_world(target_grid_pos)
	var distance = move_speed * delta
	position = position.move_toward(target_world_pos, distance)
	
	if position.distance_to(target_world_pos) < 1.0:
		position = target_world_pos
		current_grid_pos = target_grid_pos
		is_moving = false
		
		# Check collision after arriving at position
		check_player_collision()

func check_player_collision():
	"""Check if enemy touched the player"""
	if petrified or is_squashed:
		return  # Petrified or squashed enemies don't hurt player
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.current_grid_pos == current_grid_pos:
		if player.is_alive:  # Only damage if player is alive
			print("💀 Enemy hit player at: ", current_grid_pos)
			game_manager.player_hit_by_enemy()

func snap_to_nearest_cell(avoid: Array[Vector2i] = []) -> void:
	"""A statue rests on exactly one cell: the closer of start/target, so the hero cannot walk through it.
	Cells in 'avoid' (the hero's cell) are skipped when the other cell is free."""
	if not grid_manager:
		return
	var from_world := grid_manager.grid_to_world(current_grid_pos)
	var to_world := grid_manager.grid_to_world(target_grid_pos)
	var cell := target_grid_pos if position.distance_to(to_world) < position.distance_to(from_world) else current_grid_pos
	var other := current_grid_pos if cell == target_grid_pos else target_grid_pos
	if avoid.has(cell) and not avoid.has(other):
		cell = other
	current_grid_pos = cell
	target_grid_pos = cell
	position = grid_manager.grid_to_world(cell)

func _hero_cells() -> Array[Vector2i]:
	"""Cells the hero occupies or is walking into (empty outside the scene tree)."""
	var cells: Array[Vector2i] = []
	if not is_inside_tree():
		return cells
	var hero = get_tree().get_first_node_in_group("player")
	if hero and is_instance_valid(hero):
		cells.append(hero.current_grid_pos)
		if hero.is_moving:
			cells.append(hero.target_grid_pos)
	return cells

func petrify():
	if not is_petrifiable() or petrified or is_squashed:
		return
	
	petrified = true
	petrify_time_remaining = PETRIFY_DURATION
	petrify_warning_shown = false
	current_state = State.PETRIFIED
	if is_moving:
		snap_to_nearest_cell(_hero_cells())
	is_moving = false
	# A statue and the hero never share a cell: the hero is pushed out (or turned back) if needed.
	if is_inside_tree():
		var hero = get_tree().get_first_node_in_group("player")
		if hero and is_instance_valid(hero) and hero.has_method("reject_cell"):
			hero.reject_cell(current_grid_pos)
	if is_instance_valid(game_manager) and game_manager.has_method("notify_enemy_petrified"):
		game_manager.notify_enemy_petrified(self)
	
	# Every species uses same single statue overlay and transition.
	if is_instance_valid(visual):
		visual.color = Constants.COLOR_STONE_GRAY
	if is_instance_valid(eyes):
		eyes.visible = false
	if is_instance_valid(creature_art):
		creature_art.visible = false
	if is_instance_valid(petrification_visual):
		petrification_visual.visible = true
		petrification_visual.set("transition_progress", 0.0)
		if petrification_visual.has_method("set_warning_visible"):
			petrification_visual.set_warning_visible(false)
		if is_inside_tree():
			var transform := create_tween()
			transform.set_parallel(true)
			transform.tween_property(petrification_visual, "scale", Vector2.ONE, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			transform.tween_property(petrification_visual, "modulate:a", 1.0, 0.28)
			transform.tween_property(petrification_visual, "transition_progress", 1.0, 0.42).set_trans(Tween.TRANS_CUBIC)
			transform.chain().tween_callback(_finish_petrification_visual)
		else:
			_finish_petrification_visual()
	else:
		_finish_petrification_visual()
	_spawn_game_vfx("petrify")

	enemy_petrified.emit(self)
	print("🗿 Enemy petrified at: ", current_grid_pos)
	create_petrify_effect()

func _finish_petrification_visual() -> void:
	if is_instance_valid(visual):
		visual.visible = false
	if is_instance_valid(creature_art):
		creature_art.visible = false
	if is_instance_valid(petrification_visual):
		if petrification_visual.has_method("set_warning_visible"):
			petrification_visual.set_warning_visible(false)

func reset_petrification_timer() -> void:
	petrify_time_remaining = PETRIFY_DURATION
	petrify_warning_shown = false
	if is_instance_valid(petrification_visual) and petrification_visual.has_method("set_warning_visible"):
		petrification_visual.set_warning_visible(false)

func un_petrify() -> void:
	if not petrified or is_squashed:
		return
	petrified = false
	petrify_time_remaining = 0.0
	petrify_warning_shown = false
	current_state = State.PATROL
	if is_instance_valid(visual):
		visual.visible = not is_instance_valid(creature_art)
	if is_instance_valid(eyes):
		eyes.visible = true
	if is_instance_valid(creature_art):
		creature_art.visible = true
		if creature_art.has_method("set_moving"):
			creature_art.set_moving(false)
	if is_instance_valid(petrification_visual):
		petrification_visual.visible = false
		petrification_visual.scale = Vector2.ONE
		petrification_visual.modulate = Color.WHITE
		petrification_visual.set("transition_progress", 0.0)
		if petrification_visual.has_method("set_warning_visible"):
			petrification_visual.set_warning_visible(false)

func _play_sound(method: StringName) -> void:
	"""Play a SoundManager effect; skipped when no sound manager is attached (tests, stubs)."""
	if sound_manager and sound_manager.has_method(method):
		sound_manager.call(method)

func _spawn_game_vfx(effect_kind: String) -> void:
	var vfx_parent: Node = SceneLookup.effect_parent(self)
	GAME_VFX.spawn(vfx_parent, global_position, effect_kind)

func check_boss_collision_during_slide() -> bool:
	if not petrified or not is_instance_valid(game_manager) or not is_instance_valid(game_manager.boss):
		return false
	var boss_pos = grid_manager.world_to_grid(game_manager.boss.position)
	if current_grid_pos != boss_pos:
		return false
	var hit = game_manager.boss.receive_sliding_statue(self)
	if hit:
		is_sliding = false
		is_squashed = true
		if is_instance_valid(game_manager) and game_manager.enemies.has(self):
			game_manager.enemies.erase(self)
		if is_inside_tree():
			queue_free()
	return hit

func check_squash_enemies():
	"""Check if sliding block hits any live enemies along the way"""
	if not is_instance_valid(game_manager):
		return
	
	for other in game_manager.enemies:
		if other == self or not is_instance_valid(other):
			continue
		if other.is_squashed:
			continue
		# Squash non-petrified enemies hit by the sliding block
		if not other.petrified:
			var hit_dist = Constants.TILE_SIZE * 0.75
			if position.distance_to(other.position) < hit_dist:
				other.squash()

func squash():
	"""Enemy is crushed by a sliding block"""
	if is_squashed:
		return
	
	is_squashed = true
	is_moving = false
	current_state = State.PETRIFIED
	
	print("💥 Enemy squashed at ", current_grid_pos, "! +200 pts")
	enemy_squashed.emit(self)
	
	_play_sound("play_squash")
	
	# Notify GameManager
	if is_instance_valid(game_manager) and game_manager.has_method("on_enemy_squashed"):
		game_manager.on_enemy_squashed(self)
	
	# Visual squash effect (flatten, flash red, fade out)
	if is_inside_tree():
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.5, 0.2), 0.15).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate", Color(1.8, 0.3, 0.3, 0.0), 0.25)
		await tween.finished
		_spawn_game_vfx("shatter")
	queue_free()

func shatter():
	"""Petrified statue is shattered by a second beam shot"""
	if not petrified or is_squashed:
		return
	
	is_squashed = true
	is_moving = false
	
	print("💥 Stone statue shattered at ", current_grid_pos, "!")
	enemy_shattered.emit(self)
	
	_play_sound("play_shatter")
	
	# Notify GameManager
	if is_instance_valid(game_manager) and game_manager.has_method("on_enemy_shattered"):
		game_manager.on_enemy_shattered(self)
	
	# Spawn stone debris and animate if inside tree
	if is_inside_tree():
		create_shatter_debris()
		_spawn_game_vfx("shatter")
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.12)
		tween.tween_property(self, "modulate:a", 0.0, 0.12)
		await tween.finished
	queue_free()

func create_shatter_debris():
	"""Spawn crumbling stone particle fragments"""
	var parent_node = get_parent()
	if not parent_node:
		return
	
	for i in range(6):
		var chip = ColorRect.new()
		chip.size = Vector2(8, 8)
		chip.position = position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
		chip.color = Constants.COLOR_STONE_GRAY
		chip.z_index = Constants.LAYER_EFFECTS
		parent_node.add_child(chip)
		
		var vel = Vector2(randf_range(-120, 120), randf_range(-120, 120))
		var tw = chip.create_tween()
		tw.set_parallel(true)
		tw.tween_property(chip, "position", chip.position + vel * 0.3, 0.3)
		tw.tween_property(chip, "modulate:a", 0.0, 0.3)
		tw.tween_callback(chip.queue_free)

func push_to_position(new_grid_pos: Vector2i):
	"""Push statue to new position (DEPRECATED - now slides)"""
	if not petrified:
		return
	
	current_grid_pos = new_grid_pos
	target_grid_pos = new_grid_pos
	
	var new_world_pos = grid_manager.grid_to_world(new_grid_pos)
	
	# Smooth push animation
	var tween = create_tween()
	tween.tween_property(self, "position", new_world_pos, 0.2).set_ease(Tween.EASE_OUT)
	
	print("📦 Statue pushed to: ", new_grid_pos)

func slide_on_ground(final_pos: Vector2i, direction: Vector2i, waypoints: Array = []):
	"""Slide statue across GROUND until reaching obstacle (original Kickle mechanic).
	waypoints: stops on the way (hammer strikes), see SlideMotion."""
	if not petrified or is_squashed:
		return
	
	is_sliding = true
	print("🧊 Ice block sliding on GROUND from ", current_grid_pos, " to ", final_pos)
	
	# Create sliding animation
	var final_world = grid_manager.grid_to_world(final_pos)
	
	# Calculate distance for animation timing
	var distance = current_grid_pos.distance_to(final_pos)
	var slide_duration = max(0.08, 0.12 * distance)  # 0.12 sec per tile (fast slide)
	
	# Animate sliding
	var tween: Tween
	if waypoints.is_empty():
		tween = create_tween()
		tween.tween_property(self, "position", final_world, slide_duration).set_ease(Tween.EASE_OUT)
	else:
		tween = SlideMotion.through(self, grid_manager, current_grid_pos, waypoints, final_pos)
	
	# Wait for animation
	await tween.finished
	
	# Update position
	is_sliding = false
	current_grid_pos = final_pos
	target_grid_pos = final_pos
	
	# Fast motion may skip intermediate physics samples; ensure final-tile boss hit too.
	if check_boss_collision_during_slide():
		return
	
	print("📦 Ice block stopped on ground at: ", final_pos)

func slide_on_ground_into_water(water_pos: Vector2i, direction: Vector2i, waypoints: Array = []):
	"""Slide on ground then enter water at the end. waypoints: stops on the way (hammer strikes), see SlideMotion."""
	if not petrified or is_squashed:
		return
	
	is_sliding = true
	print("🧊 Ice block sliding from ", current_grid_pos, " into water at ", water_pos)
	
	# Create sliding animation to water
	var water_world = grid_manager.grid_to_world(water_pos)
	
	# Calculate distance for animation timing
	var distance = current_grid_pos.distance_to(water_pos)
	var slide_duration = max(0.08, 0.12 * distance)  # Same speed as ground sliding
	
	# Animate sliding to water
	var slide_tween: Tween
	if waypoints.is_empty():
		slide_tween = create_tween()
		slide_tween.tween_property(self, "position", water_world, slide_duration).set_ease(Tween.EASE_OUT)
	else:
		slide_tween = SlideMotion.through(self, grid_manager, current_grid_pos, waypoints, water_pos)
	
	# Wait for slide animation
	await slide_tween.finished
	
	is_sliding = false
	# Update position
	current_grid_pos = water_pos
	target_grid_pos = water_pos
	
	# Now sink into water and create bridge
	_spawn_game_vfx("splash")
	grid_manager.set_tile(water_pos, Constants.TileType.ICE)
	update_water_tile_visual(water_pos)
	
	_play_sound("play_bridge")
	
	print("💦 Ice block entered water - sinking and creating bridge!")
	
	# Sinking animation
	var sink_tween = create_tween()
	sink_tween.set_parallel(true)
	sink_tween.tween_property(self, "modulate:a", 0.0, 0.35)
	sink_tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.35)
	
	await sink_tween.finished
	
	print("✓ Bridge created at: ", water_pos, " - Block disappeared")
	queue_free()

func push_into_water(water_pos: Vector2i):
	"""Push statue into water - STOPS immediately, creates bridge and DISAPPEARS"""
	if not petrified:
		return
	
	print("💦 Ice block pushed into water at: ", water_pos, " - Creating bridge and sinking!")
	
	# Update position immediately (doesn't slide in water)
	current_grid_pos = water_pos
	target_grid_pos = water_pos
	
	var new_world_pos = grid_manager.grid_to_world(water_pos)
	_spawn_game_vfx("splash")
	
	# Change water tile to ice (walkable bridge)
	grid_manager.set_tile(water_pos, Constants.TileType.ICE)
	update_water_tile_visual(water_pos)
	
	# Animate entering and sinking, then DISAPPEAR
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", new_world_pos, 0.25)
	tween.tween_property(self, "modulate:a", 0.0, 0.35)  # Fade to invisible
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.35)  # Shrink
	
	# Wait for animation then remove
	await tween.finished
	
	print("✓ Bridge created at: ", water_pos, " - Block disappeared")
	
	# Remove the enemy completely
	queue_free()


func slide_into_water(final_pos: Vector2i, direction: Vector2i):
	"""OLD FUNCTION - Kept for compatibility but not used anymore"""
	push_into_water(final_pos)


func update_water_tile_visual(water_pos: Vector2i):
	"""Update the water tile to show it's now a bridge"""
	var main_scene = SceneLookup.main_scene(self)
	if main_scene and main_scene.has_method("add_bridge_visual"):
		main_scene.add_bridge_visual(water_pos)

func create_petrify_effect():
	if not visual or not is_inside_tree():
		return
	for i in range(3):
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(visual):
			return
		visual.modulate = Color(1.5, 1.5, 1.5, 1)
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(visual):
			return
		visual.modulate = Color(1, 1, 1, 1)
