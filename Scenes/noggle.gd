extends Enemy
class_name Noggle

## Noggle - Basic enemy that walks in straight lines (original Kickle enemy)

func _ready():
	super._ready()
	move_speed = 150.0
	wait_time = 0.5

var heading := Vector2i.ZERO

func pick_direction() -> Vector2i:
	"""Go straight. Blocked (wall, block, water edge, violet tile): quarter-turn first (side picked at random), half-turn only if both sides are blocked."""
	if heading == Vector2i.ZERO:
		heading = Vector2i.RIGHT
		for dir in patrol_pattern:
			if dir != Vector2i.ZERO:
				heading = dir
				break
	if _is_open(current_grid_pos + heading):
		return heading
	var side := Vector2i(-heading.y, heading.x)
	var first_quarter := side if randi() % 2 == 0 else -side
	var options: Array[Vector2i] = [first_quarter, -first_quarter, -heading]  # half-turn is the last resort
	for dir in options:
		if _is_open(current_grid_pos + dir):
			heading = dir
			return dir
	return Vector2i.ZERO

func _is_open(pos: Vector2i) -> bool:
	# Another enemy in the way counts as an obstacle too, so two noggles never face each other forever.
	return grid_manager.is_enemy_walkable(pos) and not is_cell_taken_by_other_enemy(pos) and not grid_manager.edge_blocked(current_grid_pos, pos)

func try_patrol_move():
	var dir := pick_direction()
	if dir == Vector2i.ZERO:
		return
	var next_pos := current_grid_pos + dir
	var player = get_tree().get_first_node_in_group("player")
	if player and next_pos == player.current_grid_pos and player.is_alive:
		game_manager.player_hit_by_enemy()
		return
	target_grid_pos = next_pos
	is_moving = true


func create_placeholder_visual():
	visual = ColorRect.new()
	visual.size = Vector2(50, 50)
	visual.position = Vector2(-25, -25)
	visual.color = Color(0.8, 0.3, 0.3, 1.0)  # Red
	add_child(visual)
	
	# Simple face
	eyes = ColorRect.new()
	eyes.size = Vector2(20, 8)
	eyes.position = Vector2(-10, -5)
	eyes.color = Color(1, 1, 1, 1)
	visual.add_child(eyes)
	
	# Round body indicator (circle-ish)
	var body_accent = ColorRect.new()
	body_accent.size = Vector2(30, 30)
	body_accent.position = Vector2(-15, 5)
	body_accent.color = Color(0.9, 0.4, 0.4, 1.0)
	visual.add_child(body_accent)
