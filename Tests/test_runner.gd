extends SceneTree

## Automated Regression Test Runner for Gorgon's Debt

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0

func _init():
	print("\n========================================================")
	print("  GORGON'S DEBT - AUTOMATED REGRESSION TEST RUNNER")
	print("========================================================\n")
	
	run_test("test_constants_and_grid", test_constants_and_grid)
	run_test("test_level_data_validation", test_level_data_validation)
	run_test("test_level_json_loader_valid_and_invalid", test_level_json_loader_valid_and_invalid)
	run_test("test_world_1_json_level_set", test_world_1_json_level_set)
	run_test("test_garden_levels_abc_playable_shapes", test_garden_levels_abc_playable_shapes)
	run_test("test_sound_manager_procedural_audio", test_sound_manager_procedural_audio)
	run_test("test_task_9_1_world_music_generation", test_task_9_1_world_music_generation)
	run_test("test_task_9_2_9_3_event_music_and_sfx", test_task_9_2_9_3_event_music_and_sfx)
	run_test("test_untrusted_level_and_save_data_never_crash", test_untrusted_level_and_save_data_never_crash)
	run_test("test_slide_path_calculation", test_slide_path_calculation)
	run_test("test_task_1_1_enemy_squash", test_task_1_1_enemy_squash)
	run_test("test_task_1_2_shatter_statue", test_task_1_2_shatter_statue)
	run_test("test_task_1_3_destroy_pillar", test_task_1_3_destroy_pillar)
	run_test("test_task_1_4_enemy_spawner", test_task_1_4_enemy_spawner)
	run_test("test_task_1_5_quick_retry", test_task_1_5_quick_retry)
	run_test("test_task_1_6_level_timer", test_task_1_6_level_timer)
	run_test("test_task_2_1_directional_spring", test_task_2_1_directional_spring)
	run_test("test_task_2_2_rotator_turns_sliding_block", test_task_2_2_rotator_turns_sliding_block)
	run_test("test_task_2_3_warp_pairs", test_task_2_3_warp_pairs)
	run_test("test_task_2_4_slippery_tiles", test_task_2_4_slippery_tiles)
	run_test("test_task_2_5_one_way_gates", test_task_2_5_one_way_gates)
	run_test("test_task_2_6_conveyor_belts", test_task_2_6_conveyor_belts)
	run_test("test_task_3_1_wall_hugger_patrol", test_task_3_1_wall_hugger_patrol)
	run_test("test_task_3_2_jumper_landing", test_task_3_2_jumper_landing)
	run_test("test_task_3_3_pusher_bridge_guardian", test_task_3_3_pusher_bridge_guardian)
	run_test("test_task_3_4_hades_shadow_gaze", test_task_3_4_hades_shadow_gaze)
	run_test("test_task_3_5_flame_beast", test_task_3_5_flame_beast)
	run_test("test_task_4_1_boss_system", test_task_4_1_boss_system)
	run_test("test_task_4_2_cyclops_patterns", test_task_4_2_cyclops_patterns)
	run_test("test_task_4_3_hydra_patterns", test_task_4_3_hydra_patterns)
	run_test("test_task_4_4_chimera_patterns", test_task_4_4_chimera_patterns)
	run_test("test_task_4_5_medusa_final_patterns", test_task_4_5_medusa_final_patterns)
	run_test("test_task_5_7_save_manager", test_task_5_7_save_manager)
	run_test("test_task_6_1_overworld_map_logic", test_task_6_1_overworld_map_logic)
	run_test("test_task_6_2_progressive_unlock", test_task_6_2_progressive_unlock)
	run_test("test_task_7_1_title_screen_logic", test_task_7_1_title_screen_logic)
	run_test("test_task_7_2_pause_menu_logic", test_task_7_2_pause_menu_logic)
	run_test("test_task_7_3_options_menu_logic", test_task_7_3_options_menu_logic)
	run_test("test_task_7_4_gamepad_input_and_feedback", test_task_7_4_gamepad_input_and_feedback)
	run_test("test_task_7_5_level_clear_score_summary", test_task_7_5_level_clear_score_summary)
	run_test("test_task_8_1_side_margin_art", test_task_8_1_side_margin_art)
	run_test("test_task_8_2_procedural_hero_visual", test_task_8_2_procedural_hero_visual)
	run_test("test_common_marble_petrification", test_common_marble_petrification)
	run_test("test_enemy_species_procedural_art", test_enemy_species_procedural_art)
	run_test("test_task_8_4_procedural_tiles", test_task_8_4_procedural_tiles)
	run_test("test_task_8_5_vfx_lifetimes_and_spawn", test_task_8_5_vfx_lifetimes_and_spawn)
	run_test("test_player_shoots_while_moving_and_adjacent_break", test_player_shoots_while_moving_and_adjacent_break)
	run_test("test_statue_timer_and_spawner_lifetime", test_statue_timer_and_spawner_lifetime)
	run_test("test_enemy_grid_centering_and_menu_text_metrics", test_enemy_grid_centering_and_menu_text_metrics)
	run_test("test_level_checker_warnings", test_level_checker_warnings)
	run_test("test_level_editor_undo_erase_and_test_session", test_level_editor_undo_erase_and_test_session)
	run_test("test_editor_test_session_routing", test_editor_test_session_routing)
	run_test("test_noggle_straight_line_and_turn", test_noggle_straight_line_and_turn)
	run_test("test_spawner_respawns_instantly_after_destruction", test_spawner_respawns_instantly_after_destruction)
	run_test("test_enemies_never_share_a_cell", test_enemies_never_share_a_cell)
	run_test("test_hero_walk_sheets_pick_direction_and_frame", test_hero_walk_sheets_pick_direction_and_frame)
	run_test("test_hero_turns_in_place_on_a_tap", test_hero_turns_in_place_on_a_tap)
	run_test("test_statue_never_shares_a_cell_with_the_hero", test_statue_never_shares_a_cell_with_the_hero)
	run_test("test_hero_fires_one_laser_at_a_time", test_hero_fires_one_laser_at_a_time)
	run_test("test_laser_beam_grows_then_trails", test_laser_beam_grows_then_trails)
	run_test("test_petrified_mid_move_snaps_to_one_cell", test_petrified_mid_move_snaps_to_one_cell)
	run_test("test_pause_menu_world_map_survives_scene_change", test_pause_menu_world_map_survives_scene_change)
	run_test("test_spawner_is_solid_like_a_wall", test_spawner_is_solid_like_a_wall)
	run_test("test_world_1_proposals_are_valid", test_world_1_proposals_are_valid)
	run_test("test_editor_springs_can_be_oriented", test_editor_springs_can_be_oriented)
	run_test("test_editor_places_mirrors_switches_and_doors", test_editor_places_mirrors_switches_and_doors)
	run_test("test_mirrors_reflect_and_block", test_mirrors_reflect_and_block)
	run_test("test_laser_bends_on_mirrors_and_can_kill_the_hero", test_laser_bends_on_mirrors_and_can_kill_the_hero)
	run_test("test_doors_block_edges_and_switches_open_them", test_doors_block_edges_and_switches_open_them)
	run_test("test_mirrors_switches_and_doors_load_from_json_and_checker_pairs_them", test_mirrors_switches_and_doors_load_from_json_and_checker_pairs_them)

	run_test("test_hole_and_hero_only_tiles", test_hole_and_hero_only_tiles)
	run_test("test_push_block_slide_and_sink", test_push_block_slide_and_sink)
	run_test("test_bonus_items_and_gorgon_orb", test_bonus_items_and_gorgon_orb)
	run_test("test_new_tiles_json_round_trip", test_new_tiles_json_round_trip)
	
	print("\n--------------------------------------------------------")
	print("TEST RESULTS: %d/%d passed (%d failed)" % [tests_passed, tests_run, tests_failed])
	print("--------------------------------------------------------\n")
	
	if tests_failed > 0:
		print("âŒ TEST SUITE FAILED!")
		quit(1)
	else:
		print("âœ… ALL REGRESSION TESTS PASSED CLEANLY!")
		quit(0)

func run_test(test_name: String, test_callable: Callable):
	tests_run += 1
	print("â–¶ RUNNING: %s..." % test_name)
	var err_msg = test_callable.call()
	if err_msg == null or err_msg == "":
		tests_passed += 1
		print("  âœ” PASSED: %s" % test_name)
	else:
		tests_failed += 1
		print("  âœ– FAILED: %s -> %s" % [test_name, err_msg])

func test_constants_and_grid():
	if Constants.GRID_COLS != 16 or Constants.GRID_ROWS != 15:
		return "Grid dimensions incorrect"
	if Constants.TILE_SIZE != 72 or Constants.PLAYFIELD_OFFSET_X != 384:
		return "Constants offset incorrect"
	
	var gm = GridManager.new()
	gm.initialize_grid()
	
	var world_0_0 = gm.grid_to_world(Vector2i(0, 0))
	if world_0_0 != Vector2(420, 36):
		gm.free()
		return "grid_to_world(0,0) expected (420, 36), got %s" % str(world_0_0)
	
	var back_grid_0_0 = gm.world_to_grid(world_0_0)
	if back_grid_0_0 != Vector2i(0, 0):
		gm.free()
		return "world_to_grid(%s) expected (0,0), got %s" % [str(world_0_0), str(back_grid_0_0)]
	
	if not gm.is_valid_grid_pos(Vector2i(0, 0)) or not gm.is_valid_grid_pos(Vector2i(15, 14)):
		gm.free()
		return "Valid grid coordinates rejected"
	if gm.is_valid_grid_pos(Vector2i(-1, 0)) or gm.is_valid_grid_pos(Vector2i(16, 0)):
		gm.free()
		return "Invalid coordinates accepted"
	
	gm.set_tile(Vector2i(2, 2), Constants.TileType.GROUND)
	if not gm.is_walkable(Vector2i(2, 2)):
		gm.free()
		return "Ground tile should be walkable"
	
	gm.set_tile(Vector2i(2, 2), Constants.TileType.WALL)
	if gm.is_walkable(Vector2i(2, 2)):
		gm.free()
		return "Wall tile should not be walkable"
	gm.set_tile(Vector2i(2, 2), Constants.TileType.WATER)
	if gm.is_walkable(Vector2i(2, 2)):
		gm.free()
		return "Water should be impassable without bridge"
	gm.set_tile(Vector2i(2, 2), Constants.TileType.STONE_BLOCK)
	if gm.is_walkable(Vector2i(2, 2)):
		gm.free()
		return "Stone block should be impassable"
	gm.set_tile(Vector2i(2, 2), Constants.TileType.ICE)
	if not gm.is_walkable(Vector2i(2, 2)):
		gm.free()
		return "Ice bridge should be walkable"
	
	gm.free()
	return ""

func test_level_data_validation():
	var levels = [
		LevelData.create_test_level(),
		LevelData.create_level_1_2(),
		LevelData.create_level_1_3()
	]
	
	for lvl in levels:
		if lvl.grid_layout.size() != 15 or lvl.grid_layout[0].size() != 16:
			return "Level %s grid layout size invalid" % lvl.level_name
		if lvl.soul_urns.is_empty():
			return "Level %s has no urns" % lvl.level_name
		if lvl.enemies.is_empty():
			return "Level %s has no enemies" % lvl.level_name
	return ""

func test_sound_manager_procedural_audio():
	var sm = SoundManager.new()
	var tone = sm.generate_tone(440, 220, 0.05, "square")
	if tone == null or tone.data.is_empty():
		sm.free()
		return "Failed to generate square tone"
	sm.free()
	return ""

func test_task_9_1_world_music_generation() -> String:
	var sm = SoundManager.new()
	var streams: Array[AudioStreamWAV] = []
	for world in range(1, 5):
		var stream: AudioStreamWAV = sm.generate_world_music(world)
		if stream == null or stream.data.is_empty():
			sm.free()
			return "World %d theme should produce non-empty WAV data" % world
		if stream.loop_mode != AudioStreamWAV.LOOP_FORWARD or stream.mix_rate != 22050:
			sm.free()
			return "World %d theme should be looping 22.05 kHz audio" % world
		streams.append(stream)
	for i in range(streams.size()):
		for j in range(i + 1, streams.size()):
			if streams[i].data == streams[j].data:
				sm.free()
				return "Each world must have a distinct original musical theme"
	if SoundManager.MUSIC_WORLD_PROFILES.size() != 4 or SoundManager.MUSIC_MELODIES.size() != 4:
		sm.free()
		return "Music profiles and original motifs must cover four worlds"
	sm.free()
	return ""

func test_task_9_2_9_3_event_music_and_sfx() -> String:
	var sm = SoundManager.new()
	var seen: Array[PackedByteArray] = []
	for sfx_name in SoundManager.SFX_NAMES:
		var stream: AudioStreamWAV = sm.generate_sfx(sfx_name)
		if stream == null or stream.data.size() < 1000:
			sm.free()
			return "Sound '%s' should produce real 16-bit audio data" % sfx_name
		if stream.format != AudioStreamWAV.FORMAT_16_BITS:
			sm.free()
			return "Sound '%s' should be 16-bit" % sfx_name
		if (sfx_name == "boss_theme") != (stream.loop_mode == AudioStreamWAV.LOOP_FORWARD):
			sm.free()
			return "Only the boss theme should loop (got wrong loop mode for '%s')" % sfx_name
		for other in seen:
			if other == stream.data:
				sm.free()
				return "Every sound must be distinct ('%s' duplicates another)" % sfx_name
		seen.append(stream.data)
	if sm.generate_sfx("final_fanfare").data.size() <= sm.generate_sfx("level_fanfare").data.size():
		sm.free()
		return "The final victory fanfare must be longer than the level fanfare"
	if sm.generate_sfx("gaze").data != sm.generate_sfx("gaze").data:
		sm.free()
		return "Sounds must be deterministic"
	if sm.generate_sfx("unknown") != null:
		sm.free()
		return "Unknown sound names must return null"
	# Boss music is a no-op while music is globally disabled, and never leaves a stale flag.
	sm.play_boss_music()
	if sm.boss_music_active and not SoundManager.MUSIC_ENABLED:
		sm.free()
		return "Boss music must not activate while MUSIC_ENABLED is false"
	sm.free()
	return ""

func test_untrusted_level_and_save_data_never_crash() -> String:
	"""Hand-edited level and save files must be rejected or clamped, never raise a script error."""
	var loader := LevelJsonLoader.new()
	var base: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Data/Levels/world_1_level_1.json"))
	var bad_levels := {
		"spawner interval as dict": func(d): d["spawners"][0]["interval"] = {},
		"spawner interval zero": func(d): d["spawners"][0]["interval"] = 0,
		"spawner interval string": func(d): d["spawners"][0]["interval"] = "x",
		"spawner pattern string": func(d): d["spawners"][0]["pattern"] = "right",
		"spawner pattern nested": func(d): d["spawners"][0]["pattern"] = [[], {}],
		"spawner type array": func(d): d["spawners"][0]["type"] = [],
		"rotator turns dict": func(d): d["rotators"] = [{"pos": [3, 9], "quarter_turns": {}}],
		"time limit string": func(d): d["time_limit"] = "abc",
		"time limit dict": func(d): d["time_limit"] = {},
		"boss name dict": func(d): d["boss"] = {"health": 3, "name": {}},
		"boss spawn interval dict": func(d): d["boss"] = {"health": 3, "spawn_interval": {}},
		"boss health huge": func(d): d["boss"] = {"health": 1e18},
		"switch id dict": func(d): d["switches"] = [{"pos": [3, 9], "id": {}}],
		"name too long": func(d): d["name"] = "x".repeat(5000),
	}
	for case_name in bad_levels:
		var doc: Dictionary = base.duplicate(true)
		bad_levels[case_name].call(doc)
		if loader.parse_text(JSON.stringify(doc)).get("ok", true):
			return "Malformed level must be rejected: %s" % case_name
	# Extreme but well-typed values are accepted and clamped to safe ranges.
	var clamped: Dictionary = base.duplicate(true)
	clamped["time_limit"] = 1e9
	clamped["spawners"][0]["interval"] = 0.0001
	clamped["rotators"] = [{"pos": [3, 9], "quarter_turns": -7}]
	var result: Dictionary = loader.parse_text(JSON.stringify(clamped))
	if not result.get("ok", false):
		return "Extreme but well-typed level should load: %s" % result.get("error", "")
	var data: LevelData = result["data"]
	if data.time_limit != LevelJsonLoader.MAX_TIME_LIMIT:
		return "time_limit must be clamped to %d, got %d" % [LevelJsonLoader.MAX_TIME_LIMIT, data.time_limit]
	if data.spawners[0]["interval"] < LevelJsonLoader.MIN_SPAWN_INTERVAL:
		return "Spawner interval must be clamped to the minimum"
	if data.rotators[0]["quarter_turns"] != -1:
		return "Rotator direction must stay counter-clockwise (-1), got %d" % data.rotators[0]["quarter_turns"]
	# Save files: wrong types, NaN-like and absurd numbers fall back or clamp.
	var sm = load("res://Scripts/save_manager.gd").new()
	var tampered: Dictionary = sm._validated_data({"version": 1, "max_world": [], "max_level_w1": "abc", "total_score": 1e30, "best_1_1": {}, "best_1_2": 5, "music_volume": [], "sfx_volume": 9.0, "timestamp": {}})
	var failure := ""
	if tampered["max_world"] != 1 or tampered["max_level_w1"] != 1:
		failure = "Wrongly typed progress must fall back to defaults"
	elif tampered["total_score"] != sm.MAX_SCORE:
		failure = "Absurd score must clamp to the maximum"
	elif tampered["best_1_1"] != 0 or tampered["best_1_2"] != 5:
		failure = "Best scores must be sanitised per key"
	elif tampered["music_volume"] != 1.0 or tampered["sfx_volume"] != 1.0:
		failure = "Volumes must fall back or clamp to 0..1"
	sm.free()
	return failure

func test_slide_path_calculation():
	var gm = GridManager.new()
	gm.initialize_grid()
	
	for x in range(16):
		gm.set_tile(Vector2i(x, 5), Constants.TileType.GROUND)
	gm.set_tile(Vector2i(7, 5), Constants.TileType.WALL)
	
	var current_pos = Vector2i(2, 5)
	var direction = Vector2i.RIGHT
	var next_pos = current_pos + direction
	var final_pos = current_pos
	
	while gm.is_valid_grid_pos(next_pos):
		var tile = gm.get_tile(next_pos)
		if tile == Constants.TileType.WALL:
			break
		final_pos = next_pos
		next_pos = final_pos + direction
	
	if final_pos != Vector2i(6, 5):
		gm.free()
		return "Expected slide to stop at (6, 5), stopped at %s" % str(final_pos)
	
	gm.set_tile(Vector2i(6, 5), Constants.TileType.WATER)
	current_pos = Vector2i(2, 5)
	next_pos = current_pos + direction
	final_pos = current_pos
	while gm.is_valid_grid_pos(next_pos):
		var tile = gm.get_tile(next_pos)
		if tile == Constants.TileType.WALL:
			break
		if tile == Constants.TileType.WATER:
			final_pos = next_pos
			break
		final_pos = next_pos
		next_pos = final_pos + direction
	
	if final_pos != Vector2i(6, 5):
		gm.free()
		return "Expected slide to enter water at (6, 5), got %s" % str(final_pos)
	
	gm.free()
	return ""

func test_task_1_1_enemy_squash():
	var gm = GridManager.new()
	gm.initialize_grid()
	
	var game_mgr = Node.new()
	game_mgr.set_script(load("res://Scripts/game_manager.gd"))
	game_mgr.grid_manager = gm
	
	var enemy_a = Enemy.new()
	enemy_a.grid_manager = gm
	enemy_a.game_manager = game_mgr
	enemy_a.current_grid_pos = Vector2i(4, 7)
	enemy_a.position = gm.grid_to_world(Vector2i(4, 7))
	enemy_a.petrified = true
	enemy_a.initialized = true
	
	var enemy_b = Enemy.new()
	enemy_b.grid_manager = gm
	enemy_b.game_manager = game_mgr
	enemy_b.current_grid_pos = Vector2i(6, 7)
	enemy_b.position = gm.grid_to_world(Vector2i(6, 7))
	enemy_b.petrified = false
	enemy_b.initialized = true
	
	game_mgr.enemies.append(enemy_a)
	game_mgr.enemies.append(enemy_b)
	
	if enemy_b.is_squashed:
		return "Enemy B should not be squashed initially"
	
	var start_score = game_mgr.score
	
	# Simulate block A moving over Enemy B
	enemy_a.is_sliding = true
	enemy_a.position = enemy_b.position
	enemy_a.check_squash_enemies()
	
	if not enemy_b.is_squashed:
		return "Enemy B was not squashed when sliding block hit it"
	
	if game_mgr.score != start_score + 200:
		return "Score should increase by 200 upon squash (got %d)" % game_mgr.score
	
	if enemy_b in game_mgr.enemies:
		return "Squashed enemy should be removed from game_mgr.enemies"
	
	enemy_a.free()
	enemy_b.free()
	game_mgr.free()
	gm.free()
	return ""

func test_task_1_2_shatter_statue():
	var gm = GridManager.new()
	gm.initialize_grid()
	
	var game_mgr = Node.new()
	game_mgr.set_script(load("res://Scripts/game_manager.gd"))
	game_mgr.grid_manager = gm
	
	var enemy = Enemy.new()
	enemy.grid_manager = gm
	enemy.game_manager = game_mgr
	enemy.current_grid_pos = Vector2i(5, 5)
	enemy.position = gm.grid_to_world(Vector2i(5, 5))
	enemy.initialized = true
	game_mgr.enemies.append(enemy)
	
	# First hit: should petrify
	game_mgr._on_projectile_hit_enemy(enemy)
	if not enemy.petrified:
		enemy.free()
		game_mgr.free()
		gm.free()
		return "Enemy was not petrified on first hit"
	
	if enemy.is_squashed:
		enemy.free()
		game_mgr.free()
		gm.free()
		return "Enemy should not be shattered on first hit"
	
	# Track shatter signal
	var fired = [false]
	game_mgr.enemy_shattered.connect(func(_e): fired[0] = true)
	
	# Second hit: should shatter
	game_mgr._on_projectile_hit_enemy(enemy)
	if not enemy.is_squashed:
		enemy.free()
		game_mgr.free()
		gm.free()
		return "Enemy was not shattered on second hit"
	
	if not fired[0]:
		enemy.free()
		game_mgr.free()
		gm.free()
		return "enemy_shattered signal was not emitted"
	
	if enemy in game_mgr.enemies:
		enemy.free()
		game_mgr.free()
		gm.free()
		return "Shattered enemy should be removed from game_mgr.enemies"
	
	enemy.free()
	game_mgr.free()
	gm.free()
	return ""

func test_task_1_3_destroy_pillar():
	var gm = GridManager.new()
	gm.initialize_grid()
	
	var game_mgr = Node.new()
	game_mgr.set_script(load("res://Scripts/game_manager.gd"))
	game_mgr.grid_manager = gm
	
	# Initial tile at (3, 3) is GROUND
	gm.set_tile(Vector2i(3, 3), Constants.TileType.GROUND)
	
	# Create pillar at (3, 3)
	var pillar = Node2D.new()
	pillar.set_script(load("res://Scenes/stone_pillar.gd"))
	pillar.grid_pos = Vector2i(3, 3)
	game_mgr.pillars.append(pillar)
	gm.set_tile(Vector2i(3, 3), Constants.TileType.STONE_BLOCK)
	
	if gm.get_tile(Vector2i(3, 3)) != Constants.TileType.STONE_BLOCK:
		pillar.free()
		game_mgr.free()
		gm.free()
		return "Tile at (3, 3) should be STONE_BLOCK"
	
	# Track destroyed signal
	var destroyed_pos = [Vector2i.ZERO]
	game_mgr.pillar_destroyed.connect(func(pos): destroyed_pos[0] = pos)
	
	# Hit pillar with projectile at (3, 3)
	game_mgr._on_projectile_hit_wall(Vector2i(3, 3))
	
	if destroyed_pos[0] != Vector2i(3, 3):
		pillar.free()
		game_mgr.free()
		gm.free()
		return "pillar_destroyed signal not emitted with correct pos"
	
	if gm.get_tile(Vector2i(3, 3)) != Constants.TileType.GROUND:
		pillar.free()
		game_mgr.free()
		gm.free()
		return "Tile at (3, 3) should revert back to GROUND after pillar destruction"
	
	if game_mgr.pillars.size() != 0:
		pillar.free()
		game_mgr.free()
		gm.free()
		return "Pillars array should be empty after destruction"
	
	pillar.free()
	game_mgr.free()
	gm.free()
	return ""
func test_task_1_4_enemy_spawner():
	var gm = GridManager.new()
	gm.initialize_grid()
	
	var game_mgr = Node.new()
	game_mgr.set_script(load("res://Scripts/game_manager.gd"))
	game_mgr.grid_manager = gm
	
	var spawner = preload("res://Scenes/enemy_spawner.gd").new()
	spawner.grid_manager = gm
	spawner.game_manager = game_mgr
	spawner.grid_pos = Vector2i(5, 5)
	spawner.respawn_interval = 2.0
	
	if not spawner.is_tile_clear():
		spawner.free()
		game_mgr.free()
		gm.free()
		return "Tile (5, 5) should be clear initially"
	
	# Block with a pillar at (5, 5)
	var pillar = Node2D.new()
	pillar.set_script(load("res://Scenes/stone_pillar.gd"))
	pillar.grid_pos = Vector2i(5, 5)
	game_mgr.pillars.append(pillar)
	
	if spawner.is_tile_clear():
		pillar.free()
		spawner.free()
		game_mgr.free()
		gm.free()
		return "Tile (5, 5) with a pillar should NOT be clear"
	
	# Remove pillar
	game_mgr.pillars.clear()
	pillar.free()
	
	if not spawner.is_tile_clear():
		spawner.free()
		game_mgr.free()
		gm.free()
		return "Tile (5, 5) should be clear after removing pillar"
	
	# Block with an enemy at (5, 5)
	var blocker = Enemy.new()
	blocker.current_grid_pos = Vector2i(5, 5)
	blocker.target_grid_pos = Vector2i(5, 5)
	game_mgr.enemies.append(blocker)
	
	if spawner.is_tile_clear():
		blocker.free()
		spawner.free()
		game_mgr.free()
		gm.free()
		return "Tile (5, 5) with an enemy should NOT be clear"
	
	# If enemy is squashed, it should no longer block
	blocker.is_squashed = true
	if not spawner.is_tile_clear():
		blocker.free()
		spawner.free()
		game_mgr.free()
		gm.free()
		return "Tile with a squashed enemy should be considered clear"
	
	blocker.free()
	spawner.free()
	game_mgr.free()
	gm.free()
	return ""
func test_task_1_5_quick_retry():
	var gm = GridManager.new()
	gm.initialize_grid()
	
	var game_mgr = Node.new()
	game_mgr.set_script(load("res://Scripts/game_manager.gd"))
	game_mgr.grid_manager = gm
	game_mgr.current_lives = 3
	game_mgr.respawn_delay = 0.0
	
	var lives_notified = [0]
	game_mgr.lives_changed.connect(func(l): lives_notified[0] = l)
	
	# Execute quick retry
	game_mgr.quick_retry_level()
	
	if game_mgr.current_lives != 2:
		game_mgr.free()
		gm.free()
		return "Expected lives = 2 after quick retry, got %d" % game_mgr.current_lives
	
	if lives_notified[0] != 2:
		game_mgr.free()
		gm.free()
		return "lives_changed not emitted with 2"
	
	# Retry down to game over
	var game_over_fired = [false]
	game_mgr.game_over.connect(func(): game_over_fired[0] = true)
	
	game_mgr.is_player_dead = false
	game_mgr.quick_retry_level() # lives -> 1
	game_mgr.is_player_dead = false
	game_mgr.quick_retry_level() # lives -> 0 -> Game Over
	
	if game_mgr.current_lives != 0:
		game_mgr.free()
		gm.free()
		return "Expected lives = 0 after exhausting lives"
	
	if not game_over_fired[0]:
		game_mgr.free()
		gm.free()
		return "game_over signal not emitted when lives reached 0"
	
	game_mgr.free()
	gm.free()
	return ""

func test_task_1_6_level_timer():
	var gm = GridManager.new()
	gm.initialize_grid()
	
	var game_mgr = Node.new()
	game_mgr.set_script(load("res://Scripts/game_manager.gd"))
	game_mgr.grid_manager = gm
	game_mgr.time_limit = 90
	game_mgr.time_remaining = 90.0
	game_mgr.is_timer_active = true
	game_mgr.score = 0
	
	var time_signals = []
	game_mgr.time_changed.connect(func(t): time_signals.append(t))
	
	# Simulate 1 second
	game_mgr._process(1.0)
	if int(ceil(game_mgr.time_remaining)) != 89:
		game_mgr.free()
		gm.free()
		return "Expected time_remaining to be 89 after 1.0s, got %f" % game_mgr.time_remaining
	
	if time_signals.is_empty() or time_signals[-1] != 89:
		game_mgr.free()
		gm.free()
		return "time_changed signal not emitted with 89"
	
	# Test score bonus on completion with 80 seconds left
	game_mgr.time_remaining = 80.0
	game_mgr.souls_collected = 5
	game_mgr.souls_required = 5
	# Mock victory screen to avoid UI instantiation errors without tree
	game_mgr.victory_screen_scene = PackedScene.new()
	
	var start_score = game_mgr.score
	# Expected bonus: 5000 + (80 * 20) = 6600
	var expected_bonus = 5000 + (80 * 20)
	
	game_mgr.is_timer_active = false
	game_mgr.add_score(expected_bonus)
	if game_mgr.score != start_score + expected_bonus:
		game_mgr.free()
		gm.free()
		return "Expected score to increase by %d, got %d" % [expected_bonus, game_mgr.score - start_score]
	
	# Test time out
	var timeout_fired = [false]
	game_mgr.time_out.connect(func(): timeout_fired[0] = true)
	game_mgr.is_timer_active = true
	game_mgr.time_remaining = 0.5
	game_mgr._process(1.0)
	
	if not timeout_fired[0]:
		game_mgr.free()
		gm.free()
		return "time_out signal not emitted when time expired"
	
	if game_mgr.is_timer_active:
		game_mgr.free()
		gm.free()
		return "Timer should be deactivated on timeout"
	
	game_mgr.free()
	gm.free()
	return ""






func test_task_2_1_directional_spring():
	var gm = GridManager.new()
	gm.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			gm.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	# Store spring tile and its cardinal direction.
	var spring_pos = Vector2i(4, 4)
	gm.set_tile(spring_pos, Constants.TileType.SPRING)
	gm.set_spring_direction(spring_pos, Vector2i.RIGHT)
	if gm.get_tile(spring_pos) != Constants.TileType.SPRING:
		gm.free()
		return "Spring tile type not stored in grid"
	if gm.get_spring_direction(spring_pos) != Vector2i.RIGHT:
		gm.free()
		return "Spring direction metadata should be RIGHT"
	
	# Reject diagonal direction without changing stored direction.
	gm.set_spring_direction(spring_pos, Vector2i(1, 1))
	if gm.get_spring_direction(spring_pos) != Vector2i.RIGHT:
		gm.free()
		return "Diagonal spring direction should be rejected"
	
	# Player gets launched one cell if destination is walkable.
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = gm
	player.current_grid_pos = spring_pos
	player.is_alive = true
	if not player.launch_from_spring(Vector2i.RIGHT):
		player.free()
		gm.free()
		return "Player should launch right from spring"
	if player.target_grid_pos != Vector2i(5, 4):
		player.free()
		gm.free()
		return "Player launch target expected (5,4), got %s" % str(player.target_grid_pos)
	
	# Blocked landing tile prevents launch.
	gm.set_tile(Vector2i(5, 4), Constants.TileType.WALL)
	player.current_grid_pos = spring_pos
	player.is_moving = false
	if player.launch_from_spring(Vector2i.RIGHT):
		player.free()
		gm.free()
		return "Player should not launch into wall"
	
	gm.initialize_grid()
	if gm.get_spring_direction(spring_pos) != Vector2i.ZERO:
		player.free()
		gm.free()
		return "Grid reset should clear spring metadata"
	
	player.free()
	gm.free()
	return ""

func test_task_2_2_rotator_turns_sliding_block():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	# Slide right into clockwise rotator: should continue downward, stop on wall.
	var rotator_pos = Vector2i(5, 4)
	grid.set_tile(rotator_pos, Constants.TileType.ROTATOR)
	grid.set_rotator_turn(rotator_pos, 1)
	grid.set_tile(Vector2i(5, 8), Constants.TileType.WALL)
	
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = grid
	var result = player.calculate_slide_path_on_ground(Vector2i(2, 4), Vector2i.RIGHT)
	if result != Vector2i(5, 7):
		player.free()
		grid.free()
		return "Clockwise rotator should direct block to (5,7), got %s" % str(result)
	if player.last_slide_direction != Vector2i.DOWN:
		player.free()
		grid.free()
		return "Expected final slide direction DOWN, got %s" % str(player.last_slide_direction)
	
	# Counter-clockwise rotator sends right-moving block upward.
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	rotator_pos = Vector2i(5, 4)
	grid.set_tile(rotator_pos, Constants.TileType.ROTATOR)
	grid.set_rotator_turn(rotator_pos, -1)
	grid.set_tile(Vector2i(5, 0), Constants.TileType.WALL)
	result = player.calculate_slide_path_on_ground(Vector2i(2, 4), Vector2i.RIGHT)
	if result != Vector2i(5, 1):
		player.free()
		grid.free()
		return "Counter-clockwise rotator should direct block to (5,1), got %s" % str(result)
	if player.last_slide_direction != Vector2i.UP:
		player.free()
		grid.free()
		return "Expected final slide direction UP, got %s" % str(player.last_slide_direction)
	
	# An unconfigured rotator is treated as an obstacle, not traversed.
	grid.rotator_turns.erase(rotator_pos)
	result = player.calculate_slide_path_on_ground(Vector2i(2, 4), Vector2i.RIGHT)
	if result != Vector2i(4, 4):
		player.free()
		grid.free()
		return "Invalid rotator config should stop at (4,4), got %s" % str(result)
	
	player.free()
	grid.free()
	return ""


func test_task_2_3_warp_pairs():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	var endpoint_a = Vector2i(3, 3)
	var endpoint_b = Vector2i(12, 9)
	if not grid.register_warp_endpoint("A", endpoint_a):
		grid.free()
		return "First warp endpoint registration failed"
	if grid.get_warp_destination(endpoint_a) != Vector2i(-1, -1):
		grid.free()
		return "Single endpoint must not teleport without its pair"
	if not grid.register_warp_endpoint("A", endpoint_b):
		grid.free()
		return "Second warp endpoint registration failed"
	if grid.get_warp_destination(endpoint_a) != endpoint_b or grid.get_warp_destination(endpoint_b) != endpoint_a:
		grid.free()
		return "Warp endpoints should resolve each other"
	
	# Pair accepts only two unique endpoints; no endpoint can be reused.
	if grid.register_warp_endpoint("A", Vector2i(6, 6)):
		grid.free()
		return "A third endpoint must be rejected"
	if grid.register_warp_endpoint("B", endpoint_a):
		grid.free()
		return "An endpoint cannot belong to two pairs"
	if grid.register_warp_endpoint("", Vector2i(6, 6)):
		grid.free()
		return "Empty pair ID must be rejected"
	
	# Slide right into endpoint A, warp to B, then continue right until a wall.
	grid.set_tile(endpoint_a, Constants.TileType.WARP)
	grid.set_tile(endpoint_b, Constants.TileType.WARP)
	for x in range(16):
		grid.set_tile(Vector2i(x, 3), Constants.TileType.GROUND)
		grid.set_tile(Vector2i(x, 9), Constants.TileType.GROUND)
	grid.set_tile(endpoint_a, Constants.TileType.WARP)
	grid.set_tile(endpoint_b, Constants.TileType.WARP)
	grid.set_tile(Vector2i(15, 9), Constants.TileType.WALL)
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = grid
	var slide_end = player.calculate_slide_path_on_ground(Vector2i(1, 3), Vector2i.RIGHT)
	if slide_end != Vector2i(14, 9):
		player.free()
		grid.free()
		return "Block should warp to (12,9), continue right to (14,9); got %s" % str(slide_end)
	
	# Reset clears endpoint metadata.
	grid.initialize_grid()
	if grid.get_warp_destination(endpoint_a) != Vector2i(-1, -1):
		player.free()
		grid.free()
		return "Grid reset should clear warp-pair metadata"
	
	player.free()
	grid.free()

func test_task_2_4_slippery_tiles():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	# Sliding starts after entering slippery terrain and retains entry direction.
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = grid
	player.current_grid_pos = Vector2i(1, 3)
	player.target_grid_pos = Vector2i(2, 3)
	player.position = grid.grid_to_world(player.target_grid_pos)
	grid.set_tile(Vector2i(2, 3), Constants.TileType.SLIPPERY)
	player.move_towards_target(0.01)
	if player.forced_move_direction != Vector2i.RIGHT:
		player.free()
		grid.free()
		return "Entering slippery tile should force continued RIGHT movement"
	
	# Forced step ignores requested steering and advances one tile straight.
	if not player.try_forced_slide_step():
		player.free()
		grid.free()
		return "Forced slide should move to next ground tile"
	if player.target_grid_pos != Vector2i(3, 3):
		player.free()
		grid.free()
		return "Forced slide expected target (3,3), got %s" % str(player.target_grid_pos)
	
	# An obstacle stops the slide without changing the current tile.
	player.current_grid_pos = Vector2i(3, 3)
	player.target_grid_pos = player.current_grid_pos
	player.is_moving = false
	grid.set_tile(Vector2i(4, 3), Constants.TileType.WALL)
	if player.try_forced_slide_step():
		player.free()
		grid.free()
		return "Forced slide should stop at wall"
	if player.forced_move_direction != Vector2i.ZERO:
		player.free()
		grid.free()
		return "Blocked forced slide should clear forced direction"
	
	# Normal ground entry does not retain forced movement.
	player.current_grid_pos = Vector2i(1, 4)
	player.target_grid_pos = Vector2i(2, 4)
	player.position = grid.grid_to_world(player.target_grid_pos)
	grid.set_tile(Vector2i(2, 4), Constants.TileType.GROUND)
	player.move_towards_target(0.01)
	if player.forced_move_direction != Vector2i.ZERO:
		player.free()
		grid.free()
		return "Normal ground tile must not force continued movement"
	
	player.free()
	grid.free()
	return ""

	return ""

func test_task_2_6_conveyor_belts():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	var belt_pos = Vector2i(4, 4)
	grid.set_tile(belt_pos, Constants.TileType.CONVEYOR)
	if not grid.set_conveyor_direction(belt_pos, Vector2i.RIGHT):
		grid.free()
		return "Valid conveyor direction RIGHT should be accepted"
	if grid.get_conveyor_direction(belt_pos) != Vector2i.RIGHT:
		grid.free()
		return "Stored conveyor direction should be RIGHT"
	if grid.set_conveyor_direction(belt_pos, Vector2i(1, 1)):
		grid.free()
		return "Diagonal conveyor direction must be rejected"
	
	# Enter conveyor from side; when standing on it, only belt direction is allowed.
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = grid
	player.current_grid_pos = Vector2i(3, 4)
	if not player.try_move(Vector2i.RIGHT) or player.target_grid_pos != belt_pos:
		player.free()
		grid.free()
		return "Player should be able to enter conveyor from side"
	player.current_grid_pos = belt_pos
	player.target_grid_pos = belt_pos
	player.is_moving = false
	if player.try_move(Vector2i.UP):
		player.free()
		grid.free()
		return "Player should not steer against conveyor direction"
	if not player.try_move(Vector2i.RIGHT) or player.target_grid_pos != Vector2i(5, 4):
		player.free()
		grid.free()
		return "Player should move along conveyor direction"
	
	# Sliding statue is carried by belt direction and records movement path.
	grid.set_tile(belt_pos, Constants.TileType.GROUND)
	grid.set_tile(Vector2i(5, 4), Constants.TileType.GROUND)
	grid.set_tile(Vector2i(6, 4), Constants.TileType.CONVEYOR)
	grid.set_conveyor_direction(Vector2i(6, 4), Vector2i.DOWN)
	grid.set_tile(Vector2i(6, 7), Constants.TileType.WALL)
	var slide_end = player.calculate_slide_path_on_ground(Vector2i(4, 4), Vector2i.RIGHT)
	if slide_end != Vector2i(6, 6):
		player.free()
		grid.free()
		return "Sliding block should follow conveyor DOWN to (6,6), got %s" % str(slide_end)
	if player.last_slide_direction != Vector2i.DOWN:
		player.free()
		grid.free()
		return "Block leaving conveyor should continue DOWN"
	
	# Clear metadata when grid resets.
	grid.initialize_grid()
	if grid.get_conveyor_direction(belt_pos) != Vector2i.ZERO:
		player.free()
		grid.free()
		return "Grid reset must clear conveyor metadata"
	
	player.free()
	grid.free()
	return ""



func test_task_2_5_one_way_gates():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	var gate_pos = Vector2i(5, 5)
	grid.set_tile(gate_pos, Constants.TileType.ONE_WAY)
	if not grid.set_one_way_direction(gate_pos, Vector2i.RIGHT):
		grid.free()
		return "Valid RIGHT direction should be accepted"
	if not grid.can_enter_one_way(gate_pos, Vector2i.RIGHT):
		grid.free()
		return "Entering gate from permitted RIGHT direction should pass"
	for blocked_direction in [Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		if grid.can_enter_one_way(gate_pos, blocked_direction):
			grid.free()
			return "Gate should reject direction %s" % str(blocked_direction)
	if not grid.can_enter_one_way(Vector2i(4, 5), Vector2i.LEFT):
		grid.free()
		return "Non-gate ground tile should preserve normal movement"
	if grid.set_one_way_direction(gate_pos, Vector2i(1, 1)):
		grid.free()
		return "Diagonal gate direction must be rejected"
	
	# Player movement accepts only the arrow direction.
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = grid
	player.current_grid_pos = Vector2i(4, 5)
	if not player.try_move(Vector2i.RIGHT) or player.target_grid_pos != gate_pos:
		player.free()
		grid.free()
		return "Player should enter gate from permitted direction"
	player.current_grid_pos = Vector2i(6, 5)
	player.target_grid_pos = player.current_grid_pos
	player.is_moving = false
	if player.try_move(Vector2i.LEFT):
		player.free()
		grid.free()
		return "Player should not enter gate against permitted direction"
	
	# Statue push is also constrained by entry direction.
	var gm = Node.new()
	gm.set_script(load("res://Scripts/game_manager.gd"))
	gm.grid_manager = grid
	player.game_manager = gm
	var statue = Enemy.new()
	statue.current_grid_pos = Vector2i(6, 5)
	statue.petrified = true
	gm.enemies.append(statue)
	player.current_grid_pos = Vector2i(7, 5)
	if player.try_push_statue(statue, Vector2i.LEFT):
		statue.free()
		gm.free()
		player.free()
		grid.free()
		return "Statue must not be pushed into gate against permitted direction"
	
	statue.free()
	gm.free()
	player.free()
	grid.free()
	return ""


func test_task_3_1_wall_hugger_patrol():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			if x == 0 or x == Constants.GRID_COLS - 1 or y == 0 or y == Constants.GRID_ROWS - 1:
				grid.set_tile(Vector2i(x, y), Constants.TileType.WALL)
			else:
				grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	var hugger = load("res://Scenes/wall_hugger.gd").new()
	var direction = hugger.choose_wall_follow_direction(grid, Vector2i(13, 2), Vector2i.DOWN)
	if direction != Vector2i.DOWN:
		hugger.free()
		grid.free()
		return "Expected wall-hugger to continue DOWN along right wall; got %s" % str(direction)
	
	var corner_direction = hugger.choose_wall_follow_direction(grid, Vector2i(13, 13), Vector2i.DOWN)
	if corner_direction != Vector2i.LEFT:
		hugger.free()
		grid.free()
		return "Expected wall-hugger to turn LEFT at lower-right corner; got %s" % str(corner_direction)
	
	# Dead-end has no safe move: enemy should wait instead of stepping into walls.
	var dead_end = Vector2i(5, 5)
	grid.set_tile(dead_end + Vector2i.UP, Constants.TileType.WALL)
	grid.set_tile(dead_end + Vector2i.DOWN, Constants.TileType.WALL)
	grid.set_tile(dead_end + Vector2i.LEFT, Constants.TileType.WALL)
	grid.set_tile(dead_end + Vector2i.RIGHT, Constants.TileType.WALL)
	var dead_end_direction = hugger.choose_wall_follow_direction(grid, dead_end, Vector2i.RIGHT)
	if dead_end_direction != Vector2i.ZERO:
		hugger.free()
		grid.free()
		return "Expected zero direction in dead-end; got %s" % str(dead_end_direction)
	
	hugger.free()
	grid.free()
	return ""


func test_task_3_2_jumper_landing():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	var jumper = load("res://Scenes/jumper_enemy.gd").new()
	# A two-cell leap may cross an obstacle in the intermediate cell.
	grid.set_tile(Vector2i(3, 5), Constants.TileType.WALL)
	var landing = jumper.calculate_jump_destination(grid, Vector2i(2, 5), Vector2i.RIGHT, [], 0, 2)
	if landing != Vector2i(4, 5):
		jumper.free()
		grid.free()
		return "Jumper should leap over intermediate wall to (4,5), got %s" % str(landing)
	
	# If the long landing is blocked, it safely falls back to one-cell landing.
	grid.set_tile(Vector2i(4, 5), Constants.TileType.WALL)
	grid.set_tile(Vector2i(3, 5), Constants.TileType.GROUND)
	landing = jumper.calculate_jump_destination(grid, Vector2i(2, 5), Vector2i.RIGHT, [], 0, 2)
	if landing != Vector2i(3, 5):
		jumper.free()
		grid.free()
		return "Jumper should fall back to valid adjacent landing (3,5), got %s" % str(landing)
	
	# No valid landing available means no movement.
	grid.set_tile(Vector2i(3, 5), Constants.TileType.WALL)
	landing = jumper.calculate_jump_destination(grid, Vector2i(2, 5), Vector2i.RIGHT, [], 0, 2)
	if landing != Vector2i(2, 5):
		jumper.free()
		grid.free()
		return "Jumper should stay put if every landing is blocked"
	
	if not jumper.jump_threatens_player(Vector2i(2, 5), Vector2i(4, 5), Vector2i(4, 5)):
		jumper.free()
		grid.free()
		return "Landing on player cell should register hit"
	if jumper.jump_threatens_player(Vector2i(2, 5), Vector2i(4, 5), Vector2i(3, 5)):
		jumper.free()
		grid.free()
		return "Player on intermediate cell should not count as landing hit"
	
	jumper.free()
	grid.free()
	return ""


func test_task_3_3_pusher_bridge_guardian():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.WALL)
	
	# Small winding pool with a bridge beside its far end.
	var water_cells = [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(4, 3)]
	for cell in water_cells:
		grid.set_tile(cell, Constants.TileType.WATER)
	var bridge_pos = Vector2i(5, 3)
	grid.set_tile(bridge_pos, Constants.TileType.ICE)
	
	var pusher = load("res://Scenes/pusher_enemy.gd").new()
	if pusher.find_nearest_bridge(grid, Vector2i(2, 2)) != bridge_pos:
		pusher.free()
		grid.free()
		return "Pusher failed to find nearest bridge"
	
	var first_step = pusher.choose_water_step_toward_bridge(grid, Vector2i(2, 2), bridge_pos)
	if first_step != Vector2i.RIGHT:
		pusher.free()
		grid.free()
		return "Expected first water route step RIGHT, got %s" % str(first_step)
	var second_step = pusher.choose_water_step_toward_bridge(grid, Vector2i(4, 2), bridge_pos)
	if second_step != Vector2i.DOWN:
		pusher.free()
		grid.free()
		return "Expected next water route step DOWN, got %s" % str(second_step)
	
	if pusher.choose_water_step_toward_bridge(grid, Vector2i(2, 2), Vector2i(6, 6)) != Vector2i.ZERO:
		pusher.free()
		grid.free()
		return "Pusher should not route through land to unreachable bridge"
	if not pusher.can_remove_bridge(grid, bridge_pos, Vector2i(1, 1)):
		pusher.free()
		grid.free()
		return "Unoccupied ice bridge should be removable"
	if pusher.can_remove_bridge(grid, bridge_pos, bridge_pos):
		pusher.free()
		grid.free()
		return "Pusher must not remove a bridge occupied by player"
	if pusher.can_remove_bridge(grid, Vector2i(3, 2), Vector2i(1, 1)):
		pusher.free()
		grid.free()
		return "Water tile is not a bridge and must not be removable"
	
	pusher.free()
	grid.free()
	return ""


func test_task_3_4_hades_shadow_gaze():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	var shadow = load("res://Scenes/hades_shadow.gd").new()
	var player_pos = Vector2i(5, 5)
	var shadow_right = Vector2i(8, 5)
	var shadow_down = Vector2i(5, 9)
	var shadow_diagonal = Vector2i(8, 8)
	
	if not shadow.is_player_looking_at_shadow(player_pos, Constants.Direction.RIGHT, shadow_right):
		shadow.free()
		grid.free()
		return "Facing RIGHT should freeze shadow ahead"
	if shadow.is_player_looking_at_shadow(player_pos, Constants.Direction.LEFT, shadow_right):
		shadow.free()
		grid.free()
		return "Facing LEFT should not freeze shadow behind hero"
	if not shadow.is_player_looking_at_shadow(player_pos, Constants.Direction.DOWN, shadow_down):
		shadow.free()
		grid.free()
		return "Facing DOWN should freeze shadow below hero"
	if shadow.is_player_looking_at_shadow(player_pos, Constants.Direction.RIGHT, shadow_diagonal):
		shadow.free()
		grid.free()
		return "Diagonal shadow should not count as directly watched"
	
	var approach = shadow.choose_approach_step(grid, Vector2i(8, 5), player_pos)
	if approach != Vector2i.LEFT:
		shadow.free()
		grid.free()
		return "Expected ghost approach LEFT toward hero, got %s" % str(approach)
	grid.set_tile(Vector2i(7, 5), Constants.TileType.WALL)
	approach = shadow.choose_approach_step(grid, Vector2i(8, 5), player_pos)
	if approach == Vector2i.LEFT:
		shadow.free()
		grid.free()
		return "Shadow must not step through wall"
	
	shadow.free()
	grid.free()
	return ""


func test_task_3_5_flame_beast():
	var grid = GridManager.new()
	grid.initialize_grid()
	for y in range(Constants.GRID_ROWS):
		for x in range(Constants.GRID_COLS):
			grid.set_tile(Vector2i(x, y), Constants.TileType.GROUND)
	
	var flame = load("res://Scenes/flame_beast.gd").new()
	if not flame.is_immune_to_petrification():
		flame.free()
		grid.free()
		return "Flame beast should report immunity to petrification"
	flame.petrify()
	if flame.petrified:
		flame.free()
		grid.free()
		return "Calling petrify must not petrify flame beast"
	
	var gm = Node.new()
	gm.set_script(load("res://Scripts/game_manager.gd"))
	gm.set("grid_manager", grid)
	flame.game_manager = gm
	gm._on_projectile_hit_enemy(flame)
	if flame.petrified:
		flame.free()
		gm.free()
		grid.free()
		return "GameManager projectile handling must preserve flame immunity"
	flame.grid_manager = grid
	flame.current_grid_pos = Vector2i(5, 6)
	var adjacent_statue = Enemy.new()
	adjacent_statue.current_grid_pos = Vector2i(5, 5)
	adjacent_statue.petrified = true
	var adjacent_live = Enemy.new()
	adjacent_live.current_grid_pos = Vector2i(6, 6)
	var distant_statue = Enemy.new()
	distant_statue.current_grid_pos = Vector2i(5, 8)
	distant_statue.petrified = true
	gm.enemies.append(flame)
	gm.enemies.append(adjacent_statue)
	gm.enemies.append(adjacent_live)
	gm.enemies.append(distant_statue)
	
	var melted = flame.burn_adjacent_statues()
	if melted != 1 or not adjacent_statue.is_squashed:
		flame.free()
		adjacent_statue.free()
		adjacent_live.free()
		distant_statue.free()
		gm.free()
		grid.free()
		return "Flame should shatter one adjacent petrified statue"
	if adjacent_live.is_squashed or distant_statue.is_squashed:
		flame.free()
		adjacent_statue.free()
		adjacent_live.free()
		distant_statue.free()
		gm.free()
		grid.free()
		return "Flame should only melt adjacent petrified statues"
	
	flame.free()
	adjacent_statue.free()
	adjacent_live.free()
	distant_statue.free()
	gm.free()
	grid.free()
	return ""


func test_task_4_1_boss_system():
	var boss = load("res://Scripts/boss.gd").new()
	boss.max_health = 3
	boss.health = 3
	if boss.receive_gaze() or boss.health != 3:
		boss.free()
		return "Boss direct gaze should not damage health"
	var statue = Enemy.new()
	statue.petrified = true
	if not boss.receive_sliding_statue(statue) or boss.health != 2:
		boss.free()
		statue.free()
		return "Petrified statue should deal one boss hit"
	statue.petrified = false
	if boss.receive_sliding_statue(statue):
		boss.free()
		statue.free()
		return "Living enemy must not damage boss"
	var defeated = [false]
	boss.boss_defeated.connect(func(): defeated[0] = true)
	boss.take_damage(2)
	if boss.health != 0 or not boss.defeated or not defeated[0]:
		boss.free()
		statue.free()
		return "Boss should emit defeat at zero HP"
	boss.free()
	statue.free()
	
	var data = LevelData.create_boss_test_level()
	var exit_cell = Vector2i(data.boss_arena.position.x + data.boss_arena.size.x / 2, data.boss_arena.end.y - 1)
	if not data.is_boss_level or data.boss_health != 3 or not data.boss_arena.has_point(data.player_start):
		return "Boss fixture needs boss config and player start inside arena"
	if data.grid_layout[exit_cell.y][exit_cell.x] != Constants.TileType.WALL:
		return "Boss arena exit should begin sealed"
	return ""

func test_task_4_2_cyclops_patterns():
	var cyclops = load("res://Scripts/cyclops_boss.gd").new()
	var stomp_events: Array = []
	var boulder_events: Array = []
	cyclops.attack_telegraphed.connect(func(kind, target):
		if kind == "stomp":
			stomp_events.append(target)
		else:
			boulder_events.append(target)
	)
	cyclops.begin_next_attack(Vector2i(7, 8), Constants.Direction.RIGHT, 0)
	if cyclops.attack_phase != "stomp" or cyclops.attack_target != Vector2i(7, 8) or stomp_events.size() != 1:
		cyclops.free()
		return "Cyclops stomp should telegraph player's current tile"
	cyclops.resolve_attack(Vector2i(7, 8))
	if cyclops.attack_phase != "idle":
		cyclops.free()
		return "Stomp attack should return Cyclops to idle"
	
	var arena = Rect2i(Vector2i(4, 3), Vector2i(9, 9))
	var target = cyclops.get_boulder_impact_target(Vector2i(8, 7), Vector2i(10, 7), Constants.Direction.RIGHT, arena, 2)
	if target != Vector2i(11, 7):
		cyclops.free()
		return "Boulder should lead player to last interior arena tile (11,7), got %s" % str(target)
	var clamped = cyclops.get_boulder_impact_target(Vector2i(8, 7), Vector2i(12, 10), Constants.Direction.DOWN, arena, 3)
	if not arena.has_point(clamped) or clamped.x <= arena.position.x or clamped.x >= arena.end.x - 1 or clamped.y <= arena.position.y or clamped.y >= arena.end.y - 1:
		cyclops.free()
		return "Boulder target should stay inside arena, got %s" % str(clamped)
	
	cyclops.begin_next_attack(Vector2i(10, 7), Constants.Direction.LEFT, 1)
	if cyclops.attack_phase != "boulder" or boulder_events.size() != 1:
		cyclops.free()
		return "Second Cyclops attack should telegraph boulder"
	if not cyclops.resolve_attack(cyclops.attack_target):
		cyclops.free()
		return "Player on boulder impact tile should be hit"
	if cyclops.resolve_attack(Vector2i(-1, -1)):
		cyclops.free()
		return "Resolved attack should not damage again"
	cyclops.free()
	return ""


func test_task_4_3_hydra_patterns():
	var hydra = load("res://Scripts/hydra_boss.gd").new()
	var acid_events: Array = []
	var sweep_events: Array = []
	hydra.hydra_attack_telegraphed.connect(func(kind, target):
		if kind == "acid":
			acid_events.append(target)
		else:
			sweep_events.append(target)
	)
	var arena = Rect2i(Vector2i(4, 3), Vector2i(9, 9))
	hydra.arena_rect = arena
	
	var acid_target = hydra.get_acid_target(Vector2i(10, 7), Constants.Direction.RIGHT, 2, arena)
	if acid_target != Vector2i(11, 7):
		hydra.free()
		return "Acid spit should lead toward interior edge; got %s" % str(acid_target)
	var clamped = hydra.get_acid_target(Vector2i(11, 7), Constants.Direction.RIGHT, 2, arena)
	if clamped != Vector2i(11, 7):
		hydra.free()
		return "Acid target should clamp inside arena; got %s" % str(clamped)
	
	var horizontal_anchor = hydra.get_sweep_anchor(Vector2i(8, 8), 1, arena)
	var horizontal_cells = hydra.get_sweep_cells(horizontal_anchor, 1, arena)
	if horizontal_cells.size() != 7 or not horizontal_cells.has(Vector2i(8, 8)):
		hydra.free()
		return "Horizontal sweep must cover exactly inner arena row"
	if not hydra.is_player_hit_by_sweep(Vector2i(5, 8), horizontal_anchor, 1, arena):
		hydra.free()
		return "Player remaining in sweep row should be hit"
	if hydra.is_player_hit_by_sweep(Vector2i(5, 7), horizontal_anchor, 1, arena):
		hydra.free()
		return "Player who dodges away from sweep should survive"
	
	var vertical_anchor = hydra.get_sweep_anchor(Vector2i(7, 8), 2, arena)
	var vertical_cells = hydra.get_sweep_cells(vertical_anchor, 2, arena)
	if vertical_cells.size() != 7 or not vertical_cells.has(Vector2i(7, 6)):
		hydra.free()
		return "Alternate sweep must cover inner arena column"
	
	hydra.begin_next_attack(Vector2i(8, 8), Constants.Direction.LEFT, 0)
	if hydra.attack_phase != "acid" or acid_events.size() != 1:
		hydra.free()
		return "First Hydra attack should telegraph acid spit"
	hydra.attack_phase = "idle"
	hydra.begin_next_attack(Vector2i(8, 8), Constants.Direction.LEFT, 1)
	if hydra.attack_phase != "sweep" or sweep_events.size() != 1:
		hydra.free()
		return "Second Hydra attack should telegraph water sweep"
	
	var level = LevelData.create_hydra_boss_level()
	if level.boss_health != 4 or level.boss_type != "hydra" or level.boss_minion_type != "zapper":
		hydra.free()
		return "Hydra level should configure 4 HP and aquatic minions"
	
	hydra.free()
	return ""


func test_task_4_4_chimera_patterns():
	var chimera = load("res://Scripts/chimera_boss.gd").new()
	var fire_events: Array = []
	var charge_events: Array = []
	chimera.chimera_attack_telegraphed.connect(func(kind, cells):
		if kind == "fire_line":
			fire_events.append(cells)
		else:
			charge_events.append(cells)
	)
	var arena = Rect2i(Vector2i(4, 3), Vector2i(9, 9))
	chimera.arena_rect = arena
	var boss_pos = Vector2i(8, 7)
	
	var fire_target = chimera.choose_attack_lane(boss_pos, Vector2i(10, 10), arena)
	if fire_target.y != boss_pos.y and fire_target.x != boss_pos.x:
		chimera.free()
		return "Fire breath target must lie on boss row or column"
	var fire_cells = chimera.get_line_cells(boss_pos, fire_target, arena)
	if fire_cells.is_empty() or not fire_cells.has(fire_target):
		chimera.free()
		return "Fire lane should include telegraphed target"
	if not chimera.is_player_hit_by_attack(fire_target, boss_pos, fire_target, "fire_line", arena):
		chimera.free()
		return "Player on fire lane should be hit"
	if chimera.is_player_hit_by_attack(Vector2i(5, 5), boss_pos, fire_target, "fire_line", arena):
		chimera.free()
		return "Player outside fire lane should evade"
	
	var charge_target = Vector2i(11, 9)
	var charge_cells = chimera.get_charge_lane(boss_pos, charge_target, arena)
	var charge_lane_cell = Vector2i(11, 7)
	if charge_cells.is_empty() or not chimera.is_player_hit_by_attack(charge_lane_cell, boss_pos, charge_target, "charge", arena):
		chimera.free()
		return "Charge should hit a cell on its telegraphed lane"
	if chimera.is_player_hit_by_attack(Vector2i(7, 8), boss_pos, charge_target, "charge", arena):
		chimera.free()
		return "Player outside charge lane should evade"
	
	chimera.begin_next_attack(Vector2i(10, 6), 0)
	if chimera.attack_phase != "fire_line" or fire_events.size() != 1:
		chimera.free()
		return "Chimera should telegraph fire line first"
	chimera.begin_next_attack(Vector2i(10, 6), 1)
	if chimera.attack_phase != "charge" or charge_events.size() != 1:
		chimera.free()
		return "Chimera should alternate to charge"
	
	var fixture = LevelData.create_chimera_boss_level()
	if fixture.boss_type != "chimera" or fixture.boss_health != 5 or fixture.boss_minion_type != "flame_beast":
		chimera.free()
		return "Chimera fixture should configure type, 5 HP, and fire minions"
	chimera.free()
	return ""


func test_task_4_5_medusa_final_patterns():
	var medusa = load("res://Scripts/medusa_boss.gd").new()
	var gaze_events: Array = []
	var teleport_events: Array = []
	var serpent_events: Array = []
	medusa.medusa_attack_telegraphed.connect(func(kind, cells):
		match kind:
			"gaze": gaze_events.append(cells)
			"teleport": teleport_events.append(cells)
			"serpents": serpent_events.append(cells)
	)
	var arena = Rect2i(Vector2i(4, 3), Vector2i(9, 9))
	medusa.arena_rect = arena
	var player_pos = Vector2i(8, 8)
	
	medusa.begin_next_attack(player_pos, Constants.Direction.UP, 0)
	if medusa.attack_phase != "gaze" or medusa.attack_target != player_pos or gaze_events.size() != 1:
		medusa.free()
		return "Medusa should telegraph gaze on player tile"
	var no_snakes: Array[Vector2i] = []
	if not medusa.is_player_hit_by_attack(player_pos, "gaze", player_pos, no_snakes):
		medusa.free()
		return "Player who remains on gaze target should be hit"
	if medusa.is_player_hit_by_attack(Vector2i(7, 8), "gaze", player_pos, no_snakes):
		medusa.free()
		return "Player who dodges gaze target should evade"
	
	medusa.begin_next_attack(player_pos, Constants.Direction.UP, 1)
	var flank = medusa.attack_target
	if medusa.attack_phase != "teleport" or teleport_events.size() != 1 or not arena.has_point(flank):
		medusa.free()
		return "Medusa teleport should telegraph a valid arena flank"
	if flank != player_pos - Vector2i.UP:
		medusa.free()
		return "Medusa should prefer teleport behind the player"
	
	medusa.begin_next_attack(player_pos, Constants.Direction.UP, 2)
	var snakes = medusa.serpent_cells.duplicate()
	if medusa.attack_phase != "serpents" or serpent_events.size() != 1 or not snakes.has(player_pos):
		medusa.free()
		return "Serpent warning should include player's tile"
	if not medusa.is_player_hit_by_attack(player_pos, "serpents", player_pos, snakes):
		medusa.free()
		return "Player on serpent tile should be hit"
	if medusa.is_player_hit_by_attack(Vector2i(5, 5), "serpents", player_pos, snakes):
		medusa.free()
		return "Player outside serpent warning cells should evade"
	
	medusa.health = 4
	medusa.max_health = 6
	medusa.phase_two = false
	medusa.take_damage(1)
	if not medusa.phase_two:
		medusa.free()
		return "Medusa second phase should start at half health"
	var phase_two_snakes = medusa.choose_serpent_cells(player_pos, true, arena)
	if phase_two_snakes.size() <= snakes.size():
		medusa.free()
		return "Second phase should expand serpent danger cells"
	
	var level = LevelData.create_medusa_boss_level()
	if level.boss_type != "medusa" or level.boss_health != 6 or level.boss_minion_type != "hades_shadow":
		medusa.free()
		return "Medusa final level fixture configuration invalid"
	medusa.free()
	return ""


func test_level_json_loader_valid_and_invalid():
	var loader = load("res://Scripts/level_json_loader.gd").new()
	var loaded = loader.load_file("res://Data/Levels/world_1_level_1.json")
	if not loaded.get("ok", false):
		return "Reference JSON failed to load: %s" % str(loaded.get("error", "unknown"))
	var data: LevelData = loaded["data"]
	var manager = load("res://Scripts/level_manager.gd").new()
	for level_number in range(1, 4):
		var selected_level = manager.get_level_data(1, level_number)
		if selected_level.world_idx != 1 or selected_level.level_idx != level_number:
			manager.free()
			return "LevelManager failed JSON loading for World 1 level %d" % level_number
	if manager.get_level_data(1, 2).level_name != "Garden Land B - Twin Reefs" or manager.get_level_data(1, 3).level_name != "Garden Land C - Frozen Blossom":
		manager.free()
		return "LevelManager did not prefer migrated Garden B-C JSON levels"
	manager.free()
	# Level 1 is edited by hand in the level editor: only check that it converts cleanly.
	if data.world_idx != 1 or data.level_idx != 1:
		return "Level 1 JSON metadata conversion failed"
	if data.grid_layout.size() != Constants.GRID_ROWS or data.grid_layout[0].size() != Constants.GRID_COLS:
		return "Level 1 grid dimensions are invalid"
	# Levels are edited by hand and no longer use ice/stone glyphs: check glyph conversion on an inline copy.
	var glyph_file = FileAccess.open("res://Data/Levels/world_1_level_1.json", FileAccess.READ)
	var glyph_doc: Dictionary = JSON.parse_string(glyph_file.get_as_text())
	glyph_file.close()
	glyph_doc["grid"][5] = "~~~~~ib~~~~~~~~~"
	var glyph_level: LevelData = loader.parse_text(JSON.stringify(glyph_doc))["data"]
	if glyph_level.grid_layout[5][5] != Constants.TileType.ICE or glyph_level.grid_layout[0][0] != Constants.TileType.WATER:
		return "Ice/ocean glyph conversion failed"
	if glyph_level.grid_layout[5][6] != Constants.TileType.STONE_BLOCK:
		return "Stone-block tile glyph conversion failed"
	
	var file = FileAccess.open("res://Data/Levels/world_1_level_1.json", FileAccess.READ)
	var valid_text = file.get_as_text()
	file.close()
	var doc: Dictionary = JSON.parse_string(valid_text)
	var malformed = doc.duplicate(true)
	malformed["grid"][0] = "###"
	if loader.parse_text(JSON.stringify(malformed)).get("ok", false):
		return "Malformed grid row should be rejected"
	malformed = doc.duplicate(true)
	malformed["grid"][1] = "#..............?"
	if loader.parse_text(JSON.stringify(malformed)).get("ok", false):
		return "Unknown tile glyph should be rejected"
	malformed = doc.duplicate(true)
	malformed["warps"] = [{"pos": [2, 10], "pair_id": "A"}]
	if loader.parse_text(JSON.stringify(malformed)).get("ok", false):
		return "Warp pair missing endpoint should be rejected"
	malformed = doc.duplicate(true)
	malformed["springs"] = [{"pos": [4, 10], "direction": "diagonal"}]
	if loader.parse_text(JSON.stringify(malformed)).get("ok", false):
		return "Invalid tile direction should be rejected"
	malformed = doc.duplicate(true)
	malformed["boss"] = {"health": 3, "arena_pos": [4, 3]}
	if loader.parse_text(JSON.stringify(malformed)).get("ok", false):
		return "Incomplete boss arena should be rejected"
	
	malformed = doc.duplicate(true)
	malformed["boss"] = {"health": 2}
	var optional_boss = loader.parse_text(JSON.stringify(malformed))
	if not optional_boss.get("ok", false) or optional_boss["data"].boss_position != Vector2i(8, 7):
		return "Optional boss position should use documented default"
	if loader.load_file("res://Data/Levels/does_not_exist.json").get("ok", false):
		return "Missing JSON file should report failure"
	return ""


func test_world_1_json_level_set():
	var loader = load("res://Scripts/level_json_loader.gd").new()
	var manager = load("res://Scripts/level_manager.gd").new()
	for level_number in range(1, 16):
		var path = "res://Data/Levels/world_1_level_%d.json" % level_number
		var result = loader.load_file(path)
		if not result.get("ok", false):
			manager.free()
			return "World 1 level %d JSON invalid: %s" % [level_number, str(result.get("error", "unknown"))]
		var data: LevelData = manager.get_level_data(1, level_number)
		if data.level_idx != level_number or data.grid_layout.size() != Constants.GRID_ROWS:
			manager.free()
			return "LevelManager did not load World 1 level %d JSON" % level_number
		# World 1 uses spawners rather than fixed enemies, so either one counts as opposition.
		if data.soul_urns.is_empty() or (data.enemies.is_empty() and data.spawners.is_empty()):
			manager.free()
			return "World 1 level %d needs objectives and enemies" % level_number
		for pos in data.soul_urns:
			if data.grid_layout[pos.y][pos.x] == Constants.TileType.WALL:
				manager.free()
				return "Level %d contains an urn inside a wall" % level_number
	manager.free()
	return ""


func test_garden_levels_abc_playable_shapes():
	var loader = load("res://Scripts/level_json_loader.gd").new()
	var a = loader.load_file("res://Data/Levels/world_1_level_1.json")
	var b = loader.load_file("res://Data/Levels/world_1_level_2.json")
	var c = loader.load_file("res://Data/Levels/world_1_level_3.json")
	for result in [a, b, c]:
		if not result.get("ok", false):
			return "Garden A-C JSON invalid: %s" % str(result.get("error", "unknown"))
	var level_a: LevelData = a["data"]
	var level_b: LevelData = b["data"]
	var level_c: LevelData = c["data"]
	for lvl in [level_a, level_b, level_c]:
		if lvl.grid_layout.size() != Constants.GRID_ROWS:
			return "%s row count invalid" % lvl.level_name
		for y in range(Constants.GRID_ROWS):
			if lvl.grid_layout[y].size() != Constants.GRID_COLS:
				return "%s row %d width invalid" % [lvl.level_name, y]
		# Levels 1-3 are edited by hand (plain ground, spawners): urns must just not sit in water or walls.
		for pos in lvl.soul_urns:
			var tile: int = lvl.grid_layout[pos.y][pos.x]
			if tile == Constants.TileType.WATER or tile == Constants.TileType.WALL:
				return "%s has inaccessible urn at %s" % [lvl.level_name, str(pos)]
		for spawner_data in lvl.spawners:
			var spawn_pos: Vector2i = spawner_data["pos"]
			if lvl.grid_layout[spawn_pos.y][spawn_pos.x] == Constants.TileType.WALL:
				return "%s has spawner inside a wall at %s" % [lvl.level_name, str(spawn_pos)]
	if level_a.time_limit >= level_b.time_limit or level_b.time_limit >= level_c.time_limit:
		return "Garden A-C challenge timers should increase progressively"
	if not level_a.grid_layout[0].has(Constants.TileType.WATER) or level_a.grid_layout[0].has(Constants.TileType.WALL):
		return "Garden A outer ocean should be water, not a wall fence"
	return ""

func test_task_5_7_save_manager() -> String:
	var sm = load("res://Scripts/save_manager.gd").new()
	sm.save_path = "user://test_save_task_5_7.json"
	sm.name = "SaveManagerTest"
	
	# Reset to clean defaults
	sm._reset_to_defaults()
	
	# 1. Default values
	if sm.get_max_world() != 1:
		return "Default max_world should be 1"
	if sm.get_max_level(1) != 1:
		return "Default max_level w1 should be 1"
	if sm.get_total_score() != 0:
		return "Default total_score should be 0"
	if sm.get_best_score(1, 1) != 0:
		return "Default best score should be 0"
	if sm.get_music_volume() != 1.0:
		return "Default music volume should be 1.0"
	if sm.get_sfx_volume() != 1.0:
		return "Default sfx volume should be 1.0"
	
	# 2. record_level_completion unlocks next level
	sm.record_level_completion(1, 1, 3000)
	if sm.get_max_level(1) != 2:
		return "After completing level 1, max_level should be 2"
	if sm.get_total_score() != 3000:
		return "Total score should be 3000 after first level"
	if sm.get_best_score(1, 1) != 3000:
		return "Best score for 1-1 should be 3000"
	
	# 3. Best score only updated when beaten
	sm.record_level_completion(1, 1, 1000)
	if sm.get_best_score(1, 1) != 3000:
		return "Best score should remain 3000, not replaced by lower 1000"
	if sm.get_total_score() != 4000:
		return "Total score should accumulate to 4000"
	
	# 4. Next world unlocked after level 17
	sm.record_level_completion(1, 17, 5000)
	if sm.get_max_world() != 2:
		return "World 2 should unlock after completing world 1 level 17"
	
	# 5. Settings
	sm.set_music_volume(0.5)
	if sm.get_music_volume() != 0.5:
		return "Music volume should be 0.5 after set"
	sm.set_sfx_volume(0.0)
	if sm.get_sfx_volume() != 0.0:
		return "SFX volume should be 0.0 after set"
	sm.set_music_volume(-1.0)
	if sm.get_music_volume() != 0.0:
		return "Music volume should clamp to 0.0 when set below 0"
	sm.set_music_volume(999.0)
	if sm.get_music_volume() != 1.0:
		return "Music volume should clamp to 1.0 when set above 1"
	
	# 6. Disk round-trip on isolated test path
	sm.save_data = {"version": sm.SAVE_VERSION, "max_world": 2, "max_level_w1": 7, "total_score": 8123, "music_volume": 0.35, "sfx_volume": 0.7, "best_1_6": 8123}
	sm.save_game()
	var reloaded = load("res://Scripts/save_manager.gd").new()
	reloaded.save_path = sm.save_path
	reloaded.load_game()
	if reloaded.get_max_world() != 2 or reloaded.get_max_level(1) != 7:
		return "Saved progression should survive disk round-trip"
	if reloaded.get_total_score() != 8123 or reloaded.get_best_score(1, 6) != 8123:
		return "Saved scores should survive disk round-trip"
	if not is_equal_approx(reloaded.get_music_volume(), 0.35) or not is_equal_approx(reloaded.get_sfx_volume(), 0.7):
		return "Saved audio settings should survive disk round-trip"

	# 7. Invalid JSON resets to defaults without touching real save file.
	var bad_file := FileAccess.open(sm.save_path, FileAccess.WRITE)
	if bad_file == null:
		return "Could not create isolated corrupt-save fixture"
	bad_file.store_string("{ this is not valid JSON")
	bad_file.close()
	reloaded.load_game()
	if reloaded.get_total_score() != 0 or reloaded.get_max_world() != 1:
		return "Corrupt JSON should reset to defaults"

	# 8. Remove only the isolated test fixture.
	reloaded.reset_save()
	var fixture_left := FileAccess.file_exists(sm.save_path)
	reloaded.free()
	sm.free()
	if fixture_left:
		return "Test save fixture should be removed after test"
	return ""


func test_task_6_1_overworld_map_logic() -> String:
	var om = load("res://Scenes/overworld_map.gd").new()
	
	# 1. Chemin dÃ©fini avec 17 entrÃ©es (16 niveaux + 1 boss)
	if om.WORLD_1_PATH.size() != 17:
		return "WORLD_1_PATH should have 17 entries (16 levels + 1 boss), got %d" % om.WORLD_1_PATH.size()
	
	# 2. Toutes les cases du chemin ont des coordonnÃ©es valides (>= 0)
	for i in range(om.WORLD_1_PATH.size()):
		var cell: Vector2i = om.WORLD_1_PATH[i]
		if cell.x < 0 or cell.y < 0:
			return "Path node %d has negative coordinates %s" % [i, str(cell)]
	
	# 3. max_unlocked dÃ©marre Ã  1
	om.max_unlocked = 1
	om.selected_index = 0
	if om.selected_index != 0:
		return "Initial selected_index should be 0"
	
	# 4. _move_cursor ne dÃ©passe pas les limites
	om.max_unlocked = 3
	om.selected_index = 0
	om._move_cursor(1)
	if om.selected_index != 1:
		return "Cursor should move to index 1"
	om._move_cursor(-5)  # Ne doit pas aller en dessous de 0
	if om.selected_index != 0:
		return "Cursor should clamp to 0, got %d" % om.selected_index
	om.selected_index = 2
	om._move_cursor(10)  # Ne doit pas dÃ©passer max_unlocked - 1
	if om.selected_index != 2:
		return "Cursor should clamp to max_unlocked-1 (2), got %d" % om.selected_index
	
	# 5. _node_center retourne Vector2 valide
	var c: Vector2 = om._node_center(0)
	if c.x <= 0 or c.y <= 0:
		return "Node center for index 0 should be positive, got %s" % str(c)
	var c_last: Vector2 = om._node_center(15)
	if c_last == c:
		return "Node centers for index 0 and 15 should differ"
	
	om.free()
	return ""

func test_task_6_2_progressive_unlock() -> String:
	var sm = load("res://Scripts/save_manager.gd").new()
	sm.save_path = "user://test_save_task_6_2.json"
	sm._reset_to_defaults()
	
	# 1. Niveau 1 dÃ©bloquÃ© par dÃ©faut
	if sm.get_max_level(1) != 1:
		return "Level 1 should be unlocked by default"
	
	# 2. ComplÃ©ter niveau 1 dÃ©bloque niveau 2
	sm.record_level_completion(1, 1, 100)
	if sm.get_max_level(1) != 2:
		return "Completing level 1 should unlock level 2, got %d" % sm.get_max_level(1)
	
	# 3. ComplÃ©ter niveau 2 dÃ©bloque niveau 3
	sm.record_level_completion(1, 2, 200)
	if sm.get_max_level(1) != 3:
		return "Completing level 2 should unlock level 3, got %d" % sm.get_max_level(1)
	
	# 4. Rejouer un niveau dÃ©jÃ  terminÃ© ne rÃ©duit pas max_level
	sm.record_level_completion(1, 1, 50)
	if sm.get_max_level(1) != 3:
		return "Replaying level 1 should not reduce max_level"
	
	# 5. ComplÃ©ter niveau 17 dÃ©bloque le Monde 2
	for lvl in range(3, 18):
		sm.record_level_completion(1, lvl, 100)
	if sm.get_max_world() != 2:
		return "Completing world 1 (level 17) should unlock world 2"
	
	# 6. Monde 2 commence avec niveau 1 dÃ©bloquÃ©
	if sm.get_max_level(2) != 1:
		return "World 2 should start with level 1 unlocked"
	
	# 7. Overworld map reflÃ¨te la progression via unlock_next_level()
	var om = load("res://Scenes/overworld_map.gd").new()
	om.max_unlocked = 1
	om.selected_index = 0
	om.unlock_next_level()
	if om.max_unlocked != 2:
		return "unlock_next_level should set max_unlocked to 2"
	if om.selected_index != 1:
		return "unlock_next_level should move selected_index to 1"
	
	# 8. unlock_next_level ne dÃ©passe pas la taille du chemin
	om.max_unlocked = om.WORLD_1_PATH.size()
	om.unlock_next_level()
	if om.max_unlocked != om.WORLD_1_PATH.size():
		return "unlock_next_level should not exceed path size"
	sm.reset_save()
	var progression_fixture_left := FileAccess.file_exists(sm.save_path)
	om.free()
	sm.free()
	if progression_fixture_left:
		return "Progression test should remove its isolated save file"
	return ""


func test_task_7_1_title_screen_logic() -> String:
	var ts = load("res://Scenes/title_screen.gd").new()

	# 1. Items de menu dÃ©finis
	if ts.MENU_ITEMS.size() != 4:
		return "Title screen should have 4 menu items, got %d" % ts.MENU_ITEMS.size()
	if ts.MENU_ITEMS[0] != "Nouvelle Partie":
		return "First item should be 'Nouvelle Partie'"
	if ts.MENU_ITEMS[1] != "Continuer":
		return "Second item should be 'Continuer'"

	# 2. SÃ©lection initiale = 0
	if ts.selected_item != 0:
		return "Initial selected_item should be 0"

	# 3. Navigation circulaire vers le bas
	ts.has_save = true
	ts._move_selection(1)
	if ts.selected_item != 1:
		return "After move down, selected should be 1"
	ts._move_selection(1)
	ts._move_selection(1)
	ts._move_selection(1)
	if ts.selected_item != 0:
		return "Selection should wrap to 0 after 4 moves down"

	# 4. Navigation vers le haut wrap
	ts.selected_item = 0
	ts._move_selection(-1)
	if ts.selected_item != 3:
		return "Moving up from 0 should wrap to 3 (Quitter)"

	# 5. Sans sauvegarde, 'Continuer' est sautÃ©
	ts.has_save = false
	ts.selected_item = 0
	ts._move_selection(1)
	if ts.selected_item == 1:
		return "Without save, 'Continuer' should be skipped"
	if ts.selected_item != 2:
		return "Without save, should jump from 0 to 2 (Options)"

	ts.free()
	return ""

func test_common_marble_petrification() -> String:
	var statue_script = load("res://Scenes/petrification_visual.gd")
	if statue_script == null:
		return "Shared marble statue script should load"
	var enemy_script = load("res://Scenes/enemy.gd")
	var statue_a = enemy_script.new()
	statue_a.visual = ColorRect.new()
	statue_a.add_child(statue_a.visual)
	statue_a.eyes = ColorRect.new()
	statue_a.visual.add_child(statue_a.eyes)
	statue_a.create_petrification_overlay()
	var statue_b = enemy_script.new()
	statue_b.visual = ColorRect.new()
	statue_b.add_child(statue_b.visual)
	statue_b.eyes = ColorRect.new()
	statue_b.visual.add_child(statue_b.eyes)
	statue_b.create_petrification_overlay()
	# Shared statue child is same renderer for different living enemy species.
	if statue_a.petrification_visual.get_script() != statue_script or statue_b.petrification_visual.get_script() != statue_script:
		return "All transformable enemies must use the common statue renderer"
	statue_a.petrify()
	statue_b.petrify()
	if not statue_a.petrified or not statue_b.petrified:
		return "Transformable enemies should enter petrified state"
	if statue_a.visual.visible or statue_b.visual.visible:
		return "Living appearance should be hidden once common statue transition completes"
	if not statue_a.petrification_visual.visible or not statue_b.petrification_visual.visible:
		return "Common marble statue overlay should replace each living appearance"
	if statue_a.petrification_visual.get_script() != statue_b.petrification_visual.get_script():
		return "Different enemy species must use identical statue animation"
	statue_a.free()
	statue_b.free()
	for enemy_path in ["res://Scenes/wall_hugger.gd", "res://Scenes/birdie.gd", "res://Scenes/zapper.gd"]:
		var species_script = load(enemy_path)
		var species = species_script.new()
		species.create_visual()
		species.create_petrification_overlay()
		species.petrify()
		if not species.petrified or species.visual.visible or not species.petrification_visual.visible:
			species.free()
			return "%s must transition from its living visual to the shared statue" % enemy_path
		species.free()

	var flame_script = load("res://Scenes/flame_beast.gd")
	var flame = flame_script.new()
	flame.petrify()
	if flame.petrified:
		return "Immune flame beast must not enter shared statue state"
	flame.free()
	return ""

func test_enemy_species_procedural_art() -> String:
	var art_script = load("res://Scenes/enemy_visual.gd")
	if art_script == null:
		return "Procedural species artwork script should load"
	var expected := {
		"noggle": "C66A5B",
		"birdie": "A7D7D7",
		"zapper": "55AFC1",
		"pusher": "4E92A0",
		"wall_hugger": "D8A64E",
		"jumper_enemy": "B96D4D",
		"hades_shadow": "9B7BC0",
		"flame_beast": "F09B42"
	}
	for species in expected:
		var art = Node2D.new()
		art.set_script(art_script)
		art.enemy_type = species
		if art.get_accent_color() != Color(expected[species]):
			art.free()
			return "Species %s should have its distinct procedural palette" % species
		art.set_moving(true)
		if not art.moving:
			art.free()
			return "Species %s should expose animated movement state" % species
		art.free()
	return ""

func test_task_8_4_procedural_tiles() -> String:
	var art_script = load("res://Scenes/tile_art_layer.gd")
	if art_script == null:
		return "Procedural tile detail layer should load"
	var expected_types := [
		Constants.TileType.WATER, Constants.TileType.GROUND, Constants.TileType.ICE,
		Constants.TileType.SLIPPERY, Constants.TileType.WALL, Constants.TileType.STONE_BLOCK,
		Constants.TileType.SPRING, Constants.TileType.ROTATOR, Constants.TileType.ONE_WAY,
		Constants.TileType.CONVEYOR, Constants.TileType.WARP
	]
	for tile_type in expected_types:
		if not art_script.supports_tile(tile_type):
			return "Tile detail renderer should support tile type %d" % tile_type
	var bounds: Rect2 = art_script.get_overlay_bounds()
	if bounds.position != Vector2(384, 0) or bounds.size != Vector2(1152, 1080):
		return "Tile detail layer must be clipped to the 16x15 playfield"
	var art = Node2D.new()
	art.set_script(art_script)
	var sample_map := [[Constants.TileType.WATER, Constants.TileType.GROUND, Constants.TileType.WALL, Constants.TileType.SLIPPERY, Constants.TileType.STONE_BLOCK]]
	art.set_layout(sample_map)
	if not art._has_water:
		return "Water tiles should activate wave animation"
	var old_phase: float = art._phase
	art._process(0.25)
	if art._phase <= old_phase:
		return "Water wave phase should advance over time"
	art.set_layout([[Constants.TileType.GROUND]])
	if art._has_water:
		return "Removing water from layout should disable water animation"
	art.free()
	return ""

func test_task_8_5_vfx_lifetimes_and_spawn() -> String:
	var vfx_script = load("res://Scenes/game_vfx.gd")
	if vfx_script == null:
		return "Procedural VFX script should load"
	var expected_lifetimes := {"gaze": 0.24, "petrify": 0.48, "impact": 0.32, "shatter": 0.5, "splash": 0.58}
	for kind in expected_lifetimes:
		if not is_equal_approx(vfx_script.lifetime_for(kind), expected_lifetimes[kind]):
			return "Unexpected lifetime for %s effect" % kind
	if vfx_script.spawn(null, Vector2.ZERO, "impact") != null:
		return "VFX spawn must safely no-op for invalid parent"
	var holder := Node2D.new()
	root.add_child(holder)
	var effect = vfx_script.spawn(holder, Vector2(100, 200), "splash", Vector2.UP)
	if effect == null or effect.effect_kind != "splash" or effect.direction != Vector2.UP:
		holder.queue_free()
		return "VFX spawn should preserve kind and direction"
	if not is_equal_approx(effect.lifetime, 0.58):
		holder.queue_free()
		return "Splash effect should initialize with configured lifetime"
	holder.free()
	return ""

func test_hero_walk_sheets_pick_direction_and_frame() -> String:
	var hero = load("res://Scenes/hero_visual.gd").new()
	var strip := ImageTexture.create_from_image(Image.create(8 * 16, 16, false, Image.FORMAT_RGBA8))
	var result := ""
	# Ignore the real strips in Assets/Sprites: this test only checks the lookup rules.
	hero._walk_sheets_loaded = true
	hero._walk_sheets.clear()
	hero.set_walk_sheet(Constants.Direction.DOWN, strip)
	hero.set_walk_sheet(Constants.Direction.RIGHT, strip)
	var down: Array = hero._walk_sheet_for(Constants.Direction.DOWN)
	var right: Array = hero._walk_sheet_for(Constants.Direction.RIGHT)
	var left: Array = hero._walk_sheet_for(Constants.Direction.LEFT)
	if down.is_empty() or down[1]:
		result = "A direction with its own strip must use it unmirrored"
	elif right.is_empty() or right[1] or left.is_empty() or not left[1]:
		result = "A missing left strip must reuse the right one mirrored"
	elif not hero._walk_sheet_for(Constants.Direction.UP).is_empty():
		result = "A direction with no strip must fall back to the single image"
	if result.is_empty():
		hero.moving = false
		hero.animation_time = 0.31
		if hero.walk_frame(8) != 0:
			result = "A standing hero must show frame 0"
		hero.moving = true
		hero.animation_time = 0.07
		if hero.walk_frame(8) != 1:
			result = "A walking hero must advance through the strip"
		hero.animation_time = 0.5
		if result.is_empty() and hero.walk_frame(8) != 0:
			result = "The walk cycle must loop after 8 frames"
		hero.animation_time = 0.45
		if result.is_empty() and hero.walk_frame(6) != 5:
			result = "A 6-frame strip must still complete its cycle in 0.5 s"
	for sheet_name in ["down", "up", "left", "right"]:
		var strip_path := "res://Assets/Sprites/hero_walk_%s.png" % sheet_name
		if result.is_empty() and ResourceLoader.exists(strip_path):
			var strip_texture: Texture2D = load(strip_path)
			if strip_texture.get_width() % strip_texture.get_height() != 0:
				result = "%s must be a strip of square frames" % strip_path
	hero.free()
	return result

func WALK_SHEET_FILE_EXISTS(sheet_name: String) -> bool:
	return ResourceLoader.exists("res://Assets/Sprites/%s.png" % sheet_name)

func test_task_8_2_procedural_hero_visual() -> String:
	var hero_script = load("res://Scenes/hero_visual.gd")
	if hero_script == null:
		return "Procedural Greek hero visual script should load"
	var hero = Node2D.new()
	hero.set_script(hero_script)
	if hero_script.get_script_constant_map().get("TUNIC", Color.TRANSPARENT) != Color("7CC4C0"):
		return "Hero should use distinct Greek tunic palette"
	for direction in [Constants.Direction.DOWN, Constants.Direction.UP, Constants.Direction.LEFT, Constants.Direction.RIGHT]:
		hero.set_pose(direction, true, false)
		if hero.facing != direction or not hero.moving:
			return "Directional movement pose should update facing/moving state"
	hero.set_pose(Constants.Direction.RIGHT, false, true)
	if not hero.pushing or hero.moving:
		return "Pushing pose should be represented independently from walking"
	hero.set_action(true)
	if not hero.shooting:
		return "Shooting action should enable Gorgon relic gaze effect"
	hero.set_action(false, true)
	if not hero.celebrating:
		return "Victory action should enable celebration pose"
	hero.set_dead(true)
	if not hero.dead:
		return "Death state should switch visual to cracked marble pose"
	hero.free()
	var player_scene: PackedScene = load("res://Scenes/player.tscn")
	if player_scene == null:
		return "Player scene should reference procedural hero controller"
	return ""

func test_task_8_1_side_margin_art() -> String:
	var art_script = load("res://Scenes/level_border_art.gd")
	if art_script == null:
		return "Procedural border art script should load"
	var rects: Array = art_script.get_side_rects()
	if rects.size() != 2:
		return "Should provide left and right margin rectangles"
	if rects[0] != Rect2(0, 0, 384, 1080):
		return "Left margin must fill x=0..383: %s" % str(rects[0])
	if rects[1] != Rect2(1536, 0, 384, 1080):
		return "Right margin must fill x=1536..1919: %s" % str(rects[1])
	var main_script = load("res://Scenes/main_scene.gd")
	if main_script == null:
		return "Main scene controller should load with border art preload"
	return ""

func test_task_7_5_level_clear_score_summary() -> String:
	var manager_script = load("res://Scripts/game_manager.gd")
	var gm = manager_script.new()
	gm.current_world = 1
	gm.current_level = 4
	gm.score = 12500
	gm.level_score_start = 10000
	gm.souls_collected = 3
	gm.enemies_squashed_this_level = 2
	gm.time_remaining = 42.2
	var summary: Dictionary = gm.build_level_clear_summary()
	if summary["earned_points"] != 2500:
		return "Summary should report level-earned points only"
	if summary["urn_points"] != 3000:
		return "Summary urn points should equal 3 * 1000"
	if summary["squash_points"] != 400 or summary["squashed_count"] != 2:
		return "Summary squash count/points mismatch"
	if summary["time_remaining"] != 43 or summary["time_bonus"] != 860:
		return "Time bonus should ceil remaining seconds and multiply by 20"
	if summary["completion_bonus"] != 5000 or summary["level_points"] != 8360:
		return "Level score should sum earned points, completion and time bonuses"
	if summary["total_score"] != 18360:
		return "Cumulative score preview should add level points to prior total"
	gm.time_remaining = -3.0
	var no_time: Dictionary = gm.build_level_clear_summary()
	if no_time["time_remaining"] != 0 or no_time["time_bonus"] != 0:
		return "Negative timer must give zero time bonus"

	var victory_scene: PackedScene = load("res://Scenes/victory_screen.tscn")
	if victory_scene == null:
		return "Victory summary scene must exist"
	var screen = victory_scene.instantiate()
	screen.create_ui()
	screen.show_victory(summary)
	if not screen.score_summary_label.text.contains("Score niveau : 8360"):
		return "Victory screen should include level score"
	if not screen.record_label.text.contains("Meilleur score : 0"):
		return "Victory screen should show previous best score"
	var record_summary := summary.duplicate(true)
	record_summary["is_new_record"] = true
	screen.show_victory(record_summary)
	if not screen.record_label.text.contains("NOUVEAU RECORD"):
		return "Victory screen should announce a new personal record"
	screen.free()
	gm.free()
	return ""

func test_task_7_4_gamepad_input_and_feedback() -> String:
	var controller_input = load("res://Scripts/controller_input.gd")
	controller_input._configured = false
	controller_input.configure()
	controller_input.configure()  # Idempotent

	# Keyboard bindings stay present; gamepad button/axis bindings added.
	for action in ["move_right", "move_left", "move_up", "move_down", "petrify_shot", "create_pillar"]:
		if not InputMap.has_action(action):
			return "Missing input action %s" % action
		if InputMap.action_get_events(action).is_empty():
			return "Input action %s should retain keyboard/gamepad events" % action
	var move_right_has_axis := false
	for event in InputMap.action_get_events("move_right"):
		if event is InputEventJoypadMotion and event.axis == JOY_AXIS_LEFT_X and event.axis_value > 0:
			move_right_has_axis = true
	if not move_right_has_axis:
		return "move_right should support positive left-stick X"
	var shot_has_buttons := {}
	for event in InputMap.action_get_events("petrify_shot"):
		if event is InputEventJoypadButton:
			shot_has_buttons[event.button_index] = true
	if not shot_has_buttons.has(JOY_BUTTON_A) or not shot_has_buttons.has(JOY_BUTTON_X):
		return "Petrify shot should map to gamepad A and X"
	var pillar_has_buttons := {}
	for event in InputMap.action_get_events("create_pillar"):
		if event is InputEventJoypadButton:
			pillar_has_buttons[event.button_index] = true
	if not pillar_has_buttons.has(JOY_BUTTON_B) or not pillar_has_buttons.has(JOY_BUTTON_Y):
		return "Pillar should map to gamepad B and Y"

	# Vibration helper clamps values and safely no-ops without connected pads.
	var feedback = load("res://Scripts/controller_feedback.gd")
	feedback.vibrate(-1.0, 2.0, -3.0)
	feedback.vibrate(0.0, 0.5, 0.5)
	feedback.stop_all()
	return ""

func test_task_7_3_options_menu_logic() -> String:
	var path := "user://test_save_task_7_3.json"
	var save_script = load("res://Scripts/save_manager.gd")
	var sm = save_script.new()
	sm.save_path = path
	sm._reset_to_defaults()

	# Separate buses are present and volume controls clamp to legal range.
	load("res://Scripts/audio_bus_setup.gd").ensure_buses()
	if AudioServer.get_bus_index("Music") < 0 or AudioServer.get_bus_index("SFX") < 0:
		return "Options should create Music and SFX audio buses"
	sm.set_music_volume(0.4)
	sm.set_sfx_volume(0.0)
	if not is_equal_approx(load("res://Scripts/audio_bus_setup.gd").get_volume("Music"), 0.4):
		return "Music slider must update Music bus volume"
	if load("res://Scripts/audio_bus_setup.gd").get_volume("SFX") != 0.0:
		return "SFX slider at zero should mute SFX bus"

	# Options scene exposes settings, control reference, and UI elements.
	var options_scene: PackedScene = load("res://Scenes/options_menu.tscn")
	if options_scene == null:
		return "Options scene resource should exist"
	var options = options_scene.instantiate()
	options.save_manager = sm
	options._build_ui()
	if options._music_slider == null or options._sfx_slider == null:
		return "Options scene should create both volume sliders"
	if not is_equal_approx(options.get_music_slider_value(), 0.4):
		return "Music slider should initialize from persisted value"
	if not is_equal_approx(options.get_sfx_slider_value(), 0.0):
		return "SFX slider should initialize from persisted value"
	options._on_fullscreen_toggled(false)
	options._on_vsync_toggled(false)
	options.close_menu()
	options.free()
	sm.reset_save()
	sm.free()
	return ""

func test_task_7_2_pause_menu_logic() -> String:
	var pm = load("res://Scenes/pause_menu.gd").new()
	root.add_child(pm)

	# 1. FermÃ© par dÃ©faut
	if pm.is_open:
		return "Pause menu should start closed"

	# 2. Ouverture
	pm._open()
	if not pm.is_open:
		return "Pause menu should be open after _open()"
	if pm.selected_item != 0:
		return "Selected item should reset to 0 on open"

	# 3. Items dÃ©finis
	if pm.MENU_ITEMS.size() != 4:
		return "Pause menu should have 4 items, got %d" % pm.MENU_ITEMS.size()
	if pm.MENU_ITEMS[0] != "Reprendre":
		return "First pause item should be 'Reprendre'"

	# 4. Navigation
	pm.selected_item = 0
	pm.selected_item = (pm.selected_item + 1) % pm.MENU_ITEMS.size()
	if pm.selected_item != 1:
		return "Navigation should move to index 1"

	# 5. Navigation wrap
	pm.selected_item = 3
	pm.selected_item = (pm.selected_item + 1) % pm.MENU_ITEMS.size()
	if pm.selected_item != 0:
		return "Navigation should wrap from 3 to 0"

	# 6. Fermeture
	pm._close()
	if pm.is_open:
		return "Pause menu should be closed after _close()"
	root.remove_child(pm)
	pm.free()

	return ""



func test_player_shoots_while_moving_and_adjacent_break() -> String:
	# Shooting must be handled before the is_moving branch so it works mid-step.
	var source: String = load("res://Scenes/player.gd").source_code
	var physics_start := source.find("func _physics_process")
	var shot_index := source.find("fire_petrify_shot()", physics_start)
	var move_index := source.find("if is_moving:", physics_start)
	if physics_start == -1 or shot_index == -1 or move_index == -1 or shot_index > move_index:
		return "Petrify shot must be handled before the is_moving branch"

	var probe_script := GDScript.new()
	probe_script.source_code = "extends Player\nvar fake_statue: Enemy\nfunc get_statue_at(grid_pos: Vector2i) -> Enemy:\n\treturn fake_statue if grid_pos == Vector2i(4, 3) else null\n"
	if probe_script.reload() != OK:
		return "Could not build player probe script"
	var player = probe_script.new()
	var statue := Enemy.new()
	statue.current_grid_pos = Vector2i(4, 3)
	statue.petrified = true
	player.fake_statue = statue
	player.current_grid_pos = Vector2i(3, 3)
	player.current_direction = Constants.Direction.RIGHT

	player.is_moving = true
	if player.break_facing_statue():
		player.free()
		return "A statue must not be broken while the hero is moving"
	player.is_moving = false
	player.current_direction = Constants.Direction.LEFT
	if player.break_facing_statue():
		player.free()
		return "A statue must not be broken unless the hero faces it"
	player.current_grid_pos = Vector2i(1, 3)
	player.current_direction = Constants.Direction.RIGHT
	if player.break_facing_statue():
		player.free()
		return "A statue must not be broken unless it is adjacent"
	player.current_grid_pos = Vector2i(3, 3)
	if not player.break_facing_statue():
		player.free()
		return "Adjacent statue in front of the hero should be broken"
	if not statue.is_squashed:
		player.free()
		return "Broken statue should be marked as destroyed"
	player.free()
	if is_instance_valid(statue):
		statue.free()
	return ""

func test_statue_timer_and_spawner_lifetime() -> String:
	var enemy := Enemy.new()
	enemy.visual = ColorRect.new()
	enemy.add_child(enemy.visual)
	enemy.eyes = ColorRect.new()
	enemy.visual.add_child(enemy.eyes)
	enemy.create_petrification_overlay()
	enemy.petrify()
	if not enemy.petrified or not is_equal_approx(enemy.petrify_time_remaining, Enemy.PETRIFY_DURATION):
		enemy.free()
		return "Petrified enemy should start a 20 second timer"
	enemy._process(5.0)
	if enemy.petrify_warning_shown:
		enemy.free()
		return "Warning must not show before the last 10 seconds"
	enemy._process(6.0)
	if not enemy.petrify_warning_shown:
		enemy.free()
		return "Warning must show once 10 seconds remain"
	enemy.reset_petrification_timer()
	if not is_equal_approx(enemy.petrify_time_remaining, Enemy.PETRIFY_DURATION) or enemy.petrify_warning_shown:
		enemy.free()
		return "Shooting a statue again must reset the timer and warning"
	enemy._process(Enemy.PETRIFY_DURATION + 0.5)
	if enemy.petrified or enemy.current_state != Enemy.State.PATROL:
		enemy.free()
		return "Statue must turn back into its enemy after 20 seconds"
	if enemy.petrification_visual.visible:
		enemy.free()
		return "Statue visual must be hidden once the enemy is back"

	# A spawner stays linked to a petrified enemy and only respawns after removal.
	var spawner := EnemySpawner.new()
	enemy.petrified = true
	spawner.active_enemy = enemy
	spawner._process(100.0)
	if spawner.respawn_timer != 0.0:
		spawner.free()
		enemy.free()
		return "Spawner must not count down while its enemy or statue still exists"
	spawner._on_active_enemy_removed()
	if spawner.respawn_timer < spawner.respawn_interval:
		spawner.free()
		enemy.free()
		return "Spawner should be ready to respawn as soon as its enemy is gone"
	spawner.free()
	enemy.free()
	return ""

func test_enemy_grid_centering_and_menu_text_metrics() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	for cell in [Vector2i(0, 0), Vector2i(7, 7), Vector2i(15, 14)]:
		var center: Vector2 = gm.grid_to_world(cell)
		var expected := Vector2(
			Constants.PLAYFIELD_OFFSET_X + cell.x * Constants.TILE_SIZE + Constants.TILE_SIZE * 0.5,
			Constants.PLAYFIELD_OFFSET_Y + cell.y * Constants.TILE_SIZE + Constants.TILE_SIZE * 0.5)
		if center != expected or gm.world_to_grid(center) != cell:
			gm.free()
			return "Grid cell %s must map to its exact tile centre" % str(cell)
	gm.free()

	# Living body must be centred on the node origin so enemies sit on the grid.
	for path in ["res://Scenes/enemy.gd", "res://Scenes/noggle.gd", "res://Scenes/birdie.gd", "res://Scenes/zapper.gd", "res://Scenes/wall_hugger.gd", "res://Scenes/jumper_enemy.gd", "res://Scenes/pusher_enemy.gd", "res://Scenes/hades_shadow.gd", "res://Scenes/flame_beast.gd"]:
		var species = load(path).new()
		species.create_visual()
		var body_center: Vector2 = species.visual.position + species.visual.size * 0.5
		var offset := body_center.length()
		species.free()
		if offset > 1.0:
			return "%s living body is %.1f px off its grid centre" % [path, offset]

	var title = load("res://Scenes/title_screen.gd").new()
	var text_size: Vector2 = title._menu_text_size("Nouvelle Partie", 42)
	# draw_string() wants the baseline: it must sit one ascent below the top of the text box, not at the box centre.
	var baseline: Vector2 = title._baseline_origin(Vector2(100, 200), 42)
	title.free()
	if text_size.x <= 0.0 or text_size.y <= 0.0:
		return "Menu text metrics must be measurable for centred highlight"
	if baseline.x != 100.0 or baseline.y <= 200.0 or baseline.y >= 200.0 + text_size.y:
		return "Menu text baseline must sit inside its text box, got %s" % str(baseline)
	return ""


func test_level_editor_undo_erase_and_test_session() -> String:
	_ensure_game_session()
	var editor = load("res://Tools/level_editor.gd").new()
	# Tests run during SceneTree._init, before _ready fires, so build the UI explicitly.
	editor._build_interface()
	var paint_index: int = editor.TILE_CODES.keys().find("~")

	# Undo/redo restores previous terrain edits.
	editor.document = _editor_test_document()
	editor.active_tool = 0
	editor.terrain_picker.selected = paint_index
	editor._push_undo()
	editor._on_cell_selected(Vector2i(4, 4))
	if str(editor.document["grid"][4]).substr(4, 1) != "~":
		editor.queue_free()
		return "Painting water should change the grid"
	editor._undo()
	if str(editor.document["grid"][4]).substr(4, 1) != ".":
		editor.queue_free()
		return "Undo should restore the previous tile"
	editor._redo()
	if str(editor.document["grid"][4]).substr(4, 1) != "~":
		editor.queue_free()
		return "Redo should reapply the painted tile"

	# Erasing removes entities and resets terrain to ground.
	editor.document["soul_urns"].append([6, 6])
	editor._on_cell_erased(Vector2i(6, 6))
	for urn in editor.document["soul_urns"]:
		if urn[0] == 6 and urn[1] == 6:
			editor.queue_free()
			return "Erase should remove the urn on that cell"
	editor._on_cell_erased(Vector2i(4, 4))
	if str(editor.document["grid"][4]).substr(4, 1) != ".":
		editor.queue_free()
		return "Erase should reset terrain to ground"

	# Undo history is bounded.
	for i in range(editor.MAX_UNDO + 20):
		editor._push_undo()
	if editor.undo_stack.size() > editor.MAX_UNDO:
		editor.queue_free()
		return "Undo history must be capped at MAX_UNDO"
	editor.queue_free()
	return ""

func _ensure_game_session() -> Node:
	# Autoloads are not instantiated yet while this runner executes, so provide one.
	var existing = root.get_node_or_null("GameSession")
	if existing:
		return existing
	var created := Node.new()
	created.name = "GameSession"
	created.set_script(load("res://Scripts/game_session.gd"))
	root.add_child(created)
	return created

func test_editor_test_session_routing() -> String:
	var session = _ensure_game_session()
	session.custom_level_path = ""
	if session.is_custom_level() or session.scene_after_level() != "res://Scenes/overworld_map.tscn":
		return "Without a custom level the campaign flow must be unchanged"
	var test_path := "user://unit_test_editor_level.json"
	session.custom_level_path = test_path
	if not session.is_custom_level() or session.scene_after_level() != "res://Tools/level_editor.tscn":
		session.custom_level_path = ""
		return "A custom test level must return to the editor"

	var test_doc := _editor_test_document()
	test_doc["name"] = "Niveau de test editeur"
	var out := FileAccess.open(test_path, FileAccess.WRITE)
	out.store_string(JSON.stringify(test_doc))
	out.close()
	var manager = load("res://Scripts/level_manager.gd").new()
	manager.session_override = session
	var loaded = manager.get_level_data(1, 1)
	if loaded == null or loaded.level_name != "Niveau de test editeur":
		session.custom_level_path = ""
		manager.free()
		return "LevelManager must load the custom level while a test session is active"
	session.custom_level_path = ""
	var campaign = manager.get_level_data(1, 1)
	manager.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	if campaign == null or campaign.level_name == "Niveau de test editeur":
		return "Campaign level must load again once the custom session ends"
	return ""


func _editor_test_document() -> Dictionary:
	var grid: Array = []
	for y in range(Constants.GRID_ROWS):
		var row := ""
		for x in range(Constants.GRID_COLS):
			row += "#" if x == 0 or y == 0 or x == Constants.GRID_COLS - 1 or y == Constants.GRID_ROWS - 1 else "."
		grid.append(row)
	return {
		"world": 1, "level": 1, "name": "Test", "time_limit": 90,
		"player_start": [2, 2], "grid": grid, "soul_urns": [[5, 5]],
		"enemies": [], "spawners": []
	}

func _set_test_tile(doc: Dictionary, pos: Vector2i, code: String) -> void:
	var row: String = doc["grid"][pos.y]
	doc["grid"][pos.y] = row.substr(0, pos.x) + code + row.substr(pos.x + 1)

func test_level_checker_warnings() -> String:
	var checker = load("res://Scripts/level_checker.gd")
	var loader = load("res://Scripts/level_json_loader.gd").new()

	var clean := _editor_test_document()
	if not loader.validate_document(clean).is_empty():
		return "Baseline editor document should be structurally valid"
	if not checker.check(clean).is_empty():
		return "A clean level must not produce warnings: %s" % str(checker.check(clean))

	var no_urn := _editor_test_document()
	no_urn["soul_urns"] = []
	if checker.check(no_urn).is_empty():
		return "A level without urns must be flagged as unfinishable"

	var urn_in_wall := _editor_test_document()
	urn_in_wall["soul_urns"] = [[0, 0]]
	if checker.check(urn_in_wall).is_empty():
		return "An urn on a wall must be flagged"

	var start_on_water := _editor_test_document()
	_set_test_tile(start_on_water, Vector2i(2, 2), "~")
	if checker.check(start_on_water).is_empty():
		return "A player start on water must be flagged"

	var overlap := _editor_test_document()
	overlap["soul_urns"] = [[2, 2]]
	var found_overlap := false
	for warning in checker.check(overlap):
		if str(warning).contains("superposent"):
			found_overlap = true
	if not found_overlap:
		return "Overlapping start and urn must be flagged"

	var land_zapper := _editor_test_document()
	land_zapper["enemies"] = [{"type": "zapper", "pos": [4, 4], "pattern": []}]
	if checker.check(land_zapper).is_empty():
		return "A zapper placed on land must be flagged"

	var water_zapper := _editor_test_document()
	_set_test_tile(water_zapper, Vector2i(4, 4), "~")
	water_zapper["enemies"] = [{"type": "zapper", "pos": [4, 4], "pattern": []}]
	if not checker.check(water_zapper).is_empty():
		return "A zapper in water is valid: %s" % str(checker.check(water_zapper))

	var bad_boss := _editor_test_document()
	bad_boss["boss"] = {"type": "cyclops", "health": 3, "pos": [8, 7], "arena_pos": [10, 8], "arena_size": [4, 4]}
	if checker.check(bad_boss).is_empty():
		return "A boss or player outside the arena must be flagged"
	return ""


func _fill_test_row(gm: GridManager, y: int, tile: int) -> void:
	for x in range(Constants.GRID_COLS):
		gm.set_tile(Vector2i(x, y), tile)

func test_mirrors_reflect_and_block() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	for row in [4, 5, 6]:
		_fill_test_row(gm, row, Constants.TileType.GROUND)
	var result := ""
	# "/" sends right->up and down->left; "\" sends right->down and up->left.
	if GridManager.reflect(Vector2i.RIGHT, "slash") != Vector2i.UP or GridManager.reflect(Vector2i.DOWN, "slash") != Vector2i.LEFT:
		result = "A '/' mirror must bend right->up and down->left"
	elif GridManager.reflect(Vector2i.RIGHT, "backslash") != Vector2i.DOWN or GridManager.reflect(Vector2i.UP, "backslash") != Vector2i.LEFT:
		result = "A '\\' mirror must bend right->down and up->left"
	gm.set_mirror(Vector2i(6, 5), "slash")
	if result.is_empty() and (gm.is_walkable(Vector2i(6, 5)) or gm.is_enemy_walkable(Vector2i(6, 5))):
		result = "A mirror must be solid like a wall"
	if result.is_empty() and gm.rotate_mirror(Vector2i(6, 5)) != "backslash":
		result = "Rotating a mirror must flip its orientation"
	if result.is_empty() and gm.rotate_mirror(Vector2i(2, 2)) != "":
		result = "Rotating an empty cell must do nothing"
	gm.rotate_mirror(Vector2i(6, 5))  # back to slash
	if result.is_empty():
		result = _check_mirror_player_rules(gm)
	gm.free()
	return result

func _check_mirror_player_rules(gm: GridManager) -> String:
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = gm
	var result := ""
	# A statue or block sliding toward a mirror stops in front of it, like a wall.
	var final_pos: Vector2i = player.calculate_slide_path_on_ground(Vector2i(2, 5), Vector2i.RIGHT)
	if final_pos != Vector2i(5, 5):
		result = "A sliding block must stop in front of a mirror, got %s" % str(final_pos)
	# The hero turns the mirror he faces, only when adjacent and facing it.
	player.current_grid_pos = Vector2i(5, 5)
	player.current_direction = Constants.Direction.RIGHT
	if result.is_empty() and (not player.rotate_facing_mirror() or gm.get_mirror(Vector2i(6, 5)) != "backslash"):
		result = "The hero must turn the mirror he faces"
	player.current_direction = Constants.Direction.LEFT
	if result.is_empty() and player.rotate_facing_mirror():
		result = "The hero must not turn a mirror he is not facing"
	player.current_grid_pos = Vector2i(3, 5)
	player.current_direction = Constants.Direction.RIGHT
	if result.is_empty() and player.rotate_facing_mirror():
		result = "The hero must not turn a mirror that is not adjacent"
	player.free()
	return result

func test_laser_bends_on_mirrors_and_can_kill_the_hero() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	for row in range(2, 9):
		_fill_test_row(gm, row, Constants.TileType.GROUND)
	gm.set_mirror(Vector2i(6, 5), "slash")
	var start := gm.grid_to_world(Vector2i(4, 5))
	var shot := PetrifyProjectile.new()
	shot.grid_manager = gm
	shot.initialize(start + Vector2(40, 0), Constants.Direction.RIGHT, start)
	var result := ""
	shot.advance(gm.grid_to_world(Vector2i(6, 5)).x - shot.position.x)  # exactly to the mirror centre
	if shot.direction != Vector2.UP or shot.bounces != 1:
		result = "A laser hitting a '/' mirror going right must turn up, got %s" % str(shot.direction)
	elif not shot.position.is_equal_approx(gm.grid_to_world(Vector2i(6, 5))):
		result = "The laser must bend at the centre of the mirror"
	if result.is_empty():
		shot.advance(72.0 * 2.0)
		if gm.world_to_grid(shot.position) != Vector2i(6, 3):
			result = "After the bend the laser must travel straight up, got %s" % str(gm.world_to_grid(shot.position))
		elif shot.path_points.size() != 2 or shot.beam_points_local().size() < 3:
			result = "The beam must be drawn around the bend"
	if result.is_empty() and not shot.hits_hero(shot.position):
		result = "A bounced laser must hurt a hero standing on its head"
	shot.free()
	if result.is_empty():
		result = _check_laser_limits(gm, start)
	gm.free()
	return result

func _check_laser_limits(gm: GridManager, start: Vector2) -> String:
	var result := ""
	# Never the hero's own direct shot.
	var direct := PetrifyProjectile.new()
	direct.grid_manager = gm
	direct.initialize(start, Constants.Direction.RIGHT, start)
	if direct.hits_hero(start):
		result = "A direct shot must never hit the hero who fired it"
	direct.free()
	# Mirror loops are cut after MAX_BOUNCES.
	var loop := PetrifyProjectile.new()
	loop.grid_manager = gm
	loop.initialize(start, Constants.Direction.RIGHT, start)
	loop.bounces = PetrifyProjectile.MAX_BOUNCES
	loop.advance(72.0 * 2.0)
	if result.is_empty() and loop.bounces != PetrifyProjectile.MAX_BOUNCES:
		result = "The laser must stop bending after the bounce limit"
	loop.free()
	return result

func test_doors_block_edges_and_switches_open_them() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	for row in [4, 5, 6]:
		_fill_test_row(gm, row, Constants.TileType.GROUND)
	var result := ""
	if GridManager.edge_key(Vector2i(5, 5), Vector2i(6, 5)) != GridManager.edge_key(Vector2i(6, 5), Vector2i(5, 5)):
		result = "An edge must have the same key seen from both sides"
	elif GridManager.edge_key(Vector2i(5, 5), Vector2i(7, 5)).z >= 0:
		result = "Two cells that are not neighbours share no edge"
	if result.is_empty() and not gm.add_door(Vector2i(5, 5), Vector2i.RIGHT, "A"):
		result = "A door must be placeable between two neighbouring cells"
	if result.is_empty() and gm.add_door(Vector2i(0, 0), Vector2i.LEFT, "A"):
		result = "A door must not point outside the grid"
	if result.is_empty() and (not gm.edge_blocked(Vector2i(5, 5), Vector2i(6, 5)) or not gm.edge_blocked(Vector2i(6, 5), Vector2i(5, 5))):
		result = "A closed door must block both ways"
	if result.is_empty() and gm.edge_blocked(Vector2i(5, 5), Vector2i(5, 4)):
		result = "A door must only block its own edge"
	if result.is_empty():
		result = _check_door_movement(gm)
	if result.is_empty():
		result = _check_door_groups(gm)
	gm.free()
	return result

func _check_door_movement(gm: GridManager) -> String:
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = gm
	player.current_grid_pos = Vector2i(5, 5)
	player.target_grid_pos = Vector2i(5, 5)
	var result := ""
	if player.try_move(Vector2i.RIGHT):
		result = "A closed door must stop the hero"
	gm.set_door_open("A", true)
	if result.is_empty() and not player.try_move(Vector2i.RIGHT):
		result = "An open door must let the hero through"
	gm.set_door_open("A", false)
	player.is_moving = false
	var slide_end: Vector2i = player.calculate_slide_path_on_ground(Vector2i(2, 5), Vector2i.RIGHT)
	if result.is_empty() and slide_end != Vector2i(5, 5):
		result = "A sliding block must stop in front of a closed door, got %s" % str(slide_end)
	player.free()
	if result.is_empty():
		var noggle = load("res://Scenes/noggle.gd").new()
		noggle.grid_manager = gm
		noggle.current_grid_pos = Vector2i(5, 5)
		noggle.heading = Vector2i.RIGHT
		if noggle.pick_direction() == Vector2i.RIGHT:
			result = "A noggle must not walk through a closed door"
		noggle.free()
	return result

func _check_door_groups(gm: GridManager) -> String:
	# Doors with the same id open and close together.
	gm.add_door(Vector2i(8, 5), Vector2i.DOWN, "A")
	gm.set_door_open("A", true)
	if not gm.is_door_open("A") or gm.edge_blocked(Vector2i(8, 5), Vector2i(8, 6)):
		return "Every door sharing an id must open together"
	gm.set_door_open("A", false)
	if gm.is_door_open("A") or not gm.edge_blocked(Vector2i(8, 6), Vector2i(8, 5)):
		return "Every door sharing an id must close together"
	return ""

func test_mirrors_switches_and_doors_load_from_json_and_checker_pairs_them() -> String:
	var loader = load("res://Scripts/level_json_loader.gd").new()
	var checker = load("res://Scripts/level_checker.gd")
	var doc: Dictionary = _editor_test_document()
	doc["mirrors"] = [{"pos": [4, 4], "orientation": "backslash"}]
	doc["switches"] = [{"pos": [6, 6], "id": "A"}]
	doc["doors"] = [{"pos": [8, 8], "direction": "right", "id": "A"}]
	var parsed: Dictionary = loader.parse_text(JSON.stringify(doc))
	if not parsed.get("ok", false):
		return "A level with a mirror, a switch and a door must load: %s" % str(parsed.get("error", ""))
	var data: LevelData = parsed["data"]
	if data.mirrors.size() != 1 or data.mirrors[0]["orientation"] != "backslash":
		return "Mirrors must be converted to LevelData"
	if data.switches[0]["id"] != "A" or data.doors[0]["direction"] != Vector2i.RIGHT or data.doors[0]["id"] != "A":
		return "Switches and doors must be converted to LevelData"
	var rejected := _check_mechanics_rejections(loader, doc)
	if not rejected.is_empty():
		return rejected
	return _check_mechanics_warnings(checker, doc)

func _check_mechanics_rejections(loader, doc: Dictionary) -> String:
	var bad: Dictionary = doc.duplicate(true)
	bad["mirrors"] = [{"pos": [4, 4], "orientation": "diagonal"}]
	if loader.parse_text(JSON.stringify(bad)).get("ok", false):
		return "An unknown mirror orientation must be rejected"
	bad = doc.duplicate(true)
	bad["doors"] = [{"pos": [15, 8], "direction": "right", "id": "A"}]
	if loader.parse_text(JSON.stringify(bad)).get("ok", false):
		return "A door pointing outside the grid must be rejected"
	bad = doc.duplicate(true)
	bad["switches"] = [{"pos": [6, 6], "id": ""}]
	if loader.parse_text(JSON.stringify(bad)).get("ok", false):
		return "A switch without id must be rejected"
	return ""

func _check_mechanics_warnings(checker, doc: Dictionary) -> String:
	if not checker.check(doc).is_empty():
		return "A paired switch and door must raise no warning: %s" % str(checker.check(doc))
	var lonely_door: Dictionary = doc.duplicate(true)
	lonely_door["switches"] = []
	if checker.check(lonely_door).is_empty():
		return "A door without switch must be reported"
	var lonely_switch: Dictionary = doc.duplicate(true)
	lonely_switch["doors"] = []
	if checker.check(lonely_switch).is_empty():
		return "A switch without door must be reported"
	var wall_mirror: Dictionary = doc.duplicate(true)
	wall_mirror["mirrors"] = [{"pos": [0, 0], "orientation": "slash"}]
	if checker.check(wall_mirror).is_empty():
		return "A mirror inside a wall must be reported"
	return ""

func test_editor_places_mirrors_switches_and_doors() -> String:
	var editor = load("res://Tools/level_editor.gd").new()
	editor._build_interface()
	editor.document = _editor_test_document()
	editor.link_edit.text = "rouge"
	var result := ""
	# Mirror: placed with the chosen look, flipped by a second click.
	editor.active_tool = 16
	editor._on_cell_selected(Vector2i(4, 4))
	if editor.document["mirrors"].size() != 1 or editor.document["mirrors"][0]["orientation"] != "slash":
		result = "A new mirror must use the chosen orientation"
	editor._on_cell_selected(Vector2i(4, 4))
	if result.is_empty() and editor.document["mirrors"][0]["orientation"] != "backslash":
		result = "Clicking a mirror again must flip it"
	# Switch and door share the id typed in the panel.
	editor.active_tool = 17
	editor._on_cell_selected(Vector2i(6, 6))
	editor.active_tool = 18
	editor._on_cell_selected(Vector2i(8, 8))
	if result.is_empty() and (editor.document["switches"][0]["id"] != "rouge" or editor.document["doors"][0]["id"] != "rouge"):
		result = "A switch and its door must share the id from the panel"
	if result.is_empty() and editor.document["doors"][0]["direction"] != "right":
		result = "A new door must point in the chosen direction"
	editor._on_cell_selected(Vector2i(8, 8))
	if result.is_empty() and editor.document["doors"][0]["direction"] != "down":
		result = "Clicking a door again must turn it a quarter clockwise"
	# A door on the right edge of the grid cannot point outside: it is refused.
	if result.is_empty():
		editor.document["doors"].clear()
		editor.direction_picker.select(0)  # right
		editor.active_tool = 18
		editor.notice_dialog = AcceptDialog.new()
		editor._on_cell_selected(Vector2i(Constants.GRID_COLS - 1, 5))
		if not editor.document["doors"].is_empty():
			result = "A door pointing outside the grid must be refused"
		editor.notice_dialog.free()
	# Erasing a cell clears all three.
	if result.is_empty():
		editor._on_cell_erased(Vector2i(4, 4))
		editor._on_cell_erased(Vector2i(6, 6))
		if not editor.document["mirrors"].is_empty() or not editor.document["switches"].is_empty():
			result = "Erasing a cell must remove its mirror and switch"
	editor.free()
	return result

func test_editor_springs_can_be_oriented() -> String:
	var editor = load("res://Tools/level_editor.gd").new()
	editor._build_interface()
	editor.document = _editor_test_document()
	editor.active_tool = 5  # spring tool
	var result := ""
	var cell := Vector2i(4, 4)
	editor._on_cell_selected(cell)
	var springs: Array = editor.document["springs"]
	if springs.size() != 1 or springs[0]["direction"] != "right":
		result = "A new spring must face the direction chosen in the panel"
	# Clicking the same spring again turns it a quarter clockwise: right, down, left, up, right.
	for expected in ["down", "left", "up", "right"]:
		if not result.is_empty():
			break
		editor._on_cell_selected(cell)
		springs = editor.document["springs"]
		if springs.size() != 1 or springs[0]["direction"] != expected:
			result = "Clicking a spring must turn it to %s" % expected
	if result.is_empty():
		editor._on_cell_selected(Vector2i(6, 4))
		if editor.document["springs"].size() != 2:
			result = "Clicking an empty cell must place a second spring"
	# Gates and belts turn the same way.
	if result.is_empty():
		editor.active_tool = 9
		editor._on_cell_selected(Vector2i(8, 8))
		editor._on_cell_selected(Vector2i(8, 8))
		if editor.document["one_way_gates"][0]["direction"] != "down":
			result = "Clicking a one-way gate must turn it as well"
	editor.free()
	return result

func test_world_1_proposals_are_valid() -> String:
	# Proposed levels 4-15 live in Data/Levels_proposals until the user approves them.
	var loader = load("res://Scripts/level_json_loader.gd").new()
	var checker = load("res://Scripts/level_checker.gd")
	for level_number in range(4, 16):
		var path := "res://Data/Levels_proposals/world_1_level_%d.json" % level_number
		var result: Dictionary = loader.load_file(path)
		if not result.get("ok", false):
			return "Proposal %d invalid: %s" % [level_number, str(result.get("error", "unknown"))]
		var data: LevelData = result["data"]
		if data.level_idx != level_number or data.soul_urns.is_empty() or data.spawners.is_empty():
			return "Proposal %d needs its number, urns and spawners" % level_number
		var file := FileAccess.open(path, FileAccess.READ)
		var warnings: Array[String] = checker.check(JSON.parse_string(file.get_as_text()))
		file.close()
		if not warnings.is_empty():
			return "Proposal %d: %s" % [level_number, warnings[0]]
	return ""

func test_spawner_is_solid_like_a_wall() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	for row in [4, 5, 6]:
		_fill_test_row(gm, row, Constants.TileType.GROUND)
	gm.set_tile(Vector2i(9, 5), Constants.TileType.WATER)
	gm.set_spawner(Vector2i(6, 5))
	var result := ""
	if gm.is_walkable(Vector2i(6, 5)) or gm.is_enemy_walkable(Vector2i(6, 5)):
		result = "Nobody may walk onto a spawner"
	elif not gm.is_walkable(Vector2i(5, 5)):
		result = "Cells next to a spawner must stay walkable"
	if result.is_empty():
		# A sliding block or statue stops in front of the spawner, never on it.
		var player = load("res://Scenes/player.gd").new()
		player.grid_manager = gm
		var final_pos: Vector2i = player.calculate_slide_path_on_ground(Vector2i(2, 5), Vector2i.RIGHT)
		if final_pos != Vector2i(5, 5):
			result = "A sliding block must stop in front of a spawner, got %s" % str(final_pos)
		player.free()
	if result.is_empty():
		# Flying and swimming enemies cannot cross it either.
		var bird = load("res://Scenes/birdie.gd").new()
		bird.grid_manager = gm
		var zap = load("res://Scenes/zapper.gd").new()
		zap.grid_manager = gm
		gm.set_spawner(Vector2i(9, 5))
		if bird.can_fly_over(Vector2i(6, 5)):
			result = "A birdie must not fly over a spawner"
		elif zap.can_swim_in(Vector2i(9, 5)):
			result = "A zapper must not swim through a spawner"
		bird.free()
		zap.free()
	if result.is_empty():
		gm.clear_spawners()
		if not gm.is_walkable(Vector2i(6, 5)):
			result = "Clearing spawners must free their cells"
	gm.free()
	return result

func test_pause_menu_world_map_survives_scene_change() -> String:
	# The main scene reacts to overworld_requested by changing scene, which removes the menu from the tree.
	# The menu must then stop instead of touching get_tree()/get_node() on a detached node.
	var pm = load("res://Scenes/pause_menu.gd").new()
	root.add_child(pm)
	var handled := [false]
	pm.overworld_requested.connect(func():
		handled[0] = true
		root.remove_child(pm))
	pm._on_button_pressed(3)
	var result := "" if handled[0] and not pm.is_inside_tree() else "Pause menu world-map button should reach its listener"
	pm.free()
	return result

func test_petrified_mid_move_snaps_to_one_cell() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	var start := Vector2i(4, 5)
	var goal := Vector2i(5, 5)
	var result := ""
	for case in [[0.7, goal], [0.2, start]]:
		var e := Enemy.new()
		e.grid_manager = gm
		e.visual = ColorRect.new()
		e.add_child(e.visual)
		e.eyes = ColorRect.new()
		e.visual.add_child(e.eyes)
		e.create_petrification_overlay()
		e.current_grid_pos = start
		e.target_grid_pos = goal
		e.is_moving = true
		e.position = gm.grid_to_world(start).lerp(gm.grid_to_world(goal), case[0])
		e.petrify()
		var cell: Vector2i = case[1]
		if not e.petrified or e.is_moving:
			result = "Enemy petrified mid-move must stop moving"
		elif e.current_grid_pos != cell or e.target_grid_pos != cell:
			result = "Statue must claim exactly one cell (the closer one), got %s" % str(e.current_grid_pos)
		elif not e.position.is_equal_approx(gm.grid_to_world(cell)):
			result = "Statue must be centered on its cell so the hero cannot walk through it"
		e.free()
		if not result.is_empty():
			break
	gm.free()
	return result

func test_enemies_never_share_a_cell() -> String:
	var stub = Node.new()
	var stub_script := GDScript.new()
	stub_script.source_code = "extends Node\nvar enemies: Array = []\n"
	stub_script.reload()
	stub.set_script(stub_script)
	var a: Enemy = Enemy.new()
	var b: Enemy = Enemy.new()
	for e in [a, b]:
		e.game_manager = stub
		stub.enemies.append(e)
	var result := ""
	# A (4,5) starts toward (5,5) first; B (6,5) wants the same cell and must stay put.
	a.current_grid_pos = Vector2i(4, 5)
	a.target_grid_pos = Vector2i(5, 5)
	a.is_moving = true
	b.current_grid_pos = Vector2i(6, 5)
	b.target_grid_pos = Vector2i(5, 5)
	b.is_moving = true
	if not a.is_moving:
		result = "The first enemy to start moving must keep its move"
	elif b.is_moving or b.target_grid_pos != b.current_grid_pos:
		result = "A second enemy must not move onto a cell another enemy is heading to"
	if result.is_empty():
		# A arrives; the cell is now occupied, B still has to wait.
		a.current_grid_pos = Vector2i(5, 5)
		a.is_moving = false
		b.target_grid_pos = Vector2i(5, 5)
		b.is_moving = true
		if b.is_moving:
			result = "An enemy must not walk onto a cell occupied by another enemy"
	if result.is_empty():
		b.target_grid_pos = Vector2i(7, 5)
		b.is_moving = true
		if not b.is_moving:
			result = "An enemy must still move onto a free cell"
	if result.is_empty():
		# A noggle treats an enemy in front of it as an obstacle and turns instead of waiting.
		var noggle = load("res://Scenes/noggle.gd").new()
		noggle.game_manager = stub
		stub.enemies.append(noggle)
		noggle.grid_manager = GridManager.new()
		noggle.grid_manager.initialize_grid()
		for row in [4, 5, 6]:
			_fill_test_row(noggle.grid_manager, row, Constants.TileType.GROUND)
		a.current_grid_pos = Vector2i(5, 5)
		a.target_grid_pos = Vector2i(5, 5)
		noggle.current_grid_pos = Vector2i(4, 5)
		noggle.target_grid_pos = Vector2i(4, 5)
		noggle.heading = Vector2i.RIGHT
		if noggle.pick_direction() == Vector2i.RIGHT:
			result = "Noggle must not walk into a cell held by another enemy"
		noggle.grid_manager.free()
		noggle.free()
	a.free()
	b.free()
	stub.free()
	return result

func test_spawner_respawns_instantly_after_destruction() -> String:
	var spawner = load("res://Scenes/enemy_spawner.gd").new()
	spawner.respawn_interval = 5.2
	spawner.respawn_timer = 0.0
	spawner._on_active_enemy_removed()
	var ready_now: bool = spawner.respawn_timer >= spawner.respawn_interval
	spawner.free()
	return "" if ready_now else "Spawner should be ready to respawn the moment its enemy is destroyed"

func test_hero_turns_in_place_on_a_tap() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	for row in [4, 5, 6]:
		_fill_test_row(gm, row, Constants.TileType.GROUND)
	var result := ""
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = gm
	player.current_grid_pos = Vector2i(5, 5)
	player.target_grid_pos = Vector2i(5, 5)
	player.current_direction = Constants.Direction.DOWN
	Input.action_press("move_right")
	player.handle_input(0.05)
	if player.current_direction != Constants.Direction.RIGHT or player.is_moving:
		result = "A new direction must turn the hero without moving"
	Input.action_release("move_right")
	player.handle_input(0.05)
	if result.is_empty() and player.is_moving:
		result = "A tap must only turn the hero"
	if result.is_empty():
		# Already facing right: pressing right walks at once.
		Input.action_press("move_right")
		player.handle_input(0.05)
		if not player.is_moving or player.target_grid_pos != Vector2i(6, 5):
			result = "Pressing the facing direction must walk immediately"
		Input.action_release("move_right")
		player.handle_input(0.05)  # a frame without the key ends the hold
	if result.is_empty():
		# Holding a new direction walks once the turn delay is over.
		player.is_moving = false
		player.target_grid_pos = player.current_grid_pos
		player.current_direction = Constants.Direction.DOWN
		Input.action_press("move_right")
		var quarter_delay: float = player.TURN_DELAY / 4.0
		for i in range(4):  # held 0, 1/4, 1/2 and 3/4 of the delay: still only turning
			player.handle_input(quarter_delay)
			if player.is_moving:
				result = "The hero must wait for the turn delay before walking"
		player.handle_input(player.TURN_DELAY / 2.0)  # now past the delay
		if result.is_empty() and not player.is_moving:
			result = "Holding the direction must walk after the turn delay"
		Input.action_release("move_right")
		player.handle_input(0.05)
	# A key already held during the previous step counts as a long press: the hero walks as soon as it ends.
	if result.is_empty():
		player.is_moving = false
		player.target_grid_pos = player.current_grid_pos
		player.current_direction = Constants.Direction.DOWN
		Input.action_press("move_right")
		for i in range(4):
			player.track_direction_hold(0.05)  # mid-step: only the hold time is measured
		player.handle_input(0.016)  # the step just ended
		if not player.is_moving:
			result = "A key held during the previous step must walk as soon as the step ends"
		Input.action_release("move_right")
		player.handle_input(0.05)
	player.free()
	gm.free()
	return result

func test_statue_never_shares_a_cell_with_the_hero() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	for row in [4, 5, 6]:
		_fill_test_row(gm, row, Constants.TileType.GROUND)
	var result := ""
	# 1. A statue petrified mid-move snaps to the cell the hero is NOT on, even if it is the closer one.
	var e := Enemy.new()
	e.grid_manager = gm
	e.current_grid_pos = Vector2i(4, 5)
	e.target_grid_pos = Vector2i(5, 5)
	e.position = gm.grid_to_world(Vector2i(5, 5)) - Vector2(10, 0)  # almost on the hero's cell
	e.snap_to_nearest_cell([Vector2i(5, 5)])
	if e.current_grid_pos != Vector2i(4, 5):
		result = "A statue must not snap onto the hero's cell, got %s" % str(e.current_grid_pos)
	e.free()
	# 2. A statue on the hero's own cell pushes the hero out, previous cell first.
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = gm
	player.current_grid_pos = Vector2i(5, 5)
	player.target_grid_pos = Vector2i(5, 5)
	player.previous_grid_pos = Vector2i(4, 5)
	if result.is_empty():
		if not player.reject_cell(Vector2i(5, 5)) or player.current_grid_pos != Vector2i(4, 5):
			result = "The hero must step back when a statue appears on his cell, got %s" % str(player.current_grid_pos)
		elif not player.position.is_equal_approx(gm.grid_to_world(Vector2i(4, 5))):
			result = "The hero must be centered on the cell he stepped to"
	# 3. Cell taken, previous cell blocked: another free neighbour is used, never the statue cell.
	if result.is_empty():
		player.current_grid_pos = Vector2i(5, 5)
		player.target_grid_pos = Vector2i(5, 5)
		player.previous_grid_pos = Vector2i(4, 5)
		gm.set_tile(Vector2i(4, 5), Constants.TileType.WALL)
		if not player.reject_cell(Vector2i(5, 5)) or player.current_grid_pos == Vector2i(5, 5) or player.current_grid_pos == Vector2i(4, 5):
			result = "The hero must find another free neighbour, got %s" % str(player.current_grid_pos)
		gm.set_tile(Vector2i(4, 5), Constants.TileType.GROUND)
	# 4. Walking toward the statue's cell: the move is cancelled.
	if result.is_empty():
		player.current_grid_pos = Vector2i(3, 5)
		player.target_grid_pos = Vector2i(4, 5)
		player.is_moving = true
		if not player.reject_cell(Vector2i(4, 5)) or player.target_grid_pos != Vector2i(3, 5):
			result = "A hero walking into a new statue must turn back"
	# 5. A statue elsewhere does not touch the hero.
	if result.is_empty():
		player.is_moving = false
		player.current_grid_pos = Vector2i(3, 5)
		player.target_grid_pos = Vector2i(3, 5)
		if player.reject_cell(Vector2i(8, 5)) or player.current_grid_pos != Vector2i(3, 5):
			result = "A statue on another cell must leave the hero alone"
	player.free()
	gm.free()
	return result

func test_hero_fires_one_laser_at_a_time() -> String:
	var player = load("res://Scenes/player.gd").new()
	var fired := [0]
	player.petrify_shot_fired.connect(func(_direction): fired[0] += 1)
	player.fire_petrify_shot()
	player.fire_petrify_shot()
	var result := ""
	if fired[0] != 1:
		result = "A second shot must wait until the first one hit something"
	player.on_shot_finished()
	player.fire_petrify_shot()
	if result.is_empty() and fired[0] != 2:
		result = "The hero must fire again once the previous shot is finished"
	player.free()
	return result

func test_laser_beam_grows_then_trails() -> String:
	var shot := PetrifyProjectile.new()
	shot.initialize(Vector2(500, 300), Constants.Direction.RIGHT, Vector2(460, 300))
	var result := ""
	if not is_equal_approx(shot.beam_tail_length(), 40.0):
		result = "The laser must start out of the hero and grow from there"
	shot.position = Vector2(460.0 + 1000.0, 300)
	if result.is_empty() and not is_equal_approx(shot.beam_tail_length(), PetrifyProjectile.BEAM_MAX_LENGTH):
		result = "The laser must trail at most 4 tiles behind its head"
	if result.is_empty() and shot.speed < 800.0:
		result = "A laser must be fast"
	shot.free()
	return result

func test_noggle_straight_line_and_turn() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	for row in [4, 5, 6]:
		_fill_test_row(gm, row, Constants.TileType.GROUND)
	gm.set_tile(Vector2i(7, 5), Constants.TileType.WALL)
	gm.set_tile(Vector2i(1, 5), Constants.TileType.WATER)
	gm.set_push_block(Vector2i(4, 5))
	var noggle = load("res://Scenes/noggle.gd").new()
	noggle.grid_manager = gm
	noggle.patrol_pattern = [Vector2i.RIGHT]
	var result := ""
	noggle.current_grid_pos = Vector2i(5, 5)
	if noggle.pick_direction() != Vector2i.RIGHT:
		result = "Noggle should keep going straight on free ground"
	# Blocked by a wall, a push block or the water edge with both sides open: always a quarter-turn, on either side.
	for case in [[Vector2i(6, 5), Vector2i.RIGHT, "wall"], [Vector2i(5, 5), Vector2i.LEFT, "push block"], [Vector2i(2, 5), Vector2i.LEFT, "water edge"]]:
		if not result.is_empty():
			break
		var heading: Vector2i = case[1]
		var seen := {}
		for i in range(60):
			noggle.heading = heading
			noggle.current_grid_pos = case[0]
			seen[noggle.pick_direction()] = true
		var side := Vector2i(-heading.y, heading.x)
		if seen.has(heading) or seen.has(Vector2i.ZERO):
			result = "Noggle must not walk into a %s" % case[2]
		elif seen.has(-heading):
			result = "Noggle must prefer a quarter-turn over a half-turn at a %s" % case[2]
		elif not (seen.has(side) and seen.has(-side)):
			result = "Noggle must not always turn the same way at a %s" % case[2]
	if result.is_empty():
		# Dead end: both sides blocked, so the half-turn is the only way out.
		for x in range(2, 7):
			gm.set_tile(Vector2i(x, 8), Constants.TileType.GROUND)
		gm.set_tile(Vector2i(7, 8), Constants.TileType.WALL)
		noggle.heading = Vector2i.RIGHT
		noggle.current_grid_pos = Vector2i(6, 8)
		if noggle.pick_direction() != Vector2i.LEFT:
			result = "Noggle must turn around in a dead end"
	noggle.free()
	gm.free()
	return result

func test_hole_and_hero_only_tiles() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	_fill_test_row(gm, 5, Constants.TileType.GROUND)
	gm.set_tile(Vector2i(4, 5), Constants.TileType.HOLE)
	gm.set_tile(Vector2i(6, 5), Constants.TileType.PLAYER_ONLY)

	if gm.is_walkable(Vector2i(4, 5)) or gm.is_enemy_walkable(Vector2i(4, 5)):
		gm.free()
		return "Nobody may walk on a water hole"
	if not gm.is_walkable(Vector2i(6, 5)):
		gm.free()
		return "The hero must be able to walk on violet tiles"
	if gm.is_enemy_walkable(Vector2i(6, 5)):
		gm.free()
		return "Enemies must not walk on violet tiles"
	if not gm.is_enemy_walkable(Vector2i(2, 5)):
		gm.free()
		return "Enemies must still walk on plain ground"

	# A sliding block crosses a hole and rests on the far side.
	var player = load("res://Scenes/player.gd").new()
	player.grid_manager = gm
	var final_pos: Vector2i = player.calculate_slide_path_on_ground(Vector2i(2, 5), Vector2i.RIGHT)
	if final_pos == Vector2i(4, 5) or final_pos.x < 5:
		player.free()
		gm.free()
		return "A sliding block must pass over the hole, got %s" % str(final_pos)
	# A block that would stop on the hole backs off to the cell before it.
	gm.set_tile(Vector2i(5, 5), Constants.TileType.WALL)
	final_pos = player.calculate_slide_path_on_ground(Vector2i(2, 5), Vector2i.RIGHT)
	player.free()
	gm.free()
	if final_pos != Vector2i(3, 5):
		return "A block must never rest on a hole, expected (3, 5) got %s" % str(final_pos)
	return ""

func test_push_block_slide_and_sink() -> String:
	var gm := GridManager.new()
	gm.initialize_grid()
	_fill_test_row(gm, 5, Constants.TileType.GROUND)
	gm.set_tile(Vector2i(9, 5), Constants.TileType.WATER)
	var block = load("res://Scenes/push_block.gd").new()
	block.initialize(Vector2i(3, 5), gm)
	if not gm.has_push_block(Vector2i(3, 5)) or gm.is_walkable(Vector2i(3, 5)):
		block.free()
		gm.free()
		return "A push block must occupy and block its cell"
	if gm.is_enemy_walkable(Vector2i(3, 5)):
		block.free()
		gm.free()
		return "Enemies must not walk through a push block"
	block.slide_to(Vector2i(7, 5))
	if gm.has_push_block(Vector2i(3, 5)) or not gm.has_push_block(Vector2i(7, 5)):
		block.free()
		gm.free()
		return "Sliding must move the occupied cell"
	block.slide_to(Vector2i(9, 5))
	var bridged := gm.get_tile(Vector2i(9, 5)) == Constants.TileType.ICE
	var released := not gm.has_push_block(Vector2i(9, 5)) and not gm.has_push_block(Vector2i(7, 5))
	block.free()
	gm.free()
	if not bridged:
		return "A block entering water must turn it into a bridge"
	if not released:
		return "A sunk block must free its cell"
	return ""

func test_bonus_items_and_gorgon_orb() -> String:
	var gm_script = load("res://Scripts/game_manager.gd")
	var game_mgr = Node.new()
	game_mgr.set_script(gm_script)
	var grid := GridManager.new()
	grid.initialize_grid()
	game_mgr.grid_manager = grid
	var enemy := Enemy.new()
	enemy.visual = ColorRect.new()
	enemy.add_child(enemy.visual)
	enemy.eyes = ColorRect.new()
	enemy.visual.add_child(enemy.eyes)
	enemy.create_petrification_overlay()
	enemy.game_manager = game_mgr
	game_mgr.enemies.append(enemy)

	var before: int = game_mgr.score
	game_mgr.collect_bonus("ambrosia")
	if game_mgr.score != before + 500:
		enemy.free()
		grid.free()
		game_mgr.free()
		return "Ambrosia should be worth 500 points"
	var count: int = game_mgr.petrify_all_enemies()
	if count != 1 or not enemy.petrified:
		enemy.free()
		grid.free()
		game_mgr.free()
		return "The Gorgon orb must petrify every living enemy"
	if game_mgr.petrify_all_enemies() != 0:
		enemy.free()
		grid.free()
		game_mgr.free()
		return "Already petrified enemies must not be counted twice"
	enemy.free()
	grid.free()
	game_mgr.free()
	return ""

func test_new_tiles_json_round_trip() -> String:
	var loader = load("res://Scripts/level_json_loader.gd").new()
	var doc := _editor_test_document()
	_set_test_tile(doc, Vector2i(4, 4), "o")
	_set_test_tile(doc, Vector2i(5, 4), "v")
	doc["push_blocks"] = [[6, 6]]
	doc["bonus_items"] = [{"pos": [7, 7], "kind": "ambrosia"}, {"pos": [8, 8], "kind": "gorgon_orb"}]
	if not loader.validate_document(doc).is_empty():
		return "Document with new elements should validate: %s" % loader.validate_document(doc)
	var result: Dictionary = loader.parse_text(JSON.stringify(doc))
	if not result.get("ok", false):
		return "Document should load: %s" % result.get("error", "")
	var data = result["data"]
	if data.grid_layout[4][4] != Constants.TileType.HOLE or data.grid_layout[4][5] != Constants.TileType.PLAYER_ONLY:
		return "Hole and violet glyphs must convert to tile types"
	if data.push_blocks != [Vector2i(6, 6)]:
		return "Push blocks must load as grid positions"
	if data.bonus_items.size() != 2 or data.bonus_items[1]["kind"] != "gorgon_orb":
		return "Bonus items must keep their kind"
	doc["bonus_items"] = [{"pos": [7, 7], "kind": "mystery"}]
	if loader.validate_document(doc).is_empty():
		return "An unknown bonus kind must be rejected"
	return ""

