extends Enemy
class_name PusherEnemy

## Aquatic guardian that hunts bridge tiles and dissolves an unoccupied bridge.

@export var bridge_attack_delay: float = 0.45
var attack_timer: float = 0.0
var target_bridge: Vector2i = Vector2i(-1, -1)

func _ready():
	super._ready()
	move_speed = 105.0
	wait_time = 0.28

func try_patrol_move():
	if patrol_pattern.is_empty() or petrified or is_squashed:
		return
	var bridge = find_nearest_bridge(grid_manager, current_grid_pos)
	if bridge != Vector2i(-1, -1):
		target_bridge = bridge
		var step = choose_water_step_toward_bridge(grid_manager, current_grid_pos, bridge)
		if step != Vector2i.ZERO:
			var next_pos = current_grid_pos + step
			var player = get_tree().get_first_node_in_group("player")
			if player and player.is_alive and next_pos == player.current_grid_pos:
				game_manager.player_hit_by_enemy()
				return
			target_grid_pos = next_pos
			is_moving = true
			return
		if attack_bridge_if_adjacent():
			return
	
	# No reachable or temporarily vulnerable bridge: patrol water only.
	var patrol_direction: Vector2i = patrol_pattern[patrol_index]
	var patrol_target = current_grid_pos + patrol_direction
	if grid_manager.is_valid_grid_pos(patrol_target) and grid_manager.get_tile(patrol_target) == Constants.TileType.WATER and not grid_manager.has_spawner(patrol_target):
		target_grid_pos = patrol_target
		is_moving = true
	patrol_index = (patrol_index + 1) % patrol_pattern.size()

func find_nearest_bridge(grid: GridManager, from_pos: Vector2i) -> Vector2i:
	if not grid:
		return Vector2i(-1, -1)
	var nearest = Vector2i(-1, -1)
	var best_distance = 1_000_000
	var bridges: Array[Vector2i] = []
	if is_instance_valid(game_manager):
		bridges = game_manager.get_bridge_positions()
	else:
		for y in range(Constants.GRID_ROWS):
			for x in range(Constants.GRID_COLS):
				var candidate = Vector2i(x, y)
				if grid.get_tile(candidate) == Constants.TileType.ICE:
					bridges.append(candidate)
	for candidate in bridges:
		var distance = absi(candidate.x - from_pos.x) + absi(candidate.y - from_pos.y)
		if distance < best_distance:
			best_distance = distance
			nearest = candidate
	return nearest

func choose_water_step_toward_bridge(grid: GridManager, from_pos: Vector2i, bridge_pos: Vector2i) -> Vector2i:
	"""Breadth-first route over water to a water cell adjacent to target bridge."""
	if not grid:
		return Vector2i.ZERO
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	var frontier: Array[Vector2i] = [from_pos]
	var first_step: Dictionary = {from_pos: Vector2i.ZERO}
	var visited: Dictionary = {from_pos: true}
	var head := 0
	while head < frontier.size():
		var current: Vector2i = frontier[head]
		head += 1
		for direction in directions:
			var next_pos = current + direction
			if next_pos == bridge_pos:
				return first_step[current]
			if not grid.is_valid_grid_pos(next_pos) or grid.get_tile(next_pos) != Constants.TileType.WATER or grid.has_spawner(next_pos) or visited.has(next_pos):
				continue
			visited[next_pos] = true
			first_step[next_pos] = direction if current == from_pos else first_step[current]
			frontier.append(next_pos)
	return Vector2i.ZERO

func attack_bridge_if_adjacent() -> bool:
	if target_bridge == Vector2i(-1, -1):
		return false
	var distance = absi(target_bridge.x - current_grid_pos.x) + absi(target_bridge.y - current_grid_pos.y)
	if distance != 1:
		return false
	var player = get_tree().get_first_node_in_group("player")
	var player_pos = player.current_grid_pos if player and player.is_alive else Vector2i(-1, -1)
	if not can_remove_bridge(grid_manager, target_bridge, player_pos):
		return false
	attack_timer += wait_time
	if attack_timer < bridge_attack_delay:
		return false
	attack_timer = 0.0
	if game_manager.has_method("remove_bridge_at"):
		return game_manager.remove_bridge_at(target_bridge)
	return false

func can_remove_bridge(grid: GridManager, bridge_pos: Vector2i, player_pos: Vector2i) -> bool:
	return grid != null and grid.get_tile(bridge_pos) == Constants.TileType.ICE and player_pos != bridge_pos

func create_visual():
	visual = ColorRect.new()
	visual.size = Vector2(50, 50)
	visual.position = Vector2(-25, -25)
	visual.color = Color("#267f87") # Sea-green hide
	add_child(visual)
	var shell = ColorRect.new()
	shell.size = Vector2(38, 28)
	shell.position = Vector2(-19, -14)
	shell.color = Color("#55bac0")
	visual.add_child(shell)
	eyes = ColorRect.new()
	eyes.size = Vector2(18, 7)
	eyes.position = Vector2(-9, -4)
	eyes.color = Color("#efffba")
	visual.add_child(eyes)
	var fin = ColorRect.new()
	fin.size = Vector2(10, 18)
	fin.position = Vector2(-5, -28)
	fin.color = Color("#1b5964")
	visual.add_child(fin)
