extends Node2D
class_name EnemySpawner

## Enemy Spawner Hole - Respawns enemies periodically to prevent soft-locks

var grid_pos: Vector2i
var enemy_type: String = "noggle"
var patrol_pattern: Array = []
var respawn_interval: float = 5.0
var respawn_timer: float = 0.0
var active_enemy: Enemy = null

var grid_manager: GridManager
var game_manager: Node

signal enemy_spawned(enemy)

func _ready():
	create_visual()
	z_index = Constants.LAYER_GROUND + 1
	
	# Managers
	var main = SceneLookup.main_scene(self)
	if main:
		game_manager = main.get_node_or_null("GameManager")
		if game_manager:
			grid_manager = game_manager.get_node_or_null("GridManager")

func create_visual():
	# Pit / hole in the ground (Greek chasm style)
	var pit_rim = ColorRect.new()
	pit_rim.size = Vector2(48, 48)
	pit_rim.position = Vector2(-24, -24)
	pit_rim.color = Color(0.35, 0.3, 0.25, 0.9)  # Dark stone rim
	add_child(pit_rim)
	
	var pit_center = ColorRect.new()
	pit_center.size = Vector2(36, 36)
	pit_center.position = Vector2(-18, -18)
	pit_center.color = Color(0.1, 0.08, 0.08, 1.0)  # Abyss / cavern depth
	add_child(pit_center)

func initialize(pos: Vector2i, type: String = "noggle", pattern: Array = [], interval: float = 5.0):
	grid_pos = pos
	enemy_type = type
	patrol_pattern = pattern
	respawn_interval = interval
	respawn_timer = 0.0
	
	var gm = get_node_or_null("/root/Main/GameManager/GridManager")
	if gm:
		grid_manager = gm
		position = grid_manager.grid_to_world(grid_pos)
	elif grid_manager:
		position = grid_manager.grid_to_world(grid_pos)
	
	# Spawn initial enemy immediately if tile is free
	call_deferred("try_spawn")

func _process(delta):
	# A living enemy and its petrified statue remain linked to this hole. Respawn only
	# after statue/creature has actually left the scene (shattered, squashed or sunk).
	if active_enemy != null and is_instance_valid(active_enemy):
		return
	active_enemy = null
	respawn_timer += delta
	if respawn_timer >= respawn_interval and is_tile_clear():
		respawn_timer = 0.0
		try_spawn()

func is_tile_clear() -> bool:
	if not is_instance_valid(game_manager):
		return false
	
	# Check player
	if is_inside_tree():
		var tree = get_tree()
		if tree:
			var player = tree.get_first_node_in_group("player")
			if player and is_instance_valid(player):
				if player.current_grid_pos == grid_pos or player.target_grid_pos == grid_pos:
					return false
	
	# Check other enemies
	for enemy in game_manager.enemies:
		if is_instance_valid(enemy) and not enemy.is_squashed:
			if enemy.current_grid_pos == grid_pos or enemy.target_grid_pos == grid_pos:
				return false
	
	# Check stone pillars
	for pillar in game_manager.pillars:
		if is_instance_valid(pillar) and pillar.grid_pos == grid_pos:
			return false
	
	return true

func try_spawn():
	if not is_instance_valid(game_manager):
		return
	
	if not is_tile_clear():
		return
	
	# Create enemy via game manager
	var spawned = await game_manager.spawn_enemy(grid_pos, patrol_pattern, enemy_type)
	if spawned and is_instance_valid(spawned):
		active_enemy = spawned
		if not spawned.tree_exited.is_connected(_on_active_enemy_removed):
			spawned.tree_exited.connect(_on_active_enemy_removed)
		
		# Spawn emergence animation
		spawned.scale = Vector2(0.2, 0.2)
		var tween = spawned.create_tween()
		tween.tween_property(spawned, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT)
		
		enemy_spawned.emit(spawned)
		print("🌀 Spawner at ", grid_pos, " emerged enemy (", enemy_type, ")")

func _on_active_enemy_removed() -> void:
	# Queue-free/destruction removes the entity; petrification alone does not.
	# Timer pre-filled: _process respawns on the next frame (waits only while the cell is occupied).
	active_enemy = null
	respawn_timer = respawn_interval
