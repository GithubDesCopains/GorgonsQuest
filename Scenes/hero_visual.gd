extends Node2D
class_name HeroVisual

## Original procedural Greek hero illustration. No borrowed sprites.

const OUTLINE := Color("1A1418")
const SKIN := Color("F2C29A")
const TUNIC := Color("7CC4C0")
const TUNIC_LIGHT := Color("B5E0D2")
const GOLD := Color("F2D07A")
const HAIR := Color("4B302E")
const STONE := Color("B8BFC0")

# Hand-painted hero (Assets/Sprites/hero_game.png). Falls back to the procedural drawing if the file is missing.
const SPRITE_PATH := "res://Assets/Sprites/hero_game.png"
const SPRITE_SIZE := 87.0       # on-screen size in px (a tile is 72 px)
const SPRITE_FEET_Y := 28.0     # feet position relative to the cell center
const SPRITE_FEET_FRAC := 0.988 # feet position inside the image (0 = top, 1 = bottom)
const UP_TINT := Color(0.8, 0.8, 0.88)
const STONE_TINT := Color(0.62, 0.66, 0.68)

var _texture: Texture2D
var _texture_missing := false

# Walk cycles: one horizontal strip of square frames per direction (any frame count; the Craftpix swordsman has 6).
# Drop hero_walk_down/up/left/right.png in Assets/Sprites. A missing left (or right) strip reuses the
# other one mirrored; with no strip at all the single painted image above is used.
const WALK_SHEET_PATHS := {
	Constants.Direction.DOWN: "res://Assets/Sprites/hero_walk_down.png",
	Constants.Direction.UP: "res://Assets/Sprites/hero_walk_up.png",
	Constants.Direction.LEFT: "res://Assets/Sprites/hero_walk_left.png",
	Constants.Direction.RIGHT: "res://Assets/Sprites/hero_walk_right.png",
}
const WALK_CYCLE_SECONDS := 0.5  # one full cycle whatever the frame count (about two tiles of walking)
# Pixel-art strips (32 px cells) are drawn at an integer scale (3x = 96 px) with nearest filtering so pixels stay crisp.
const WALK_SPRITE_SIZE := 96.0
const WALK_FEET_Y := 28.0      # feet position relative to the cell center
const WALK_FEET_FRAC := 0.969  # feet row inside the cell (31/32)
const WALK_CHEST := Vector2(0.0, WALK_FEET_Y - WALK_SPRITE_SIZE * 0.47)  # where the gaze beam starts

var _walk_sheets: Dictionary = {}  # direction -> Texture2D
var _walk_sheets_loaded := false

var facing: int = Constants.Direction.DOWN
var moving: bool = false
var pushing: bool = false
var shooting: bool = false
var dead: bool = false
var celebrating: bool = false
var animation_time: float = 0.0

func set_pose(direction: int, is_moving: bool, is_pushing: bool) -> void:
	facing = direction
	moving = is_moving
	pushing = is_pushing
	queue_redraw()

func set_action(is_shooting: bool, is_celebrating: bool = false) -> void:
	shooting = is_shooting
	celebrating = is_celebrating
	queue_redraw()

func set_dead(value: bool) -> void:
	dead = value
	queue_redraw()

func _process(delta: float) -> void:
	animation_time += delta
	if moving or shooting or celebrating:
		queue_redraw()

func _draw() -> void:
	var bob: float = sin(animation_time * 14.0) * 2.0 if moving else 0.0
	var stride: float = sin(animation_time * 14.0) * 5.0 if moving else 0.0
	if dead:
		var dead_sheet := _walk_sheet_for(facing)
		if not dead_sheet.is_empty():
			_draw_walk_frame(dead_sheet, 0, STONE_TINT)
			return
		var statue_texture := _sprite_texture()
		if statue_texture != null:
			_draw_sprite(statue_texture, Vector2.ZERO, false, false, 0.0, STONE_TINT)
		else:
			_draw_death_pose()
		return
	if celebrating:
		_draw_hero(Vector2.ZERO, stride, true)
		return
	var side := facing == Constants.Direction.LEFT or facing == Constants.Direction.RIGHT
	var dir_sign := -1.0 if facing == Constants.Direction.LEFT else 1.0
	var front := facing == Constants.Direction.DOWN
	_draw_hero(Vector2(0, bob), stride, false, dir_sign, side, front)

func _draw_hero(offset: Vector2, stride: float, victory_pose: bool, dir_sign: float = 1.0, side: bool = false, front: bool = true) -> void:
	var p := offset
	var sheet := _walk_sheet_for(Constants.Direction.DOWN if victory_pose else facing)
	if not sheet.is_empty():
		# Victory: face the camera and hop.
		var hop := -absf(sin(animation_time * 8.0)) * 8.0 if victory_pose else 0.0
		_draw_walk_frame(sheet, 0 if victory_pose else -1, Color.WHITE, hop)
		return
	var tex := _sprite_texture()
	if tex != null:
		_draw_ellipse(Vector2(p.x, p.y + SPRITE_FEET_Y), Vector2(30, 9), Color(0.12, 0.18, 0.2, 0.3))
		# One painted view: mirror it so the relic hand points toward the walking side, darken it when walking up.
		var flip := side and dir_sign > 0.0
		var tint := UP_TINT if (not front and not side and not victory_pose) else Color.WHITE
		_draw_sprite(tex, p, flip, victory_pose, stride, tint)
		if shooting:
			_draw_sprite_gaze(p, flip, victory_pose)
		return
	_draw_ellipse(Vector2(p.x, p.y + 25), Vector2(22, 8), Color(0.12, 0.18, 0.2, 0.3))
	var leg_spread := 9.0 if not victory_pose else 13.0
	_draw_limb(Vector2(p.x - 6, p.y + 8), Vector2(p.x - leg_spread + stride, p.y + 22), SKIN, 6.0)
	_draw_limb(Vector2(p.x + 6, p.y + 8), Vector2(p.x + leg_spread - stride, p.y + 22), SKIN, 6.0)
	_draw_sandal(Vector2(p.x - leg_spread + stride, p.y + 22))
	_draw_sandal(Vector2(p.x + leg_spread - stride, p.y + 22))

	var tunic := PackedVector2Array([
		p + Vector2(-13, -8), p + Vector2(13, -8), p + Vector2(17, 12),
		p + Vector2(11, 19), p + Vector2(-11, 19), p + Vector2(-17, 12)
	])
	draw_colored_polygon(tunic, TUNIC)
	draw_polyline(PackedVector2Array([tunic[0], tunic[1], tunic[2], tunic[3], tunic[4], tunic[5], tunic[0]]), OUTLINE, 3.6, true)
	draw_line(p + Vector2(-12, 13), p + Vector2(12, 13), GOLD, 2.0)
	draw_line(p + Vector2(0, -5), p + Vector2(0, 11), TUNIC_LIGHT, 2.0)
	draw_circle(p + Vector2(10, -6), 3.5, GOLD)

	var shoulder := p + Vector2(dir_sign * 10.0, -5)
	var hand: Vector2
	if victory_pose:
		hand = p + Vector2(dir_sign * 24.0, -26.0)
	elif pushing:
		hand = p + Vector2(dir_sign * 22.0, 1.0)
	else:
		hand = p + Vector2(dir_sign * 21.0, -7.0)
	_draw_limb(shoulder, hand, SKIN, 5.0)
	_draw_gorgon_relic(hand + Vector2(dir_sign * 4.0, -4.0), dir_sign)
	_draw_limb(p + Vector2(-10, -5), p + Vector2(-18, 5), SKIN, 5.0)

	var head_center := p + Vector2(0, -20)
	var head_w := 13.0 if side else 12.0
	draw_circle(head_center, head_w + 2.0, HAIR)
	draw_circle(head_center + Vector2(0, 2), head_w, SKIN)
	for i in range(5):
		var curl_x := -10.0 + i * 5.0
		draw_circle(head_center + Vector2(curl_x, -8), 3.2, HAIR)
	draw_arc(head_center + Vector2(0, -2), 13.0, PI + 0.2, TAU - 0.2, 18, GOLD, 2.2)
	for i in range(5):
		var leaf_x := -9.0 + i * 4.5
		draw_colored_polygon(PackedVector2Array([head_center + Vector2(leaf_x - 2, -10), head_center + Vector2(leaf_x, -15), head_center + Vector2(leaf_x + 2, -10)]), GOLD)
	if front:
		draw_circle(head_center + Vector2(-4, 1), 1.4, OUTLINE)
		draw_circle(head_center + Vector2(4, 1), 1.4, OUTLINE)
		draw_arc(head_center + Vector2(0, 4), 3.5, 0.2, PI - 0.2, 12, OUTLINE, 1.2)
	elif side:
		draw_circle(head_center + Vector2(dir_sign * 7, 2), 2.0, SKIN)

func set_walk_sheet(direction: int, texture: Texture2D) -> void:
	_load_walk_sheets()
	_walk_sheets[direction] = texture
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _load_walk_sheets() -> void:
	if _walk_sheets_loaded:
		return
	_walk_sheets_loaded = true
	for direction in WALK_SHEET_PATHS:
		var path: String = WALK_SHEET_PATHS[direction]
		if ResourceLoader.exists(path):
			_walk_sheets[direction] = load(path)
	if not _walk_sheets.is_empty():
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _walk_sheet_for(direction: int) -> Array:
	"""[texture, mirrored] for this direction, or [] when no strip applies."""
	_load_walk_sheets()
	if _walk_sheets.has(direction):
		return [_walk_sheets[direction], false]
	var mirror := -1
	if direction == Constants.Direction.LEFT:
		mirror = Constants.Direction.RIGHT
	elif direction == Constants.Direction.RIGHT:
		mirror = Constants.Direction.LEFT
	if _walk_sheets.has(mirror):
		return [_walk_sheets[mirror], true]
	return []

func walk_frame(frame_count: int) -> int:
	"""Frame to show: the cycle advances while walking, frame 0 (standing) otherwise."""
	if not moving or frame_count < 1:
		return 0
	return int(animation_time / WALK_CYCLE_SECONDS * frame_count) % frame_count

func _draw_walk_frame(sheet: Array, frame: int = -1, tint: Color = Color.WHITE, lift: float = 0.0) -> void:
	var tex: Texture2D = sheet[0]
	var cell := tex.get_height()
	var frame_count := maxi(1, floori(float(tex.get_width()) / float(cell)))
	if frame < 0:
		frame = walk_frame(frame_count)
	_draw_ellipse(Vector2(0, WALK_FEET_Y), Vector2(20, 6) * (WALK_SPRITE_SIZE / 64.0), Color(0.12, 0.18, 0.2, 0.3))
	# Origin at the feet, so mirroring pivots there.
	draw_set_transform(Vector2(0.0, WALK_FEET_Y + lift), 0.0, Vector2(-1.0 if sheet[1] else 1.0, 1.0))
	draw_texture_rect_region(tex, Rect2(Vector2(-WALK_SPRITE_SIZE * 0.5, -WALK_SPRITE_SIZE * WALK_FEET_FRAC), Vector2(WALK_SPRITE_SIZE, WALK_SPRITE_SIZE)), Rect2(frame * cell, 0, cell, cell), tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if shooting:
		# Muzzle flash only: the laser itself is the projectile.
		var beam: Vector2 = Constants.DIR_VECTORS.get(facing, Vector2.DOWN)
		draw_circle(WALK_CHEST + beam * 16.0, 9.0, Color(0.4, 0.9, 0.3, 0.35))
		draw_circle(WALK_CHEST + beam * 16.0, 4.0, Color("F2FFD8"))

func _sprite_texture() -> Texture2D:
	if _texture == null and not _texture_missing:
		if ResourceLoader.exists(SPRITE_PATH):
			_texture = load(SPRITE_PATH)
		_texture_missing = _texture == null
	return _texture

func _draw_sprite(tex: Texture2D, p: Vector2, flip: bool, victory_pose: bool, stride: float, tint: Color) -> void:
	var size := SPRITE_SIZE * (1.08 if victory_pose else 1.0)
	var lift := -8.0 if victory_pose else 0.0
	# Origin at the feet so mirroring and the walking tilt pivot there.
	draw_set_transform(p + Vector2(0.0, SPRITE_FEET_Y + lift), stride * 0.012, Vector2(-1.0 if flip else 1.0, 1.0))
	draw_texture_rect(tex, Rect2(Vector2(-size * 0.5, -size * SPRITE_FEET_FRAC), Vector2(size, size)), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_sprite_gaze(p: Vector2, flip: bool, victory_pose: bool) -> void:
	"""Green glow on the painted relic plus a short beam toward the facing direction."""
	var size := SPRITE_SIZE * (1.08 if victory_pose else 1.0)
	var lift := -8.0 if victory_pose else 0.0
	var relic := p + Vector2(-0.18 * size * (-1.0 if flip else 1.0), SPRITE_FEET_Y + lift - 0.658 * size)
	var beam: Vector2 = Constants.DIR_VECTORS.get(facing, Vector2.DOWN)
	draw_circle(relic, 11.0, Color(0.66, 0.89, 0.49, 0.45))
	draw_line(relic, relic + beam * 30.0, Color("A9E27D"), 3.0)
	draw_circle(relic + beam * 30.0, 3.0, Color("E6F5A5"))

func _draw_gorgon_relic(center: Vector2, direction: float) -> void:
	var mask := PackedVector2Array([
		center + Vector2(-7, -6), center + Vector2(7, -6),
		center + Vector2(6, 4), center + Vector2(0, 8), center + Vector2(-6, 4)
	])
	draw_colored_polygon(mask, Color("8AA66B"))
	draw_polyline(PackedVector2Array([mask[0], mask[1], mask[2], mask[3], mask[4], mask[0]]), OUTLINE, 1.5, true)
	draw_circle(center + Vector2(-3, -1), 1.2, GOLD)
	draw_circle(center + Vector2(3, -1), 1.2, GOLD)
	draw_line(center + Vector2(0, 2), center + Vector2(0, 5), OUTLINE, 1.1)
	for i in range(3):
		var curl_x := direction * (7.0 + i * 2.0)
		var curl_y := -7.0 + i * 4.0
		draw_arc(center + Vector2(curl_x, curl_y), 3.0, PI, TAU * 1.7, 10, TUNIC_LIGHT, 1.6)
	if shooting:
		var gaze := center + Vector2(direction * 12.0, 0)
		draw_line(center + Vector2(direction * 5.0, -1), gaze, Color("A9E27D"), 2.0)
		draw_circle(gaze, 2.0, Color("E6F5A5"))

func _draw_limb(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	draw_line(from, to, OUTLINE, width + 3.6, true)
	draw_line(from, to, color, width, true)
	draw_circle(to, width * 0.48, color)
	draw_circle(to, width * 0.48, OUTLINE, false, 1.0)

func _draw_sandal(at: Vector2) -> void:
	draw_line(at + Vector2(-4, 2), at + Vector2(5, 2), OUTLINE, 4.0, true)
	draw_line(at + Vector2(-4, 1), at + Vector2(4, 1), GOLD, 2.0, true)
	draw_line(at + Vector2(0, -2), at + Vector2(2, 2), TUNIC_LIGHT, 1.2)

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)

func _draw_death_pose() -> void:
	draw_circle(Vector2.ZERO, 24, STONE)
	draw_line(Vector2(-18, -15), Vector2(-3, -2), OUTLINE, 3.0)
	draw_line(Vector2(-3, -2), Vector2(-12, 12), OUTLINE, 2.0)
	draw_line(Vector2(10, -18), Vector2(3, 1), OUTLINE, 2.5)
	draw_colored_polygon(PackedVector2Array([Vector2(20, -9), Vector2(28, -14), Vector2(24, -2)]), GOLD)
