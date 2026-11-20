extends Enemy
class_name HadesShadow

## Shadow of Hades approaches only while hero looks away; freezes when watched.

@export var approach_interval: float = 0.45
var approach_timer: float = 0.0

func _ready():
	super._ready()
	move_speed = 115.0
	wait_time = 0.1

func process_patrol(delta: float):
	if petrified or is_squashed:
		return
	if is_moving:
		move_towards_target(delta)
		return
	approach_timer += delta
	if approach_timer < approach_interval:
		return
	approach_timer = 0.0
	try_approach_player()

func try_approach_player() -> bool:
	if not is_instance_valid(game_manager) or not is_instance_valid(grid_manager):
		return false
	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.is_alive:
		return false
	if is_player_looking_at_shadow(player.current_grid_pos, player.current_direction, current_grid_pos):
		set_frozen_visual(true)
		return false
	set_frozen_visual(false)
	var step = choose_approach_step(grid_manager, current_grid_pos, player.current_grid_pos)
	if step == Vector2i.ZERO:
		return false
	var next_pos = current_grid_pos + step
	if next_pos == player.current_grid_pos:
		game_manager.player_hit_by_enemy()
		return false
	target_grid_pos = next_pos
	is_moving = true
	return true

func is_player_looking_at_shadow(player_pos: Vector2i, facing: int, shadow_pos: Vector2i) -> bool:
	var facing_vector = direction_enum_to_vector(facing)
	var toward_shadow = shadow_pos - player_pos
	# Top-down gaze blocks ghost only on same row or column, in facing direction.
	if facing_vector.x != 0:
		return toward_shadow.y == 0 and toward_shadow.x * facing_vector.x > 0
	if facing_vector.y != 0:
		return toward_shadow.x == 0 and toward_shadow.y * facing_vector.y > 0
	return false

func direction_enum_to_vector(facing: int) -> Vector2i:
	match facing:
		Constants.Direction.RIGHT:
			return Vector2i.RIGHT
		Constants.Direction.DOWN:
			return Vector2i.DOWN
		Constants.Direction.LEFT:
			return Vector2i.LEFT
		Constants.Direction.UP:
			return Vector2i.UP
	return Vector2i.ZERO

func choose_approach_step(grid: GridManager, from_pos: Vector2i, player_pos: Vector2i) -> Vector2i:
	if not grid:
		return Vector2i.ZERO
	var delta = player_pos - from_pos
	var preferred: Array[Vector2i] = []
	if absi(delta.x) >= absi(delta.y):
		if delta.x != 0:
			preferred.append(Vector2i(signi(delta.x), 0))
		if delta.y != 0:
			preferred.append(Vector2i(0, signi(delta.y)))
	else:
		if delta.y != 0:
			preferred.append(Vector2i(0, signi(delta.y)))
		if delta.x != 0:
			preferred.append(Vector2i(signi(delta.x), 0))
	for step in preferred:
		var destination = from_pos + step
		if grid.is_enemy_walkable(destination) and grid.get_tile(destination) != Constants.TileType.WATER:
			return step
	return Vector2i.ZERO

func set_frozen_visual(frozen: bool):
	if visual:
		visual.modulate = Color(0.55, 0.75, 1.0, 0.75) if frozen else Color.WHITE

func create_visual():
	visual = ColorRect.new()
	visual.size = Vector2(48, 56)
	visual.position = Vector2(-24, -28)
	visual.color = Color("#36304f")
	add_child(visual)
	var cloak = ColorRect.new()
	cloak.size = Vector2(38, 44)
	cloak.position = Vector2(-19, -20)
	cloak.color = Color("#6b5b91")
	visual.add_child(cloak)
	eyes = ColorRect.new()
	eyes.size = Vector2(14, 6)
	eyes.position = Vector2(-7, -6)
	eyes.color = Color("#b9ebff")
	visual.add_child(eyes)
	var wisp = ColorRect.new()
	wisp.size = Vector2(12, 12)
	wisp.position = Vector2(-6, 19)
	wisp.color = Color("#c7b9ef")
	visual.add_child(wisp)
