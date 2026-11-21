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
	gm.level_manager.load_level(3, Constants.BOSS_LEVEL)
	await create_timer(0.4).timeout
	if not is_instance_valid(gm.boss):
		push_error("Chimera boss level did not instantiate boss")
		quit(1)
		return
	if gm.boss.get_script().resource_path != "res://Scripts/chimera_boss.gd" or gm.boss.health != 5:
		push_error("World 3 boss must instantiate ChimeraBoss with 5 HP")
		quit(1)
		return
	if gm.boss.arena_rect != gm.boss_arena_rect:
		push_error("Chimera arena bounds did not initialize")
		quit(1)
		return
	print("✅ Chimera integration: boss instantiated, 5 HP, arena bounds initialized")
	quit(0)
