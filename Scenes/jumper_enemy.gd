extends Enemy
class_name JumperEnemy

## Bronze-armored jumping bruiser. Leaps over one cell, then threatens player on landing.

@export var jump_cooldown: float = 1.15
@export var jump_distance: int = 2
@export var jump_arc_height: float = 88.0

var jump_timer: float = 0.0
var has_landed: bool = true
var is_jumping: bool = false
var jump_tween: Tween

func _ready():
	super._ready()
	move_speed = 185.0
	wait_time = 0.25

func process_patrol(delta: float):
	if is_jumping or petrified or is_squashed:
		return
	if is_moving:
		move_towards_target(delta)
		return
	jump_timer += delta
	if jump_timer < jump_cooldown:
		return
	jump_timer = 0.0
	
	var player = get_tree().get_first_node_in_group("player")
	var preferred_direction = Vector2i.ZERO
	if player and player.is_alive:
		preferred_direction = get_cardinal_direction_toward(current_grid_pos, player.current_grid_pos)
	var landing = calculate_jump_destination(grid_manager, current_grid_pos, preferred_direction, patrol_pattern, patrol_index, jump_distance)
	if landing == current_grid_pos:
		return
	if player and player.is_alive and jump_threatens_player(current_grid_pos, landing, player.current_grid_pos):
		print("💥 Jumper lands on player at: ", landing)
		game_manager.player_hit_by_enemy()
		# Still animate leap into landing tile so threat has clear telegraph.
	perform_jump(landing)

func get_cardinal_direction_toward(from_pos: Vector2i, to_pos: Vector2i) -> Vector2i:
	var offset = to_pos - from_pos
	if offset == Vector2i.ZERO:
		return Vector2i.ZERO
	if abs(offset.x) >= abs(offset.y):
		return Vector2i.RIGHT if offset.x > 0 else Vector2i.LEFT
	return Vector2i.DOWN if offset.y > 0 else Vector2i.UP

func calculate_jump_destination(grid: GridManager, from_pos: Vector2i, preferred_direction: Vector2i, pattern: Array, pattern_index: int, max_distance: int = 2) -> Vector2i:
	"""Choose a clear landing cell; a two-cell leap may pass over water or an enemy."""
	if not grid or max_distance < 1:
		return from_pos
	var directions: Array[Vector2i] = []
	if preferred_direction != Vector2i.ZERO:
		directions.append(preferred_direction)
	if not pattern.is_empty():
		for i in range(pattern.size()):
			var candidate: Vector2i = pattern[(pattern_index + i) % pattern.size()]
			if not directions.has(candidate):
				directions.append(candidate)
	if directions.is_empty():
		directions = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	
	for direction in directions:
		for distance in range(max_distance, 0, -1):
			var landing = from_pos + direction * distance
			if not grid.is_valid_grid_pos(landing) or not grid.is_enemy_walkable(landing):
				continue
			# Don't land inside another petrified statue; enemies and water may be leapt over.
			if _has_petrified_statue_at(landing) or is_cell_taken_by_other_enemy(landing):
				continue
			if _door_on_path(grid, from_pos, direction, distance):
				continue  # a closed door stops the leap
			return landing
	return from_pos

func _door_on_path(grid: GridManager, from_pos: Vector2i, direction: Vector2i, distance: int) -> bool:
	for step in range(distance):
		if grid.edge_blocked(from_pos + direction * step, from_pos + direction * (step + 1)):
			return true
	return false

func _has_petrified_statue_at(pos: Vector2i) -> bool:
	if not is_inside_tree():
		return false
	for other in get_tree().get_nodes_in_group("enemies"):
		if other != self and is_instance_valid(other) and other.petrified and not other.is_squashed and other.current_grid_pos == pos:
			return true
	return false

func jump_threatens_player(from_pos: Vector2i, landing_pos: Vector2i, player_pos: Vector2i) -> bool:
	return landing_pos == player_pos

func perform_jump(landing_pos: Vector2i):
	if is_jumping or petrified or is_squashed:
		return
	is_jumping = true
	has_landed = false
	is_moving = false
	target_grid_pos = landing_pos
	var landing_world = grid_manager.grid_to_world(landing_pos)
	var start_world = position
	var midpoint = (start_world + landing_world) * 0.5 + Vector2.UP * jump_arc_height
	
	jump_tween = create_tween()
	jump_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	jump_tween.tween_property(self, "position", midpoint, 0.18)
	jump_tween.tween_property(self, "position", landing_world, 0.18)
	await jump_tween.finished
	if not is_instance_valid(self):
		return
	is_jumping = false
	has_landed = true
	if petrified or is_squashed:
		return
	position = landing_world
	current_grid_pos = landing_pos
	target_grid_pos = landing_pos
	check_player_collision()

func petrify():
	if is_jumping and jump_tween and jump_tween.is_running():
		jump_tween.kill()
		position = grid_manager.grid_to_world(current_grid_pos)
		target_grid_pos = current_grid_pos  # drop the reserved landing cell
		is_jumping = false
	super.petrify()

func create_visual():
	visual = ColorRect.new()
	visual.size = Vector2(54, 54)
	visual.position = Vector2(-27, -27)
	visual.color = Color("#9a4e37") # Terracotta minotaur armor
	add_child(visual)
	
	var armor = ColorRect.new()
	armor.size = Vector2(40, 40)
	armor.position = Vector2(-20, -20)
	armor.color = Color("#c77746")
	visual.add_child(armor)
	
	eyes = ColorRect.new()
	eyes.size = Vector2(20, 8)
	eyes.position = Vector2(-10, -5)
	eyes.color = Color("#fff0a6")
	visual.add_child(eyes)
	
	var horn_left = ColorRect.new()
	horn_left.size = Vector2(8, 16)
	horn_left.position = Vector2(-20, -28)
	horn_left.color = Color("#f0d6a2")
	visual.add_child(horn_left)
	var horn_right = ColorRect.new()
	horn_right.size = Vector2(8, 16)
	horn_right.position = Vector2(12, -28)
	horn_right.color = Color("#f0d6a2")
	visual.add_child(horn_right)
