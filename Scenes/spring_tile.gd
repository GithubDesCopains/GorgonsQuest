extends Node2D
class_name SpringTile

## Directional spring tile: launches player/block one extra cell in arrow direction.

var grid_pos: Vector2i
var direction: Vector2i = Vector2i.UP

func _ready():
	z_index = Constants.LAYER_OBJECTS
	build_visual()

func initialize(pos: Vector2i, launch_direction: Vector2i):
	grid_pos = pos
	direction = launch_direction
	var grid_manager = get_node_or_null("/root/Main/GameManager/GridManager")
	if grid_manager:
		position = grid_manager.grid_to_world(pos)
	build_visual()

func build_visual():
	# Rebuild for safe initialize-before/after-ready order.
	for child in get_children():
		child.queue_free()
	
	var base = ColorRect.new()
	base.name = "SpringBase"
	base.size = Vector2(44, 44)
	base.position = Vector2(-22, -22)
	base.color = Color("#c9875b")
	add_child(base)
	
	var arrow = Label.new()
	arrow.name = "DirectionArrow"
	arrow.text = direction_to_arrow(direction)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow.position = Vector2(-20, -24)
	arrow.size = Vector2(40, 40)
	arrow.add_theme_font_size_override("font_size", 34)
	arrow.add_theme_color_override("font_color", Color("#fff2c6"))
	arrow.add_theme_color_override("font_outline_color", Color("#51352c"))
	arrow.add_theme_constant_override("outline_size", 3)
	add_child(arrow)

func direction_to_arrow(dir: Vector2i) -> String:
	if dir == Vector2i.UP:
		return "↑"
	if dir == Vector2i.DOWN:
		return "↓"
	if dir == Vector2i.LEFT:
		return "←"
	if dir == Vector2i.RIGHT:
		return "→"
	return "↑"

func animate_compression():
	if not is_inside_tree():
		return
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.82, 0.82), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _exit_tree():
	if is_instance_valid(get_node_or_null("/root/Main/GameManager/GridManager")):
		var gm = get_node("/root/Main/GameManager/GridManager")
		if gm.get_tile(grid_pos) == Constants.TileType.SPRING:
			gm.set_tile(grid_pos, Constants.TileType.GROUND)
		gm.spring_directions.erase(grid_pos)
   