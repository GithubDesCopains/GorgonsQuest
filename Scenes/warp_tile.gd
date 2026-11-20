extends Node2D
class_name WarpTile

## One endpoint in a linked pair of magical warp gates.

var grid_pos: Vector2i
var pair_id: String = ""

func _ready():
	z_index = Constants.LAYER_OBJECTS
	build_visual()

func initialize(pos: Vector2i, link_id: String):
	grid_pos = pos
	pair_id = link_id
	var grid_manager = get_node_or_null("/root/Main/GameManager/GridManager")
	if grid_manager:
		position = grid_manager.grid_to_world(pos)
	build_visual()

func build_visual():
	for child in get_children():
		child.queue_free()
	var outer = ColorRect.new()
	outer.size = Vector2(52, 52)
	outer.position = Vector2(-26, -26)
	outer.color = Color("#563b92")
	add_child(outer)
	var inner = ColorRect.new()
	inner.size = Vector2(36, 36)
	inner.position = Vector2(-18, -18)
	inner.color = Color("#a57be0")
	add_child(inner)
	var label = Label.new()
	label.text = pair_id.substr(0, 1).to_upper()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-18, -18)
	label.size = Vector2(36, 36)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color("#30204d"))
	label.add_theme_constant_override("outline_size", 3)
	add_child(label)
	
	if is_inside_tree():
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.55).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_SINE)

func animate_activation():
	if not is_inside_tree():
		return
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 0.7), 0.07)
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)
