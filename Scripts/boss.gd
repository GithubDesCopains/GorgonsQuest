extends Node2D
class_name PuzzleBoss

## Reusable puzzle boss. Direct gaze is harmless; only a sliding petrified minion hurts it.

@export var max_health: int = 3
@export var minion_spawn_interval: float = 4.0
@export var minion_type: String = "noggle"

var health: int = 3
var boss_name: String = "Guardian"
var spawn_timer: float = 0.0
var game_manager: Node
var health_fill: ColorRect
var body: ColorRect
var defeated: bool = false

signal health_changed(current: int, maximum: int)
signal boss_defeated

func _ready():
	add_to_group("bosses")
	health = max_health
	build_visual()
	game_manager = get_tree().root.get_node_or_null("Main/GameManager")
	update_health_bar()

func _process(delta: float):
	if defeated or not game_manager or not game_manager.is_inside_tree():
		return
	spawn_timer += delta
	if spawn_timer >= minion_spawn_interval:
		spawn_timer = 0.0
		spawn_minion()

func configure(name: String, hp: int, summon_type: String = "noggle", interval: float = 4.0):
	boss_name = name
	max_health = maxi(1, hp)
	health = max_health
	minion_type = summon_type
	minion_spawn_interval = maxf(1.0, interval)
	if is_inside_tree():
		update_health_bar()

func build_visual():
	body = ColorRect.new()
	body.name = "BossBody"
	body.size = Vector2(150, 150)
	body.position = Vector2(-75, -75)
	body.color = Color("#76509b")
	add_child(body)
	var eye = ColorRect.new()
	eye.size = Vector2(50, 22)
	eye.position = Vector2(-25, -10)
	eye.color = Color("#f5d989")
	body.add_child(eye)
	fit_parts_to_body()
	var bar_back = ColorRect.new()
	bar_back.name = "HealthBack"
	bar_back.size = Vector2(170, 16)
	bar_back.position = Vector2(-85, -105)
	bar_back.color = Color("#321d35")
	add_child(bar_back)
	health_fill = ColorRect.new()
	health_fill.name = "HealthFill"
	health_fill.position = Vector2(-82, -102)
	health_fill.size = Vector2(164, 10)
	health_fill.color = Color("#e25355")
	add_child(health_fill)

func fit_parts_to_body() -> void:
	"""Body parts are authored around the boss origin, but a ColorRect child is placed from the body's own
	top-left corner. Shift every part back so eyes, horns and necks land on the body they belong to."""
	if body == null:
		return
	for part in body.get_children():
		if part is Control:
			part.position -= body.position

func update_health_bar():
	if health_fill:
		health_fill.size.x = 164.0 * clampf(float(health) / float(max_health), 0.0, 1.0)

func receive_gaze() -> bool:
	# Explicitly invulnerable to direct petrification shots.
	return false

func receive_sliding_statue(statue: Enemy) -> bool:
	if defeated or not is_instance_valid(statue) or not statue.petrified or statue.is_squashed:
		return false
	return take_damage(1)

func take_damage(amount: int = 1) -> bool:
	if defeated or amount <= 0:
		return false
	health = maxi(0, health - amount)
	update_health_bar()
	health_changed.emit(health, max_health)
	print("⚔ Boss hit: ", boss_name, " HP ", health, "/", max_health)
	if health == 0:
		defeated = true
		boss_defeated.emit()
		print("🏆 Boss defeated: ", boss_name)
		queue_free()
	return true

func spawn_minion():
	if not is_instance_valid(game_manager) or defeated:
		return null
	var spawn_pos = game_manager.find_open_boss_spawn_position(global_position)
	if spawn_pos == Vector2i(-1, -1):
		return null
	return await game_manager.spawn_enemy(spawn_pos, [Vector2i.RIGHT, Vector2i.LEFT], minion_type)

func set_arena(arena: Rect2i):
	# Boss arena is bounded by wall tiles in the grid; set from level configuration.
	if is_instance_valid(game_manager):
		game_manager.configure_boss_arena(arena)
