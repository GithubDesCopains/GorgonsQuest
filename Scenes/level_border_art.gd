extends Node2D

## Procedural Greek temple border art for the two 384px side margins.
## Drawn with original geometric motifs; no external/copyrighted artwork.

const SCREEN_W := 1920.0
const SCREEN_H := 1080.0
const FIELD_X := 384.0
const FIELD_W := 1152.0
const BAND_W := 384.0
const DEEP := Color("233448")
const MARBLE := Color("D8C5A1")
const MARBLE_LIGHT := Color("F0E3C5")
const MARBLE_DARK := Color("9C8461")
const GOLD := Color("C99A4A")
const SEA := Color("29475A")

func _ready() -> void:
	z_index = 5
	queue_redraw()

func _draw() -> void:
	_draw_side(0.0)
	_draw_side(FIELD_X + FIELD_W)
	_draw_corner_medallion(Vector2(FIELD_X * 0.5, SCREEN_H * 0.5))
	_draw_corner_medallion(Vector2(FIELD_X + FIELD_W + FIELD_X * 0.5, SCREEN_H * 0.5))

func _draw_side(x: float) -> void:
	# Dark sea-colored field and stone frame.
	draw_rect(Rect2(Vector2(x, 0), Vector2(BAND_W, SCREEN_H)), DEEP)
	draw_rect(Rect2(Vector2(x + 8, 8), Vector2(BAND_W - 16, SCREEN_H - 16)), SEA)
	draw_rect(Rect2(Vector2(x + 18, 18), Vector2(BAND_W - 36, SCREEN_H - 36)), MARBLE_DARK, false, 5.0)

	# Repeated Greek-key friezes across the top and bottom.
	_draw_meander(Rect2(Vector2(x + 28, 30), Vector2(BAND_W - 56, 74)))
	_draw_meander(Rect2(Vector2(x + 28, SCREEN_H - 104), Vector2(BAND_W - 56, 74)))

	# Fluted columns frame the empty margin and provide a painted temple feel.
	_draw_column(Vector2(x + 70, 140), 800)
	_draw_column(Vector2(x + BAND_W - 70, 140), 800)

	# Central decorative panel, built from original geometric relief motifs.
	var panel := Rect2(Vector2(x + 126, 190), Vector2(BAND_W - 252, 700))
	draw_rect(panel, Color("344B5A"))
	draw_rect(panel, GOLD, false, 3.0)
	draw_rect(panel.grow(-12), MARBLE_DARK, false, 2.0)
	_draw_laurel_emblem(panel.get_center())

func _draw_meander(rect: Rect2) -> void:
	draw_rect(rect, MARBLE_DARK)
	draw_rect(rect.grow(-7), DEEP)
	var x := rect.position.x + 12.0
	var y := rect.position.y + 12.0
	var end_x := rect.end.x - 12.0
	var cell := 24.0
	while x + cell <= end_x:
		var path := [
			Vector2(x, y + cell), Vector2(x, y), Vector2(x + cell, y),
			Vector2(x + cell, y + cell * 0.65), Vector2(x + cell * 0.35, y + cell * 0.65),
			Vector2(x + cell * 0.35, y + cell * 1.35), Vector2(x + cell, y + cell * 1.35)
		]
		for i in range(path.size() - 1):
			draw_line(path[i], path[i + 1], GOLD, 4.0, true)
		x += cell * 1.5

func _draw_column(base: Vector2, height: float) -> void:
	var width := 38.0
	var shaft := Rect2(base.x - width * 0.5, base.y, width, height)
	draw_rect(shaft, MARBLE_DARK)
	draw_rect(shaft.grow(-5), MARBLE)
	# Vertical flutes.
	for i in range(5):
		var flute_x := shaft.position.x + 7.0 + i * 6.0
		draw_line(Vector2(flute_x, base.y + 12), Vector2(flute_x, base.y + height - 12), MARBLE_LIGHT, 1.4)
	# Ionic-inspired capital and base.
	draw_rect(Rect2(base.x - width, base.y - 24, width * 2.0, 24), GOLD)
	draw_rect(Rect2(base.x - width * 0.85, base.y + height, width * 1.7, 25), GOLD)
	draw_rect(Rect2(base.x - width * 1.1, base.y + height + 25, width * 2.2, 12), MARBLE_DARK)

func _draw_laurel_emblem(center: Vector2) -> void:
	draw_circle(center, 74, MARBLE_DARK)
	draw_circle(center, 66, DEEP)
	# Laurel branches: paired leaves around a simple central gorgon-eye glyph.
	for i in range(7):
		var t := float(i) / 6.0
		var y := center.y + 42.0 - t * 82.0
		var spread := 16.0 + sin(t * PI) * 38.0
		_draw_leaf(Vector2(center.x - spread, y), -0.55)
		_draw_leaf(Vector2(center.x + spread, y), 0.55)
	draw_circle(center, 12, GOLD)
	draw_circle(center, 5, MARBLE_LIGHT)
	draw_arc(center, 29, PI, TAU, 24, MARBLE, 3.0)
	draw_arc(center, 29, 0.0, PI, 24, MARBLE, 3.0)

func _draw_leaf(at: Vector2, angle: float) -> void:
	var direction := Vector2(cos(angle), sin(angle))
	var tip := at + direction * 17.0
	var normal := direction.rotated(PI * 0.5) * 7.0
	draw_colored_polygon(PackedVector2Array([at - normal, tip, at + normal]), GOLD)
	draw_line(at - normal, tip, MARBLE_LIGHT, 1.0)

func _draw_corner_medallion(center: Vector2) -> void:
	draw_circle(center, 22.0, GOLD)
	draw_circle(center, 16.0, DEEP)
	draw_circle(center, 5.0, MARBLE_LIGHT)

static func get_side_rects() -> Array[Rect2]:
	return [Rect2(0, 0, FIELD_X, SCREEN_H), Rect2(FIELD_X + FIELD_W, 0, SCREEN_W - FIELD_X - FIELD_W, SCREEN_H)]
