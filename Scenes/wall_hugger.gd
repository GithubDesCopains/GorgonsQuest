extends Enemy
class_name WallHugger

## Fast automaton that follows walkable cells along wall edges.

var facing_direction: Vector2i = Vector2i.DOWN

func _ready():
	super._ready()
	move_speed = 230.0
	wait_time = 0.12

func try_patrol_move():
	if not grid_manager or petrified or is_squashed:
		return
	var chosen_direction = choose_wall_follow_direction(grid_manager, current_grid_pos, facing_direction)
	if chosen_direction == Vector2i.ZERO:
		return
	var next_pos = current_grid_pos + chosen_direction
	var player = get_tree().get_first_node_in_group("player")
	if player and player.is_alive and next_pos == player.current_grid_pos:
		game_manager.player_hit_by_enemy()
		return
	facing_direction = chosen_direction
	current_direction = direction_to_enum(chosen_direction)
	target_grid_pos = next_pos
	is_moving = true

func choose_wall_follow_direction(grid: GridManager, from_pos: Vector2i, facing: Vector2i) -> Vector2i:
	"""Follow boundary with a right-hand rule: turn right if open, then straight, left, reverse."""
	if not grid or facing == Vector2i.ZERO:
		return Vector2i.ZERO
	# Continue along current wall edge; turn at a blocked corner (clockwise first).
	var candidates = [facing, rotate_clockwise(facing), rotate_counterclockwise(facing), -facing]
	for candidate in candidates:
		var destination = from_pos + candidate
		if grid.is_enemy_walkable(destination) and grid.get_tile(destination) != Constants.TileType.WATER:
			return candidate
	return Vector2i.ZERO

func rotate_clockwise(direction: Vector2i) -> Vector2i:
	return Vector2i(-direction.y, direction.x)

func rotate_counterclockwise(direction: Vector2i) -> Vector2i:
	return Vector2i(direction.y, -direction.x)

func direction_to_enum(direction: Vector2i) -> int:
	if direction == Vector2i.RIGHT:
		return Constants.Direction.RIGHT
	if direction == Vector2i.DOWN:
		return Constants.Direction.DOWN
	if direction == Vector2i.LEFT:
		return Constants.Direction.LEFT
	return Constants.Direction.UP

func create_visual():
	visual = ColorRect.new()
	visual.size = Vector2(52, 52)
	visual.position = Vector2(-26, -26)
	visual.color = Color("#b87532") # Fired-bronze automaton
	add_child(visual)
	
	var shell = ColorRect.new()
	shell.size = Vector2(38, 38)
	shell.position = Vector2(-19, -19)
	shell.color = Color("#d8a64e")
	visual.add_child(shell)
	
	eyes = ColorRect.new()
	eyes.size = Vector2(18, 7)
	eyes.position = Vector2(-9, -4)
	eyes.color = Color("#fff2a0")
	visual.add_child(eyes)
	
	var crest = ColorRect.new()
	crest.size = Vector2(7, 18)
	crest.position = Vector2(-3, -26)
	crest.color = Color("#79512e")
	visual.add_child(crest)

func petrify():
	if petrified or is_squashed:
		return
	super.petrify()
