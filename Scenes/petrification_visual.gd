extends Node2D
class_name PetrificationVisual

## One shared, original marble-statue transformation for every petrifiable creature.

const MARBLE_LIGHT := Color("E5E5D8")
const MARBLE := Color("AEB8B8")
const MARBLE_DARK := Color("626D70")
const GLOW := Color("E9FFF0")

var transition_progress: float = 0.0:
	set(value):
		transition_progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var warning_visible := false
var warning_phase := 0.0

func set_warning_visible(value: bool) -> void:
	warning_visible = value
	queue_redraw()

func _process(delta: float) -> void:
	if warning_visible:
		warning_phase += delta
		queue_redraw()

func _draw() -> void:
	var t := transition_progress
	var body := PackedVector2Array([
		Vector2(-12, -24), Vector2(10, -24), Vector2(16, -16),
		Vector2(15, 10), Vector2(21, 20), Vector2(12, 24),
		Vector2(-12, 24), Vector2(-21, 20), Vector2(-15, 10), Vector2(-16, -16)
	])
	var stone := MARBLE_LIGHT.lerp(MARBLE, t)
	draw_colored_polygon(body, stone)
	draw_polyline(PackedVector2Array([body[0], body[1], body[2], body[3], body[4], body[5], body[6], body[7], body[8], body[9], body[0]]), MARBLE_DARK, 2.0, true)
	# Simple face, chiton folds, belt and plinth identify carved statue.
	draw_circle(Vector2(-5, -11), 2.0, MARBLE_DARK)
	draw_circle(Vector2(5, -11), 2.0, MARBLE_DARK)
	draw_line(Vector2(-8, -4), Vector2(8, -4), MARBLE_DARK, 1.5)
	draw_line(Vector2(-8, 6), Vector2(8, 6), MARBLE_LIGHT.darkened(0.2), 1.4)
	draw_line(Vector2(-4, 1), Vector2(-7, 16), MARBLE_DARK, 1.4)
	draw_line(Vector2(4, 1), Vector2(7, 16), MARBLE_DARK, 1.4)
	draw_rect(Rect2(Vector2(-17, 20), Vector2(34, 5)), MARBLE_DARK)
	# Common cracks appear as petrification finishes.
	if t > 0.35:
		draw_line(Vector2(-10, -20), Vector2(-3, -10), MARBLE_DARK, 1.8)
		draw_line(Vector2(-3, -10), Vector2(-8, -3), MARBLE_DARK, 1.4)
		draw_line(Vector2(10, -18), Vector2(4, -8), MARBLE_DARK, 1.8)
		draw_line(Vector2(4, -8), Vector2(11, 0), MARBLE_DARK, 1.4)
		draw_line(Vector2(-8, 11), Vector2(-1, 7), MARBLE_DARK, 1.3)
	var glow := GLOW
	glow.a = (1.0 - t) * 0.75
	if glow.a > 0.0:
		draw_arc(Vector2.ZERO, 29.0, 0.0, TAU, 32, glow, 3.0)
	if warning_visible:
		var blink := 0.35 + (sin(warning_phase * 9.0) + 1.0) * 0.3
		var warning := Color("D94B46")
		warning.a = blink
		# Countdown warning glyph: halo and three fading ticks.
		draw_arc(Vector2.ZERO, 34.0, -PI * 0.8, -PI * 0.2, 24, warning, 3.0)
		for i in range(3):
			var tick_color := warning
			tick_color.a *= 1.0 if i < 3 else 0.25
			draw_circle(Vector2(-6.0 + i * 6.0, -31.0), 1.7, tick_color)
