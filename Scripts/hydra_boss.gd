extends PuzzleBoss
class_name HydraBoss

## Lernaean Hydra: telegraphed acid spit and water-line sweep.

@export var attack_interval: float = 2.0
@export var acid_telegraph_time: float = 0.72
@export var sweep_telegraph_time: float = 0.9
@export var acid_lead_distance: int = 1

var attack_timer: float = 0.0
var attack_timer_remaining: float = 0.0
var attack_count: int = 0
var attack_phase: String = "idle"
var attack_target: Vector2i = Vector2i(-1, -1)
var arena_rect: Rect2i
var grid_manager: GridManager
var attack_visuals: Array[ColorRect] = []

signal hydra_attack_telegraphed(kind: String, target: Vector2i)
signal hydra_attack_resolved(kind: String, target: Vector2i, hit_player: bool)

func _ready():
	super._ready()
	var main = SceneLookup.main_scene(self)
	var gm = main.get_node_or_null("GameManager") if main else null
	if gm:
		grid_manager = gm.get_node_or_null("GridManager")
		arena_rect = gm.boss_arena_rect

func configure(name: String = "Lernaean Hydra", hp: int = 4, summon_type: String = "zapper", interval: float = 3.0):
	super.configure(name, hp, summon_type, interval)

func _process(delta: float):
	super._process(delta)
	if defeated or not is_instance_valid(game_manager) or not is_instance_valid(game_manager.player):
		return
	if attack_phase == "idle":
		attack_timer += delta
		if attack_timer >= attack_interval:
			attack_timer = 0.0
			begin_next_attack(game_manager.player.current_grid_pos, game_manager.player.current_direction, attack_count)
	else:
		attack_timer_remaining -= delta
		if attack_timer_remaining <= 0.0:
			resolve_attack(game_manager.player.current_grid_pos)

func begin_next_attack(player_pos: Vector2i, player_facing: int, phase_index: int = -1):
	var phase = attack_count if phase_index < 0 else phase_index
	if phase % 2 == 0:
		attack_phase = "acid"
		attack_target = get_acid_target(player_pos, player_facing, acid_lead_distance, arena_rect)
		attack_timer_remaining = acid_telegraph_time
		set_telegraph_cells([attack_target], Color("#84d65b"))
		hydra_attack_telegraphed.emit("acid", attack_target)
	else:
		attack_phase = "sweep"
		attack_target = get_sweep_anchor(player_pos, phase, arena_rect)
		attack_timer_remaining = sweep_telegraph_time
		set_telegraph_cells(get_sweep_cells(attack_target, phase, arena_rect), Color("#4bc9d4"))
		hydra_attack_telegraphed.emit("water_sweep", attack_target)
	attack_count = phase + 1

func direction_enum_to_vector(facing: int) -> Vector2i:
	match facing:
		Constants.Direction.RIGHT: return Vector2i.RIGHT
		Constants.Direction.DOWN: return Vector2i.DOWN
		Constants.Direction.LEFT: return Vector2i.LEFT
		Constants.Direction.UP: return Vector2i.UP
	return Vector2i.ZERO

func get_acid_target(player_pos: Vector2i, facing: int, lead: int, arena: Rect2i) -> Vector2i:
	return clamp_to_arena_interior(player_pos + direction_enum_to_vector(facing) * lead, arena)

func get_sweep_anchor(player_pos: Vector2i, phase: int, arena: Rect2i) -> Vector2i:
	var inside = arena_rect_interior(arena)
	if inside.size == Vector2i.ZERO:
		return player_pos
	var x = clampi(player_pos.x, inside.position.x, inside.end.x - 1)
	var y = clampi(player_pos.y, inside.position.y, inside.end.y - 1)
	return Vector2i(inside.position.x, y) if phase % 2 == 1 else Vector2i(x, inside.position.y)

func arena_rect_interior(arena: Rect2i) -> Rect2i:
	if arena.size.x < 3 or arena.size.y < 3:
		return Rect2i()
	return Rect2i(arena.position + Vector2i.ONE, arena.size - Vector2i(2, 2))

func get_sweep_cells(anchor: Vector2i, phase: int, arena: Rect2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var inside = arena_rect_interior(arena)
	if inside.size == Vector2i.ZERO:
		return cells
	if phase % 2 == 1:
		for x in range(inside.position.x, inside.end.x):
			cells.append(Vector2i(x, anchor.y))
	else:
		for y in range(inside.position.y, inside.end.y):
			cells.append(Vector2i(anchor.x, y))
	return cells

func is_player_hit_by_sweep(player_pos: Vector2i, anchor: Vector2i, phase: int, arena: Rect2i) -> bool:
	return get_sweep_cells(anchor, phase, arena).has(player_pos)

func clamp_to_arena_interior(pos: Vector2i, arena: Rect2i) -> Vector2i:
	var inside = arena_rect_interior(arena)
	if inside.size == Vector2i.ZERO:
		return pos
	return Vector2i(clampi(pos.x, inside.position.x, inside.end.x - 1), clampi(pos.y, inside.position.y, inside.end.y - 1))

func resolve_attack(player_pos: Vector2i) -> bool:
	if attack_phase == "idle":
		return false
	var kind = attack_phase
	var target = attack_target
	var phase = attack_count - 1
	attack_phase = "idle"
	attack_timer_remaining = 0.0
	clear_telegraphs()
	if kind == "acid":
		await animate_acid_projectile(target)
	if not is_instance_valid(self) or defeated:
		return false
	var actual_player_pos = player_pos
	if is_instance_valid(game_manager) and is_instance_valid(game_manager.player):
		actual_player_pos = game_manager.player.current_grid_pos
	var hit = actual_player_pos == target if kind == "acid" else is_player_hit_by_sweep(actual_player_pos, target, phase, arena_rect)
	hydra_attack_resolved.emit(kind, target, hit)
	if hit and is_instance_valid(game_manager):
		game_manager.player_hit_by_enemy()
	return hit

func animate_acid_projectile(target: Vector2i):
	if not is_inside_tree() or not is_instance_valid(game_manager):
		return
	var main = SceneLookup.main_scene(self)
	if not main:
		return
	var acid = ColorRect.new()
	acid.name = "HydraAcidProjectile"
	acid.size = Vector2(22, 22)
	acid.color = Color("#9cea61")
	acid.z_index = Constants.LAYER_EFFECTS + 1
	acid.position = global_position - Vector2(11, 11)
	main.add_child(acid)
	var target_world = game_manager.grid_manager.grid_to_world(target)
	var tween = acid.create_tween()
	tween.tween_property(acid, "position", target_world - Vector2(11, 11), 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	if is_instance_valid(acid):
		acid.queue_free()

func set_telegraph_cells(cells: Array[Vector2i], tint: Color):
	clear_telegraphs()
	if not is_inside_tree():
		return
	var main = SceneLookup.main_scene(self)
	if not main:
		return
	for cell in cells:
		var visual = ColorRect.new()
		visual.size = Vector2(Constants.TILE_SIZE - 8, Constants.TILE_SIZE - 8)
		visual.position = Vector2(Constants.PLAYFIELD_OFFSET_X + cell.x * Constants.TILE_SIZE + 4, Constants.PLAYFIELD_OFFSET_Y + cell.y * Constants.TILE_SIZE + 4)
		visual.color = Color(tint.r, tint.g, tint.b, 0.38)
		visual.z_index = Constants.LAYER_EFFECTS
		main.add_child(visual)
		attack_visuals.append(visual)

func clear_telegraphs():
	for visual in attack_visuals:
		if is_instance_valid(visual):
			visual.queue_free()
	attack_visuals.clear()

func build_visual():
	body = ColorRect.new()
	body.name = "HydraBody"
	body.size = Vector2(152, 118)
	body.position = Vector2(-76, -56)
	body.color = Color("#286f53")
	add_child(body)
	for i in range(3):
		var neck = ColorRect.new()
		neck.size = Vector2(14, 58)
		neck.position = Vector2(-48 + i * 42, -102 - (8 if i == 1 else 0))
		neck.color = Color("#499b62")
		body.add_child(neck)
		var head = ColorRect.new()
		head.size = Vector2(31, 27)
		head.position = Vector2(-56 + i * 42, -112 - (8 if i == 1 else 0))
		head.color = Color("#75b75d")
		body.add_child(head)
		var eye = ColorRect.new()
		eye.size = Vector2(11, 5)
		eye.position = head.position + Vector2(10, 9)
		eye.color = Color("#f4e79a")
		body.add_child(eye)
	build_health_bar()

func build_health_bar():
	var back = ColorRect.new()
	back.name = "HealthBack"
	back.size = Vector2(190, 18)
	back.position = Vector2(-95, -126)
	back.color = Color("#263429")
	add_child(back)
	health_fill = ColorRect.new()
	health_fill.name = "HealthFill"
	health_fill.position = Vector2(-92, -123)
	health_fill.size = Vector2(184, 12)
	health_fill.color = Color("#88cf4c")
	add_child(health_fill)

func take_damage(amount: int = 1) -> bool:
	var damaged = super.take_damage(amount)
	if damaged and is_instance_valid(body):
		var tween = body.create_tween()
		tween.tween_property(body, "modulate", Color(1.7, 1.7, 1.7), 0.07)
		tween.tween_property(body, "modulate", Color.WHITE, 0.12)
	return damaged
