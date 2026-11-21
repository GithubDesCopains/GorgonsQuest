extends SceneTree

func _init():
	call_deferred("run_integration")

func run_integration():
	var main = load("res://Scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var gm = main.get_node_or_null("GameManager")
	if not gm:
		push_error("GameManager missing")
		quit(1)
		return
	gm.level_manager.load_level(4, Constants.BOSS_LEVEL)
	await create_timer(0.45).timeout
	if not is_instance_valid(gm.boss):
		push_error("Final Medusa level failed to instantiate boss")
		quit(1)
		return
	if gm.boss.get_script().resource_path != "res://Scripts/medusa_boss.gd" or gm.boss.health != 6:
		push_error("Final boss should be Medusa with six HP")
		quit(1)
		return
	if gm.boss.arena_rect != gm.boss_arena_rect or gm.level_manager.current_world != 4:
		push_error("Medusa arena or world progression is incorrectly configured")
		quit(1)
		return
	print("✅ Final arena integration: Medusa instantiated with 6 HP, arena and World 4 progression valid")
	quit(0)
