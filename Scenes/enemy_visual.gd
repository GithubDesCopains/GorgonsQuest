extends Node2D

## Original procedural living silhouettes for the Greek-mythology bestiary.
## Petrification is rendered separately by the shared statue scene.

const INK := Color("1A1418")
const CREAM := Color("F6E7C5")
const GOLD := Color("E5B85C")

# Hand-painted noggle (Assets/Sprites/noggle_game.png). Falls back to the procedural drawing if the file is missing.
const NOGGLE_SPRITE_PATH := "res://Assets/Sprites/noggle_game.png"
const NOGGLE_SPRITE_SIZE := 69.0

var _noggle_texture: Texture2D
var _noggle_texture_missing := false

var enemy_type: String = "noggle"
var moving := false
var phase := 0.0

func get_accent_color() -> Color:
	match enemy_type:
		"birdie": return Color("A7D7D7")
		"zapper": return Color("55AFC1")
		"pusher": return Color("4E92A0")
		"wall_hugger": return Color("D8A64E")
		"jumper", "jumper_enemy": return Color("B96D4D")
		"hades_shadow": return Color("9B7BC0")
		"flame_beast": return Color("F09B42")
		_: return Color("C66A5B")

func set_moving(value: bool) -> void:
	if moving == value:
		return
	moving = value
	queue_redraw()

func _process(delta: float) -> void:
	phase += delta * (12.0 if moving else 2.0)
	if moving:
		queue_redraw()

func _draw() -> void:
	var bob := sin(phase) * 2.0
	match enemy_type:
		"birdie": _draw_bird(bob)
		"zapper", "pusher": _draw_fish(bob)
		"wall_hugger": _draw_scarab()
		"jumper", "jumper_enemy": _draw_bull()
		"hades_shadow": _draw_wraith(bob)
		"flame_beast": _draw_salamander(bob)
		_: _draw_noggle(bob)

func _noggle_sprite() -> Texture2D:
	if _noggle_texture == null and not _noggle_texture_missing:
		if ResourceLoader.exists(NOGGLE_SPRITE_PATH):
			_noggle_texture = load(NOGGLE_SPRITE_PATH)
		_noggle_texture_missing = _noggle_texture == null
	return _noggle_texture

func _draw_noggle(bob: float = 0.0) -> void:
	var sprite := _noggle_sprite()
	if sprite != null:
		_draw_ellipse(Vector2(0, 30), Vector2(24, 7), Color(0.12, 0.18, 0.2, 0.28))
		var half := NOGGLE_SPRITE_SIZE * 0.5
		draw_texture_rect(sprite, Rect2(Vector2(-half, -half + bob), Vector2(NOGGLE_SPRITE_SIZE, NOGGLE_SPRITE_SIZE)), false)
		return
	var body := Color("C66A5B")
	for side in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([Vector2(side * 12, -14), Vector2(side * 20, -26), Vector2(side * 19, -8)]), body.darkened(0.2))
	draw_circle(Vector2.ZERO, 21.5, INK)
	draw_circle(Vector2.ZERO, 17, body)
	_draw_eyes(CREAM)
	draw_arc(Vector2(0, 8), 7, 0.15, PI - 0.15, 12, INK, 2.0)

func _draw_bird(bob: float) -> void:
	var flap := sin(phase * 1.8) * 9.0
	_draw_limb(Vector2(-8, bob), Vector2(-28, -8 + flap + bob), Color("A7D7D7"), 5)
	_draw_limb(Vector2(8, bob), Vector2(28, -8 - flap + bob), Color("A7D7D7"), 5)
	draw_circle(Vector2(0, bob), 14, Color("77B8C8"))
	_draw_eyes(CREAM)
	draw_colored_polygon(PackedVector2Array([Vector2(-4, 6 + bob), Vector2(5, 6 + bob), Vector2(0, 15 + bob)]), GOLD)

func _draw_fish(bob: float) -> void:
	var tail := sin(phase * 1.4) * 4.0
	draw_colored_polygon(PackedVector2Array([Vector2(-12, bob), Vector2(-29, -10 + tail + bob), Vector2(-25, 10 + tail + bob)]), Color("4E92A0"))
	draw_circle(Vector2(0, bob), 19, Color("55AFC1"))
	for side in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([Vector2(side * 8, -8 + bob), Vector2(side * 24, -18 + bob), Vector2(side * 20, 2 + bob)]), Color("83C4CC"))
	_draw_eyes(Color("FFF1A6"))
	if enemy_type == "pusher":
		draw_arc(Vector2(0, 2 + bob), 10, 0, PI, 16, INK, 2.0)

func _draw_scarab() -> void:
	for side in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([Vector2(side * 9, -12), Vector2(side * 19, -25), Vector2(side * 18, -8)]), GOLD)
	draw_circle(Vector2.ZERO, 21.5, INK)
	draw_circle(Vector2.ZERO, 16, Color("D8A64E"))
	draw_line(Vector2(0, -13), Vector2(0, 14), Color("79512E"), 2.0)
	for side in [-1.0, 1.0]:
		_draw_limb(Vector2(side * 12, -3), Vector2(side * 25, 10), Color("D8A64E"), 3)
	_draw_eyes(Color("FFF2A0"))

func _draw_bull() -> void:
	for side in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([Vector2(side * 12, -9), Vector2(side * 28, -23), Vector2(side * 22, -2)]), GOLD)
	var armor := PackedVector2Array([Vector2(-17, -8), Vector2(-12, -20), Vector2(12, -20), Vector2(17, -8), Vector2(15, 15), Vector2(0, 22), Vector2(-15, 15)])
	draw_colored_polygon(armor, Color("B96D4D"))
	draw_polyline(PackedVector2Array([armor[0], armor[1], armor[2], armor[3], armor[4], armor[5], armor[6], armor[0]]), INK, 3.4, true)
	_draw_eyes(CREAM)

func _draw_wraith(bob: float) -> void:
	var robe := PackedVector2Array([Vector2(-14, -16 + bob), Vector2(-7, -24 + bob), Vector2(8, -21 + bob), Vector2(15, -10 + bob), Vector2(12, 11 + bob), Vector2(20, 20 + bob), Vector2(0, 16 + bob), Vector2(-20, 20 + bob), Vector2(-12, 10 + bob)])
	draw_colored_polygon(robe, Color("756391"))
	draw_polyline(PackedVector2Array([robe[0], robe[1], robe[2], robe[3], robe[4], robe[5], robe[6], robe[7], robe[8], robe[0]]), INK, 3.4, true)
	for side in [-1.0, 1.0]:
		draw_circle(Vector2(side * 5, -3 + bob), 2.2, Color("E7D8FF"))

func _draw_salamander(bob: float) -> void:
	for i in range(5):
		var x := -14.0 + i * 7.0
		var flicker := sin(phase * 1.5 + i) * 3.0
		draw_colored_polygon(PackedVector2Array([Vector2(x - 4, -13 + bob), Vector2(x, -27 - flicker + bob), Vector2(x + 4, -13 + bob)]), GOLD)
	draw_circle(Vector2(0, bob + 3), 20.5, INK)
	draw_circle(Vector2(0, bob + 3), 15, Color("F09B42"))
	_draw_ellipse(Vector2(0, bob + 8), Vector2(8, 6), Color("FFD878"))
	_draw_eyes(Color("FFF1A6"))

func _draw_eyes(color: Color) -> void:
	for side in [-1.0, 1.0]:
		_draw_ellipse(Vector2(side * 6, -4), Vector2(4, 5), color)
		draw_circle(Vector2(side * 6, -4), 1.7, INK)

func _draw_limb(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	draw_line(from, to, INK, width + 3.4, true)
	draw_line(from, to, color, width, true)

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(17):
		var angle := TAU * float(i) / 16.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)