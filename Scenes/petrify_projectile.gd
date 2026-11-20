extends Node2D
class_name PetrifyProjectile

const GameVFX = preload("res://Scenes/game_vfx.gd")

## Projectile that petrifies enemies on contact

var direction: Vector2
var speed: float = 1100.0  # a laser: crosses the whole board in under a second
var grid_direction: int
var traveled_tiles: int = 0
var max_range: int = 8  # Maximum travel distance in tiles

var origin: Vector2  # where the beam leaves the hero
var age := 0.0
var path_points: Array[Vector2] = []  # origin, then the centre of every mirror the beam bent on
var bounces := 0
var _cell := Vector2i(-999, -999)  # cell the head was in last frame, to detect crossing a door edge
var _bent_cell := Vector2i(-999, -999)

const MAX_BOUNCES := 8
const HERO_HIT_RADIUS := 34.0

const BEAM_MAX_LENGTH := 288.0  # the visible beam never trails longer than 4 tiles
const BEAM_CORE := Color("F2FFD8")
const BEAM_MID := Color("A9E27D")
const BEAM_GLOW := Color(0.4, 0.9, 0.3, 0.28)

@onready var grid_manager: GridManager

signal enemy_hit(enemy)
signal wall_hit(grid_pos: Vector2i)

func _ready():
	# The laser is drawn in _draw(): no child node needed.
	
	z_index = Constants.LAYER_EFFECTS
	
	# Get grid manager
	grid_manager = get_node("/root/Main/GameManager/GridManager")

func initialize(start_pos: Vector2, dir: int, beam_origin: Vector2 = Vector2.INF):
	"""Initialize the projectile; beam_origin is where the laser leaves the hero (defaults to start_pos)."""
	position = start_pos
	origin = start_pos if beam_origin == Vector2.INF else beam_origin
	grid_direction = dir
	direction = Constants.DIR_VECTORS[dir]
	path_points = [origin]
	bounces = 0
	if grid_manager != null:
		_cell = grid_manager.world_to_grid(origin)  # the hero's cell: crossing out of it checks the first door
	queue_redraw()
	
	# The laser is drawn along 'direction' in _draw(): nothing to rotate.

func advance(distance: float) -> void:
	"""Move the head along the beam. On a mirror it reaches the cell centre, then turns 90 degrees."""
	position += direction * distance
	if grid_manager == null or bounces >= MAX_BOUNCES:
		return
	var cell := grid_manager.world_to_grid(position)
	if not grid_manager.has_mirror(cell) or cell == _bent_cell:
		return
	var centre := grid_manager.grid_to_world(cell)
	if (position - centre).dot(direction) < 0.0:
		return  # still on its way to the middle of the mirror
	position = centre
	path_points.append(centre)
	var bent := GridManager.reflect(Vector2i(direction), grid_manager.get_mirror(cell))
	direction = Vector2(bent)
	_bent_cell = cell
	bounces += 1

func hits_hero(hero_position: Vector2) -> bool:
	"""Only a beam that already bounced can reach the hero: the hero never shoots himself directly."""
	return bounces > 0 and position.distance_to(hero_position) < HERO_HIT_RADIUS

func check_hero_collision() -> bool:
	if bounces == 0 or not is_inside_tree():
		return false
	for hero in get_tree().get_nodes_in_group("player"):
		if is_instance_valid(hero) and hero.is_alive and hits_hero(hero.position):
			GameVFX.spawn(SceneLookup.main_scene(self), hero.position, "impact")
			var manager := get_tree().root.get_node_or_null("Main/GameManager")
			if manager and manager.has_method("player_hit_by_enemy"):
				manager.player_hit_by_enemy()  # petrified by his own reflected gaze
			queue_free()
			return true
	return false

func _process(delta):
	advance(speed * delta)
	age += delta
	queue_redraw()
	
	var current_grid = grid_manager.world_to_grid(position)
	
	# Check collision with walls
	if not grid_manager.is_valid_grid_pos(current_grid):
		hit_wall(current_grid)
		return
	
	# A closed door stops the beam like a wall, on the edge between two cells.
	if _cell != Vector2i(-999, -999) and current_grid != _cell and grid_manager.edge_blocked(_cell, current_grid):
		position = grid_manager.grid_to_world(_cell)
		hit_wall(_cell)
		return
	_cell = current_grid
	
	if bounces >= MAX_BOUNCES and grid_manager.has_mirror(current_grid):
		hit_wall(current_grid)  # safety net against endless mirror loops
		return
	if check_hero_collision():
		return
	
	if grid_manager.has_spawner(current_grid):
		# Solid like a wall, but an enemy just emerged from it can still be hit first.
		check_enemy_collision()
		if not is_queued_for_deletion():
			hit_wall(current_grid)
		return
	var tile_type = grid_manager.get_tile(current_grid)
	if tile_type == Constants.TileType.WALL or tile_type == Constants.TileType.STONE_BLOCK:
		hit_wall(current_grid)
		return
	
	# Check collision with bosses and regular enemies.
	if check_boss_collision():
		return
	check_enemy_collision()

func beam_tail_length() -> float:
	"""Visible beam length behind the head (around the bends): grows out of the hero, then trails at most BEAM_MAX_LENGTH."""
	var total := 0.0
	var from := position
	for i in range(path_points.size() - 1, -1, -1):
		total += from.distance_to(path_points[i])
		from = path_points[i]
	return clampf(total, 0.0, BEAM_MAX_LENGTH)

func beam_points_local() -> PackedVector2Array:
	"""The beam as a polyline in local coordinates: head first, then back through each bend, cut at BEAM_MAX_LENGTH."""
	var result := PackedVector2Array([Vector2.ZERO])
	var remaining := BEAM_MAX_LENGTH
	var from := position
	for i in range(path_points.size() - 1, -1, -1):
		var to: Vector2 = path_points[i]
		var segment := from.distance_to(to)
		if segment >= remaining:
			result.append(from + (to - from).normalized() * remaining - position)
			return result
		result.append(to - position)
		remaining -= segment
		from = to
	return result

func _draw() -> void:
	var points := beam_points_local()
	var flicker := 0.85 + 0.15 * sin(age * 60.0)
	# Soft glow, then the green beam, then a white-hot core, with a flare at the head.
	if points.size() >= 2:
		draw_polyline(points, BEAM_GLOW, 20.0 * flicker, true)
		draw_polyline(points, BEAM_MID, 9.0, true)
		draw_polyline(points, BEAM_CORE, 3.5, true)
		for i in range(1, points.size() - 1):  # round the bends
			draw_circle(points[i], 10.0 * flicker, BEAM_GLOW)
			draw_circle(points[i], 4.5, BEAM_MID)
			draw_circle(points[i], 1.75, BEAM_CORE)
	draw_circle(Vector2.ZERO, 11.0 * flicker, BEAM_GLOW)
	draw_circle(Vector2.ZERO, 5.0, BEAM_CORE)

func check_boss_collision() -> bool:
	if not is_inside_tree():
		return false
	for boss in get_tree().get_nodes_in_group("bosses"):
		if is_instance_valid(boss) and position.distance_to(boss.position) < 90.0:
			GameVFX.spawn(SceneLookup.main_scene(self), position, "impact")
			if boss.has_method("receive_gaze"):
				boss.receive_gaze()
			queue_free()
			return true
	return false

func check_enemy_collision():
	"""Check if projectile hits an enemy"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_squashed:
			if position.distance_to(enemy.position) < 35:
				if enemy.has_method("is_immune_to_petrification") and enemy.is_immune_to_petrification():
					if enemy.has_method("show_immune_flash"):
						enemy.show_immune_flash()
					queue_free()
					return
				GameVFX.spawn(SceneLookup.main_scene(self), enemy.global_position, "impact")
				if enemy.petrified and enemy.has_method("reset_petrification_timer"):
					enemy.reset_petrification_timer()
				else:
					enemy_hit.emit(enemy)
				queue_free()
				return

func hit_wall(grid_pos: Vector2i):
	"""Called when hitting a wall"""
	wall_hit.emit(grid_pos)
	# Original golden impact sparks.
	var root_parent := SceneLookup.effect_parent(self)
	GameVFX.spawn(root_parent, position, "impact")
	queue_free()

func create_hit_effect():
	"""Public compatibility hook for impact effects."""
	var root_parent := SceneLookup.effect_parent(self)
	return GameVFX.spawn(root_parent, position, "impact")
