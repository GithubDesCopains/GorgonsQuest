extends SceneTree

func _init():
	call_deferred("run_levels")

func run_levels():
	var main = load("res://Scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var gm = main.get_node_or_null("GameManager")
	if not gm:
		push_error("GameManager missing")
		quit(1)
		return
	for level_number in range(1, 16):
		gm.level_manager.load_level(1, level_number)
		await create_timer(0.15).timeout
		var level_data = gm.level_manager.current_level_data
		if level_data.level_idx != level_number or gm.souls_required <= 0:
			push_error("World 1 level %d failed to build objectives" % level_number)
			quit(1)
			return
		if not gm.grid_manager.is_walkable(level_data.player_start):
			push_error("World 1 level %d starts player on non-walkable terrain" % level_number)
			quit(1)
			return
	print("✅ World 1 JSON integration: levels 1-15 loaded and built with valid player start/objectives")
	quit(0)
