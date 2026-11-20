extends PuzzleBoss
class_name CyclopsBoss

## Polyphemus: telegraphed ground stomp and a rolling/arcing boulder aimed at predicted player cell.

@export var attack_interval: float = 2.4
@export var stomp_telegraph_time: float = 0.65
@export var boulder_telegraph_time: float = 0.8
@export var boulder_speed: float = 5.0

var grid_manager: GridManager
var attack_timer: float = 0.0
var attack_phase: String = "idle"
var attack_target: Vector2i = Vector2i(-1, -1)
var attack_timer_remaining: float = 0.0
var attack_count: int = 0
var attack_visual: ColorRect

signal attack_telegraphed(kind: String, target: Vector2i)
signal attack_resolved(kind: String, target: Vector2i, hit_player: bool)

func _ready():
	super._ready()
	var main_scene = SceneLookup.main_scene(self)
	var gm = main_scene.get_node_or_null("GameManager") if main_scene else null
	grid_manager = gm.get_node_or_null("GridManager") if gm else null

func configure(name: String = "Polyphemus", hp: int = 3, summon_type: String = "noggle", interval: float = 3.0):
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

func begin_next_attack(player_pos: Vector2i, player_facing: int, phase_index: int = -1) -> void:
	var phase = attack_count if phase_index < 0 else phase_index
	if phase % 2 == 0:
		attack_phase = "stomp"
		attack_target = stomp_target_for_player(player_pos)
		attack_timer_remaining = stomp_telegraph_time
		set_attack_telegraph(attack_target, Color("#e35a45"))
		attack_telegraphed.emit("stomp", attack_target)
	else:
		attack_phase = "boulder"
		attack_target = get_boulder_impact_target(boss_grid_position(), player_pos, player_facing, game_manager.boss_arena_rect if is_instance_valid(game_manager) else Rect2i(), int(round(boulder_speed)))
		attack_timer_remaining = boulder_telegraph_time
		set_attack_telegraph(attack_target, Color("#d5b187"))
		attack_telegraphed.emit("boulder", attack_target)
	attack_count = phase + 1

func boss_grid_position() -> Vector2i:
	if is_instance_valid(game_manager) and is_instance_valid(game_manager.grid_manager):
		return game_manager.grid_manager.world_to_grid(position)
	return Vector2i(roundi(position.x / Constants.TILE_SIZE), roundi(position.y / Constants.TILE_SIZE))

func stomp_target_for_player(player_pos: Vector2i) -> Vector2i:
	return player_pos

func direction_enum_to_vector(facing: int) -> Vector2i:
	match facing:
		Constants.Direction.RIGHT:
			return Vector2i.RIGHT
		Constants.Direction.DOWN:
			return Vector2i.DOWN
		Constants.Direction.LEFT:
			return Vector2i.LEFT
		Constants.Direction.UP:
			return Vector2i.UP
	return Vector2i.ZERO

func resolve_attack(player_pos: Vector2i) -> bool:
	if attack_phase == "idle":
		return false
	var kind = attack_phase
	var target = attack_target
	attack_phase = "idle"
	attack_timer_remaining = 0.0
	clear_attack_telegraph()
	
	if kind == "boulder":
		await animate_boulder_to(target)
	elif kind == "stomp":
		await animate_stomp()
	
	if not is_instance_valid(self) or defeated:
		return false
	var player = game_manager.player if is_instance_valid(game_manager) else null
	var final_player_pos = player.current_grid_pos if is_instance_valid(player) else player_pos
	var hit = final_player_pos == target
	attack_resolved.emit(kind, target, hit)
	if hit and is_instance_valid(game_manager):
		game_manager.player_hit_by_enemy()
	return hit

func animate_stomp() -> void:
	if not body or not is_inside_tree():
		return
	var stomp_tween = create_tween()
	stomp_tween.tween_property(body, "scale", Vector2(1.2, 0.78), 0.12).set_trans(Tween.TRANS_BACK)
	stomp_tween.tween_property(body, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BOUNCE)
	await stomp_tween.finished

func animate_boulder_to(target: Vector2i) -> void:
	if not is_inside_tree():
		return
	var main = SceneLookup.main_scene(self)
	if not main:
		return
	var rock = ColorRect.new()
	rock.name = "CyclopsBoulder"
	rock.size = Vector2(34, 34)
	rock.color = Color("#75604d")
	rock.z_index = Constants.LAYER_EFFECTS + 1
	var start = global_position
	var finish = game_manager.grid_manager.grid_to_world(target) if is_instance_valid(game_manager) else start
	rock.position = start - Vector2(17, 17)
	main.add_child(rock)
	var midpoint = (start + finish) * 0.5 + Vector2.UP * 72.0 - Vector2(17, 17)
	var tween = rock.create_tween()
	tween.tween_property(rock, "position", midpoint, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(rock, "position", finish - Vector2(17, 17), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	if is_instance_valid(rock):
		rock.queue_free()

func get_boulder_impact_target(boss_pos: Vector2i, player_pos: Vector2i, player_facing: int, arena: Rect2i, lead_distance: int = 2) -> Vector2i:
	var predicted = player_pos + direction_enum_to_vector(player_facing) * lead_distance
	var candidate: Vector2i
	if predicted.x == boss_pos.x or predicted.y == boss_pos.y:
		candidate = predicted
	elif absi(player_pos.x - boss_pos.x) >= absi(player_pos.y - boss_pos.y):
		candidate = Vector2i(player_pos.x, boss_pos.y)
	else:
		candidate = Vector2i(boss_pos.x, player_pos.y)
	if arena.size != Vector2i.ZERO:
		candidate.x = clampi(candidate.x, arena.position.x + 1, arena.end.x - 2)
		candidate.y = clampi(candidate.y, arena.position.y + 1, arena.end.y - 2)
	return candidate

func set_attack_telegraph(target: Vector2i, tint: Color) -> void:
	clear_attack_telegraph()
	var main = SceneLookup.main_scene(self)
	if not main:
		return
	attack_visual = ColorRect.new()
	attack_visual.size = Vector2(Constants.TILE_SIZE - 8, Constants.TILE_SIZE - 8)
	attack_visual.position = Vector2(Constants.PLAYFIELD_OFFSET_X + target.x * Constants.TILE_SIZE + 4, Constants.PLAYFIELD_OFFSET_Y + target.y * Constants.TILE_SIZE + 4)
	attack_visual.color = Color(tint.r, tint.g, tint.b, 0.42)
	attack_visual.z_index = Constants.LAYER_EFFECTS
	main.add_child(attack_visual)

func clear_attack_telegraph() -> void:
	if is_instance_valid(attack_visual):
		attack_visual.queue_free()
	attack_visual = null

func build_visual():
	body = ColorRect.new()
	body.name = "BossBody"
	body.size = Vector2(168, 168)
	body.position = Vector2(-84, -84)
	body.color = Color("#8d563d") # Cyclops hide / leather armor
	add_child(body)
	var armor = ColorRect.new()
	armor.size = Vector2(128, 110)
	armor.position = Vector2(-64, -48)
	armor.color = Color("#bd8151")
	body.add_child(armor)
	var eye = ColorRect.new()
	eye.size = Vector2(36, 20)
	eye.position = Vector2(-18, -30)
	eye.color = Color("#ffe18a")
	body.add_child(eye)
	var horn_left = ColorRect.new()
	horn_left.size = Vector2(14, 30)
	horn_left.position = Vector2(-60, -72)
	horn_left.color = Color("#ead0a0")
	body.add_child(horn_left)
	var horn_right = ColorRect.new()
	horn_right.size = Vector2(14, 30)
	horn_right.position = Vector2(46, -72)
	horn_right.color = Color("#ead0a0")
	body.add_child(horn_right)
	fit_parts_to_body()
	build_health_bar()

func build_health_bar():
	var bar_back = ColorRect.new()
	bar_back.name = "HealthBack"
	bar_back.size = Vector2(186, 18)
	bar_back.position = Vector2(-93, -116)
	bar_back.color = Color("#321d35")
	add_child(bar_back)
	health_fill = ColorRect.new()
	health_fill.name = "HealthFill"
	health_fill.position = Vector2(-90, -113)
	health_fill.size = Vector2(180, 12)
	health_fill.color = Color("#e25355")
	add_child(health_fill)

func take_damage(amount: int = 1) -> bool:
	var damaged = super.take_damage(amount)
	if damaged and is_instance_valid(body):
		var tween = body.create_tween()
		tween.tween_property(body, "modulate", Color(1.8, 1.8, 1.8), 0.07)
		tween.tween_property(body, "modulate", Color.WHITE, 0.12)
	return damaged
