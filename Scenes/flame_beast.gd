extends Enemy
class_name FlameBeast

## Tartarean ember creature immune to petrification; melts stone statues on contact.

var burn_cooldown: float = 0.35
var burn_timer: float = 0.0

func _ready():
	super._ready()
	move_speed = 125.0
	wait_time = 0.34

func _physics_process(delta: float):
	if not initialized or not grid_manager or petrified or is_squashed:
		return
	if is_moving:
		move_towards_target(delta)
		return
	burn_timer += delta
	if burn_timer >= burn_cooldown:
		burn_timer = 0.0
		burn_adjacent_statues()
	process_patrol(delta)

func is_immune_to_petrification() -> bool:
	return true

func petrify():
	# Fire monster is immune to Gorgon's gaze.
	return

func show_immune_flash():
	if not visual or not is_inside_tree():
		return
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color(1.7, 1.2, 0.5, 1.0), 0.07)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.12)

func burn_adjacent_statues() -> int:
	if not is_instance_valid(game_manager) or not is_instance_valid(grid_manager):
		return 0
	var removed := 0
	for direction in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		var adjacent = current_grid_pos + direction
		var statue = find_petrified_enemy_at(adjacent)
		if statue:
			statue.shatter()
			removed += 1
	return removed

func find_petrified_enemy_at(pos: Vector2i) -> Enemy:
	if not is_instance_valid(game_manager):
		return null
	for candidate in game_manager.enemies:
		if is_instance_valid(candidate) and candidate != self and candidate.petrified and not candidate.is_squashed and candidate.current_grid_pos == pos:
			return candidate
	return null

func create_visual():
	visual = ColorRect.new()
	visual.size = Vector2(52, 52)
	visual.position = Vector2(-26, -26)
	visual.color = Color("#b5412e")
	add_child(visual)
	var flame_core = ColorRect.new()
	flame_core.size = Vector2(34, 40)
	flame_core.position = Vector2(-17, -18)
	flame_core.color = Color("#ff9b38")
	visual.add_child(flame_core)
	eyes = ColorRect.new()
	eyes.size = Vector2(18, 7)
	eyes.position = Vector2(-9, -5)
	eyes.color = Color("#fff4aa")
	visual.add_child(eyes)
	var crown_flame = ColorRect.new()
	crown_flame.size = Vector2(14, 12)
	crown_flame.position = Vector2(-7, -30)
	crown_flame.color = Color("#ffd45c")
	visual.add_child(crown_flame)
