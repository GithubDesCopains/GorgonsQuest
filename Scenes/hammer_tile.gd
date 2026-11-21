extends Node2D

## Hammer: a pivot with a head on one of its four neighbours, solid like a wall. A block reaching the SIDE of the head
## makes it swing three quarters of a turn and strike the block away; the hero can push the head one quarter turn.
## The rules live in GridManager (the head turns at once); this node only draws it and animates the swing.

const INK := Color("1A1418")
const WOOD := Color("A8743C")
const WOOD_LIGHT := Color("C9985C")
const STONE := Color("8E8A82")
const STONE_LIGHT := Color("BDB8AE")
const SWING_SECONDS := 0.45
const FAILSAFE_MSEC := 8000                # longest legitimate wait for a strike's slide to reach the hammer

var _swinging := false
var _waiting_since_msec := -1
var grid_pos: Vector2i                     # the pivot cell
var grid_manager: GridManager
var game_manager: Node
var angle: float = 0.0:                    # head direction on screen; positive turns clockwise
	set(value):
		angle = value
		queue_redraw()

static func angle_of(direction: Vector2i) -> float:
	return Vector2(direction).angle()

func initialize(pivot: Vector2i, head_dir: Vector2i, grid: GridManager, manager: Node = null) -> void:
	grid_manager = grid
	game_manager = manager
	grid_pos = pivot
	position = grid.grid_to_world(pivot)
	z_index = Constants.LAYER_OBJECTS
	angle = angle_of(head_dir)
	add_to_group("hammers")

func _process(_delta: float) -> void:
	# The grid turns the head the moment a block hits it, but the swing is only animated when that block's slide reaches
	# the hammer. If the block is destroyed on the way, nobody would ever finish the swing: snap the head into place.
	if grid_manager == null:
		return
	if grid_manager.is_hammer_swinging(grid_pos) and not _swinging:
		if _waiting_since_msec < 0:
			_waiting_since_msec = Time.get_ticks_msec()
		elif Time.get_ticks_msec() - _waiting_since_msec > FAILSAFE_MSEC:
			angle = angle_of(grid_manager.get_hammer_dir(grid_pos))
			_finish_swing()
	else:
		_waiting_since_msec = -1

func swing(quarter_turns: int, seconds: float = SWING_SECONDS) -> void:
	"""Turn the head visually; the grid already holds the new direction. Releases the swept cells when done."""
	_swinging = true
	var target := angle + float(quarter_turns) * PI / 2.0
	if not is_inside_tree():
		angle = target
		_finish_swing()
		return
	var tween := create_tween()
	tween.tween_property(self, "angle", target, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_finish_swing)

func _finish_swing() -> void:
	_swinging = false
	_waiting_since_msec = -1
	if grid_manager:
		grid_manager.finish_hammer_swing(grid_pos)
	if is_instance_valid(game_manager) and game_manager.has_method("_play_sound"):
		game_manager._play_sound("play_hammer")
	queue_redraw()

func _draw() -> void:
	var tile := float(Constants.TILE_SIZE)
	var dir := Vector2.RIGHT.rotated(angle)
	var side := dir.orthogonal()
	var handle_end := dir * tile * 0.62
	var head_center := dir * tile * 0.86
	# Handle.
	draw_line(Vector2.ZERO, handle_end, INK, 13.0)
	draw_line(Vector2.ZERO, handle_end, WOOD, 8.0)
	draw_line(Vector2.ZERO, handle_end, WOOD_LIGHT, 2.5)
	# Head: a block across the handle, its two striking faces on the sides.
	var half_long := tile * 0.36
	var half_thick := tile * 0.16
	var corners := PackedVector2Array([
		head_center + side * half_long + dir * half_thick,
		head_center - side * half_long + dir * half_thick,
		head_center - side * half_long - dir * half_thick,
		head_center + side * half_long - dir * half_thick,
	])
	draw_colored_polygon(corners, STONE)
	draw_polyline(PackedVector2Array([corners[0], corners[1], corners[2], corners[3], corners[0]]), INK, 3.0)
	draw_line(corners[1] + side * 5.0 - dir * 4.0, corners[0] - side * 5.0 - dir * 4.0, STONE_LIGHT, 3.0)
	# Pivot.
	draw_circle(Vector2.ZERO, tile * 0.24, INK)
	draw_circle(Vector2.ZERO, tile * 0.19, STONE)
	draw_circle(Vector2.ZERO, tile * 0.07, INK)
