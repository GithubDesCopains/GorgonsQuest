extends Node2D
class_name SlipperyTile

## Polished marble floor; player slides along entry direction until leaving it.

var grid_pos: Vector2i

func _ready():
	z_index = Constants.LAYER_GROUND + 1
	build_visual()

func initialize(pos: Vector2i):
	grid_pos = pos
	var grid_manager = get_node_or_null("/root/Main/GameManager/GridManager")
	if grid_manager:
		position = grid_manager.grid_to_world(pos)
	build_visual()

func build_visual():
	for child in get_children():
		child.queue_free()
	var tile = ColorRect.new()
	tile.size = Vector2(58, 58)
	tile.position = Vector2(-29, -29)
	tile.color = Color("#b8d4db")
	add_child(tile)
	var sheen = ColorRect.new()
	sheen.size = Vector2(36, 8)
	sheen.position = Vector2(-18, -14)
	sheen.color = Color(0.92, 0.98, 1.0, 0.8)
	add_child(sheen)
