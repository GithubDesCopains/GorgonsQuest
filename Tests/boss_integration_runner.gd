extends SceneTree

func _init():
	call_deferred("run_integration")

func run_integration():
	var main_scene = load("res://Scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await process_frame
	await process_frame
	var game_manager = main_scene.get_node_or_null("GameManager")
	if not game_manager:
		push_error("GameManager missing")
		quit(1)
		return
	game_manager.level_manager.load_level(1, 16)
	await create_timer(0.5).timeout
	if not is_instance_valid(game_manager.boss):
		push_error("Boss level did not instantiate boss")
		quit(1)
		return
	if game_manager.boss.health != 3:
		push_error("Boss health not initialized from level data")
		quit(1)
		return
	if game_manager.boss.get_script().resource_path != "res://Scripts/cyclops_boss.gd":
		push_error("World 1 boss fixture should instantiate CyclopsBoss")
		quit(1)
		return
	if game_manager.find_open_boss_spawn_position(game_manager.boss.position) == Vector2i(-1, -1):
		push_error("Boss arena has no legal minion spawn position")
		quit(1)
		return
	var exit_pos = Vector2i(game_manager.boss_arena_rect.position.x + game_manager.boss_arena_rect.size.x / 2, game_manager.boss_arena_rect.end.y - 1)
	if game_manager.grid_manager.get_tile(exit_pos) != Constants.TileType.WALL:
		push_error("Boss exit should be locked until victory")
		quit(1)
		return
	# Simulate attempting to leave through the locked doorway; player returns inside.
	var player = game_manager.player
	player.previous_grid_pos = exit_pos + Vector2i.UP
	player.current_grid_pos = exit_pos
	player.target_grid_pos = exit_pos
	game_manager._on_player_moved(exit_pos)
	if not game_manager.boss_arena_rect.has_point(player.current_grid_pos):
		push_error("Player must be blocked from leaving locked arena")
		quit(1)
		return
	print("✅ Boss arena integration: boss spawned, HP initialized, minion cell available, exit locked, player contained")
	quit(0)
