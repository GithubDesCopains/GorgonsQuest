extends PuzzleBoss
class_name ChimeraBoss

## Chimera: telegraphed fire line and fast charge through an arena lane.

@export var attack_interval: float = 1.9
@export var fire_telegraph_time: float = 0.75
@export var charge_telegraph_time: float = 0.65

var attack_timer: float = 0.0
var attack_timer_remaining: float = 0.0
var attack_count: int = 0
var attack_phase: String = "idle"
var attack_target: Vector2i = Vector2i(-1, -1)
var arena_rect: Rect2i
var telegraphs: Array[ColorRect] = []

signal chimera_attack_telegraphed(kind: String, cells: Array[Vector2i])
signal chimera_attack_resolved(kind: String, target: Vector2i, hit_player: bool)

func _ready():
	super._ready()
	var main = SceneLookup.main_scene(self)
	game_manager = main.get_node_or_null("GameManager") if main else null
	if is_instance_valid(game_manager):
		arena_rect = game_manager.boss_arena_rect

func configure(name: String = "Chimera", hp: int = 5, summon_type: String = "flame_beast", interval: float = 2.5):
	super.configure(name, hp, summon_type, interval)

func _process(delta: float):
	super._process(delta)
	if defeated or not is_instance_valid(game_manager) or not is_instance_valid(game_manager.player):
		return
	if attack_phase == "idle":
		attack_timer += delta
		if attack_timer >= attack_interval:
			attack_timer = 0.0
			begin_next_attack(game_manager.player.current_grid_pos, attack_count)
	else:
		attack_timer_remaining -= delta
		if attack_timer_remaining <= 0.0:
			resolve_attack(game_manager.player.current_grid_pos)

func begin_next_attack(player_pos: Vector2i, phase_index: int = -1):
	var phase = attack_count if phase_index < 0 else phase_index
	var boss_pos = boss_grid_position()
	if phase % 2 == 0:
		attack_phase = "fire_line"
		attack_target = choose_attack_lane(boss_pos, player_pos, arena_rect)
		attack_timer_remaining = fire_telegraph_time
		var cells = get_line_cells(boss_pos, attack_target, arena_rect)
		show_telegraph(cells, Color("#ff7138"))
		chimera_attack_telegraphed.emit("fire_line", cells)
	else:
		attack_phase = "charge"
		attack_target = clamp_to_arena(player_pos, arena_rect)
		attack_timer_remaining = charge_telegraph_time
		var cells = get_charge_lane(boss_pos, attack_target, arena_rect)
		show_telegraph(cells, Color("#ffcc45"))
		chimera_attack_telegraphed.emit("charge", cells)
	attack_count = phase + 1

func boss_grid_position() -> Vector2i:
	if is_instance_valid(game_manager) and is_instance_valid(game_manager.grid_manager):
		return game_manager.grid_manager.world_to_grid(position)
	return Vector2i(roundi(position.x / Constants.TILE_SIZE), roundi(position.y / Constants.TILE_SIZE))

func choose_attack_lane(boss_pos: Vector2i, player_pos: Vector2i, arena: Rect2i) -> Vector2i:
	var interior = arena_interior(arena)
	var target = player_pos
	if absi(player_pos.x - boss_pos.x) >= absi(player_pos.y - boss_pos.y):
		target.y = boss_pos.y
	else:
		target.x = boss_pos.x
	return clamp_to_arena(target, interior)

func get_line_cells(boss_pos: Vector2i, target: Vector2i, arena: Rect2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var interior = arena_interior(arena)
	if interior.size == Vector2i.ZERO:
		return cells
	if target.y == boss_pos.y:
		var start_x = mini(boss_pos.x, target.x)
		var end_x = maxi(boss_pos.x, target.x)
		for x in range(start_x, end_x + 1):
			var pos = Vector2i(x, boss_pos.y)
			if interior.has_point(pos):
				cells.append(pos)
	elif target.x == boss_pos.x:
		var start_y = mini(boss_pos.y, target.y)
		var end_y = maxi(boss_pos.y, target.y)
		for y in range(start_y, end_y + 1):
			var pos = Vector2i(boss_pos.x, y)
			if interior.has_point(pos):
				cells.append(pos)
	return cells

func get_charge_lane(boss_pos: Vector2i, target: Vector2i, arena: Rect2i) -> Array[Vector2i]:
	# Charge is axis-aligned; target determines horizontal or vertical lane.
	var lane_target = target
	if absi(target.x - boss_pos.x) >= absi(target.y - boss_pos.y):
		lane_target.y = boss_pos.y
	else:
		lane_target.x = boss_pos.x
	return get_line_cells(boss_pos, lane_target, arena)

func is_player_hit_by_attack(player_pos: Vector2i, boss_pos: Vector2i, target: Vector2i, phase: String, arena: Rect2i) -> bool:
	if phase == "fire_line":
		return get_line_cells(boss_pos, target, arena).has(player_pos)
	if phase == "charge":
		return get_charge_lane(boss_pos, target, arena).has(player_pos)
	return false

func resolve_attack(player_pos: Vector2i) -> bool:
	if attack_phase == "idle":
		return false
	var phase = attack_phase
	var target = attack_target
	var boss_pos = boss_grid_position()
	attack_phase = "idle"
	attack_timer_remaining = 0.0
	clear_telegraphs()
	if phase == "charge":
		await animate_charge(target)
	if not is_instance_valid(self) or defeated:
		return false
	var actual_player_pos = player_pos
	if is_instance_valid(game_manager) and is_instance_valid(game_manager.player):
		actual_player_pos = game_manager.player.current_grid_pos
	var hit = is_player_hit_by_attack(actual_player_pos, boss_pos, target, phase, arena_rect)
	chimera_attack_resolved.emit(phase, target, hit)
	if hit and is_instance_valid(game_manager):
		game_manager.player_hit_by_enemy()
	return hit

func animate_charge(target: Vector2i):
	if not is_inside_tree() or not is_instance_valid(game_manager):
		return
	var target_world = game_manager.grid_manager.grid_to_world(target)
	var body_start = position
	var charge_tween = create_tween()
	charge_tween.tween_property(self, "position", target_world, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	charge_tween.tween_property(self, "position", body_start, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await charge_tween.finished

func arena_interior(arena: Rect2i) -> Rect2i:
	if arena.size.x < 3 or arena.size.y < 3:
		return Rect2i()
	return Rect2i(arena.position + Vector2i.ONE, arena.size - Vector2i(2, 2))

func clamp_to_arena(pos: Vector2i, area: Rect2i) -> Vector2i:
	if area.size == Vector2i.ZERO:
		return pos
	return Vector2i(clampi(pos.x, area.position.x, area.end.x - 1), clampi(pos.y, area.position.y, area.end.y - 1))

func show_telegraph(cells: Array[Vector2i], tint: Color):
	clear_telegraphs()
	if not is_inside_tree():
		return
	var main = SceneLookup.main_scene(self)
	if not main:
		return
	for cell in cells:
		var warning = ColorRect.new()
		warning.size = Vector2(Constants.TILE_SIZE - 8, Constants.TILE_SIZE - 8)
		warning.position = Vector2(Constants.PLAYFIELD_OFFSET_X + cell.x * Constants.TILE_SIZE + 4, Constants.PLAYFIELD_OFFSET_Y + cell.y * Constants.TILE_SIZE + 4)
		warning.color = Color(tint.r, tint.g, tint.b, 0.42)
		warning.z_index = Constants.LAYER_EFFECTS
		main.add_child(warning)
		telegraphs.append(warning)

func clear_telegraphs():
	for warning in telegraphs:
		if is_instance_valid(warning):
			warning.queue_free()
	telegraphs.clear()

func build_visual():
	body = ColorRect.new()
	body.name = "ChimeraBody"
	body.size = Vector2(150, 124)
	body.position = Vector2(-75, -58)
	body.color = Color("#8c4e3a")
	add_child(body)
	var lion_mane = ColorRect.new()
	lion_mane.size = Vector2(88, 84)
	lion_mane.position = Vector2(-44, -36)
	lion_mane.color = Color("#d18a45")
	body.add_child(lion_mane)
	var lion_face = ColorRect.new()
	lion_face.size = Vector2(46, 40)
	lion_face.position = Vector2(-23, -24)
	lion_face.color = Color("#e6b45b")
	body.add_child(lion_face)
	var eye = ColorRect.new()
	eye.size = Vector2(20, 7)
	eye.position = Vector2(-10, -10)
	eye.color = Color("#fff0a0")
	body.add_child(eye)
	var goat_horn = ColorRect.new()
	goat_horn.size = Vector2(10, 30)
	goat_horn.position = Vector2(38, -52)
	goat_horn.color = Color("#ece0c0")
	body.add_child(goat_horn)
	var snake_tail = ColorRect.new()
	snake_tail.size = Vector2(52, 12)
	snake_tail.position = Vector2(28, 34)
	snake_tail.color = Color("#54a56b")
	body.add_child(snake_tail)
	fit_parts_to_body()
	build_health_bar()

func build_health_bar():
	var back = ColorRect.new()
	back.name = "HealthBack"
	back.size = Vector2(190, 18)
	back.position = Vector2(-95, -126)
	back.color = Color("#35251f")
	add_child(back)
	health_fill = ColorRect.new()
	health_fill.name = "HealthFill"
	health_fill.position = Vector2(-92, -123)
	health_fill.size = Vector2(184, 12)
	health_fill.color = Color("#d7553e")
	add_child(health_fill)
