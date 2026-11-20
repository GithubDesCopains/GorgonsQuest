extends Node2D
class_name StonePillar

## Stone pillar that blocks movement

var grid_pos: Vector2i

func _ready():
	# Create visual
	var visual = ColorRect.new()
	visual.size = Vector2(60, 60)
	visual.position = Vector2(-30, -30)
	visual.color = Constants.COLOR_STONE_GRAY
	add_child(visual)
	
	# Add border
	var border = ColorRect.new()
	border.size = Vector2(52, 52)
	border.position = Vector2(-26, -26)
	border.color = Color(0.5, 0.5, 0.5)
	add_child(border)
	visual.z_index = 1
	
	z_index = Constants.LAYER_OBJECTS

func initialize(pos: Vector2i):
	"""Initialize pillar at grid position"""
	grid_pos = pos
	var grid_manager = get_node("/root/Main/GameManager/GridManager")
	position = grid_manager.grid_to_world(grid_pos)
	
	# Animation: pop in
	scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func destroy():
	"""Destroy the pillar with animation and debris"""
	create_debris()
	if is_inside_tree():
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0, 0), 0.15)
		await tween.finished
	queue_free()

func create_debris():
	"""Spawn crumbling stone particle fragments"""
	var parent_node = get_parent()
	if not parent_node or not is_inside_tree():
		return
	
	for i in range(6):
		var chip = ColorRect.new()
		chip.size = Vector2(8, 8)
		chip.position = position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
		chip.color = Constants.COLOR_STONE_GRAY
		chip.z_index = Constants.LAYER_EFFECTS
		parent_node.add_child(chip)
		
		var vel = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		var tw = chip.create_tween()
		tw.set_parallel(true)
		tw.tween_property(chip, "position", chip.position + vel * 0.25, 0.25)
		tw.tween_property(chip, "modulate:a", 0.0, 0.25)
		tw.tween_callback(chip.queue_free)
