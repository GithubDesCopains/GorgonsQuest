extends Node2D
class_name ConveyorTile

## Ancient conveyor belt forcing movers along its arrow direction.
var grid_pos: Vector2i
var direction: Vector2i = Vector2i.RIGHT

func _ready():
	z_index = Constants.LAYER_OBJECTS
	build_visual()

func initialize(pos: Vector2i, move_direction: Vector2i):
	grid_pos = pos
	direction = move_direction
	var grid_manager = get_node_or_null("/root/Main/GameManager/GridManager")
	if grid_manager:
		position = grid_manager.grid_to_world(pos)
	build_visual()

func build_visual():
	for child in get_children():
		child.queue_free()
	var belt = ColorRect.new()
	belt.size = Vector2(58, 58)
	belt.position = Vector2(-29, -29)
	belt.color = Color("#82715a")
	add_child(belt)
	var arrow = Label.new()
	arrow.text = direction_arrow(direction)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow.position = Vector2(-27, -25)
	arrow.size = Vector2(54, 50)
	arrow.add_theme_font_size_override("font_size", 38)
	arrow.add_theme_color_override("font_color", Color("#f5d69b"))
	arrow.add_theme_color_override("font_outline_color", Color("#42372c"))
	arrow.add_theme_constant_override("outline_size", 3)
	add_child(arrow)

func animate_motion():
	if not is_inside_tree():
		return
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(direction) * 5.0, 0.08)
	tween.tween_property(self, "position", position, 0.08)

func direction_arrow(dir: Vector2i) -> String:
	if dir == Vector2i.RIGHT:
		return "→"
	if dir == Vector2i.LEFT:
		return "←"
	if dir == Vector2i.UP:
		return "↑"
	if dir == Vector2i.DOWN:
		return "↓"
	return "?"
