extends Node2D
class_name SwitchTile

## Pressure plate. Held down by a pushable block or a petrified enemy resting on it.
## Its colour matches the doors that share its id.

const INK := Color("1A1418")
const PALETTE := [Color("E0645C"), Color("5C9BE0"), Color("6CC070"), Color("EBC34F"), Color("A97BD6"), Color("EE9A4D")]

var grid_pos: Vector2i
var switch_id: String = ""
var pressed: bool = false

static func color_for(id: String) -> Color:
	return PALETTE[absi(id.hash()) % PALETTE.size()]

func initialize(pos: Vector2i, id: String, grid: GridManager) -> void:
	grid_pos = pos
	switch_id = id
	position = grid.grid_to_world(pos)
	z_index = Constants.LAYER_GROUND + 1
	add_to_group("switches")
	grid.set_switch(pos, id)
	queue_redraw()

func set_pressed(value: bool) -> void:
	if pressed == value:
		return
	pressed = value
	queue_redraw()

func _draw() -> void:
	var color := color_for(switch_id)
	var half := Constants.TILE_SIZE * 0.5 - 12.0
	var plate := Rect2(Vector2(-half, -half), Vector2(half * 2.0, half * 2.0))
	draw_rect(plate.grow(4.0), INK)
	draw_rect(plate, color.darkened(0.35) if pressed else color)
	if pressed:
		draw_rect(plate.grow(-8.0), color.lightened(0.4))     # glowing: the door is open
	else:
		draw_rect(Rect2(plate.position + Vector2(5, 5), Vector2(plate.size.x - 10.0, 7.0)), color.lightened(0.45))
	draw_rect(plate, INK, false, 3.0)
