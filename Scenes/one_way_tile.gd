extends Node2D
class_name OneWayTile

## Directional gate. Arrow marks the only direction allowed to enter its cell.
var grid_pos: Vector2i
var permitted_direction: Vector2i = Vector2i.RIGHT

func _ready():
	z_index = Constants.LAYER_OBJECTS
	build_visual()

func initialize(pos: Vector2i, direction: Vector2i):
	grid_pos = pos
	permitted_direction = direction
	var grid_manager = get_node_or_null("/root/Main/GameManager/GridManager")
	if grid_manager:
		position = grid_manager.grid_to_world(pos)
	build_visual()

func build_visual():
	for child in get_children():
		child.queue_free()
	var base = ColorRect.new()
	base.size = Vector2(44, 44)
	base.position = Vector2(-22, -22)
	base.color = Color("#a57f46")
	add_child(base)
	var arrow = Label.new()
	arrow.text = direction_arrow(permitted_direction)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow.position = Vector2(-20, -23)
	arrow.size = Vector2(40, 40)
	arrow.add_theme_font_size_override("font_size", 34)
	arrow.add_theme_color_override("font_color", Color("#fff2c6"))
	arrow.add_theme_color_override("font_outline_color", Color("#51352c"))
	arrow.add_theme_constant_override("outline_size", 3)
	add_child(arrow)

func direction_arrow(direction: Vector2i) -> String:
	if direction == Vector2i.RIGHT:
		return "→"
	if direction == Vector2i.LEFT:
		return "←"
	if direction == Vector2i.UP:
		return "↑"
	if direction == Vector2i.DOWN:
		return "↓"
	return "?"
