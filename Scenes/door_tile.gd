extends Node2D
class_name DoorTile

## Barrier on the edge between two orthogonally adjacent cells. Closed: nothing crosses it.
## Open: only two posts remain. The colour matches the switch that shares its id.

const INK := Color("1A1418")
const SWITCH = preload("res://Scenes/switch_tile.gd")

var grid_pos: Vector2i
var direction: Vector2i = Vector2i.RIGHT
var door_id: String = ""
var is_open: bool = false

func initialize(pos: Vector2i, dir: Vector2i, id: String, grid: GridManager) -> void:
	grid_pos = pos
	direction = dir
	door_id = id
	# Centred on the shared edge: half a tile from the cell centre, toward the neighbour.
	position = grid.grid_to_world(pos) + Vector2(dir) * (Constants.TILE_SIZE * 0.5)
	z_index = Constants.LAYER_OBJECTS + 1
	add_to_group("doors")
	grid.add_door(pos, dir, id)
	queue_redraw()

func set_open(value: bool) -> void:
	if is_open == value:
		return
	is_open = value
	queue_redraw()

func _draw() -> void:
	var color: Color = SWITCH.color_for(door_id)
	# A door on a left/right edge is a vertical bar; on an up/down edge a horizontal one.
	var along := Vector2.DOWN if direction.x != 0 else Vector2.RIGHT
	var half := Constants.TILE_SIZE * 0.5 - 3.0
	if is_open:
		for sign in [-1.0, 1.0]:
			var post: Vector2 = along * half * sign
			draw_circle(post, 7.0, INK)
			draw_circle(post, 4.5, color)
		return
	draw_line(-along * half, along * half, INK, 16.0, true)
	draw_line(-along * half, along * half, color, 9.0, true)
	for i in range(-2, 3):
		var rivet: Vector2 = along * float(i) * half * 0.42
		draw_circle(rivet, 2.5, INK)
