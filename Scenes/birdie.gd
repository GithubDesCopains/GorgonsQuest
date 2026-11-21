extends Enemy
class_name Birdie

## Birdie - Flying enemy that can fly over water and obstacles (original Kickle enemy)

var is_flying: bool = false
var fly_height_offset: float = 0.0

func _ready():
	super._ready()
	move_speed = 180.0
	wait_time = 0.3
	z_index = Constants.LAYER_ENEMIES + 1  # Fly above ground

func _process(delta):
	# Bobbing animation for flying
	fly_height_offset = sin(Time.get_ticks_msec() / 200.0) * 5
	if visual:
		visual.position.y = -25 + fly_height_offset

func try_patrol_move():
	if patrol_pattern.is_empty():
		return
	
	var move_dir = patrol_pattern[patrol_index]
	var next_pos = current_grid_pos + move_dir
	
	# Birdies can fly over everything except walls
	if can_fly_over(next_pos):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			if next_pos == player.current_grid_pos and player.is_alive:
				print("💀 Birdie will hit player at: ", next_pos)
				game_manager.player_hit_by_enemy()
				return
		
		target_grid_pos = next_pos
		is_moving = true
		patrol_index = (patrol_index + 1) % patrol_pattern.size()
	else:
		patrol_index = (patrol_index + 1) % patrol_pattern.size()

func can_fly_over(pos: Vector2i) -> bool:
	if not grid_manager.is_valid_grid_pos(pos) or grid_manager.has_spawner(pos) or grid_manager.has_mirror(pos) or grid_manager.has_hammer(pos):
		return false
	if grid_manager.edge_blocked(current_grid_pos, pos):
		return false  # a closed door stops flyers too
	
	var tile = grid_manager.get_tile(pos)
	# Can fly over water, ice, ground, but NOT walls or spawners
	return tile != Constants.TileType.WALL and tile != Constants.TileType.PLAYER_ONLY and not grid_manager.has_push_block(pos)

func create_placeholder_visual():
	visual = ColorRect.new()
	visual.size = Vector2(50, 50)
	visual.position = Vector2(-25, -25)
	visual.color = Color(0.3, 0.7, 0.9, 1.0)  # Sky blue
	add_child(visual)
	
	eyes = ColorRect.new()
	eyes.size = Vector2(20, 8)
	eyes.position = Vector2(-10, -5)
	eyes.color = Color(0, 0, 0, 1)
	visual.add_child(eyes)
	
	# Wings
	var wing_left = ColorRect.new()
	wing_left.size = Vector2(15, 8)
	wing_left.position = Vector2(-30, -2)
	wing_left.color = Color(0.5, 0.8, 1.0, 1.0)
	visual.add_child(wing_left)
	
	var wing_right = ColorRect.new()
	wing_right.size = Vector2(15, 8)
	wing_right.position = Vector2(15, -2)
	wing_right.color = Color(0.5, 0.8, 1.0, 1.0)
	visual.add_child(wing_right)
	
	# Beak
	var beak = ColorRect.new()
	beak.size = Vector2(8, 6)
	beak.position = Vector2(-4, 8)
	beak.color = Color(1.0, 0.8, 0.2, 1.0)
	visual.add_child(beak)
