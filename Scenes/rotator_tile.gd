extends Node2D
class_name RotatorTile

## Rotator tile turns a sliding statue 90 degrees on contact.
## `quarter_turns`: 1 turns clockwise, -1 turns counter-clockwise.

var grid_pos: Vector2i
var quarter_turns: int = 1

func _ready():
	z_index = Constants.LAYER_OBJECTS
	build_visual()

func initialize(pos: Vector2i, turn_direction: int = 1):
	grid_pos = pos
	quarter_turns = 1 if turn_direction >= 0 else -1
	var grid_manager = get_node_or_null("/root/Main/GameManager/GridManager")
	if grid_manager:
		position = grid_manager.grid_to_world(pos)
	build_visual()

func build_visual():
	for child in get_children():
		child.queue_free()
	
	var base = ColorRect.new()
	base.size = Vector2(46, 46)
	base.position = Vector2(-23, -23)
	base.color = Color("#6d8f88")
	add_child(base)
	
	var indicator = Label.new()
	indicator.text = "↻" if quarter_turns > 0 else "↺"
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	indicator.position = Vector2(-21, -24)
	indicator.size = Vector2(42, 42)
	indicator.add_theme_font_size_override("font_size", 34)
	indicator.add_theme_color_override("font_color", Color("#f4f0d5"))
	indicator.add_theme_color_override("font_outline_color", Color("#294b46"))
	indicator.add_theme_constant_override("outline_size", 3)
	add_child(indicator)

func animate_turn():
	if not is_inside_tree():
		return
	var tween = create_tween()
	tween.tween_property(self, "rotation", rotation + quarter_turns * PI / 2.0, 0.16)
   