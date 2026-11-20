extends Node2D

## Lightweight original VFX rendered procedurally; nodes self-delete after lifetime.

const GOLD := Color("F4D36C")
const GAZE := Color("B5EF9B")
const MARBLE := Color("D9E0DC")
const WATER := Color("9BE3E5")

var effect_kind: String = "impact"
var lifetime := 0.42
var age := 0.0
var direction := Vector2.RIGHT
var seed_value := 1

static func spawn(parent: Node, world_position: Vector2, kind: String, facing: Vector2 = Vector2.RIGHT) -> Node2D:
	if not is_instance_valid(parent):
		return null
	var effect := Node2D.new()
	effect.set_script(load("res://Scenes/game_vfx.gd"))
	effect.effect_kind = kind
	effect.lifetime = lifetime_for(kind)
	effect.direction = facing.normalized() if facing != Vector2.ZERO else Vector2.RIGHT
	effect.position = world_position
	parent.add_child(effect)
	effect.z_index = Constants.LAYER_EFFECTS
	return effect

func _ready() -> void:
	lifetime = lifetime_for(effect_kind)
	seed_value = int(abs(position.x * 31.0 + position.y * 17.0))
	queue_redraw()

static func lifetime_for(kind: String) -> float:
	match kind:
		"gaze": return 0.24
		"petrify": return 0.48
		"shatter": return 0.5
		"splash", "bridge": return 0.58
		_: return 0.32

func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var progress := clampf(age / lifetime, 0.0, 1.0)
	match effect_kind:
		"gaze": _draw_gaze(progress)
		"petrify": _draw_petrify(progress)
		"shatter": _draw_shards(progress)
		"splash", "bridge": _draw_splash(progress)
		_: _draw_impact(progress)

func _draw_gaze(progress: float) -> void:
	var alpha := 1.0 - progress
	var tail := -direction * (12.0 + progress * 28.0)
	var side := direction.rotated(PI * 0.5)
	var tip := direction * 13.0
	var color := GAZE
	color.a = alpha
	draw_line(tail, tip, color, 5.0 * (1.0 - progress * 0.5), true)
	draw_line(tail + side * 4, tip, Color(GOLD, alpha * 0.75), 1.6, true)
	draw_circle(tip, 5.0 * (1.0 - progress * 0.6), Color(GOLD, alpha))

func _draw_impact(progress: float) -> void:
	var alpha := 1.0 - progress
	var radius := 6.0 + progress * 22.0
	var color := GOLD
	color.a = alpha
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, color, maxf(1.0, 4.0 * (1.0 - progress)))
	for i in range(4):
		var angle := float(i) * PI * 0.5 + 0.7
		var ray := Vector2(cos(angle), sin(angle))
		draw_line(ray * (radius * 0.45), ray * (radius + 5.0), color, 2.0, true)

func _draw_petrify(progress: float) -> void:
	var alpha := 1.0 - progress
	var glow := Color(GAZE, alpha * 0.7)
	var radius := 17.0 + progress * 18.0
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 28, glow, 2.0)
	for i in range(7):
		var angle := TAU * float(i) / 7.0 + progress * 0.4
		var ray := Vector2(cos(angle), sin(angle))
		draw_line(ray * 14.0, ray * (radius + 5.0), Color(MARBLE, alpha), 2.0, true)

func _draw_shards(progress: float) -> void:
	var alpha := 1.0 - progress
	for i in range(8):
		var angle := TAU * float(i) / 8.0 + float(seed_value % 17) * 0.03
		var travel := 8.0 + progress * (20.0 + float(i % 3) * 5.0)
		var ray := Vector2(cos(angle), sin(angle))
		var center := ray * travel
		var side := ray.rotated(PI * 0.5) * (2.0 + (i % 2))
		draw_colored_polygon(PackedVector2Array([center + ray * 4.0, center + side, center - side]), Color(MARBLE, alpha))

func _draw_splash(progress: float) -> void:
	var alpha := 1.0 - progress
	var radius := 8.0 + progress * 32.0
	var ring := Color(WATER, alpha)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, ring, 3.0 * (1.0 - progress * 0.6))
	for side in [-1.0, 1.0]:
		var start := Vector2(side * 7.0, 2.0)
		var end := Vector2(side * (12.0 + progress * 18.0), -8.0 - progress * 7.0)
		draw_line(start, end, Color(WATER, alpha), 2.4, true)