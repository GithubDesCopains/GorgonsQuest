extends Enemy
class_name Zapper

## Zapper - Aquatic enemy that swims in water (original Kickle enemy)

var swim_bobbing: float = 0.0

func _ready():
	super._ready()
	move_speed = 120.0
	wait_time = 0.6

func _process(delta):
	# Swimming bobbing animation
	swim_bobbing = sin(Time.get_ticks_msec() / 150.0) * 3
	if visual:
		visual.position.y = -25 + swim_bobbing

func try_patrol_move():
	if patrol_pattern.is_empty():
		return
	
	var move_dir = patrol_pattern[patrol_index]
	var next_pos = current_grid_pos + move_dir
	
	# Zappers can ONLY move in water
	if can_swim_in(next_pos):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			if next_pos == player.current_grid_pos and player.is_alive:
				print("💀 Zapper will hit player at: ", next_pos)
				game_manager.player_hit_by_enemy()
				return
		
		target_grid_pos = next_pos
		is_moving = true
		patrol_index = (patrol_index + 1) % patrol_pattern.size()
	else:
		# Can't move, try next direction
		patrol_index = (patrol_index + 1) % patrol_pattern.size()

func can_swim_in(pos: Vector2i) -> bool:
	if not grid_manager.is_valid_grid_pos(pos) or grid_manager.has_spawner(pos) or grid_manager.has_mirror(pos) or grid_manager.has_hammer(pos):
		return false
	if grid_manager.edge_blocked(current_grid_pos, pos):
		return false
	
	var tile = grid_manager.get_tile(pos)
	# Can ONLY swim in water
	return tile == Constants.TileType.WATER

func create_placeholder_visual():
	visual = ColorRect.new()
	visual.size = Vector2(50, 50)
	visual.position = Vector2(-25, -25)
	visual.color = Color(0.2, 0.5, 0.8, 1.0)  # Deep blue
	add_child(visual)
	
	eyes = ColorRect.new()
	eyes.size = Vector2(20, 8)
	eyes.position = Vector2(-10, -5)
	eyes.color = Color(1, 1, 0, 1)  # Yellow eyes
	visual.add_child(eyes)
	
	# Fins
	var fin_top = ColorRect.new()
	fin_top.size = Vector2(10, 20)
	fin_top.position = Vector2(-5, -30)
	fin_top.color = Color(0.3, 0.6, 0.9, 1.0)
	visual.add_child(fin_top)
	
	# Water splash indicators
	var splash1 = ColorRect.new()
	splash1.size = Vector2(8, 8)
	splash1.position = Vector2(-30, 10)
	splash1.color = Color(0.6, 0.8, 1.0, 0.7)
	visual.add_child(splash1)
	
	var splash2 = ColorRect.new()
	splash2.size = Vector2(8, 8)
	splash2.position = Vector2(22, 10)
	splash2.color = Color(0.6, 0.8, 1.0, 0.7)
	visual.add_child(splash2)
