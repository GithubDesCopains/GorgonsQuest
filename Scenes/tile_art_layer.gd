extends Node2D

## Procedural HD-inspired tile details. Overlay only; grid/collision data unchanged.

const TILE := 72.0
const OFFSET_X := 384.0
const INK := Color("1A1418")
const WATER_DARK := Color("5FA8CC")
const WATER_LIGHT := Color("E3F6F7")
const MARBLE_LINE := Color("B8A27E")
const MARBLE_LIGHT := Color("FFF6E0")
const GRASS_DARK := Color("A9C9A0")
const FROST := Color("EAF6F8")
const EDGE_WIDTH := 5.0

var _layout: Array = []
var _phase := 0.0
var _has_water := false

func set_layout(layout: Array) -> void:
	_layout = layout.duplicate(true)
	_has_water = false
	for row in _layout:
		if row.has(Constants.TileType.WATER) or row.has(Constants.TileType.HOLE):
			_has_water = true
			break
	queue_redraw()

func _process(delta: float) -> void:
	if _has_water:
		_phase += delta
		queue_redraw()

func _draw() -> void:
	for y in range(_layout.size()):
		var row: Array = _layout[y]
		for x in range(row.size()):
			var tile_type: int = row[x]
			var origin := Vector2(OFFSET_X + x * TILE + 1.0, y * TILE + 1.0)
			match tile_type:
				Constants.TileType.WATER:
					_draw_water(origin, x, y)
				Constants.TileType.GROUND, Constants.TileType.ICE, Constants.TileType.SPRING, Constants.TileType.ROTATOR:
					_draw_marble(origin, x, y, false)
				Constants.TileType.SLIPPERY:
					_draw_marble(origin, x, y, true)
				Constants.TileType.WALL, Constants.TileType.STONE_BLOCK:
					_draw_cut_stone(origin, x, y, tile_type == Constants.TileType.STONE_BLOCK)
				Constants.TileType.ONE_WAY, Constants.TileType.CONVEYOR, Constants.TileType.WARP:
					_draw_marble(origin, x, y, false)
				Constants.TileType.HOLE:
					_draw_hole(origin)
				Constants.TileType.PLAYER_ONLY:
					_draw_player_only(origin)
			if tile_type != Constants.TileType.HOLE:
				_draw_gouache(origin, x, y)
			_draw_edges(x, y)

func _tile_class(x: int, y: int) -> int:
	if y < 0 or y >= _layout.size() or x < 0 or x >= _layout[y].size():
		return -1
	match _layout[y][x]:
		Constants.TileType.WALL, Constants.TileType.STONE_BLOCK:
			return 1
		Constants.TileType.WATER, Constants.TileType.HOLE:
			return 2
	return 0

func _draw_edges(x: int, y: int) -> void:
	"""Thick black ink line wherever land, water and walls meet (right and bottom edges only, so each border is drawn once)."""
	var here := _tile_class(x, y)
	var corner := Vector2(OFFSET_X + x * TILE, y * TILE)
	var half := EDGE_WIDTH * 0.5
	var right := _tile_class(x + 1, y)
	if right >= 0 and right != here:
		draw_line(corner + Vector2(TILE, -half), corner + Vector2(TILE, TILE + half), INK, EDGE_WIDTH, true)
	var below := _tile_class(x, y + 1)
	if below >= 0 and below != here:
		draw_line(corner + Vector2(-half, TILE), corner + Vector2(TILE + half, TILE), INK, EDGE_WIDTH, true)

func _draw_gouache(origin: Vector2, x: int, y: int) -> void:
	"""Deterministic semi-transparent brush strokes, so each flat tile looks hand-painted."""
	var seed := posmod(x * 73 + y * 151, 997)
	for i in range(3):
		var a := float(posmod(seed * (i + 3) + i * 41, 61))
		var p := origin + Vector2(8.0 + fposmod(a * 1.9, 46.0), 8.0 + fposmod(a * 3.1 + i * 13.0, 46.0))
		draw_line(p, p + Vector2(11.0, -4.0 + i * 3.0), Color(1, 1, 1, 0.22), 7.0, true)
	var q := origin + Vector2(10.0 + fposmod(float(seed), 40.0), 44.0 + fposmod(seed * 0.7, 14.0))
	draw_line(q, q + Vector2(14.0, 2.0), Color(0.4, 0.25, 0.1, 0.10), 6.0, true)

func _draw_water(origin: Vector2, x: int, y: int) -> void:
	var wave_y := origin.y + 17.0 + fposmod(_phase * 24.0 + x * 11.0 + y * 7.0, 37.0)
	var alpha := 0.2 + (sin(_phase * 2.2 + x * 0.8 + y) + 1.0) * 0.12
	var color := WATER_LIGHT
	color.a = alpha
	draw_arc(Vector2(origin.x + 35.0, wave_y), 15.0, PI * 1.08, PI * 1.92, 16, color, 2.0, true)
	draw_line(Vector2(origin.x + 9.0, origin.y + 52.0), Vector2(origin.x + 22.0, origin.y + 52.0), WATER_DARK, 1.0)

func _draw_hole(origin: Vector2) -> void:
	# Round water hole set in the ground: dark rim, bright ripple.
	var center := origin + Vector2(35.0, 35.0)
	draw_circle(center, 29.0, INK)
	draw_circle(center, 24.0, WATER_DARK)
	var ripple := WATER_LIGHT
	ripple.a = 0.35 + (sin(_phase * 2.0) + 1.0) * 0.15
	draw_arc(center, 14.0, 0.0, TAU, 24, ripple, 2.0, true)

func _draw_player_only(origin: Vector2) -> void:
	# Violet pad reserved for the hero, with a small gem mark.
	var rect := Rect2(origin + Vector2(5, 5), Vector2(60, 60))
	draw_rect(rect, Color("B79BE0"), false, 2.0)
	var c := origin + Vector2(35.0, 35.0)
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -9), c + Vector2(9, 0), c + Vector2(0, 9), c + Vector2(-9, 0)]), Color("E6D8FA"))

func _draw_marble(origin: Vector2, x: int, y: int, frosted: bool) -> void:
	var tone := FROST if frosted else MARBLE_LINE
	var selector := posmod(x * 3 + y * 5, 4)
	var points := PackedVector2Array()
	match selector:
		0:
			points = PackedVector2Array([origin + Vector2(13, 11), origin + Vector2(25, 24), origin + Vector2(19, 35), origin + Vector2(31, 48)])
		1:
			points = PackedVector2Array([origin + Vector2(55, 9), origin + Vector2(46, 21), origin + Vector2(53, 34), origin + Vector2(42, 52)])
		2:
			points = PackedVector2Array([origin + Vector2(7, 42), origin + Vector2(20, 37), origin + Vector2(29, 45)])
		_:
			points = PackedVector2Array([origin + Vector2(35, 8), origin + Vector2(43, 16), origin + Vector2(37, 28)])
	draw_polyline(points, tone, 1.3, true)
	if frosted:
		draw_line(origin + Vector2(8, 9), origin + Vector2(18, 9), FROST, 1.0, true)
		draw_line(origin + Vector2(49, 56), origin + Vector2(62, 56), FROST, 1.0, true)
	else:
		var seed := float(posmod(x * 17 + y * 31, 53))
		var fleck := origin + Vector2(10.0 + fposmod(seed, 48.0), 10.0 + fposmod(seed * 1.7, 48.0))
		draw_circle(fleck, 1.2, GRASS_DARK)

func _draw_cut_stone(origin: Vector2, x: int, y: int, block: bool) -> void:
	var inset := 6.0 if block else 4.0
	var rect := Rect2(origin + Vector2(inset, inset), Vector2(TILE - 2.0 - inset * 2.0, TILE - 2.0 - inset * 2.0))
	draw_rect(rect, INK, false, 3.0)
	draw_line(rect.position + Vector2(3, 8), rect.position + Vector2(rect.size.x - 3, 8), MARBLE_LIGHT, 1.2)
	draw_line(rect.position + Vector2(8, 8), rect.position + Vector2(8, rect.size.y - 3), MARBLE_LINE, 1.0)
	if block:
		var crack_start := rect.position + Vector2(35 + posmod(x + y, 8), 18)
		draw_line(crack_start, crack_start + Vector2(-7, 9), Color("745F49"), 1.5)
		draw_line(crack_start + Vector2(-7, 9), crack_start + Vector2(2, 18), Color("745F49"), 1.3)

static func get_overlay_bounds() -> Rect2:
	return Rect2(OFFSET_X, 0, Constants.PLAYFIELD_WIDTH, Constants.PLAYFIELD_HEIGHT)

static func supports_tile(tile_type: int) -> bool:
	return tile_type in [Constants.TileType.WATER, Constants.TileType.GROUND, Constants.TileType.ICE, Constants.TileType.SLIPPERY, Constants.TileType.WALL, Constants.TileType.STONE_BLOCK, Constants.TileType.SPRING, Constants.TileType.ROTATOR, Constants.TileType.ONE_WAY, Constants.TileType.CONVEYOR, Constants.TileType.WARP, Constants.TileType.HOLE, Constants.TileType.PLAYER_ONLY]