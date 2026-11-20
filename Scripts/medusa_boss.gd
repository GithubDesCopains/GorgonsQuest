extends PuzzleBoss
class_name MedusaBoss

## Final Gorgon: telegraphed gaze, flank teleport, summoned serpent hazards; two phases.
@export var attack_interval: float = 1.7
@export var gaze_telegraph_time: float = 0.8
@export var serpent_telegraph_time: float = 0.7
var attack_timer: float = 0.0
var attack_timer_remaining: float = 0.0
var attack_count: int = 0
var attack_phase: String = "idle"
var attack_target: Vector2i = Vector2i(-1, -1)
var arena_rect: Rect2i
var serpent_cells: Array[Vector2i] = []
var phase_two: bool = false
var attack_markers: Array[ColorRect] = []
signal medusa_attack_telegraphed(kind: String, cells: Array[Vector2i])
signal medusa_attack_resolved(kind: String, hit_player: bool)
signal medusa_teleported(from_cell: Vector2i, to_cell: Vector2i)
signal medusa_phase_changed(phase: int)

func _ready():
	super._ready()
	var main = SceneLookup.main_scene(self)
	game_manager = main.get_node_or_null("GameManager") if main else null
	if is_instance_valid(game_manager):
		arena_rect = game_manager.boss_arena_rect

func configure(name: String = "Medusa", hp: int = 6, summon_type: String = "hades_shadow", interval: float = 2.3):
	super.configure(name, hp, summon_type, interval)
	phase_two = health <= 3

func _process(delta: float):
	super._process(delta)
	if defeated or not is_instance_valid(game_manager) or not is_instance_valid(game_manager.player):
		return
	if attack_phase == "idle":
		attack_timer += delta
		if attack_timer >= attack_interval * (0.65 if phase_two else 1.0):
			attack_timer = 0.0
			begin_next_attack(game_manager.player.current_grid_pos, game_manager.player.current_direction, attack_count)
	else:
		attack_timer_remaining -= delta
		if attack_timer_remaining <= 0.0:
			resolve_attack(game_manager.player.current_grid_pos)

func begin_next_attack(player_pos: Vector2i, player_facing: int, phase_index: int = -1):
	var phase = attack_count if phase_index < 0 else phase_index
	match phase % 3:
		0:
			attack_phase = "gaze"
			attack_target = player_pos
			attack_timer_remaining = gaze_telegraph_time * (0.65 if phase_two else 1.0)
			serpent_cells.clear()
			set_telegraph_cells([attack_target], Color("#bc67db"))
			medusa_attack_telegraphed.emit("gaze", [attack_target])
		1:
			attack_phase = "teleport"
			attack_timer_remaining = 0.25 if phase_two else 0.4
			serpent_cells.clear()
			attack_target = choose_teleport_flank(player_pos, player_facing, arena_rect)
			set_telegraph_cells([attack_target], Color("#e05ba5"))
			medusa_attack_telegraphed.emit("teleport", [attack_target])
		2:
			attack_phase = "serpents"
			serpent_cells = choose_serpent_cells(player_pos, phase_two, arena_rect)
			attack_timer_remaining = serpent_telegraph_time * (0.7 if phase_two else 1.0)
			attack_target = player_pos
			set_telegraph_cells(serpent_cells, Color("#8fcb56"))
			medusa_attack_telegraphed.emit("serpents", serpent_cells)
	attack_count = phase + 1

func direction_enum_to_vector(facing: int) -> Vector2i:
	match facing:
		Constants.Direction.RIGHT: return Vector2i.RIGHT
		Constants.Direction.DOWN: return Vector2i.DOWN
		Constants.Direction.LEFT: return Vector2i.LEFT
		Constants.Direction.UP: return Vector2i.UP
	return Vector2i.ZERO

func arena_interior(arena: Rect2i) -> Rect2i:
	if arena.size.x < 3 or arena.size.y < 3:
		return Rect2i()
	return Rect2i(arena.position + Vector2i.ONE, arena.size - Vector2i(2, 2))

func choose_teleport_flank(player_pos: Vector2i, player_facing: int, arena: Rect2i) -> Vector2i:
	var inside = arena_interior(arena)
	if inside.size == Vector2i.ZERO:
		return player_pos
	var behind = player_pos - direction_enum_to_vector(player_facing)
	if inside.has_point(behind):
		return behind
	for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var flank = player_pos + offset
		if inside.has_point(flank):
			return flank
	return Vector2i(clampi(player_pos.x, inside.position.x, inside.end.x - 1), clampi(player_pos.y, inside.position.y, inside.end.y - 1))

func choose_serpent_cells(player_pos: Vector2i, faster_phase: bool, arena: Rect2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var inside = arena_interior(arena)
	if inside.size == Vector2i.ZERO:
		return cells
	var offsets: Array[Vector2i] = [Vector2i.ZERO, Vector2i.LEFT, Vector2i.RIGHT]
	if faster_phase:
		offsets.append(Vector2i.UP)
	for offset in offsets:
		var cell = player_pos + offset
		if inside.has_point(cell):
			cells.append(cell)
	return cells

func is_player_hit_by_attack(player_pos: Vector2i, phase: String, target: Vector2i, snakes: Array[Vector2i]) -> bool:
	if phase == "gaze":
		return player_pos == target
	if phase == "serpents":
		return snakes.has(player_pos)
	return false

func resolve_attack(player_pos: Vector2i) -> bool:
	if attack_phase == "idle":
		return false
	var phase = attack_phase
	var target = attack_target
	var snakes: Array[Vector2i] = serpent_cells.duplicate()
	attack_phase = "idle"
	attack_timer_remaining = 0.0
	clear_telegraphs()
	if phase == "teleport":
		perform_teleport(target)
	var actual_pos = player_pos
	if is_instance_valid(game_manager) and is_instance_valid(game_manager.player):
		actual_pos = game_manager.player.current_grid_pos
	var hit = is_player_hit_by_attack(actual_pos, phase, target, snakes)
	medusa_attack_resolved.emit(phase, hit)
	if hit and is_instance_valid(game_manager):
		game_manager.player_hit_by_enemy()
	return hit

func perform_teleport(destination: Vector2i):
	var from_cell = boss_grid_position()
	if is_instance_valid(game_manager) and is_instance_valid(game_manager.grid_manager):
		position = game_manager.grid_manager.grid_to_world(destination)
	medusa_teleported.emit(from_cell, destination)

func boss_grid_position() -> Vector2i:
	if is_instance_valid(game_manager) and is_instance_valid(game_manager.grid_manager):
		return game_manager.grid_manager.world_to_grid(position)
	return Vector2i(roundi(position.x / Constants.TILE_SIZE), roundi(position.y / Constants.TILE_SIZE))

func set_telegraph_cells(cells: Array[Vector2i], tint: Color):
	clear_telegraphs()
	if not is_inside_tree():
		return
	var main = SceneLookup.main_scene(self)
	if not main:
		return
	for cell in cells:
		var marker = ColorRect.new()
		marker.size = Vector2(Constants.TILE_SIZE - 8, Constants.TILE_SIZE - 8)
		marker.position = Vector2(Constants.PLAYFIELD_OFFSET_X + cell.x * Constants.TILE_SIZE + 4, Constants.PLAYFIELD_OFFSET_Y + cell.y * Constants.TILE_SIZE + 4)
		marker.color = Color(tint.r, tint.g, tint.b, 0.42)
		marker.z_index = Constants.LAYER_EFFECTS
		main.add_child(marker)
		attack_markers.append(marker)

func clear_telegraphs():
	for marker in attack_markers:
		if is_instance_valid(marker):
			marker.queue_free()
	attack_markers.clear()

func build_visual():
	body = ColorRect.new()
	body.name = "MedusaBody"
	body.size = Vector2(148, 128)
	body.position = Vector2(-74, -58)
	body.color = Color("#47754b")
	add_child(body)
	var face = ColorRect.new()
	face.size = Vector2(52, 48)
	face.position = Vector2(-26, -32)
	face.color = Color("#a8bd69")
	body.add_child(face)
	var eye = ColorRect.new()
	eye.size = Vector2(20, 8)
	eye.position = Vector2(-10, -14)
	eye.color = Color("#f5dd86")
	body.add_child(eye)
	for index in range(5):
		var serpent = ColorRect.new()
		serpent.size = Vector2(10, 34)
		serpent.position = Vector2(-48 + index * 24, -68 - (8 if index % 2 == 0 else 0))
		serpent.color = Color("#8bc568")
		body.add_child(serpent)
	build_health_bar()

func build_health_bar():
	var back = ColorRect.new()
	back.name = "HealthBack"
	back.size = Vector2(190, 18)
	back.position = Vector2(-95, -130)
	back.color = Color("#253928")
	add_child(back)
	health_fill = ColorRect.new()
	health_fill.name = "HealthFill"
	health_fill.position = Vector2(-92, -127)
	health_fill.size = Vector2(184, 12)
	health_fill.color = Color("#91c856")
	add_child(health_fill)

func take_damage(amount: int = 1) -> bool:
	var damaged = super.take_damage(amount)
	if damaged and health <= 3 and not phase_two:
		phase_two = true
		attack_timer = 0.0
		medusa_phase_changed.emit(2)
	if damaged and is_instance_valid(body):
		var tween = body.create_tween()
		tween.tween_property(body, "modulate", Color(1.7, 1.7, 1.7), 0.06)
		tween.tween_property(body, "modulate", Color.WHITE, 0.12)
	return damaged
